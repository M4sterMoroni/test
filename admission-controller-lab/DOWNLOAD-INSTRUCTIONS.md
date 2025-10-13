# Download Admission Controller from Prisma Cloud Console

## Step-by-Step Instructions

The browser should now be open at: **https://localhost:8083**

### Step 1: Login
- **Username**: `admin`
- **Password**: `admin234`

### Step 2: Navigate to Defenders
1. Click on **"Manage"** in the left sidebar
2. Click on **"Defenders"**
3. Click on **"Deploy"** button (top right)

### Step 3: Configure Deployment
1. **Deployment Method**: Select **"Single Defender"**
2. **Orchestrator**: Select **"Kubernetes"**
3. **Defender Type**: Select **"Admission Controller"**

### Step 4: Configure Console Address
- **Console address**: Enter exactly: `https://host.minikube.internal:8083`
- **Namespace**: Leave as `twistlock` (should be default)

### Step 5: Download/Copy YAML
1. Scroll down to see the generated YAML
2. Click **"Copy"** button OR manually select all and copy
3. Open a text editor (Notepad, VS Code, etc.)
4. Paste the YAML content
5. Save as: `05-admission-controller.yaml` in the `admission-controller-lab` folder

### File Location
Save to: `C:\Users\mahon\OneDrive\Documentos\Espacio compartido\MPIV\test\admission-controller-lab\05-admission-controller.yaml`

### What the YAML Contains
The admission controller YAML includes:
- ConfigMap with Prisma Cloud Console configuration
- Secret with authentication credentials
- DaemonSet or Deployment for admission controller pods
- Service for webhook communication
- ValidatingWebhookConfiguration
- ServiceAccount, ClusterRole, ClusterRoleBinding (may be included or separate)

### Verification
After saving, verify the file exists:
```powershell
Test-Path "05-admission-controller.yaml"
Get-Content "05-admission-controller.yaml" | Select-Object -First 20
```

### Next Step
Once you have the file saved, run:
```bash
kubectl apply -f 05-admission-controller.yaml
```

---

**Alternative**: If the Console UI doesn't show the YAML generator, try:
1. Go to: **Manage → System → Downloads**
2. Look for **Defender** downloads
3. Select the appropriate version for Kubernetes

OR

Use the API (if the UI doesn't work):
```powershell
.\get-admission-controller.ps1
```

---

**Need Help?** 
- Check the **LAB-GUIDE.md** for detailed screenshots and explanations
- Review **README.md** for troubleshooting tips

