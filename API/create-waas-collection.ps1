# Create Prisma Cloud Collection for WAAS Test Application

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
    [string[]]$Images,
    [string[]]$Labels,
    [string[]]$Containers
  )
  $body = @{ 
    name=$Name; 
    description=$Description; 
    color=$Color; 
    images=$Images; 
    labels=$Labels; 
    containers=$Containers;
    namespaces=@();
    hosts=@();
    clusters=@()
  } | ConvertTo-Json
  
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

# Create collection specifically for WAAS test application
# This targets containers with the 'app: waas-test' label
New-OrUpdate-Collection -Name 'waas-test-app' -Description 'WAAS Test Application Collection - Targets containers with app:waas-test label' -Color '#FF6B35' -Images @('*waas-test*', 'web-app-waas-test-app*') -Labels @('app:waas-test') -Containers @('*waas-test*')

Write-Host 'WAAS Test Application Collection created successfully!' -ForegroundColor Cyan
Write-Host 'You can now use this collection when creating WAAS policies.' -ForegroundColor Yellow


