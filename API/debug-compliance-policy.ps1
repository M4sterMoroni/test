[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$ConsoleUrl='https://localhost:8083'
$Username='admin'; $Password='admin234'
$authBody=@{ username=$Username; password=$Password }|ConvertTo-Json
$auth=Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/authenticate" -Method POST -Body $authBody -ContentType 'application/json'
$h=@{ Authorization='Bearer '+$auth.token }

Write-Host "Attempting to find the first container or host compliance policy..." -ForegroundColor Yellow

# Get compliance policies for containers (fallback to hosts)
$polUris=@("$ConsoleUrl/api/v1/policies/compliance/container","$ConsoleUrl/api/v1/policies/compliance/host")
$pol=$null
foreach($u in $polUris){
    try {
        $r=Invoke-RestMethod -Uri $u -Headers $h -Method GET
        if($r){
            Write-Host "Successfully fetched data from: $u" -ForegroundColor Green
            $pol=$r[0]
            break
        }
    } catch {}
}

if(-not $pol){
    Write-Host "No container or host compliance policies were found." -ForegroundColor Red
    exit 1
}

Write-Host "----------------------------------"
Write-Host "Found a policy object. Here is its structure:" -ForegroundColor Cyan
# Convert the policy object to JSON and print it so we can inspect its properties
$pol | ConvertTo-Json -Depth 5
Write-Host "----------------------------------"
Write-Host "Please copy the output above so I can identify the correct ID field for the update." -ForegroundColor Yellow
