[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$ConsoleUrl='https://localhost:8083'
$Username='admin'; $Password='admin234'
$authBody=@{ username=$Username; password=$Password }|ConvertTo-Json
$auth=Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/authenticate" -Method POST -Body $authBody -ContentType 'application/json'
$h=@{ Authorization='Bearer '+$auth.token }

# Get vulnerability image policies (fallback to containers)
$polUris=@("$ConsoleUrl/api/v1/policies/vulnerability/images","$ConsoleUrl/api/v1/policies/vulnerability/containers","$ConsoleUrl/api/v1/policies/vulnerabilities")
$pol=$null
$polUriUsed=$null
foreach($u in $polUris){ try { $r=Invoke-RestMethod -Uri $u -Headers $h -Method GET; if($r){ $pol=$r[0]; $polUriUsed=$u; break } } catch {} }
if(-not $pol){ Write-Host 'No vulnerability policies found' -ForegroundColor Yellow; exit 1 }

# Ensure collections array exists and add our collections if not present
$targetCollections=@('production-workloads-dev','production-workloads-security')
if(-not $pol.collections){ $pol | Add-Member -NotePropertyName collections -NotePropertyValue @() }
foreach($c in $targetCollections){ if(-not ($pol.collections -contains $c)){ $pol.collections += $c } }

# PUT back the policy
try{
  $body=($pol | ConvertTo-Json -Depth 12)
  Invoke-RestMethod -Uri $polUriUsed -Headers $h -Method PUT -Body $body -ContentType 'application/json'
  Write-Host 'Vulnerability policy updated to include collections.' -ForegroundColor Green
}catch{ Write-Host ("Failed to update vulnerability policy: {0}" -f $_.Exception.Message) -ForegroundColor Red; throw }
