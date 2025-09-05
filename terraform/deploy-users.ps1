# Prisma Cloud Compute User Deployment Script
# This script deploys users using Terraform

param(
    [switch]$Plan,
    [switch]$Apply,
    [switch]$Destroy,
    [switch]$Init,
    [switch]$Help
)

if ($Help) {
    Write-Host "Prisma Cloud Compute User Deployment Script" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage: .\deploy-users.ps1 [options]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -Init     Initialize Terraform (download providers)" -ForegroundColor White
    Write-Host "  -Plan     Show what will be created (dry run)" -ForegroundColor White
    Write-Host "  -Apply    Deploy the users" -ForegroundColor White
    Write-Host "  -Destroy  Remove all created users" -ForegroundColor White
    Write-Host "  -Help     Show this help message" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\deploy-users.ps1 -Init" -ForegroundColor White
    Write-Host "  .\deploy-users.ps1 -Plan" -ForegroundColor White
    Write-Host "  .\deploy-users.ps1 -Apply" -ForegroundColor White
    exit 0
}

# Check if Terraform is installed
try {
    $terraformVersion = terraform version
    Write-Host "Terraform found: $($terraformVersion.Split("`n")[0])" -ForegroundColor Green
} catch {
    Write-Host "Error: Terraform is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Terraform from https://www.terraform.io/downloads" -ForegroundColor Yellow
    exit 1
}

# Check if we're in the terraform directory
if (-not (Test-Path "main.tf")) {
    Write-Host "Error: This script must be run from the terraform directory" -ForegroundColor Red
    Write-Host "Please navigate to the terraform folder and run the script from there" -ForegroundColor Yellow
    Write-Host "Example: cd terraform && .\deploy-users.ps1 -Init" -ForegroundColor Cyan
    exit 1
}

# Check if terraform.tfvars exists
if (-not (Test-Path "terraform.tfvars")) {
    Write-Host "Warning: terraform.tfvars not found" -ForegroundColor Yellow
    Write-Host "Copy terraform.tfvars.example to terraform.tfvars and update with your values" -ForegroundColor Yellow
    Write-Host ""
    if (Test-Path "terraform.tfvars.example") {
        Copy-Item "terraform.tfvars.example" "terraform.tfvars"
        Write-Host "Created terraform.tfvars from example file" -ForegroundColor Green
    } else {
        Write-Host "Error: terraform.tfvars.example not found" -ForegroundColor Red
        exit 1
    }
}

# Execute Terraform commands
if ($Init) {
    Write-Host "Initializing Terraform..." -ForegroundColor Blue
    terraform init
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Terraform initialized successfully" -ForegroundColor Green
    } else {
        Write-Host "Terraform initialization failed" -ForegroundColor Red
        exit 1
    }
}

if ($Plan) {
    Write-Host "Planning Terraform deployment..." -ForegroundColor Blue
    terraform plan
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Terraform plan completed successfully" -ForegroundColor Green
    } else {
        Write-Host "Terraform plan failed" -ForegroundColor Red
        exit 1
    }
}

if ($Apply) {
    Write-Host "Applying Terraform configuration..." -ForegroundColor Blue
    Write-Host "This will create users in Prisma Cloud Compute" -ForegroundColor Yellow
    Write-Host ""
    $confirm = Read-Host "Do you want to continue? (y/N)"
    if ($confirm -eq "y" -or $confirm -eq "Y") {
        terraform apply -auto-approve
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Users deployed successfully!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Deployment summary:" -ForegroundColor Blue
            terraform output
        } else {
            Write-Host "Terraform apply failed" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "Deployment cancelled" -ForegroundColor Yellow
    }
}

if ($Destroy) {
    Write-Host "Destroying Terraform resources..." -ForegroundColor Blue
    Write-Host "This will remove all created users from Prisma Cloud Compute" -ForegroundColor Red
    Write-Host ""
    $confirm = Read-Host "Are you sure you want to destroy all resources? (y/N)"
    if ($confirm -eq "y" -or $confirm -eq "Y") {
        terraform destroy -auto-approve
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Resources destroyed successfully!" -ForegroundColor Green
        } else {
            Write-Host "Terraform destroy failed" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "Destroy cancelled" -ForegroundColor Yellow
    }
}

# If no options specified, show help
if (-not ($Init -or $Plan -or $Apply -or $Destroy)) {
    Write-Host "No action specified. Use -Help to see available options." -ForegroundColor Yellow
    Write-Host ""
    .\deploy-users.ps1 -Help
}
