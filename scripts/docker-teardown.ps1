$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Move to repo root
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

Write-Host "Stopping MPIV Docker Compose environment..." -ForegroundColor Yellow

# Stop and remove containers, networks, and volumes
docker-compose down -v

Write-Host "✅ Docker Compose environment stopped and cleaned up." -ForegroundColor Green
