# Check WAAS Status and Unprotected Applications

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

# Check running containers
Write-Host "`n🔍 Checking running containers..." -ForegroundColor Cyan
try {
  $containers = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/containers" -Headers $headers -Method GET
  Write-Host "Found $($containers.Count) containers" -ForegroundColor White
  
  $waasContainer = $containers | Where-Object { $_.labels -contains "app:waas-test" -or $_.name -like "*waas*" }
  if ($waasContainer) {
    Write-Host "✅ WAAS Test App container found:" -ForegroundColor Green
    Write-Host "   Name: $($waasContainer.name)" -ForegroundColor White
    Write-Host "   Image: $($waasContainer.image)" -ForegroundColor White
    Write-Host "   Labels: $($waasContainer.labels -join ', ')" -ForegroundColor White
    Write-Host "   Ports: $($waasContainer.ports -join ', ')" -ForegroundColor White
  } else {
    Write-Host "❌ WAAS Test App container not found in Prisma Cloud" -ForegroundColor Red
    Write-Host "Available containers:" -ForegroundColor Yellow
    foreach ($container in $containers) {
      Write-Host "   - $($container.name) ($($container.image))" -ForegroundColor Gray
    }
  }
} catch {
  Write-Host "Failed to get containers: $($_.Exception.Message)" -ForegroundColor Red
}

# Check collections
Write-Host "`n📁 Checking collections..." -ForegroundColor Cyan
try {
  $collections = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/collections" -Headers $headers -Method GET
  $waasCollection = $collections | Where-Object { $_.name -eq 'waas-test-app' }
  if ($waasCollection) {
    Write-Host "✅ WAAS Test App collection found!" -ForegroundColor Green
  } else {
    Write-Host "❌ WAAS Test App collection not found!" -ForegroundColor Red
  }
} catch {
  Write-Host "Failed to get collections: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Open Prisma Cloud Console: https://localhost:8083" -ForegroundColor White
Write-Host "2. Navigate to: Defend → WAAS → Container" -ForegroundColor White
Write-Host "3. Click '+ Add rule'" -ForegroundColor White
Write-Host "4. Select collection: 'waas-test-app'" -ForegroundColor White
Write-Host "5. Set Protection Mode: 'In-Line'" -ForegroundColor White
Write-Host "6. Configure port: 3000 (HTTP)" -ForegroundColor White
Write-Host "7. Enable OWASP Top 10 protection" -ForegroundColor White


