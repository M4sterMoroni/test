# Prisma Cloud Compute User Management with Terraform

This Terraform configuration deploys users in Prisma Cloud Compute using the HTTP provider to interact with the Prisma Cloud Compute API directly.

## Prerequisites

1. **Terraform** installed (version >= 1.0)
2. **Prisma Cloud Compute** instance running and accessible
3. **Valid credentials** for Prisma Cloud Compute console
4. **API access** enabled on your Prisma Cloud Compute instance

## Configuration

### 1. Provider Configuration

The configuration uses the HashiCorp HTTP provider to make API calls:

```hcl
terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}
```

### 2. Authentication

The configuration authenticates with Prisma Cloud Compute using the `/api/v1/authenticate` endpoint and uses the returned token for subsequent API calls.

Update `terraform.tfvars` with your Prisma Cloud Compute credentials:

```hcl
console_url = "https://your-console-url:8083"
username    = "your-username"
password    = "your-password"
```

### 3. Resources Created

This configuration creates:

- **4 Users** with different roles:
  - `terraform-admin` (Admin role)
  - `security-analyst` (User role)
  - `viewer-user` (User role)
  - `custom-security-user` (User role)

## Usage

### Navigate to the terraform directory

```bash
cd terraform
```

### Initialize Terraform

```bash
terraform init
```

### Plan the deployment

```bash
terraform plan
```

### Apply the configuration

```bash
terraform apply
```

### View outputs

```bash
terraform output
```

### Destroy resources

```bash
terraform destroy
```

### Using the PowerShell scripts

The terraform directory includes convenient PowerShell scripts:

```powershell
# Navigate to terraform directory
cd terraform

# Initialize Terraform
.\deploy-users.ps1 -Init

# Plan the deployment
.\deploy-users.ps1 -Plan

# Deploy the users
.\deploy-users.ps1 -Apply

# Test the deployment
.\test-deployment.ps1

# Destroy resources
.\deploy-users.ps1 -Destroy
```

## Available Roles

The configuration uses these Prisma Cloud Compute roles:

- **Admin**: Full administrative access
- **User**: Standard user access with appropriate permissions

## API Endpoints Used

The configuration interacts with these Prisma Cloud Compute API endpoints:
- `POST /api/v1/authenticate` - Authentication
- `POST /api/v1/users` - User creation

## Security Notes

- Change default passwords in `terraform.tfvars`
- The `terraform.tfvars` file is gitignored for security
- Use environment variables for sensitive data in production
- Consider using Terraform Cloud or similar for state management

## Troubleshooting

### SSL Certificate Issues

If you encounter SSL certificate issues with self-signed certificates, uncomment this line in `main.tf`:

```hcl
provider "prismacloudcompute" {
  console_url = var.console_url
  username    = var.username
  password    = var.password
  skip_ssl_verification = true  # Uncomment this line
}
```

### Authentication Issues

Verify your credentials and console URL are correct. Test connectivity:

```bash
curl -k https://your-console-url:8083/api/v1/version
```

## Next Steps

After successful deployment, you can:

1. **Extend the configuration** with additional users and roles
2. **Add more custom roles** with specific permission sets
3. **Integrate with external identity providers** (LDAP, SAML, OIDC)
4. **Set up automated user provisioning** workflows
5. **Implement RBAC policies** for fine-grained access control

## Support

For issues with:
- **Terraform provider**: Check the [Palo Alto Networks provider documentation](https://registry.terraform.io/providers/PaloAltoNetworks/prismacloudcompute/latest/docs)
- **Prisma Cloud Compute**: Refer to the [Prisma Cloud documentation](https://docs.paloaltonetworks.com/prisma/prisma-cloud)
