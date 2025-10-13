# Admission Controller Lab - Final Summary

## What We've Accomplished

### ✅ Completed Steps:

1. **Minikube Cluster**: Running Kubernetes v1.33.1
2. **Namespace Created**: `twistlock` namespace configured
3. **RBAC Setup**: ClusterRole and ClusterRoleBinding deployed
4. **Service Account**: `twistlock-service` configured
5. **Test Workloads**: 4 comprehensive test scenarios prepared
6. **Documentation**: Complete guides and reports created

### 📋 Lab Files Created:

```
admission-controller-lab/
├── Infrastructure (DEPLOYED ✅)
│   ├── 01-namespace.yaml
│   ├── 02-service-account.yaml
│   ├── 03-cluster-role.yaml
│   └── 04-cluster-role-binding.yaml
│
├── Admission Controller (PENDING ⏳)
│   ├── 05-admission-controller.yaml (needs download from Console)
│   └── 05-admission-controller-template.yaml (instructions)
│
├── Test Workloads (READY ✅)
│   ├── test-workloads/01-compliant-pod.yaml
│   ├── test-workloads/02-non-compliant-pod.yaml
│   ├── test-workloads/03-compliant-deployment.yaml
│   └── test-workloads/04-high-severity-pod.yaml
│
├── Documentation (COMPLETE ✅)
│   ├── README.md (263 lines)
│   ├── LAB-GUIDE.md (388 lines)
│   ├── QUICK-START-GUIDE.md
│   ├── Admission-Controller-Lab-Report.md (20KB)
│   └── DOWNLOAD-INSTRUCTIONS.md
│
└── Scripts (READY ✅)
    ├── deploy-lab.ps1
    ├── check-readiness.ps1
    └── get-admission-controller.ps1
```

## Next Steps to Complete the Lab

### Step 1: Download Admission Controller from Console

**The browser should already be open at: https://localhost:8083**

1. **Login Credentials**:
   - Username: `admin`
   - Password: `admin234`

2. **Navigate**:
   - Manage → Defenders → Deploy

3. **Configure**:
   - Deployment Method: **Single Defender**
   - Orchestrator: **Kubernetes**
   - Defender Type: **Admission Controller**
   - Console Address: `https://host.minikube.internal:8083`

4. **Download**:
   - Copy the generated YAML
   - Save as: `05-admission-controller.yaml`

### Step 2: Deploy Admission Controller

```powershell
# Verify you're in the right directory
cd "C:\Users\mahon\OneDrive\Documentos\Espacio compartido\MPIV\test\admission-controller-lab"

# Deploy the admission controller
kubectl apply -f 05-admission-controller.yaml

# Wait for pods to be ready (2-3 minutes)
kubectl wait --for=condition=ready pod -l app=twistlock-defender --namespace=twistlock --timeout=300s

# Verify deployment
kubectl get pods -n twistlock
kubectl get svc -n twistlock
```

### Step 3: Verify Webhook Configuration

```bash
# Check validating webhooks
kubectl get validatingwebhookconfigurations

# Check mutating webhooks
kubectl get mutatingwebhookconfigurations

# Describe webhook details
kubectl describe validatingwebhookconfigurations | Select-String "twistlock"
```

### Step 4: Configure Policies in Prisma Cloud Console

1. **Open Console**: https://localhost:8083
2. **Navigate**: Defend → Access → Admission
3. **Add Rule**: Click "+ Add Rule"
4. **Configure**:
   - Rule Name: `Block High Severity`
   - Effect: **Block**
   - Critical Vulnerabilities: **Block**
   - High Vulnerabilities: **Block**
   - Privileged Containers: **Block**
   - Root User: **Block**
5. **Save**: Click Save

### Step 5: Test with Compliant Workload (Should Succeed ✅)

```bash
kubectl apply -f test-workloads/01-compliant-pod.yaml
kubectl get pod compliant-nginx
kubectl describe pod compliant-nginx
```

**Expected Result**: Pod created successfully

### Step 6: Test with Non-Compliant Workload (Should Fail ❌)

```bash
kubectl apply -f test-workloads/02-non-compliant-pod.yaml
```

**Expected Result**: 
```
Error from server: admission webhook "twistlock-validating-webhook.twistlock.svc" denied the request: 
Security policy violation: Container running as root user with privileged access
```

### Step 7: Test with Vulnerable Image (Should Fail ❌)

```bash
kubectl apply -f test-workloads/04-high-severity-pod.yaml
```

**Expected Result**:
```
Error from server: admission webhook denied the request: 
Image wordpress:4.6 contains high severity vulnerabilities
```

### Step 8: Monitor and Analyze

**View Logs**:
```bash
kubectl logs -n twistlock -l app=twistlock-defender --tail=50
kubectl logs -n twistlock -l app=twistlock-defender -f  # Follow logs
```

**View Events in Console**:
1. Navigate to: Monitor → Events → Admission Audits
2. Review allowed and blocked deployments
3. Check policy violations
4. Analyze timestamps and details

