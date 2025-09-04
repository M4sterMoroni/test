# Create Prisma Cloud Compute collections via API

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

# Defaults (dev)
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
} catch {
  Write-Host "Authentication failed: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}

function New-OrUpdate-Collection {
  param(
    [string]$Name,
    [string]$Description,
    [string]$Color,
    [string[]]$Images
  )
  $body = @{ name=$Name; description=$Description; color=$Color; images=$Images; labels=@(); namespaces=@() } | ConvertTo-Json
  try {
    # PUT upsert (works if collection exists)
    Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/collections/$Name" -Headers $headers -Method PUT -Body $body -ContentType 'application/json' | Out-Null
    Write-Host "Updated collection: $Name" -ForegroundColor Green
  } catch {
    # POST create if PUT failed
    try {
      Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/collections" -Headers $headers -Method POST -Body $body -ContentType 'application/json' | Out-Null
      Write-Host "Created collection: $Name" -ForegroundColor Green
    } catch {
      Write-Host ("Failed to create/update {0}: {1}" -f $Name, $_.Exception.Message) -ForegroundColor Red
      throw
    }
  }
}

# Define collections
New-OrUpdate-Collection -Name 'production-workloads-dev' -Description 'Development environment collection with relaxed scoping' -Color '#00FF00' -Images @('nginx:latest','dev-*','test-*')
New-OrUpdate-Collection -Name 'production-workloads-security' -Description 'Security-critical workloads requiring enhanced monitoring' -Color '#FF0000' -Images @('security-*','auth-*','payment-*','vault-*')

Write-Host 'Done.' -ForegroundColor Cyan




