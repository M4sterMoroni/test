# Prisma Cloud Admission Controller Lab

## 🎯 Lab Objectives

This hands-on lab provides practical experience deploying and configuring Prisma Cloud Admission Controller on a Kubernetes cluster (Minikube). You'll learn how to prevent vulnerable and non-compliant workloads from being deployed.

## ✅ Prerequisites Completed

- [x] Minikube v1.37.0 running
- [x] Kubernetes v1.33.1 cluster ready
- [x] kubectl v1.34.1 configured
- [x] Docker Desktop running
- [x] Prisma Cloud Console running (localhost:8083)
- [x] Admin permissions verified

## 📁 Lab Structure

```
admission-controller-lab/
├── 01-namespace.yaml                  ✅ DEPLOYED
├── 02-service-account.yaml            ✅ DEPLOYED
├── 03-cluster-role.yaml               ✅ DEPLOYED  
├── 04-cluster-role-binding.yaml       ✅ DEPLOYED
├── 05-admission-controller.yaml       ⏳ PENDING (needs download)
├── deploy-lab.ps1                     Automated deployment script
├── download-admission-controller.ps1  Download from Prisma Cloud
├── test-workloads/                    Test cases
│   ├── 01-compliant-pod.yaml         Secure nginx pod
│   ├── 02-non-compliant-pod.yaml     Privileged pod (should block)
│   ├── 03-compliant-deployment.yaml  Secure deployment
│   └── 04-high-severity-pod.yaml     Vulnerable image (should block)
├── LAB-GUIDE.md                       Complete step-by-step guide
└── README.md                          This file
```

## 🚀 Quick Start

### Option 1: Automated Deployment (Recommended)
```powershell
.\deploy-lab.ps1
```

### Option 2: Manual Step-by-Step
Follow the [LAB-GUIDE.md](LAB-GUIDE.md) for detailed instructions.

## 📋 Current Status

### Completed:
✅ Minikube cluster started
✅ Kubernetes connectivity verified  
✅ Admin permissions checked
✅ Namespace `twistlock` created
✅ Service account `twistlock-service` created
✅ ClusterRole `twistlock-view` created
✅ ClusterRoleBinding configured
✅ Test workloads prepared

### Next Steps:
1. **Download Admission Controller from Prisma Cloud Console**
2. Deploy admission controller
3. Configure policies
4. Test with workloads
5. Generate lab report

## 🔧 Download Admission Controller

You need to download the admission controller configuration from your Prisma Cloud Console:

### Method 1: PowerShell Script (Automated)
```powershell
.\download-admission-controller.ps1
```

### Method 2: Manual Download (Recommended for Learning)
1. Open browser: **https://localhost:8083**
2. Login: **admin / admin234**
3. Navigate to: **Manage → Defenders → Deploy**
4. Click: **Deploy → Single Defender**
5. Configure:
   - **Orchestrator**: Kubernetes
   - **Defender Type**: Admission Controller  
   - **Console Address**: `https://host.minikube.internal:8083`
   - **Namespace**: `twistlock`
6. Click **Copy** to get the YAML
7. Save as: `05-admission-controller.yaml`

### Method 3: Using twistcli
```bash
# If you have twistcli configured
twistcli defender export kubernetes \
  --address https://localhost:8083 \
  --user admin \
  --password admin234 \
  --defender-type admission \
  --namespace twistlock > 05-admission-controller.yaml
```

## 🎬 After Downloading

Once you have `05-admission-controller.yaml`:

```bash
# Deploy the admission controller
kubectl apply -f 05-admission-controller.yaml

# Wait for pods to be ready (2-3 minutes)
kubectl wait --for=condition=ready pod \
  -l app=twistlock-defender \
  --namespace=twistlock \
  --timeout=300s

# Verify deployment
kubectl get pods -n twistlock
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations
```

## 🧪 Testing

### Test 1: Deploy Compliant Pod (Should Succeed)
```bash
kubectl apply -f test-workloads/01-compliant-pod.yaml
```
**Expected**: ✅ Pod created successfully

