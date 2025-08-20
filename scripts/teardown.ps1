$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

param(
  [switch]$All
)

# Stop port-forwards
Get-Process kubectl -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

if ($All) {
  Write-Host "Deleting Minikube cluster..."
  minikube delete
} else {
  Write-Host "Deleting app resources..."
  kubectl delete -f k8s/istio/ -f k8s/apps/ -n default -l app
  Write-Host "To remove Istio and addons, run:"
  Write-Host "  kubectl delete -f istio-1.22.3/samples/addons/prometheus.yaml"
  Write-Host "  kubectl delete -f istio-1.22.3/samples/addons/grafana.yaml"
  Write-Host "  istioctl uninstall -y"
}
