# Simple script to download Admission Controller from Prisma Cloud

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

$ConsoleUrl = 'https://localhost:8083'
$Username = 'admin'
$Password = 'admin234'

Write-Host "Downloading Admission Controller Configuration..." -ForegroundColor Cyan

# Authenticate
$authBody = @{ username = $Username; password = $Password } | ConvertTo-Json
try {
    $auth = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/authenticate" -Method POST -Body $authBody -ContentType 'application/json'
    $headers = @{ Authorization = 'Bearer ' + $auth.token }
    Write-Host "Authentication successful!" -ForegroundColor Green
} catch {
    Write-Host "Authentication failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Download admission controller YAML
$url = "$ConsoleUrl/api/v1/scripts/defender.yaml?type=admission" + "&" + "consoleaddr=https://host.minikube.internal:8083"

try {
    $yaml = Invoke-RestMethod -Uri $url -Headers $headers -Method GET
    $yaml | Out-File -FilePath "05-admission-controller.yaml" -Encoding UTF8
    Write-Host "Downloaded successfully to 05-admission-controller.yaml" -ForegroundColor Green
} catch {
    Write-Host "Download failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please download manually from Console" -ForegroundColor Yellow
}

