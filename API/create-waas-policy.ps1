# Create WAAS Policy for Test Application

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

# Create WAAS Policy
$waasPolicy = @{
  name = "WAAS Test App Protection"
  description = "In-Line WAAS protection for WAAS test application"
  collections = @("waas-test-app")
  type = "container"
  protectionMode = "inline"
  webApplication = @{
    enabled = $true
    port = 3000
    protocol = "http"
    autoDetect = $true
  }
  owaspTop10 = @{
    enabled = $true
    rules = @{
      injection = @{ enabled = $true; action = "block" }
      brokenAuthentication = @{ enabled = $true; action = "block" }
      sensitiveDataExposure = @{ enabled = $true; action = "alert" }
      xmlExternalEntities = @{ enabled = $true; action = "block" }
      brokenAccessControl = @{ enabled = $true; action = "block" }
      securityMisconfiguration = @{ enabled = $true; action = "alert" }
      crossSiteScripting = @{ enabled = $true; action = "block" }
      insecureDeserialization = @{ enabled = $true; action = "block" }
      knownVulnerabilities = @{ enabled = $true; action = "block" }
      insufficientLogging = @{ enabled = $true; action = "alert" }
    }
  }
  attackSignatures = @{
    enabled = $true
    action = "block"
  }
  rateLimiting = @{
    enabled = $true
    requestsPerMinute = 100
    action = "block"
  }
  fileUpload = @{
    enabled = $true
    allowedExtensions = @(".jpg", ".png", ".pdf", ".txt")
    maxFileSize = "10MB"
    action = "block"
  }
  customRules = @()
} | ConvertTo-Json -Depth 10

try {
  # Create the WAAS policy
  $response = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/policies/firewall/app/container" -Headers $headers -Method POST -Body $waasPolicy -ContentType 'application/json'
  Write-Host "✅ WAAS Policy created successfully!" -ForegroundColor Green
  Write-Host "Policy Name: WAAS Test App Protection" -ForegroundColor Cyan
  Write-Host "Collection: waas-test-app" -ForegroundColor Cyan
  Write-Host "Protection Mode: In-Line" -ForegroundColor Cyan
  Write-Host "Port: 3000 (HTTP)" -ForegroundColor Cyan
} catch {
  Write-Host "Failed to create WAAS policy: $($_.Exception.Message)" -ForegroundColor Red
  Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
}

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Wait 2-5 minutes for policy propagation" -ForegroundColor White
Write-Host "2. Check Monitor → WAAS → Unprotected web apps" -ForegroundColor White
Write-Host "3. Test the application at http://localhost:3001" -ForegroundColor White
Write-Host "4. Monitor WAAS events in Monitor → WAAS → WAAS Explorer" -ForegroundColor White


