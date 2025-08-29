$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Move to repo root
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

Write-Host "Starting MPIV Docker Compose environment..." -ForegroundColor Green

# Stop any existing containers
Write-Host "Stopping existing containers..." -ForegroundColor Yellow
docker-compose down -v

# Build and start services
Write-Host "Building and starting services..." -ForegroundColor Yellow
docker-compose up --build -d

# Wait for services to be ready
Write-Host "Waiting for services to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Check service status
Write-Host "Checking service status..." -ForegroundColor Yellow
docker-compose ps

Write-Host "`n🎉 Docker Compose environment is ready!" -ForegroundColor Green
Write-Host "Available services:" -ForegroundColor Yellow
Write-Host "  • App (Frontend):     http://localhost:8080/" -ForegroundColor Cyan
Write-Host "  • API (JSON test):    http://localhost:8080/get" -ForegroundColor Cyan
Write-Host "  • Traefik Dashboard:  http://localhost:8090/" -ForegroundColor Cyan
Write-Host "  • Grafana:           http://localhost:3000/ (admin/admin)" -ForegroundColor Cyan
Write-Host "  • Prometheus:        http://localhost:9090/" -ForegroundColor Cyan
Write-Host "  • Container Metrics: http://localhost:8088/" -ForegroundColor Cyan

Write-Host "`nTo view logs:" -ForegroundColor Yellow
Write-Host "  docker-compose logs -f [service-name]" -ForegroundColor White
Write-Host "`nTo stop:" -ForegroundColor Yellow
Write-Host "  .\scripts\docker-teardown.ps1" -ForegroundColor White
