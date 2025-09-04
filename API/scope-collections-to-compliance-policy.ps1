[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$ConsoleUrl='https://localhost:8083'
$Username='admin'; $Password='admin234'
$authBody=@{ username=$Username; password=$Password }|ConvertTo-Json
$auth=Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/authenticate" -Method POST -Body $authBody -ContentType 'application/json'
$h=@{ Authorization='Bearer '+$auth.token }

# Fetch the single, global container compliance policy document
$policyUrl = "$ConsoleUrl/api/v1/policies/compliance/container"
try {
    $policyDoc = Invoke-RestMethod -Uri $policyUrl -Headers $h -Method GET
} catch {
    Write-Host "Failed to fetch compliance policy document from $policyUrl. Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Find the specific rule we want to modify within the document
$ruleNameToModify = "Default - alert on critical and high"
$rule = $policyDoc.rules | Where-Object { $_.name -eq $ruleNameToModify }

if (-not $rule) {
    Write-Host "Could not find the rule '$ruleNameToModify' in the compliance policy document." -ForegroundColor Red
    exit 1
}

Write-Host "Found compliance rule to update:" -ForegroundColor Cyan
Write-Host "  Name: $($rule.name)"
Write-Host "----------------------------------"

# The API requires full collection objects, not just names.
# We will create minimal collection objects containing only the 'name' property.
$targetCollectionNames = @('production-workloads-dev','production-workloads-security')

# Start with the existing collections in the rule
$newCollectionList = @($rule.collections)

foreach($cName in $targetCollectionNames){
    # Check if a collection with this name already exists in the rule
    $exists = $newCollectionList | Where-Object { $_.name -eq $cName }
    if(-not $exists){
        # If it doesn't exist, add a new minimal collection object
        $newCollectionList += @{ name = $cName }
    }
}
$rule.collections = $newCollectionList

# PUT the entire modified policy document back to the API
try{
  $body=($policyDoc | ConvertTo-Json -Depth 10)
  Invoke-RestMethod -Uri $policyUrl -Headers $h -Method PUT -Body $body -ContentType 'application/json'
  Write-Host "SUCCESS: Compliance policy document updated to scope rule '$($rule.name)' to the new collections." -ForegroundColor Green
}catch{
    Write-Host ("Failed to update compliance policy: {0}" -f $_.Exception.Message) -ForegroundColor Red
    throw
}
