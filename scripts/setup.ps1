$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Move to repo root
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

# Ensure istioctl in PATH (adjust version folder if needed)
$istioBin = Join-Path $root "istio-1.22.3\bin"
if (Test-Path $istioBin) { $env:PATH += ";$istioBin" }

# Start Minikube (tuned for Docker Desktop on Windows)
minikube start --cpus 2 --memory 6g --driver=docker

# Install Istio (demo profile)
istioctl install --set profile=demo -y

# Enable sidecar injection
kubectl label namespace default istio-injection=enabled --overwrite

# Deploy apps and Istio gateway/virtualservice
kubectl apply -f k8s/apps/
kubectl apply -f k8s/istio/

# Install Prometheus and Grafana addons
kubectl apply -f "istio-1.22.3/samples/addons/prometheus.yaml"
kubectl apply -f "istio-1.22.3/samples/addons/grafana.yaml"

# Wait for app rollouts
$deploys = @(
  "deployment/mpiv-frontend",
  "deployment/details-v1",
  "deployment/productpage-v1",
  "deployment/reviews-v1"
)
foreach ($d in $deploys) { kubectl rollout status $d --timeout=180s }

# Wait for monitoring rollouts
kubectl -n istio-system rollout status deployment/grafana --timeout=300s
kubectl -n istio-system rollout status deployment/prometheus --timeout=300s

Write-Host "Ready. Run scripts\\port-forward.ps1, then open:"
Write-Host "  App:        http://localhost:8080/"
Write-Host "  JSON test:  http://localhost:8080/get"
Write-Host "  Grafana:    http://localhost:3000"
Write-Host "  Prometheus: http://localhost:9090"
