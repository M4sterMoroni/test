# Verify Prisma Cloud Collections

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

# Defaults
$ConsoleUrl = 'https://localhost:8083'
$Username   = 'admin'
$Password   = 'admin234'

# Try to read creds from creds.json if present
try {
  if (Test-Path -Path '.\creds.json') {
    $creds = Get-Content '.\creds.json' | ConvertFrom-Json
    if ($creds.console_url) { $ConsoleUrl = $creds.console_url }
    if ($creds.username)   { $Username   = $creds.username }
    if ($creds.password)   { $Password   = $creds.password }
  }
} catch {}

# Authenticate
try {
  $authBody = @{ username = $Username; password = $Password } | ConvertTo-Json
  $auth     = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/authenticate" -Method POST -Body $authBody -ContentType 'application/json'
  $headers  = @{ Authorization = 'Bearer ' + $auth.token }
  Write-Host "Authentication successful!" -ForegroundColor Green
} catch {
  Write-Host "Authentication failed: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}

# Get collections
try {
  $collections = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/collections" -Headers $headers -Method GET
  Write-Host "`nCollections:" -ForegroundColor Cyan
  foreach ($collection in $collections) {
    Write-Host "  - Name: $($collection.name)" -ForegroundColor White
    Write-Host "    Description: $($collection.description)" -ForegroundColor Gray
    Write-Host "    Labels: $($collection.labels -join ', ')" -ForegroundColor Gray
    Write-Host ""
  }
} catch {
  Write-Host "Failed to get collections: $($_.Exception.Message)" -ForegroundColor Red
}

# Check if our WAAS test app collection exists
$waasCollection = $collections | Where-Object { $_.name -eq 'waas-test-app' }
if ($waasCollection) {
  Write-Host "✅ WAAS Test App collection found!" -ForegroundColor Green
} else {
  Write-Host "❌ WAAS Test App collection not found!" -ForegroundColor Red
}


