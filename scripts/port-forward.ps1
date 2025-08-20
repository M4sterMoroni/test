$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Kill existing kubectl port-forwards
Get-Process kubectl -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# Ingress 8080 -> 80
Start-Process -WindowStyle Minimized powershell -ArgumentList "-NoProfile","-Command","kubectl -n istio-system port-forward svc/istio-ingressgateway 8080:80"

# Grafana 3000 -> 3000
Start-Process -WindowStyle Minimized powershell -ArgumentList "-NoProfile","-Command","kubectl -n istio-system port-forward svc/grafana 3000:3000"

# Prometheus 9090 -> 9090
Start-Process -WindowStyle Minimized powershell -ArgumentList "-NoProfile","-Command","kubectl -n istio-system port-forward svc/prometheus 9090:9090"

Write-Host "Port-forwards started:"
Write-Host "  http://localhost:8080/"
Write-Host "  http://localhost:3000"
Write-Host "  http://localhost:9090"
