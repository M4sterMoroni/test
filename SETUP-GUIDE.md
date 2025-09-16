# Quick Setup Guide - TwistCLI Security Pipeline

## What You Have Now

✅ **GitHub Actions Workflow** (`.github/workflows/twistcli-scan.yml`)
- Automatically scans Terraform files and Docker images
- Runs on push/PR to main/develop branches
- Only triggers when relevant files change

✅ **Bash Scripts** (for local testing)
- `scripts/setup-twistcli.sh` - Downloads and configures TwistCLI
- `scripts/scan-with-twistcli.sh` - Runs security scans locally

✅ **Environment Configuration**
- `env.example` - Template for environment variables

## Quick Start

### 1. Set up GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions, and add:

- `PRISMA_CLOUD_URL`: Your Prisma Cloud Console URL (e.g., `https://your-instance.prismacloud.io`)
- `PRISMA_CLOUD_USERNAME`: Your Prisma Cloud username
- `PRISMA_CLOUD_PASSWORD`: Your Prisma Cloud password

### 2. Test the Pipeline

The pipeline will automatically run when you:
- Push changes to `main` or `develop` branches
- Create a pull request targeting `main` or `develop`
- Modify files in `terraform/`, `Dockerfile*`, or `docker-compose.yml`

### 3. Local Testing (Optional)

If you want to test locally:

```bash
# Make scripts executable
chmod +x scripts/setup-twistcli.sh scripts/scan-with-twistcli.sh

# Set up TwistCLI
./scripts/setup-twistcli.sh "https://your-prisma-cloud-url" "username" "password"

# Set environment variables
export PRISMA_CLOUD_URL="https://your-prisma-cloud-url"
export PRISMA_CLOUD_USERNAME="username"
export PRISMA_CLOUD_PASSWORD="password"

# Run scans
./scripts/scan-with-twistcli.sh
```

## What Gets Scanned

- **Terraform files** in `terraform/` directory
- **Docker images** built from `Dockerfile`
- **Docker Compose services** from `docker-compose.yml`

## Results

- Scan results are saved as GitHub Actions artifacts
- A security summary is generated and displayed
- All results are in JSON format for easy parsing

## Next Steps

1. Configure CI policies in your Prisma Cloud Console
2. Review the scan results in GitHub Actions
3. Address any security issues found
4. Customize the pipeline as needed

That's it! Your TwistCLI security pipeline is ready to go.
