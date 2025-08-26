# MPIV Docker Compose Environment

A complete microservices setup with service mesh, monitoring, and observability using Docker Compose.

## 🏗️ Architecture

- **Traefik**: Service mesh/API Gateway (replaces Istio)
- **Frontend**: Custom nginx with landing page
- **Backend Services**: ProductPage, Reviews, Details (using httpbin)
- **Monitoring**: Prometheus + Grafana + cAdvisor + Node Exporter

## 🚀 Quick Start

### Prerequisites
- Docker Desktop running
- At least 4GB RAM available

### Start Everything
```powershell
.\scripts\docker-setup.ps1
```

### Stop Everything
```powershell
.\scripts\docker-teardown.ps1
```

## 🌐 Service URLs

| Service | URL | Description |
|---------|-----|-------------|
| **Frontend** | http://localhost:8080/ | Main landing page |
| **API Test** | http://localhost:8080/get | JSON API endpoint |
| **Reviews API** | http://localhost:8080/reviews | Reviews service |
| **Details API** | http://localhost:8080/details | Details service |
| **Traefik Dashboard** | http://localhost:8090/ | Service mesh dashboard |
| **Grafana** | http://localhost:3000/ | Monitoring dashboards (admin/admin) |
| **Prometheus** | http://localhost:9090/ | Metrics collection |
| **Container Metrics** | http://localhost:8088/ | cAdvisor container metrics |

## 📊 Monitoring

### Grafana Dashboards
- Pre-configured Prometheus datasource
- Container metrics from cAdvisor
- System metrics from Node Exporter
- Traefik service mesh metrics

### Key Metrics Available
- HTTP request rates and latencies
- Container CPU/Memory usage
- Network traffic
- Service health status

## 🔍 Container Visibility

Unlike Kubernetes, with Docker Compose you can easily:

```powershell
# View all running containers
docker-compose ps

# View logs for specific service
docker-compose logs -f mpiv-frontend
docker-compose logs -f traefik

# View logs for all services
docker-compose logs -f

# Execute commands in containers
docker-compose exec mpiv-frontend sh
docker-compose exec traefik sh

# Scale services
docker-compose up --scale productpage=3 -d

# Restart specific service
docker-compose restart mpiv-frontend
```

## 🛠️ Development

### File Structure
```
├── docker-compose.yml          # Main orchestration
├── Dockerfile                  # Frontend image
├── index.html                  # Frontend content
├── monitoring/
│   ├── prometheus.yml          # Prometheus config
│   └── grafana/
│       ├── datasources/        # Grafana datasources
│       └── dashboards/         # Dashboard configs
└── scripts/
    ├── docker-setup.ps1        # Start environment
    └── docker-teardown.ps1     # Stop environment
```

### Adding New Services

1. Add service to `docker-compose.yml`
2. Add Traefik labels for routing
3. Update Prometheus config if needed
4. Restart: `docker-compose up -d`

### Custom Routing

Traefik automatically discovers services via Docker labels:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.myservice.rule=Host(`localhost`) && PathPrefix(`/mypath`)"
  - "traefik.http.services.myservice.loadbalancer.server.port=80"
```

## 🔒 Security Benefits

- **No CVE-2024-24790**: Uses latest Docker images
- **Latest Go versions**: All services use current base images
- **Network isolation**: Services communicate via Docker network
- **Resource limits**: Can easily add CPU/memory constraints

## 🆚 vs Kubernetes

| Feature | Docker Compose | Kubernetes |
|---------|----------------|------------|
| **Visibility** | ✅ Easy `docker ps` | ❌ Complex kubectl |
| **Debugging** | ✅ Simple logs | ❌ Multiple commands |
| **Resource Usage** | ✅ Lightweight | ❌ Heavy (Minikube) |
| **Development** | ✅ Fast iteration | ❌ Slower rebuilds |
| **Service Mesh** | ✅ Traefik | ✅ Istio |
| **Monitoring** | ✅ Same tools | ✅ Same tools |
| **Production** | ❌ Limited scaling | ✅ Enterprise ready |

## 📈 Load Testing

Generate traffic to see metrics:

```powershell
# Simple load test
1..1000 | % { 
    curl.exe -s http://localhost:8080/get > $null
    curl.exe -s http://localhost:8080/reviews > $null
    Start-Sleep -Milliseconds 100 
}
```

Watch the metrics in Grafana at http://localhost:3000/

## 🧹 Cleanup

```powershell
# Stop and remove everything
.\scripts\docker-teardown.ps1

# Remove images if needed
docker system prune -a
```
