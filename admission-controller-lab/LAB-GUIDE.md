# Prisma Cloud Admission Controller Lab Guide

## Overview

This lab provides hands-on experience with Prisma Cloud Admission Controller on Kubernetes (Minikube). You will learn how to deploy, configure, and test admission controller functionality for securing Kubernetes workloads.

## Lab Objectives

1. **Prerequisites Verification**: Verify Kubernetes cluster, permissions, and connectivity
2. **Deployment**: Deploy Prisma Cloud Admission Controller on Minikube
3. **RBAC Configuration**: Configure proper role-based access control
4. **Webhook Setup**: Configure validating and mutating webhooks
5. **Policy Configuration**: Set up admission control policies in Prisma Cloud Console
6. **Testing**: Test admission controller with compliant and non-compliant workloads
7. **Validation**: Verify policy enforcement and blocking capabilities

## Architecture Overview

```
Developer → kubectl apply → Kubernetes API Server → Admission Controller Webhook 
→ Prisma Cloud Console → Policy Evaluation → Allow/Deny Decision
```

## Lab Environment

- **Kubernetes**: Minikube (v1.37.0)
- **Kubernetes Version**: v1.33.1
- **Prisma Cloud Console**: localhost:8083
- **Namespace**: twistlock

## Prerequisites

✅ Minikube installed and running
✅ kubectl configured and working
✅ Docker Desktop running
✅ Prisma Cloud Console running (localhost:8083)
✅ Admin permissions on Kubernetes cluster

## Lab Structure

```
admission-controller-lab/
├── 01-namespace.yaml                  # Namespace configuration
├── 02-service-account.yaml            # Service account for admission controller
├── 03-cluster-role.yaml               # RBAC cluster role
├── 04-cluster-role-binding.yaml       # RBAC role binding
├── 05-admission-controller.yaml       # Admission controller deployment (from Console)
├── deploy-lab.ps1                     # Automated deployment script
├── download-admission-controller.ps1  # Download script from Prisma Cloud
├── test-workloads/                    # Test workloads
│   ├── 01-compliant-pod.yaml
│   ├── 02-non-compliant-pod.yaml
│   ├── 03-compliant-deployment.yaml
│   └── 04-high-severity-pod.yaml
└── LAB-GUIDE.md                       # This file
```

## Part 1: Prerequisites Verification

### Step 1.1: Verify Minikube
```bash
minikube status
kubectl get nodes
```

**Expected Output**: Minikube running, nodes ready

### Step 1.2: Verify Permissions
```bash
kubectl auth can-i create validatingwebhookconfigurations
kubectl auth can-i create mutatingwebhookconfigurations
kubectl auth can-i create namespaces
```

**Expected Output**: "yes" for all

### Step 1.3: Verify Prisma Cloud Console
```bash
curl -k https://localhost:8083/api/v1/status
```

**Expected Output**: Console is accessible

## Part 2: Deploy Admission Controller

### Option A: Automated Deployment (Recommended)
```powershell
.\deploy-lab.ps1
```

This script will:
- Verify prerequisites
- Create namespace and RBAC
- Download admission controller configuration
- Deploy admission controller
- Verify webhook configuration

### Option B: Manual Deployment

#### Step 2.1: Create Namespace
```bash
kubectl apply -f 01-namespace.yaml
kubectl get namespace twistlock
```

#### Step 2.2: Create Service Account
```bash
kubectl apply -f 02-service-account.yaml
kubectl get serviceaccount -n twistlock
```

#### Step 2.3: Create RBAC
```bash
kubectl apply -f 03-cluster-role.yaml
kubectl apply -f 04-cluster-role-binding.yaml
kubectl get clusterrole twistlock-view
kubectl get clusterrolebinding twistlock-view-binding
```

#### Step 2.4: Download Admission Controller Configuration

**Method 1**: Using PowerShell script
```powershell
.\download-admission-controller.ps1
```

**Method 2**: Manual download from Console
1. Open https://localhost:8083
2. Login: admin / admin234
3. Navigate to: **Manage → Defenders → Deploy**
4. Select:
   - **Deployment Method**: Single Defender
   - **Orchestrator**: Kubernetes
   - **Defender Type**: Admission Controller
   - **Console Address**: https://host.minikube.internal:8083
5. Copy the YAML content
6. Save as `05-admission-controller.yaml`

#### Step 2.5: Deploy Admission Controller
```bash
kubectl apply -f 05-admission-controller.yaml

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=twistlock-defender --namespace=twistlock --timeout=300s

# Check status
kubectl get pods -n twistlock
kubectl get deployments -n twistlock
```

#### Step 2.6: Verify Webhooks
```bash
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations
kubectl describe validatingwebhookconfigurations twistlock-validating-webhook
```

## Part 3: Configure Policies in Prisma Cloud Console

### Step 3.1: Access Prisma Cloud Console
1. Open: https://localhost:8083
2. Login: admin / admin234

### Step 3.2: Configure Admission Control Policies
1. Navigate to: **Defend → Access → Admission**
2. Click **Add Rule**
3. Configure the following:

**Rule Configuration**:
- **Rule Name**: `Block High Severity Vulnerabilities`
- **Effect**: `Block`
- **Scope**: `All Namespaces` or `Collections: All`

**Vulnerability Settings**:
- **Critical**: Block
- **High**: Block
- **Medium**: Alert
- **Low**: Ignore

**Compliance Settings**:
- **Critical**: Block
- **High**: Alert

**Container Settings**:
- **Block privileged containers**: ✅
- **Block root user**: ✅
- **Block images without resource limits**: ⚠️ (Optional)

4. Click **Save**

