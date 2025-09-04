[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$ConsoleUrl='https://localhost:8083'
$Username='admin'; $Password='admin234'
$authBody=@{ username=$Username; password=$Password }|ConvertTo-Json
$auth=Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/authenticate" -Method POST -Body $authBody -ContentType 'application/json'
$h=@{ Authorization='Bearer '+$auth.token }

# Find the first vulnerability policy (same logic as scoping script)
$polUris=@("$ConsoleUrl/api/v1/policies/vulnerability/images","$ConsoleUrl/api/v1/policies/vulnerability/containers","$ConsoleUrl/api/v1/policies/vulnerabilities")
$pol=$null
foreach($u in $polUris){ try { $r=Invoke-RestMethod -Uri $u -Headers $h -Method GET; if($r){ $pol=$r[0]; break } } catch {} }

if(-not $pol){
    Write-Host "Could not find any vulnerability policies to verify." -ForegroundColor Red
    exit 1
}

Write-Host "Verifying policy:" -ForegroundColor Cyan
Write-Host "  Name: $($pol.name)"
Write-Host "  Rule Type: $($pol.rule.type)"
Write-Host "----------------------------------"

# Check the collections
$targetCollections=@('production-workloads-dev','production-workloads-security')
$scopedCollections = $pol.collections
$foundCount = 0

Write-Host "Collections currently scoped to this policy:" -ForegroundColor Cyan
if($scopedCollections) {
    foreach($c in $scopedCollections){
        Write-Host "  - $c"
        if($targetCollections -contains $c){
            $foundCount++
        }
    }
} else {
    Write-Host "  (None)"
}

Write-Host "----------------------------------"

# Final verification result
if($foundCount -eq $targetCollections.Count){
    Write-Host "SUCCESS: Both target collections are correctly scoped to the policy." -ForegroundColor Green
} else {
    Write-Host "FAILURE: Not all target collections were found in the policy scope." -ForegroundColor Red
    Write-Host "Found $foundCount of $($targetCollections.Count) expected collections."
}
