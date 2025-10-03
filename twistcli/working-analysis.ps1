# Working Image Analysis Script

$ConsoleUrl = 'https://localhost:8083'
$Username = 'admin'
$Password = 'admin234'
$ImageName = 'web-app-waas-test-app'

Write-Host "🔍 WAAS Test Application - Image Analysis" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check Docker Image
Write-Host "🐳 Checking Docker Image..." -ForegroundColor Yellow
try {
    $dockerImages = docker images $ImageName
    Write-Host "Docker Image Found:" -ForegroundColor Green
    Write-Host $dockerImages -ForegroundColor White
} catch {
    Write-Host "❌ Docker image not found: $ImageName" -ForegroundColor Red
    Write-Host "Building image first..." -ForegroundColor Yellow
    Set-Location "..\web-app"
    docker-compose build
    Set-Location "..\twistcli"
}

# Step 2: Analyze Image History
Write-Host "`n📊 Image History Analysis..." -ForegroundColor Yellow
try {
    $imageHistory = docker history $ImageName
    Write-Host "Image Layers:" -ForegroundColor White
    Write-Host $imageHistory -ForegroundColor Gray
} catch {
    Write-Host "❌ Could not get image history" -ForegroundColor Red
}

# Step 3: Inspect Container Configuration
Write-Host "`n🔍 Container Configuration Analysis..." -ForegroundColor Yellow
try {
    $containerInfo = docker inspect $ImageName | ConvertFrom-Json
    Write-Host "Container Details:" -ForegroundColor White
    Write-Host "  Architecture: $($containerInfo[0].Architecture)" -ForegroundColor Gray
    Write-Host "  OS: $($containerInfo[0].Os)" -ForegroundColor Gray
    Write-Host "  User: $($containerInfo[0].Config.User)" -ForegroundColor Gray
    Write-Host "  Exposed Ports: $($containerInfo[0].Config.ExposedPorts -join ', ')" -ForegroundColor Gray
    Write-Host "  Environment Variables:" -ForegroundColor Gray
    foreach ($env in $containerInfo[0].Config.Env) {
        Write-Host "    $env" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Could not inspect container" -ForegroundColor Red
}

# Step 4: Security Analysis
Write-Host "`n🔒 Security Analysis..." -ForegroundColor Yellow
$securityFindings = @()

try {
    $containerInfo = docker inspect $ImageName | ConvertFrom-Json
    
    # Check user context
    if ($containerInfo[0].Config.User -eq "" -or $containerInfo[0].Config.User -eq "root") {
        $securityFindings += "⚠️  SECURITY RISK: Container runs as root user"
        Write-Host "⚠️  SECURITY RISK: Container runs as root user" -ForegroundColor Red
    } else {
        Write-Host "✅ Container runs as non-root user: $($containerInfo[0].Config.User)" -ForegroundColor Green
    }
    
    # Check exposed ports
    if ($containerInfo[0].Config.ExposedPorts) {
        Write-Host "📡 Exposed Ports: $($containerInfo[0].Config.ExposedPorts -join ', ')" -ForegroundColor Yellow
        $securityFindings += "📡 Container exposes ports: $($containerInfo[0].Config.ExposedPorts -join ', ')"
    } else {
        Write-Host "✅ No ports exposed" -ForegroundColor Green
    }
    
    # Check environment variables
    if ($containerInfo[0].Config.Env) {
        Write-Host "🔧 Environment Variables Present: $($containerInfo[0].Config.Env.Count)" -ForegroundColor Cyan
        $securityFindings += "🔧 Environment variables configured: $($containerInfo[0].Config.Env.Count)"
    }
    
} catch {
    Write-Host "❌ Security analysis failed" -ForegroundColor Red
}

# Step 5: Prisma Cloud Console Check
Write-Host "`n🔍 Prisma Cloud Console Integration..." -ForegroundColor Yellow
$consoleStatus = "Not Connected"
try {
    $authBody = @{ username = $Username; password = $Password } | ConvertTo-Json
    $auth = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/authenticate" -Method POST -Body $authBody -ContentType 'application/json' -SkipCertificateCheck
    $headers = @{ Authorization = 'Bearer ' + $auth.token }
    
    Write-Host "✅ Prisma Cloud Console accessible" -ForegroundColor Green
    $consoleStatus = "Connected"
    
    $containers = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/containers" -Headers $headers -Method GET -SkipCertificateCheck
    $waasContainer = $containers | Where-Object { $_.labels -contains "app:waas-test" -or $_.name -like "*waas*" }
    
    if ($waasContainer) {
        Write-Host "✅ WAAS container found in console" -ForegroundColor Green
        Write-Host "  Name: $($waasContainer.name)" -ForegroundColor White
        Write-Host "  Image: $($waasContainer.image)" -ForegroundColor White
        Write-Host "  Labels: $($waasContainer.labels -join ', ')" -ForegroundColor White
    } else {
        Write-Host "⚠️  WAAS container not found in console" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ Could not connect to Prisma Cloud Console" -ForegroundColor Red
}

# Step 6: Generate Report
Write-Host "`n📄 Generating Analysis Report..." -ForegroundColor Yellow

# Create report content
$reportLines = @()
$reportLines += "# WAAS Test Application - Security Analysis Report"
$reportLines += ""
$reportLines += "## Analysis Summary"
$reportLines += "- Image Name: $ImageName"
$reportLines += "- Analysis Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$reportLines += "- Analysis Type: Docker Image Security Analysis"
$reportLines += ""
$reportLines += "## Docker Image Information"
$reportLines += $dockerImages
$reportLines += ""
$reportLines += "## Security Findings"
foreach ($finding in $securityFindings) {
    $reportLines += $finding
}
$reportLines += ""
$reportLines += "## Recommendations"
$reportLines += "1. User Context: Ensure container runs as non-root user"
$reportLines += "2. Port Security: Minimize exposed ports"
$reportLines += "3. Environment Variables: Review for sensitive information"
$reportLines += "4. WAAS Integration: Configure proper protection"
$reportLines += ""
$reportLines += "## Next Steps"
$reportLines += "1. Address security findings"
$reportLines += "2. Configure WAAS protection"
$reportLines += "3. Set up monitoring"
$reportLines += "4. Regular security assessments"
$reportLines += ""
$reportLines += "---"
$reportLines += "*Report generated by Prisma Cloud Security Analysis*"

# Save report
$reportContent = $reportLines -join "`n"
$reportContent | Out-File -FilePath "WAAS-Security-Analysis-Report.md" -Encoding UTF8

Write-Host "✅ Analysis complete!" -ForegroundColor Green
Write-Host "📄 Report saved as: WAAS-Security-Analysis-Report.md" -ForegroundColor Cyan
Write-Host "`n📊 Analysis Summary:" -ForegroundColor Yellow
Write-Host "  Security Findings: $($securityFindings.Count)" -ForegroundColor White
Write-Host "  Console Status: $consoleStatus" -ForegroundColor White
Write-Host "  Report Generated: ✅" -ForegroundColor Green
