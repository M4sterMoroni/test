# Admission Controller Lab - Quick Start Guide

## ✅ What's Already Done

- [x] Minikube cluster running (v1.33.1)
- [x] Namespace `twistlock` created
- [x] Service account configured
- [x] RBAC permissions set up
- [x] Test workloads prepared

## 🎯 What You Need to Do

### Step 1: Download Admission Controller (5 minutes)

1. Open browser: **https://localhost:8083**
2. Login: **admin / admin234**
3. Navigate: **Manage → Defenders → Deploy**
4. Click **Deploy**
5. Select:
   - **Deployment Method**: Single Defender
   - **Orchestrator**: Kubernetes
   - **Defender Type**: Admission Controller
6. Enter Console Address: `https://host.minikube.internal:8083`
7. Copy the entire YAML output
8. Save as: `C:\Users\mahon\OneDrive\Documentos\Espacio compartido\MPIV\test\admission-controller-lab\05-admission-controller.yaml`

### Step 2: Deploy Admission Controller (2 minutes)

```powershell
cd "C:\Users\mahon\OneDrive\Documentos\Espacio compartido\MPIV\test\admission-controller-lab"
kubectl apply -f 05-admission-controller.yaml
```

### Step 3: Wait for Pods to be Ready (2-3 minutes)

```bash
kubectl wait --for=condition=ready pod -l app=twistlock-defender --namespace=twistlock --timeout=300s
```

### Step 4: Verify Deployment (1 minute)

```bash
kubectl get pods -n twistlock
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations
```

### Step 5: Configure Policies in Console (3 minutes)

1. Open: **https://localhost:8083**
2. Navigate: **Defend → Access → Admission**
3. Click **Add Rule**
4. Configure:
   - **Rule Name**: Block High Severity
   - **Effect**: Block
   - **Critical Vulnerabilities**: Block
   - **High Vulnerabilities**: Block
   - **Privileged Containers**: Block
   - **Root User**: Block

### Step 6: Test with Compliant Workload (1 minute)

```bash
kubectl apply -f test-workloads/01-compliant-pod.yaml
kubectl get pod compliant-nginx
```

**Expected**: ✅ Pod created successfully

### Step 7: Test with Non-Compliant Workload (1 minute)

```bash
kubectl apply -f test-workloads/02-non-compliant-pod.yaml
```

**Expected**: ❌ Error: admission webhook denied the request

### Step 8: Review Results (2 minutes)

**Console**:
- Navigate: **Monitor → Events → Admission Audits**
- Review allowed and blocked deployments

**Logs**:
```bash
kubectl logs -n twistlock -l app=twistlock-defender --tail=50
```

## 🎉 Success Criteria

- [ ] Admission controller pods running (2/2)
- [ ] Webhooks registered
- [ ] Compliant pod deployed successfully
- [ ] Non-compliant pod blocked
- [ ] Events visible in Console

## ⏱️ Total Time: ~15-20 minutes

## 🆘 Need Help?

- **README.md**: Full documentation
- **LAB-GUIDE.md**: Detailed step-by-step guide
- **Admission-Controller-Lab-Report.md**: Comprehensive analysis

## 📋 Commands Cheat Sheet

```bash
# Check cluster
kubectl get nodes
kubectl get namespaces

# Check admission controller
kubectl get pods -n twistlock
kubectl logs -n twistlock -l app=twistlock-defender

# Check webhooks
kubectl get validatingwebhookconfigurations
kubectl describe validatingwebhookconfigurations

# Test deployments
kubectl apply -f test-workloads/01-compliant-pod.yaml      # Should work
kubectl apply -f test-workloads/02-non-compliant-pod.yaml  # Should fail

# View events
kubectl get events --all-namespaces --sort-by=.metadata.creationTimestamp

# Cleanup
kubectl delete pod compliant-nginx
kubectl delete -f 05-admission-controller.yaml
```

## 🔗 URLs

- **Prisma Cloud Console**: https://localhost:8083
- **Minikube Dashboard**: `minikube dashboard`

---
**Ready to go!** Follow the steps above to complete your lab. Good luck! 🚀

