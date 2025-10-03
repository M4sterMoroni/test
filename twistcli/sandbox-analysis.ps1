# Image Sandbox Analysis Script

$ConsoleUrl = 'https://localhost:8083'
$Username = 'admin'
$Password = 'admin234'
$ImageName = 'web-app-waas-test-app'

Write-Host "🔍 Image Sandbox Analysis for WAAS Test Application" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "📋 Checking Prerequisites..." -ForegroundColor Yellow

# Check if TwistCLI exists
if (-not (Test-Path "twistcli.exe")) {
    Write-Host "❌ TwistCLI not found! Please download it first." -ForegroundColor Red
    Write-Host "Download from: $ConsoleUrl → Settings → System → Downloads" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ TwistCLI found" -ForegroundColor Green

# Check if Docker image exists
Write-Host "`n🐳 Checking Docker Image..." -ForegroundColor Yellow
try {
    $imageExists = docker images $ImageName --format "{{.Repository}}:{{.Tag}}"
    if ($imageExists) {
        Write-Host "✅ Image found: $imageExists" -ForegroundColor Green
    } else {
        Write-Host "❌ Image not found: $ImageName" -ForegroundColor Red
        Write-Host "Building image first..." -ForegroundColor Yellow
        Set-Location "..\web-app"
        docker-compose build
        Set-Location "..\twistcli"
    }
} catch {
    Write-Host "❌ Docker check failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 1: Regular Image Scan
Write-Host "`n🔍 Step 1: Running Regular Image Scan..." -ForegroundColor Cyan
Write-Host "Command: .\twistcli.exe images scan --address $ConsoleUrl --user $Username --password $Password $ImageName" -ForegroundColor Gray

try {
    $scanResult = .\twistcli.exe images scan --address $ConsoleUrl --user $Username --password $Password $ImageName
    Write-Host "✅ Image scan completed" -ForegroundColor Green
    Write-Host "Scan Results:" -ForegroundColor White
    Write-Host $scanResult -ForegroundColor Gray
} catch {
    Write-Host "❌ Image scan failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 2: Image Sandbox Analysis
Write-Host "`n🔬 Step 2: Running Image Sandbox Analysis..." -ForegroundColor Cyan
Write-Host "Command: .\twistcli.exe sandbox --address $ConsoleUrl --user $Username --password $Password $ImageName" -ForegroundColor Gray

try {
    Write-Host "⏳ Starting sandbox analysis (this may take several minutes)..." -ForegroundColor Yellow
    $sandboxResult = .\twistcli.exe sandbox --address $ConsoleUrl --user $Username --password $Password $ImageName
    Write-Host "✅ Sandbox analysis completed" -ForegroundColor Green
    Write-Host "Sandbox Results:" -ForegroundColor White
    Write-Host $sandboxResult -ForegroundColor Gray
} catch {
    Write-Host "❌ Sandbox analysis failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3: Generate Report
Write-Host "`n📊 Step 3: Generating Analysis Report..." -ForegroundColor Cyan

$reportContent = @"
# Image Sandbox Analysis Report

## Analysis Details
- **Image Name**: $ImageName
- **Analysis Date**: $(Get-Date)
- **Console URL**: $ConsoleUrl
- **Analysis Type**: Image Sandbox Analysis

## Scan Results
$scanResult

## Sandbox Analysis Results
$sandboxResult

## Next Steps
1. Review results in Prisma Cloud Console
2. Navigate to Monitor → Sandbox Analysis
3. Check for any security findings
4. Implement remediation if needed

## Console Access
- **URL**: $ConsoleUrl
- **Username**: $Username
- **Password**: $Password
"@

$reportContent | Out-File -FilePath "sandbox-analysis-report.md" -Encoding UTF8
Write-Host "✅ Report saved to: sandbox-analysis-report.md" -ForegroundColor Green

Write-Host "`n🎯 Analysis Complete!" -ForegroundColor Green
Write-Host "Check the following locations for detailed results:" -ForegroundColor White
Write-Host "1. Local Report: sandbox-analysis-report.md" -ForegroundColor Cyan
Write-Host "2. Prisma Cloud Console: Monitor → Sandbox Analysis" -ForegroundColor Cyan
Write-Host "3. Prisma Cloud Console: Monitor → Vulnerabilities" -ForegroundColor Cyan
