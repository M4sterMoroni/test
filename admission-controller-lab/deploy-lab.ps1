# Prisma Cloud Admission Controller Lab - Deployment Script

Write-Host "🚀 Prisma Cloud Admission Controller Lab - Deployment" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Verify Prerequisites
Write-Host "📋 Step 1: Verifying Prerequisites..." -ForegroundColor Yellow
Write-Host ""

Write-Host "Checking Minikube status..." -ForegroundColor White
minikube status
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Minikube is not running. Please start it first." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Minikube is running" -ForegroundColor Green

Write-Host "`nChecking kubectl connectivity..." -ForegroundColor White
kubectl get nodes
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Cannot connect to Kubernetes cluster" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Kubernetes cluster is accessible" -ForegroundColor Green

Write-Host "`nChecking permissions..." -ForegroundColor White
$canCreate = kubectl auth can-i create validatingwebhookconfigurations
if ($canCreate -eq "yes") {
    Write-Host "✅ Admin permissions verified" -ForegroundColor Green
} else {
    Write-Host "❌ Insufficient permissions" -ForegroundColor Red
    exit 1
}

# Step 2: Create Namespace and RBAC
Write-Host "`n📦 Step 2: Creating Namespace and RBAC..." -ForegroundColor Yellow
Write-Host ""

Write-Host "Creating namespace..." -ForegroundColor White
kubectl apply -f 01-namespace.yaml
Write-Host "✅ Namespace created" -ForegroundColor Green

Write-Host "`nCreating service account..." -ForegroundColor White
kubectl apply -f 02-service-account.yaml
Write-Host "✅ Service account created" -ForegroundColor Green

Write-Host "`nCreating cluster role..." -ForegroundColor White
kubectl apply -f 03-cluster-role.yaml
Write-Host "✅ Cluster role created" -ForegroundColor Green

Write-Host "`nCreating cluster role binding..." -ForegroundColor White
kubectl apply -f 04-cluster-role-binding.yaml
Write-Host "✅ Cluster role binding created" -ForegroundColor Green

# Step 3: Download Admission Controller from Prisma Cloud Console
Write-Host "`n📥 Step 3: Downloading Admission Controller Configuration..." -ForegroundColor Yellow
Write-Host ""

if (Test-Path "05-admission-controller.yaml") {
    Write-Host "⚠️  Admission controller YAML already exists. Skipping download." -ForegroundColor Yellow
} else {
    Write-Host "Downloading from Prisma Cloud Console..." -ForegroundColor White
    .\download-admission-controller.ps1
    
    if (-not (Test-Path "05-admission-controller.yaml")) {
        Write-Host "`n⚠️  Automatic download failed. Please download manually:" -ForegroundColor Yellow
        Write-Host "1. Open https://localhost:8083" -ForegroundColor White
        Write-Host "2. Go to: Manage → Defenders → Deploy" -ForegroundColor White
        Write-Host "3. Select: Orchestrator: Kubernetes, Type: Admission Controller" -ForegroundColor White
        Write-Host "4. Copy the YAML and save as 05-admission-controller.yaml" -ForegroundColor White
        Write-Host "`nPress any key when ready to continue..." -ForegroundColor Cyan
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

# Step 4: Deploy Admission Controller
Write-Host "`n🎯 Step 4: Deploying Admission Controller..." -ForegroundColor Yellow
Write-Host ""

if (Test-Path "05-admission-controller.yaml") {
    Write-Host "Applying admission controller configuration..." -ForegroundColor White
    kubectl apply -f 05-admission-controller.yaml
    Write-Host "✅ Admission controller deployed" -ForegroundColor Green
    
    Write-Host "`nWaiting for pods to be ready (this may take a few minutes)..." -ForegroundColor White
    kubectl wait --for=condition=ready pod -l app=twistlock-defender --namespace=twistlock --timeout=300s
    
    Write-Host "`nChecking pod status..." -ForegroundColor White
    kubectl get pods -n twistlock
    Write-Host "✅ Admission controller pods are running" -ForegroundColor Green
} else {
    Write-Host "❌ Admission controller YAML not found. Please download it first." -ForegroundColor Red
    exit 1
}

# Step 5: Verify Webhooks
Write-Host "`n🔍 Step 5: Verifying Webhook Configuration..." -ForegroundColor Yellow
Write-Host ""

Write-Host "Checking validating webhooks..." -ForegroundColor White
kubectl get validatingwebhookconfigurations
Write-Host "`nChecking mutating webhooks..." -ForegroundColor White
kubectl get mutatingwebhookconfigurations
Write-Host "✅ Webhooks configured" -ForegroundColor Green

# Summary
Write-Host "`n✅ Admission Controller Deployment Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Configure policies in Prisma Cloud Console" -ForegroundColor White
Write-Host "2. Test with compliant workloads: kubectl apply -f test-workloads/01-compliant-pod.yaml" -ForegroundColor White
Write-Host "3. Test blocking with non-compliant: kubectl apply -f test-workloads/02-non-compliant-pod.yaml" -ForegroundColor White
Write-Host "4. View logs: kubectl logs -n twistlock -l app=twistlock-defender" -ForegroundColor White
Write-Host ""
Write-Host "🔗 Prisma Cloud Console: https://localhost:8083" -ForegroundColor Cyan

