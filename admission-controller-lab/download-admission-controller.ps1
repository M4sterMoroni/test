# Download Admission Controller Configuration from Prisma Cloud Console

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

$ConsoleUrl = 'https://host.minikube.internal:8083'
$Username = 'admin'
$Password = 'admin234'

Write-Host "🔐 Downloading Admission Controller Configuration from Prisma Cloud Console" -ForegroundColor Cyan
Write-Host "=================================================================================" -ForegroundColor Cyan
Write-Host ""

# Authenticate
try {
    Write-Host "📋 Authenticating with Prisma Cloud Console..." -ForegroundColor Yellow
    $authBody = @{ username = $Username; password = $Password } | ConvertTo-Json
    $auth = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/authenticate" -Method POST -Body $authBody -ContentType 'application/json' -SkipCertificateCheck
    $headers = @{ Authorization = 'Bearer ' + $auth.token }
    Write-Host "✅ Authentication successful!" -ForegroundColor Green
} catch {
    Write-Host "❌ Authentication failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Download admission controller configuration
try {
    Write-Host "`n📥 Downloading admission controller YAML..." -ForegroundColor Yellow
    $admissionControllerYaml = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/scripts/defender.yaml?type=admission&consoleaddr=https://host.minikube.internal:8083" -Headers $headers -Method GET -SkipCertificateCheck
    
    if ($admissionControllerYaml) {
        $admissionControllerYaml | Out-File -FilePath "05-admission-controller.yaml" -Encoding UTF8
        Write-Host "✅ Admission controller YAML downloaded successfully!" -ForegroundColor Green
        Write-Host "📄 Saved to: 05-admission-controller.yaml" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Failed to download admission controller YAML" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Failed to download: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`n💡 Manual steps:" -ForegroundColor Yellow
    Write-Host "1. Open Prisma Cloud Console: https://localhost:8083" -ForegroundColor White
    Write-Host "2. Go to: Manage → System → Defenders → Deploy → Single Defender" -ForegroundColor White
    Write-Host "3. Select: Orchestrator: Kubernetes" -ForegroundColor White
    Write-Host "4. Select: Defender type: Admission Controller" -ForegroundColor White
    Write-Host "5. Download the YAML file" -ForegroundColor White
}

Write-Host "`n✅ Download complete!" -ForegroundColor Green
Write-Host "Next step: kubectl apply -f 05-admission-controller.yaml" -ForegroundColor Cyan