### Test 2: Deploy Non-Compliant Pod (Should Fail)
```bash
kubectl apply -f test-workloads/02-non-compliant-pod.yaml
```
**Expected**: ❌ Admission webhook denies the request

### Test 3: Deploy Vulnerable Image (Should Fail)
```bash
kubectl apply -f test-workloads/04-high-severity-pod.yaml
```
**Expected**: ❌ High severity vulnerabilities detected

## 📊 Monitor Results

### View Logs
```bash
kubectl logs -n twistlock -l app=twistlock-defender --tail=50
```

### View Events in Console
1. Open: https://localhost:8083
2. Go to: **Monitor → Events → Admission Audits**
3. Review blocked and allowed deployments

## 🔍 Verification Commands

```bash
# Check namespace
kubectl get namespace twistlock

# Check service account
kubectl get serviceaccount -n twistlock

# Check RBAC
kubectl get clusterrole twistlock-view
kubectl get clusterrolebinding twistlock-view-binding

# Check admission controller pods
kubectl get pods -n twistlock

# Check webhooks
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations

# Check events
kubectl get events --all-namespaces --sort-by=.metadata.creationTimestamp
```

## 🛠️ Troubleshooting

### Admission Controller Pods Not Starting
```bash
kubectl describe pod -n twistlock -l app=twistlock-defender
kubectl logs -n twistlock -l app=twistlock-defender
```

### Verify Console Connectivity from Minikube
```bash
minikube ssh
curl -k https://host.minikube.internal:8083/api/v1/status
exit
```

### Webhook Not Working
```bash
kubectl describe validatingwebhookconfigurations
kubectl get events --field-selector reason=FailedCreate
```

## 🧹 Cleanup

```bash
# Remove admission controller
kubectl delete -f 05-admission-controller.yaml

# Remove RBAC and namespace
kubectl delete -f 04-cluster-role-binding.yaml
kubectl delete -f 03-cluster-role.yaml
kubectl delete -f 02-service-account.yaml
kubectl delete -f 01-namespace.yaml

# Remove test workloads
kubectl delete pod compliant-nginx --ignore-not-found
kubectl delete deployment compliant-webapp --ignore-not-found
```

## 📚 Documentation

- **[LAB-GUIDE.md](LAB-GUIDE.md)**: Complete step-by-step lab guide
- **[Test Workloads](test-workloads/)**: Sample deployments for testing
- **[Prisma Cloud Docs](https://docs.prismacloud.io/)**: Official documentation

## 🎓 Learning Outcomes

By completing this lab, you will understand:

1. **Admission Controller Architecture**: How webhooks intercept Kubernetes API calls
2. **RBAC Configuration**: Proper permissions for admission controllers
3. **Policy Enforcement**: Pre-deployment security policy validation
4. **Webhook Types**: Validating vs mutating webhooks
5. **Real-time Protection**: Prevention vs detection security models
6. **Prisma Cloud Integration**: Kubernetes + Prisma Cloud workflows

## 🔗 Helpful Resources

- [Kubernetes Admission Controllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)
- [Webhook Admission Control](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/)
- [Prisma Cloud Compute Edition](https://docs.prismacloud.io/en/compute-edition/34)

## 💡 Tips

- **Namespace Exclusions**: Some namespaces (kube-system) may be excluded from admission control
- **Failure Policy**: Check if webhooks use `Fail` or `Ignore` failure policy
- **Performance**: Admission controller adds ~100-200ms latency to deployments
- **Testing**: Always test in non-production first
- **Policies**: Start permissive, then gradually tighten

## ✅ Lab Completion Checklist

- [ ] Minikube cluster running
- [ ] RBAC configured
- [ ] Admission controller deployed
- [ ] Webhooks registered
- [ ] Policies configured in Console
- [ ] Compliant deployment tested (success)
- [ ] Non-compliant deployment tested (blocked)
- [ ] Admission events reviewed
- [ ] Logs analyzed
- [ ] Lab report generated

---

**Lab Version**: 1.0  
**Last Updated**: October 10, 2025  
**Kubernetes Version**: v1.33.1  
**Prisma Cloud Console**: v34.00.141

