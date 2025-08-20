# Kubernetes Multi-Service Environment with Istio and Prometheus

This project provides a comprehensive setup for a multi-service Kubernetes environment on Minikube, complete with Istio for service mesh capabilities and Prometheus/Grafana for monitoring.

## Prerequisites

- **Docker Desktop:** Ensure Docker Desktop is installed and running.
- **Minikube:** Make sure you have Minikube installed.
- **kubectl:** The Kubernetes command-line tool.
- **Istio CLI:** You will need to install the Istio command-line tool.

## Setup Instructions

### 1. Start Minikube

Start your Minikube cluster with sufficient resources to run the entire stack.

```bash
minikube start --cpus 4 --memory 8g --driver=docker
```

### 2. Install Istio

Download and install Istio on your machine. For Windows, you can follow these steps:

1.  **Download Istio:** Go to the [Istio releases page](https://github.com/istio/istio/releases) and download the latest `istio-*-win.zip` file. You have already done this step.
2.  **Extract the Zip File:** Unzip the downloaded file. This will create a folder like `istio-1.22.3`. You have also completed this step.
3.  **Add to Path:** Add the `bin` directory from the extracted Istio folder to your system's PATH. You can do this for your current terminal session with the following command (replace the version number if it's different):

```powershell
$env:PATH += ";${PWD}\istio-1.22.3\bin"
```

To make this change permanent, you'll need to add it to your System Environment Variables in Windows settings.

After adding Istio to your path, you can proceed with the installation on your cluster:

```bash
# Install Istio on your Minikube cluster
istioctl install --set profile=demo -y
```

### 3. Enable Sidecar Injection

Label the `default` namespace to enable automatic Istio sidecar injection for your applications.

```bash
kubectl label namespace default istio-injection=enabled
```

### 4. Deploy the Sample Applications

Deploy the three sample applications (`productpage`, `reviews`, and `details`) to your cluster.

```bash
kubectl apply -f k8s/apps/
```

### 5. Deploy Istio Gateway and VirtualService

Apply the Istio Gateway and VirtualService to expose your `productpage` service to external traffic.

```bash
kubectl apply -f k8s/istio/
```

### 6. Install Prometheus and Grafana

Istio comes with sample installations of Prometheus and Grafana. You can deploy them from the Istio installation directory.

```bash
# From within the istio-* directory
kubectl apply -f samples/addons/prometheus.yaml
kubectl apply -f samples/addons/grafana.yaml
```

### 7. Access Your Services

**To get the IP address for your service:**

```bash
minikube ip
```

**To get the port for your service:**

```bash
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export GATEWAY_URL=$(minikube ip):$INGRESS_PORT
```

You can now access your `productpage` service at `http://<GATEWAY_URL>/get`. The `/get` path is because we are using `httpbin` which responds on that path.

### 8. Access Grafana

To view the Grafana dashboard, you first need to expose it.

```bash
kubectl -n istio-system port-forward svc/grafana 3000:3000
```

Now, you can open your browser and navigate to `http://localhost:3000`. You will find pre-built dashboards for monitoring your services.

## Teardown

To clean up your environment, you can run the following commands:

```bash
# Delete the applications and Istio configurations
kubectl delete -f k8s/apps/
kubectl delete -f k8s/istio/

# Uninstall Prometheus and Grafana
# From within the istio-* directory
kubectl delete -f samples/addons/prometheus.yaml
kubectl delete -f samples/addons/grafana.yaml

# Uninstall Istio
istioctl uninstall -y

# Stop the Minikube cluster
minikube stop

# (Optional) Delete the Minikube cluster
minikube delete
```