### Step 3.3: Verify Policy
1. Go to: **Monitor → Events → Admission Audits**
2. Confirm policy is active

## Part 4: Test Admission Controller

### Test 1: Deploy Compliant Pod (Should Succeed)
```bash
kubectl apply -f test-workloads/01-compliant-pod.yaml
```

**Expected Result**: ✅ Pod created successfully
**Verification**:
```bash
kubectl get pod compliant-nginx
kubectl describe pod compliant-nginx
```

### Test 2: Deploy Non-Compliant Pod (Should Fail)
```bash
kubectl apply -f test-workloads/02-non-compliant-pod.yaml
```

**Expected Result**: ❌ Admission webhook denied the request
**Expected Error**: 
```
Error from server: admission webhook "twistlock-validating-webhook.twistlock.svc" denied the request: 
Security policy violation: Container running as root user
```

### Test 3: Deploy Compliant Deployment (Should Succeed)
```bash
kubectl apply -f test-workloads/03-compliant-deployment.yaml
kubectl get deployment compliant-webapp
kubectl get pods -l app=webapp
```

**Expected Result**: ✅ Deployment created with 2 pods running

### Test 4: Deploy High Severity Vulnerable Image (Should Fail)
```bash
kubectl apply -f test-workloads/04-high-severity-pod.yaml
```

**Expected Result**: ❌ Admission webhook denied the request
**Expected Error**: 
```
Error from server: admission webhook denied the request: 
Image wordpress:4.6 has high severity vulnerabilities
```

## Part 5: Monitor and Analyze

### Step 5.1: View Admission Controller Logs
```bash
kubectl logs -n twistlock -l app=twistlock-defender --tail=50
kubectl logs -n twistlock -l app=twistlock-defender -f  # Follow logs
```

### Step 5.2: View Admission Events in Console
1. Open Prisma Cloud Console: https://localhost:8083
2. Navigate to: **Monitor → Events → Admission Audits**
3. Review:
   - Allowed deployments
   - Blocked deployments
   - Policy violations
   - Timestamps and details

### Step 5.3: Analyze Webhook Activity
```bash
kubectl get events --all-namespaces --sort-by=.metadata.creationTimestamp
kubectl get events --field-selector reason=FailedCreate
```

## Part 6: Advanced Testing

### Test Bypass Namespace (Optional)
Some namespaces might be excluded from admission control:
```bash
kubectl get namespaces -l twistlock.com/admission-disabled=true
```

### Test Webhook Failure Policy
```bash
kubectl describe validatingwebhookconfigurations | grep "Failure Policy"
```

### Test Performance
```bash
# Measure deployment time with admission controller
time kubectl apply -f test-workloads/03-compliant-deployment.yaml

# Compare with direct pod creation
time kubectl run test-nginx --image=nginx:alpine
```

## Troubleshooting

### Issue 1: Admission Controller Pods Not Starting
```bash
kubectl describe pod -n twistlock -l app=twistlock-defender
kubectl logs -n twistlock -l app=twistlock-defender
```

**Common Causes**:
- Console URL not accessible from Minikube
- Authentication credentials incorrect
- Network connectivity issues

**Solution**:
```bash
# Verify console is accessible from Minikube
minikube ssh
curl -k https://host.minikube.internal:8083/api/v1/status
```

### Issue 2: Webhooks Not Blocking
```bash
kubectl get validatingwebhookconfigurations twistlock-validating-webhook -o yaml
```

**Check**:
- Failure policy (should be "Fail")
- Service endpoint
- CA bundle configured
- Webhook rules match your resources

### Issue 3: All Deployments Blocked
- Check Prisma Cloud Console policies
- Verify policy scope
- Review admission audit logs
- Adjust vulnerability thresholds

## Cleanup

### Remove Test Workloads
```bash
kubectl delete pod compliant-nginx --ignore-not-found
kubectl delete deployment compliant-webapp --ignore-not-found
```

### Remove Admission Controller
```bash
kubectl delete -f 05-admission-controller.yaml
kubectl delete -f 04-cluster-role-binding.yaml
kubectl delete -f 03-cluster-role.yaml
kubectl delete -f 02-service-account.yaml
kubectl delete -f 01-namespace.yaml
```

### Verify Cleanup
```bash
kubectl get all -n twistlock
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations
```

## Lab Completion Checklist

- [ ] Prerequisites verified
- [ ] Namespace and RBAC configured
- [ ] Admission controller deployed
- [ ] Webhooks configured
- [ ] Policies configured in Console
- [ ] Compliant pod deployment tested (success)
- [ ] Non-compliant pod deployment tested (blocked)
- [ ] Admission events reviewed in Console
- [ ] Logs analyzed
- [ ] Lab report generated

## Key Learnings

1. **Admission Controller Architecture**: Understanding webhook-based policy enforcement
2. **RBAC Configuration**: Proper permissions for admission controller
3. **Policy Management**: Centralized policy configuration in Prisma Cloud
4. **Real-time Enforcement**: Prevention vs detection
5. **Webhook Types**: Validating vs mutating webhooks
6. **Failure Policies**: Importance of fail-safe vs fail-open
7. **Integration**: Kubernetes + Prisma Cloud integration patterns

## Additional Resources

- [Kubernetes Admission Controllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)
- [Prisma Cloud Compute Edition Documentation](https://docs.prismacloud.io/en/compute-edition/34)
- [Webhook Admission Control](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/)

## Next Steps

1. Explore advanced OPA policies
2. Configure custom admission rules
3. Integrate with CI/CD pipelines
4. Implement namespace-specific policies
5. Set up monitoring and alerting

---
*Lab Version: 1.0 | Last Updated: October 10, 2025*

