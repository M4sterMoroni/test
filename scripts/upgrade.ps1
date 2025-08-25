$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Move to repo root
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

# Function to find and add Istio to PATH
function Add-IstioToPath {
    $istioFolders = Get-ChildItem -Directory -Name "istio-*" | Sort-Object -Descending
    
    if ($istioFolders.Count -eq 0) {
        Write-Error "No Istio folder found. Please download and extract Istio first."
        Write-Host "Download from: https://github.com/istio/istio/releases"
        exit 1
    }
    
    $latestIstio = $istioFolders[0]
    $istioBin = Join-Path $root $latestIstio "bin"
    
    if (-not (Test-Path $istioBin)) {
        Write-Error "Istio bin directory not found at: $istioBin"
        exit 1
    }
    
    $env:PATH = "$istioBin;$env:PATH"
    
    try {
        $version = & "$istioBin\istioctl.exe" version --short 2>$null
        Write-Host "✓ Istio $version found and added to PATH"
        return $true
    }
    catch {
        Write-Error "Failed to execute istioctl from: $istioBin"
        exit 1
    }
}

# Function to check current Istio version
function Get-CurrentIstioVersion {
    try {
        $image = kubectl -n istio-system get deployment istiod -o jsonpath='{.spec.template.spec.containers[0].image}'
        if ($image -match 'pilot:(\d+\.\d+\.\d+)') {
            return $matches[1]
        }
        return $null
    }
    catch {
        Write-Warning "Could not determine current Istio version"
        return $null
    }
}

# Function to check for available updates
function Test-IstioUpdates {
    Write-Host "Checking for Istio updates..." -ForegroundColor Yellow
    
    # Get current version
    $currentVersion = Get-CurrentIstioVersion
    if ($currentVersion) {
        Write-Host "Current Istio version: $currentVersion" -ForegroundColor Cyan
    }
    
    # Check latest available version
    $latestVersion = (Get-ChildItem -Directory -Name "istio-*" | Sort-Object -Descending)[0] -replace 'istio-', ''
    Write-Host "Latest available version: $latestVersion" -ForegroundColor Cyan
    
    if ($currentVersion -and $currentVersion -ne $latestVersion) {
        Write-Host "Update available: $currentVersion -> $latestVersion" -ForegroundColor Yellow
        return $true
    }
    
    Write-Host "✓ Istio is up to date" -ForegroundColor Green
    return $false
}

# Main upgrade process
Write-Host "Starting Istio upgrade process..." -ForegroundColor Green

# Check if Minikube is running
try {
    minikube status | Out-Null
    Write-Host "✓ Minikube is running" -ForegroundColor Green
}
catch {
    Write-Error "Minikube is not running. Please start it first with: .\scripts\setup.ps1"
    exit 1
}

# Add Istio to PATH
Add-IstioToPath

# Check for updates
$updateAvailable = Test-IstioUpdates

if (-not $updateAvailable) {
    Write-Host "No updates needed. Exiting." -ForegroundColor Green
    exit 0
}

# Confirm upgrade
Write-Host "`n⚠️  WARNING: This will upgrade Istio in-place." -ForegroundColor Yellow
Write-Host "This may cause brief service interruptions." -ForegroundColor Yellow
$confirm = Read-Host "Do you want to continue? (y/N)"

if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "Upgrade cancelled." -ForegroundColor Yellow
    exit 0
}

# Perform upgrade
Write-Host "`nUpgrading Istio..." -ForegroundColor Yellow
istioctl upgrade --set profile=demo -y

# Verify upgrade
Write-Host "`nVerifying upgrade..." -ForegroundColor Yellow
$newVersion = Get-CurrentIstioVersion
if ($newVersion) {
    Write-Host "✓ Istio upgraded to version: $newVersion" -ForegroundColor Green
}

# Check pod status
Write-Host "`nChecking Istio system pods..." -ForegroundColor Yellow
kubectl -n istio-system get pods

Write-Host "`n🎉 Upgrade complete!" -ForegroundColor Green
Write-Host "If you experience any issues, you may need to restart the port-forwards:" -ForegroundColor Yellow
Write-Host "  .\scripts\port-forward.ps1" -ForegroundColor White