**View Kubernetes Events**:
```bash
kubectl get events --all-namespaces --sort-by=.metadata.creationTimestamp
kubectl get events --field-selector reason=FailedCreate
```

## Expected Outcomes

### Test 1: Compliant Pod ✅
- **Status**: Deployed successfully
- **Reason**: Meets all security requirements
- **Pod Name**: `compliant-nginx`
- **Image**: nginx:1.27-alpine
- **Security**: Non-root user, no privilege escalation

### Test 2: Non-Compliant Pod ❌
- **Status**: Blocked by admission controller
- **Reason**: Privileged container running as root
- **Error**: Policy violation
- **Image**: nginx:1.14 (vulnerable)

### Test 3: Compliant Deployment ✅
- **Status**: Deployed successfully (2 replicas)
- **Reason**: Meets security standards
- **Deployment Name**: `compliant-webapp`

### Test 4: Vulnerable Image ❌
- **Status**: Blocked by admission controller
- **Reason**: High severity vulnerabilities detected
- **Error**: Image contains known CVEs
- **Image**: wordpress:4.6

## Verification Checklist

- [ ] Minikube running
- [ ] Namespace `twistlock` exists
- [ ] RBAC configured
- [ ] Admission controller YAML downloaded
- [ ] Admission controller deployed
- [ ] Pods running (2/2)
- [ ] Webhooks registered
- [ ] Policies configured in Console
- [ ] Compliant pod deployed (success)
- [ ] Non-compliant pod blocked (failed)
- [ ] Vulnerable image blocked (failed)
- [ ] Events visible in Console
- [ ] Logs reviewed

## Troubleshooting

### If Admission Controller Pods Don't Start

```bash
# Check pod status
kubectl describe pod -n twistlock -l app=twistlock-defender

# Check logs
kubectl logs -n twistlock -l app=twistlock-defender

# Verify console connectivity from Minikube
minikube ssh
curl -k https://host.minikube.internal:8083/api/v1/status
exit
```

### If Webhooks Don't Block

```bash
# Check webhook configuration
kubectl get validatingwebhookconfigurations -o yaml

# Verify failure policy
kubectl describe validatingwebhookconfigurations | grep "Failure Policy"

# Check service endpoint
kubectl get svc -n twistlock
```

### If All Deployments Blocked

- Review policies in Console (may be too strict)
- Check policy scope
- Verify collection configuration
- Adjust vulnerability thresholds

## Performance Impact

**Expected Latency**:
- Admission validation: 100-200ms
- Policy evaluation: 50-100ms
- Total deployment time: +170-350ms

**Resource Usage**:
- CPU: 100m-500m per pod
- Memory: 256Mi-512Mi per pod
- Replicas: 2 (for HA)

## Key Learnings from This Lab

### Architecture

1. **Webhook Flow**: API Server → Webhook → Policy Engine → Decision
2. **Validation**: Webhooks intercept before persistence
3. **Enforcement**: Real-time blocking of non-compliant workloads

### Security

1. **Shift-Left**: Catch vulnerabilities before deployment
2. **Prevention**: Block vs detect approach
3. **Centralized**: Policy management in one place
4. **Auditing**: Complete trail of all decisions

### Operations

1. **High Availability**: Multiple replicas recommended
2. **Failure Policy**: Fail-safe vs fail-open
3. **Monitoring**: Track webhook performance
4. **Updates**: Policy changes apply immediately

## What You've Learned

✅ How admission controllers work
✅ Kubernetes webhook architecture
✅ RBAC configuration for security
✅ Policy-as-Code concepts
✅ Pre-deployment security validation
✅ Prisma Cloud integration patterns
✅ Security policy management
✅ Vulnerability blocking at deployment time

## Additional Resources

- **Kubernetes Admission Controllers**: https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/
- **Prisma Cloud Documentation**: https://docs.prismacloud.io/
- **Lab Files**: All in `admission-controller-lab/` directory

## Cleanup (When Done)

```bash
# Remove test workloads
kubectl delete pod compliant-nginx --ignore-not-found
kubectl delete deployment compliant-webapp --ignore-not-found

# Remove admission controller
kubectl delete -f 05-admission-controller.yaml

# Remove RBAC and namespace
kubectl delete -f 04-cluster-role-binding.yaml
kubectl delete -f 03-cluster-role.yaml
kubectl delete -f 02-service-account.yaml
kubectl delete -f 01-namespace.yaml

# Verify cleanup
kubectl get all -n twistlock
kubectl get validatingwebhookconfigurations
```

## Final Notes

This lab demonstrates enterprise-grade admission control for Kubernetes. The admission controller acts as a security gateway, ensuring only compliant and secure workloads reach your cluster.

**Time to Complete**: ~15-20 minutes (after downloading admission controller)

**Difficulty**: Intermediate

**Value**: High - Critical security skill for Kubernetes environments

---

**Lab Status**: Infrastructure Ready - Awaiting Admission Controller Deployment

**Next Action**: Download `05-admission-controller.yaml` from Prisma Cloud Console

Good luck completing your lab! 🚀

