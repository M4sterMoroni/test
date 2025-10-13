# Check if Admission Controller is ready for deployment

Write-Host "🔍 Checking Admission Controller Lab Readiness..." -ForegroundColor Cyan
Write-Host ""

$ready = $true

# Check 1: Minikube running
Write-Host "1. Checking Minikube status..." -ForegroundColor Yellow
try {
    $minikubeStatus = minikube status 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Minikube is running" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Minikube is not running" -ForegroundColor Red
        $ready = $false
    }
} catch {
    Write-Host "   ❌ Minikube check failed" -ForegroundColor Red
    $ready = $false
}

# Check 2: Kubectl connectivity
Write-Host "`n2. Checking kubectl connectivity..." -ForegroundColor Yellow
try {
    $nodes = kubectl get nodes 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ kubectl can connect to cluster" -ForegroundColor Green
    } else {
        Write-Host "   ❌ kubectl cannot connect" -ForegroundColor Red
        $ready = $false
    }
} catch {
    Write-Host "   ❌ kubectl check failed" -ForegroundColor Red
    $ready = $false
}

# Check 3: Namespace exists
Write-Host "`n3. Checking twistlock namespace..." -ForegroundColor Yellow
try {
    $namespace = kubectl get namespace twistlock 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Namespace 'twistlock' exists" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Namespace 'twistlock' not found" -ForegroundColor Red
        $ready = $false
    }
} catch {
    Write-Host "   ❌ Namespace check failed" -ForegroundColor Red
    $ready = $false
}

# Check 4: RBAC configured
Write-Host "`n4. Checking RBAC configuration..." -ForegroundColor Yellow
try {
    $clusterRole = kubectl get clusterrole twistlock-view 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ ClusterRole 'twistlock-view' exists" -ForegroundColor Green
    } else {
        Write-Host "   ❌ ClusterRole not found" -ForegroundColor Red
        $ready = $false
    }
} catch {
    Write-Host "   ❌ RBAC check failed" -ForegroundColor Red
    $ready = $false
}

# Check 5: Admission controller YAML exists
Write-Host "`n5. Checking for admission controller YAML..." -ForegroundColor Yellow
if (Test-Path "05-admission-controller.yaml") {
    Write-Host "   ✅ File '05-admission-controller.yaml' found" -ForegroundColor Green
    $fileSize = (Get-Item "05-admission-controller.yaml").Length
    Write-Host "   📄 File size: $fileSize bytes" -ForegroundColor White
    
    if ($fileSize -lt 1000) {
        Write-Host "   ⚠️  File seems too small - verify it contains the full YAML" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ❌ File '05-admission-controller.yaml' not found" -ForegroundColor Red
    Write-Host "   📋 Please download from Prisma Cloud Console" -ForegroundColor Yellow
    Write-Host "   📖 See: DOWNLOAD-INSTRUCTIONS.md" -ForegroundColor Yellow
    $ready = $false
}

# Check 6: Admission controller deployed
Write-Host "`n6. Checking admission controller deployment..." -ForegroundColor Yellow
try {
    $pods = kubectl get pods -n twistlock -l app=twistlock-defender 2>&1
    if ($LASTEXITCODE -eq 0 -and $pods -notlike "*No resources found*") {
        Write-Host "   ✅ Admission controller pods found" -ForegroundColor Green
        kubectl get pods -n twistlock
    } else {
        Write-Host "   ⏳ Admission controller not yet deployed" -ForegroundColor Yellow
        Write-Host "   💡 Run: kubectl apply -f 05-admission-controller.yaml" -ForegroundColor Cyan
    }
} catch {
    Write-Host "   ⏳ Admission controller not yet deployed" -ForegroundColor Yellow
}

# Check 7: Webhooks configured
Write-Host "`n7. Checking webhook configuration..." -ForegroundColor Yellow
try {
    $webhooks = kubectl get validatingwebhookconfigurations 2>&1
    if ($LASTEXITCODE -eq 0 -and $webhooks -like "*twistlock*") {
        Write-Host "   ✅ Validating webhook configured" -ForegroundColor Green
    } else {
        Write-Host "   ⏳ Validating webhook not yet configured" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⏳ Webhook not yet configured" -ForegroundColor Yellow
}

# Summary
Write-Host "`n" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
if ($ready) {
    Write-Host "✅ READY TO DEPLOY ADMISSION CONTROLLER" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next step:" -ForegroundColor Yellow
    Write-Host "  kubectl apply -f 05-admission-controller.yaml" -ForegroundColor White
} else {
    Write-Host "⏳ NOT READY - Complete missing steps" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Please complete the prerequisites above" -ForegroundColor White
}

