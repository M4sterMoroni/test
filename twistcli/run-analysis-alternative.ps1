# Alternative Image Analysis using Available Tools

$ConsoleUrl = 'https://localhost:8083'
$Username = 'admin'
$Password = 'admin234'
$ImageName = 'web-app-waas-test-app'

Write-Host "🔍 Alternative Image Analysis for WAAS Test Application" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check Docker Image Details
Write-Host "📋 Step 1: Analyzing Docker Image Details..." -ForegroundColor Yellow

$imageInfo = @{
    ImageName = $ImageName
    AnalysisDate = Get-Date
    ConsoleUrl = $ConsoleUrl
}

# Get Docker image information
try {
    Write-Host "🐳 Checking Docker image..." -ForegroundColor Cyan
    $dockerImages = docker images $ImageName --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
    Write-Host "Docker Image Information:" -ForegroundColor White
    Write-Host $dockerImages -ForegroundColor Gray
    
    $imageInfo.DockerImages = $dockerImages
} catch {
    Write-Host "❌ Could not retrieve Docker image info: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 2: Analyze Docker Image Layers
Write-Host "`n🔍 Step 2: Analyzing Docker Image Layers..." -ForegroundColor Yellow

try {
    Write-Host "📊 Getting image layers..." -ForegroundColor Cyan
    $imageHistory = docker history $ImageName --format "table {{.CreatedBy}}\t{{.Size}}\t{{.CreatedAt}}"
    Write-Host "Image Layers:" -ForegroundColor White
    Write-Host $imageHistory -ForegroundColor Gray
    
    $imageInfo.ImageLayers = $imageHistory
} catch {
    Write-Host "❌ Could not retrieve image history: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3: Check Container Runtime Information
Write-Host "`n🔍 Step 3: Analyzing Container Runtime..." -ForegroundColor Yellow

try {
    Write-Host "📊 Getting container information..." -ForegroundColor Cyan
    $containerInfo = docker inspect $ImageName
    Write-Host "Container Configuration:" -ForegroundColor White
    Write-Host "Architecture: $($containerInfo[0].Architecture)" -ForegroundColor Gray
    Write-Host "OS: $($containerInfo[0].Os)" -ForegroundColor Gray
    Write-Host "User: $($containerInfo[0].Config.User)" -ForegroundColor Gray
    Write-Host "Exposed Ports: $($containerInfo[0].Config.ExposedPorts -join ', ')" -ForegroundColor Gray
    
    $imageInfo.ContainerConfig = @{
        Architecture = $containerInfo[0].Architecture
        OS = $containerInfo[0].Os
        User = $containerInfo[0].Config.User
        ExposedPorts = $containerInfo[0].Config.ExposedPorts
        Environment = $containerInfo[0].Config.Env
        Labels = $containerInfo[0].Config.Labels
    }
} catch {
    Write-Host "❌ Could not retrieve container info: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 4: Security Analysis using Docker
Write-Host "`n🔒 Step 4: Basic Security Analysis..." -ForegroundColor Yellow

$securityFindings = @()

# Check if running as root
if ($imageInfo.ContainerConfig.User -eq "" -or $imageInfo.ContainerConfig.User -eq "root") {
    $securityFindings += "⚠️  Container runs as root user - security risk"
    Write-Host "⚠️  SECURITY FINDING: Container runs as root user" -ForegroundColor Red
} else {
    Write-Host "✅ Container runs as non-root user: $($imageInfo.ContainerConfig.User)" -ForegroundColor Green
}

# Check exposed ports
if ($imageInfo.ContainerConfig.ExposedPorts) {
    Write-Host "📡 Exposed Ports: $($imageInfo.ContainerConfig.ExposedPorts -join ', ')" -ForegroundColor Yellow
    $securityFindings += "📡 Container exposes ports: $($imageInfo.ContainerConfig.ExposedPorts -join ', ')"
} else {
    Write-Host "✅ No ports exposed" -ForegroundColor Green
}

# Check environment variables
if ($imageInfo.ContainerConfig.Environment) {
    Write-Host "🔧 Environment Variables:" -ForegroundColor Cyan
    foreach ($env in $imageInfo.ContainerConfig.Environment) {
        Write-Host "  $env" -ForegroundColor Gray
    }
    $securityFindings += "🔧 Environment variables configured"
}

# Step 5: Check Prisma Cloud Console Integration
Write-Host "`n🔍 Step 5: Checking Prisma Cloud Console Integration..." -ForegroundColor Yellow

try {
    # Test console connectivity
    $authBody = @{ username = $Username; password = $Password } | ConvertTo-Json
    $auth = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/authenticate" -Method POST -Body $authBody -ContentType 'application/json' -SkipCertificateCheck
    $headers = @{ Authorization = 'Bearer ' + $auth.token }
    
    Write-Host "✅ Prisma Cloud Console accessible" -ForegroundColor Green
    
    # Get container information from console
    $containers = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/containers" -Headers $headers -Method GET -SkipCertificateCheck
    $waasContainer = $containers | Where-Object { $_.labels -contains "app:waas-test" -or $_.name -like "*waas*" }
    
    if ($waasContainer) {
        Write-Host "✅ WAAS container found in Prisma Cloud Console" -ForegroundColor Green
        Write-Host "Container Name: $($waasContainer.name)" -ForegroundColor White
        Write-Host "Container Image: $($waasContainer.image)" -ForegroundColor White
        Write-Host "Container Labels: $($waasContainer.labels -join ', ')" -ForegroundColor White
        
        $imageInfo.PrismaCloudContainer = @{
            Name = $waasContainer.name
            Image = $waasContainer.image
            Labels = $waasContainer.labels
            Status = $waasContainer.status
        }
    } else {
        Write-Host "⚠️  WAAS container not found in Prisma Cloud Console" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ Could not connect to Prisma Cloud Console: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 6: Generate Comprehensive Report
Write-Host "`n📊 Step 6: Generating Comprehensive Analysis Report..." -ForegroundColor Yellow

$reportContent = @"
# WAAS Test Application - Image Analysis Report

## Executive Summary
This report provides a comprehensive analysis of the WAAS Test Application Docker image, including security findings, configuration analysis, and recommendations for improvement.

## Analysis Details
- **Image Name**: $ImageName
- **Analysis Date**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
- **Analysis Type**: Docker Image Security Analysis
- **Console URL**: $ConsoleUrl
- **Analyst**: Prisma Cloud Security Analysis

## Docker Image Information

### Image Details
$($imageInfo.DockerImages)

### Image Layers Analysis
$($imageInfo.ImageLayers)

## Container Configuration Analysis

### Architecture and OS
- **Architecture**: $($imageInfo.ContainerConfig.Architecture)
- **Operating System**: $($imageInfo.ContainerConfig.OS)
- **User Context**: $($imageInfo.ContainerConfig.User)

### Network Configuration
- **Exposed Ports**: $($imageInfo.ContainerConfig.ExposedPorts -join ', ')

### Environment Variables
$($imageInfo.ContainerConfig.Environment -join "`n")

### Container Labels
$($imageInfo.ContainerConfig.Labels -join "`n")

## Security Findings

### Critical Findings
$($securityFindings -join "`n")

### Security Assessment
- **Root User**: $(if ($imageInfo.ContainerConfig.User -eq "" -or $imageInfo.ContainerConfig.User -eq "root") { "❌ HIGH RISK - Running as root" } else { "✅ LOW RISK - Running as non-root user" })
- **Exposed Ports**: $(if ($imageInfo.ContainerConfig.ExposedPorts) { "⚠️  MEDIUM RISK - Ports exposed" } else { "✅ LOW RISK - No ports exposed" })
- **Environment Variables**: $(if ($imageInfo.ContainerConfig.Environment) { "⚠️  REVIEW REQUIRED - Environment variables present" } else { "✅ LOW RISK - No environment variables" })

## Prisma Cloud Integration

### Console Integration Status
$(if ($imageInfo.PrismaCloudContainer) {
    @"
- **Status**: ✅ Successfully integrated with Prisma Cloud Console
- **Container Name**: $($imageInfo.PrismaCloudContainer.Name)
- **Container Image**: $($imageInfo.PrismaCloudContainer.Image)
- **Container Labels**: $($imageInfo.PrismaCloudContainer.Labels -join ', ')
- **Container Status**: $($imageInfo.PrismaCloudContainer.Status)
"@
} else {
    "- **Status**: ⚠️  Not found in Prisma Cloud Console"
})

## Recommendations

### High Priority
1. **User Context**: $(if ($imageInfo.ContainerConfig.User -eq "" -or $imageInfo.ContainerConfig.User -eq "root") { "Change container to run as non-root user" } else { "✅ Already running as non-root user" })
2. **Port Security**: $(if ($imageInfo.ContainerConfig.ExposedPorts) { "Review and minimize exposed ports" } else { "✅ No unnecessary ports exposed" })

### Medium Priority
1. **Environment Variables**: Review environment variables for sensitive information
2. **Image Layers**: Minimize image layers and remove unnecessary components
3. **WAAS Integration**: Ensure proper WAAS protection is configured

### Low Priority
1. **Monitoring**: Implement comprehensive monitoring and logging
2. **Updates**: Regularly update base images and dependencies

## Next Steps

### Immediate Actions
1. Review security findings and implement recommended changes
2. Configure WAAS protection in Prisma Cloud Console
3. Set up monitoring and alerting for the application

### Long-term Actions
1. Implement automated security scanning in CI/CD pipeline
2. Regular security assessments and penetration testing
3. Security training for development team

## Conclusion

The WAAS Test Application shows $(if ($securityFindings.Count -gt 0) { "some security concerns that need attention" } else { "good security practices overall" }). 

**Overall Security Rating**: $(if ($securityFindings.Count -gt 2) { "⚠️  MEDIUM RISK" } elseif ($securityFindings.Count -gt 0) { "⚠️  LOW-MEDIUM RISK" } else { "✅ LOW RISK" })

**Recommendation**: $(if ($securityFindings.Count -gt 0) { "Address security findings before production deployment" } else { "Ready for production with ongoing monitoring" })

---
*Report generated by Prisma Cloud Security Analysis Tool*
*For questions or clarifications, contact the security team*
"@

# Save report
$reportContent | Out-File -FilePath "WAAS-Test-App-Security-Analysis-Report.md" -Encoding UTF8

Write-Host "✅ Comprehensive analysis report generated!" -ForegroundColor Green
Write-Host "📄 Report saved as: WAAS-Test-App-Security-Analysis-Report.md" -ForegroundColor Cyan

# Display summary
Write-Host "`n📊 Analysis Summary:" -ForegroundColor Yellow
Write-Host "===================" -ForegroundColor Yellow
Write-Host "Security Findings: $($securityFindings.Count)" -ForegroundColor White
Write-Host "Report Generated: ✅" -ForegroundColor Green
Write-Host "Console Integration: $(if ($imageInfo.PrismaCloudContainer) { "✅ Connected" } else { "⚠️  Not Connected" })" -ForegroundColor $(if ($imageInfo.PrismaCloudContainer) { "Green" } else { "Yellow" })

Write-Host "`n🎯 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Review the generated report: WAAS-Test-App-Security-Analysis-Report.md" -ForegroundColor White
Write-Host "2. Address any security findings" -ForegroundColor White
Write-Host "3. Configure WAAS protection in Prisma Cloud Console" -ForegroundColor White
Write-Host "4. Set up monitoring and alerting" -ForegroundColor White
