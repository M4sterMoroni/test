# Prisma Cloud Compute Terraform Setup Helper
# This script helps users navigate to the terraform directory and run commands

param(
    [switch]$Init,
    [switch]$Plan,
    [switch]$Apply,
    [switch]$Test,
    [switch]$Destroy,
    [switch]$Help
)

if ($Help) {
    Write-Host "Prisma Cloud Compute Terraform Setup Helper" -ForegroundColor Green
    Write-Host "=============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "This script helps you run Terraform commands from the root directory" -ForegroundColor Yellow
    Write-Host "by automatically navigating to the terraform folder." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Usage: .\terraform-setup.ps1 [options]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -Init     Initialize Terraform" -ForegroundColor White
    Write-Host "  -Plan     Show what will be created (dry run)" -ForegroundColor White
    Write-Host "  -Apply    Deploy the users" -ForegroundColor White
    Write-Host "  -Test     Test the deployment" -ForegroundColor White
    Write-Host "  -Destroy  Remove all created users" -ForegroundColor White
    Write-Host "  -Help     Show this help message" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\terraform-setup.ps1 -Init" -ForegroundColor White
    Write-Host "  .\terraform-setup.ps1 -Plan" -ForegroundColor White
    Write-Host "  .\terraform-setup.ps1 -Apply" -ForegroundColor White
    Write-Host "  .\terraform-setup.ps1 -Test" -ForegroundColor White
    Write-Host ""
    Write-Host "Note: This script runs the commands in the terraform/ directory" -ForegroundColor Cyan
    exit 0
}

# Check if terraform directory exists
if (-not (Test-Path "terraform")) {
    Write-Host "Error: terraform directory not found" -ForegroundColor Red
    Write-Host "Please ensure you're in the project root directory" -ForegroundColor Yellow
    exit 1
}

# Check if terraform directory has the required files
if (-not (Test-Path "terraform/main.tf")) {
    Write-Host "Error: terraform/main.tf not found" -ForegroundColor Red
    Write-Host "The terraform directory appears to be incomplete" -ForegroundColor Yellow
    exit 1
}

Write-Host "Navigating to terraform directory..." -ForegroundColor Blue
Set-Location "terraform"

# Execute the appropriate command
if ($Init) {
    Write-Host "Running: .\deploy-users.ps1 -Init" -ForegroundColor Cyan
    .\deploy-users.ps1 -Init
} elseif ($Plan) {
    Write-Host "Running: .\deploy-users.ps1 -Plan" -ForegroundColor Cyan
    .\deploy-users.ps1 -Plan
} elseif ($Apply) {
    Write-Host "Running: .\deploy-users.ps1 -Apply" -ForegroundColor Cyan
    .\deploy-users.ps1 -Apply
} elseif ($Test) {
    Write-Host "Running: .\test-deployment.ps1" -ForegroundColor Cyan
    .\test-deployment.ps1
} elseif ($Destroy) {
    Write-Host "Running: .\deploy-users.ps1 -Destroy" -ForegroundColor Cyan
    .\deploy-users.ps1 -Destroy
} else {
    Write-Host "No action specified. Use -Help to see available options." -ForegroundColor Yellow
    Write-Host ""
    .\terraform-setup.ps1 -Help
}

# Return to original directory
Set-Location ".."



