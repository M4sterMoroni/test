# Prisma Cloud Compute Management Project

This project contains various tools and configurations for managing Prisma Cloud Compute environments, including user management, monitoring, and deployment automation.

## 📁 Project Structure

```
├── terraform/                 # Terraform configurations for user management
│   ├── main.tf               # Main Terraform configuration
│   ├── variables.tf          # Variable definitions
│   ├── outputs.tf            # Output definitions
│   ├── terraform.tfvars      # Configuration values
│   ├── terraform.tfvars.example # Example configuration
│   ├── .gitignore           # Git ignore rules
│   └── README-Terraform.md  # Terraform documentation
├── terraform-setup.ps1       # Helper script to run Terraform from root
├── API/                      # PowerShell API scripts
│   ├── create-collections.ps1
│   ├── debug-compliance-policy.ps1
│   ├── scope-collections-to-compliance-policy.ps1
│   ├── scope-collections-to-vuln-policy.ps1
│   ├── verify-scope.ps1
│   └── creds.json            # API credentials
├── k8s/                      # Kubernetes configurations
│   ├── apps/                 # Application manifests
│   └── istio/                # Istio service mesh configs
├── monitoring/               # Monitoring configurations
│   ├── grafana/              # Grafana dashboards and datasources
│   └── prometheus.yml        # Prometheus configuration
├── scripts/                  # PowerShell scripts
│   ├── deploy-users.ps1     # User deployment script
│   ├── test-deployment.ps1  # Deployment test script
│   ├── create-compliance-standard.ps1 # Compliance standard script
│   ├── docker-setup.ps1
│   ├── docker-teardown.ps1
│   ├── port-forward.ps1
│   ├── setup.ps1
│   ├── teardown.ps1
│   └── upgrade.ps1
├── Summaries/                # Documentation summaries
│   ├── Prisma_Cloud_CWP_API_Management_Summary.md
│   ├── Prisma_Cloud_CWP_Policy_Management_Summary.md
│   ├── Prisma_Cloud_Defender_Agentless_Summary.md
│   └── Prisma_Cloud_RBAC_SSO_Configuration_Summary.md
└── istio-1.27.0/             # Istio service mesh installation files
```

## 🚀 Quick Start

### Prerequisites

- **Terraform** (version >= 1.0) - for user management
- **PowerShell** (Windows) - for automation scripts
- **Prisma Cloud Compute** instance running and accessible
- **Docker** (optional) - for containerized deployments

### User Management with Terraform

#### Option 1: Using the helper script (recommended)

From the project root directory:

```powershell
# Initialize and deploy users
.\terraform-setup.ps1 -Init
.\terraform-setup.ps1 -Plan
.\terraform-setup.ps1 -Apply

# Test the deployment
.\terraform-setup.ps1 -Test
```

#### Option 2: Direct navigation

1. **Navigate to the terraform directory**:
   ```powershell
   cd terraform
   ```

2. **Initialize and deploy users**:
   ```powershell
   .\deploy-users.ps1 -Init
   .\deploy-users.ps1 -Plan
   .\deploy-users.ps1 -Apply
   ```

3. **Test the deployment**:
   ```powershell
   .\test-deployment.ps1
   ```

### Custom Compliance Standard

Create a custom compliance standard with controls, requirements, and policy mappings using PowerShell:

```powershell
# Navigate to scripts directory
cd scripts

# Create compliance standard using PowerShell
.\create-compliance-standard.ps1

# Dry run to see what would be created
.\create-compliance-standard.ps1 -DryRun
```

For detailed documentation, see:
- [Terraform User Management](terraform/README-Terraform.md)

### API Management

The `API/` directory contains PowerShell scripts for managing Prisma Cloud Compute via API:

- **Collections Management**: Create and manage collections
- **Policy Management**: Debug and scope compliance policies
- **Verification**: Verify scopes and configurations

### Kubernetes and Istio

The `k8s/` directory contains Kubernetes manifests and Istio service mesh configurations for deploying applications with Prisma Cloud Compute integration.

### Monitoring

The `monitoring/` directory includes Grafana dashboards and Prometheus configurations for monitoring Prisma Cloud Compute environments.

## 📚 Documentation

- **[Terraform User Management](terraform/README-Terraform.md)** - Complete guide for managing users with Terraform
- **[Docker Setup](README-Docker.md)** - Docker deployment instructions
- **[API Management Summaries](Summaries/)** - Detailed documentation for various Prisma Cloud Compute features

## 🔧 Configuration

### Credentials

Update the credentials in the appropriate files:
- `API/creds.json` - for API scripts
- `terraform/terraform.tfvars` - for Terraform deployments

### Environment Variables

Some scripts may require environment variables. Check individual script documentation for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is for educational and testing purposes. Please ensure compliance with your organization's policies and Prisma Cloud Compute licensing terms.

## 🆘 Support

For issues with:
- **Terraform**: Check the [terraform/README-Terraform.md](terraform/README-Terraform.md) documentation
- **API Scripts**: Review the individual script files and Prisma Cloud Compute API documentation
- **Kubernetes/Istio**: Refer to the respective official documentation

## 🔗 Related Resources

- [Prisma Cloud Documentation](https://docs.paloaltonetworks.com/prisma/prisma-cloud)
- [Terraform Provider for Prisma Cloud Compute](https://registry.terraform.io/providers/PaloAltoNetworks/prismacloudcompute/latest/docs)
- [Istio Documentation](https://istio.io/latest/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
