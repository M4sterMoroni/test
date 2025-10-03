# Configure TwistCLI for Image Sandbox Analysis

$ConsoleUrl = 'https://localhost:8083'
$Username = 'admin'
$Password = 'admin234'

Write-Host "🔧 Configuring TwistCLI for Image Sandbox Analysis" -ForegroundColor Cyan
Write-Host ""

# Check if TwistCLI exists
if (-not (Test-Path "twistcli.exe")) {
    Write-Host "❌ TwistCLI not found!" -ForegroundColor Red
    Write-Host "Please download TwistCLI from: $ConsoleUrl" -ForegroundColor Yellow
    Write-Host "Navigate to: Settings → System → Downloads" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ TwistCLI found!" -ForegroundColor Green

# Test TwistCLI version
Write-Host "`n📋 TwistCLI Information:" -ForegroundColor Cyan
try {
    $version = .\twistcli.exe version
    Write-Host "Version: $version" -ForegroundColor White
} catch {
    Write-Host "Could not get version information" -ForegroundColor Yellow
}

# Test authentication
Write-Host "`n🔐 Testing Authentication:" -ForegroundColor Cyan
try {
    $authTest = .\twistcli.exe images scan --address $ConsoleUrl --user $Username --password $Password --help
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Authentication successful!" -ForegroundColor Green
    } else {
        Write-Host "❌ Authentication failed" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Authentication test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Run image scan: .\twistcli.exe images scan web-app-waas-test-app" -ForegroundColor White
Write-Host "2. Run sandbox analysis: .\twistcli.exe sandbox web-app-waas-test-app" -ForegroundColor White
Write-Host "3. Check results in Prisma Cloud Console" -ForegroundColor White
