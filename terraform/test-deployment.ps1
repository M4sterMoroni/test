# Test Prisma Cloud Compute User Deployment
# This script tests the deployed users by attempting to authenticate

param(
    [string]$ConsoleUrl = "https://localhost:8083",
    [string]$Username = "terraform-admin",
    [string]$Password = "AdminPass123!"
)

# Check if we're in the terraform directory
if (-not (Test-Path "main.tf")) {
    Write-Host "Error: This script must be run from the terraform directory" -ForegroundColor Red
    Write-Host "Please navigate to the terraform folder and run the script from there" -ForegroundColor Yellow
    Write-Host "Example: cd terraform && .\test-deployment.ps1" -ForegroundColor Cyan
    exit 1
}

Write-Host "Testing Prisma Cloud Compute User Deployment" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""

# Test authentication for each user
$users = @(
    @{username="terraform-admin"; password="AdminPass123!"; role="Admin"},
    @{username="security-analyst"; password="AnalystPass123!"; role="User"},
    @{username="viewer-user"; password="ViewerPass123!"; role="User"},
    @{username="custom-security-user"; password="CustomPass123!"; role="User"}
)

$successCount = 0
$totalCount = $users.Count

foreach ($user in $users) {
    Write-Host "Testing user: $($user.username)" -ForegroundColor Blue
    
    try {
        # Create authentication request
        $authBody = @{
            username = $user.username
            password = $user.password
        } | ConvertTo-Json
        
        # Make authentication request
        $response = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/authenticate" -Method POST -Body $authBody -ContentType "application/json" -SkipCertificateCheck
        
        if ($response.token) {
            Write-Host "  ✓ Authentication successful" -ForegroundColor Green
            Write-Host "  ✓ Token received: $($response.token.Substring(0, 20))..." -ForegroundColor Green
            $successCount++
        } else {
            Write-Host "  ✗ Authentication failed - no token received" -ForegroundColor Red
        }
    } catch {
        Write-Host "  ✗ Authentication failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
}

# Summary
Write-Host "Test Summary" -ForegroundColor Blue
Write-Host "===========" -ForegroundColor Blue
Write-Host "Successful authentications: $successCount/$totalCount" -ForegroundColor $(if ($successCount -eq $totalCount) { "Green" } else { "Yellow" })

if ($successCount -eq $totalCount) {
    Write-Host "✓ All users deployed and working correctly!" -ForegroundColor Green
} else {
    Write-Host "⚠ Some users may not be deployed correctly" -ForegroundColor Yellow
    Write-Host "Check the Terraform output for more details" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "To view Terraform outputs, run: terraform output" -ForegroundColor Cyan
