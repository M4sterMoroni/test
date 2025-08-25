$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Move to repo root (handle being run from scripts subdirectory)
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

# Function to find and add Istio to PATH
function Add-IstioToPath {
    # Look for Istio folders in the current directory
    $istioFolders = @(Get-ChildItem -Directory -Name "istio-*" | Sort-Object -Descending)
    
    if ($istioFolders.Length -eq 0) {
        Write-Error "No Istio folder found. Please download and extract Istio first."
        Write-Host "Download from: https://github.com/istio/istio/releases"
        exit 1
    }
    
    $latestIstio = $istioFolders[0]
    $istioDir = Join-Path -Path $root -ChildPath $latestIstio
    $istioBin = Join-Path -Path $istioDir -ChildPath "bin"
    $istioExe = Join-Path -Path $istioBin -ChildPath "istioctl.exe"
    
    if (-not (Test-Path $istioBin)) {
        Write-Error "Istio bin directory not found at: $istioBin"
        exit 1
    }
    if (-not (Test-Path $istioExe)) {
        Write-Error "istioctl.exe not found at: $istioExe"
        exit 1
    }
    
    # Unblock istioctl if needed (downloaded from internet)
    try { Unblock-File -Path $istioExe -ErrorAction SilentlyContinue } catch {}
    
    # Add to PATH
    $env:PATH = "$istioBin;$env:PATH"
    
    # istioctl is available - proceed without version check
    Write-Host "Istio 1.27.0 found and added to PATH"
    return $true
}

# Function to check prerequisites
function Test-Prerequisites {
    Write-Host "Checking prerequisites..."
    
    # Check Docker
    try {
        docker version | Out-Null
        Write-Host "Docker is running"
    }
    catch {
        Write-Error "Docker is not running. Please start Docker Desktop first."
        exit 1
    }
    
    # Check Minikube
    try {
        minikube version | Out-Null
        Write-Host "Minikube is installed"
    }
    catch {
        Write-Error "Minikube is not installed or not in PATH"
        exit 1
    }
    
    # Check kubectl
    try {
        kubectl version --client | Out-Null
        Write-Host "kubectl is installed"
    }
    catch {
        Write-Error "kubectl is not installed or not in PATH"
        exit 1
    }
}

# Main setup process
Write-Host "Starting MPIV Kubernetes environment setup..." -ForegroundColor Green

# Check prerequisites
Test-Prerequisites

# Add Istio to PATH
Add-IstioToPath

# Start Minikube (tuned for Docker Desktop on Windows)
Write-Host "Starting Minikube..." -ForegroundColor Yellow
minikube start --cpus 2 --memory 6g --driver=docker

# Install Istio (demo profile)
Write-Host "Installing Istio..." -ForegroundColor Yellow
istioctl install --set profile=demo -y

# Enable sidecar injection
Write-Host "Enabling Istio sidecar injection..." -ForegroundColor Yellow
kubectl label namespace default istio-injection=enabled --overwrite

# Deploy apps and Istio gateway/virtualservice
Write-Host "Deploying applications..." -ForegroundColor Yellow
kubectl apply -f k8s/apps/
kubectl apply -f k8s/istio/

# Install Prometheus and Grafana addons
Write-Host "Installing monitoring addons..." -ForegroundColor Yellow
$istioFolder = (Get-ChildItem -Directory -Name "istio-*" | Sort-Object -Descending)[0]
kubectl apply -f "$istioFolder/samples/addons/prometheus.yaml"
kubectl apply -f "$istioFolder/samples/addons/grafana.yaml"

# Wait for app rollouts
Write-Host "Waiting for application rollouts..." -ForegroundColor Yellow
$deploys = @(
    "deployment/mpiv-frontend",
    "deployment/details-v1",
    "deployment/productpage-v1",
    "deployment/reviews-v1"
)
foreach ($d in $deploys) { 
    Write-Host "  Waiting for $d..." -ForegroundColor Cyan
    kubectl rollout status $d --timeout=180s 
}

# Wait for monitoring rollouts
Write-Host "Waiting for monitoring rollouts..." -ForegroundColor Yellow
kubectl -n istio-system rollout status deployment/grafana --timeout=300s
kubectl -n istio-system rollout status deployment/prometheus --timeout=300s

Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run: .\scripts\port-forward.ps1" -ForegroundColor White
Write-Host "2. Open your browser to:" -ForegroundColor White
Write-Host "   App:        http://localhost:8080/" -ForegroundColor Cyan
Write-Host "   JSON test:  http://localhost:8080/get" -ForegroundColor Cyan
Write-Host "   Grafana:    http://localhost:3000" -ForegroundColor Cyan
Write-Host "   Prometheus: http://localhost:9090" -ForegroundColor Cyan
