# Running TwistCLI Pipeline Locally with Act

This guide shows how to run the TwistCLI security pipeline locally using [act](https://github.com/nektos/act).

## Prerequisites

1. **Install act**: Follow the [installation guide](https://github.com/nektos/act#installation)
2. **Docker**: Make sure Docker is running
3. **Prisma Cloud**: Your local instance running on `https://localhost:8083/`

## Quick Start

### 1. Create a `.secrets` file

Create a `.secrets` file in your project root with your Prisma Cloud credentials:

```bash
# .secrets file
PRISMA_CLOUD_URL=https://localhost:8083
PRISMA_CLOUD_USERNAME=admin
PRISMA_CLOUD_PASSWORD=admin234
```

### 2. Run the pipeline with act

```bash
# Run the entire pipeline
act

# Run with specific event (push to main)
act push

# Run with verbose output
act -v

# Run and see the logs
act --verbose
```

### 3. View results

The pipeline will:
- Download TwistCLI from your Prisma Cloud instance
- Scan your Terraform files in `terraform/`
- Build and scan your Docker image from `Dockerfile`
- Build and scan Docker Compose services from `docker-compose.yml`
- Display scan results in the console
- Save results as JSON files

## What Gets Scanned

- **Terraform files**: All `.tf` files in the `terraform/` directory
- **Docker image**: Built from your `Dockerfile`
- **Docker Compose services**: All services defined in `docker-compose.yml`

## Troubleshooting

### If TwistCLI download fails
Make sure your Prisma Cloud instance is running and accessible:
```bash
curl -k https://localhost:8083/api/v1/util/twistcli
```

### If Docker builds fail
Make sure Docker is running:
```bash
docker version
```

### If scans fail
Check that your Prisma Cloud instance is properly configured and the credentials are correct.

## Act Commands

```bash
# List available workflows
act -l

# Run specific job
act -j security-scan

# Run with specific platform
act -P ubuntu-latest=catthehacker/ubuntu:act-latest

# Run with secrets from file
act --secret-file .secrets

# Dry run (see what would happen)
act -n
```

## Example Output

When you run `act`, you should see output like:

```
[TwistCLI Security Scan/TwistCLI Security Scan] 🚀  Start image=catthehacker/ubuntu:act-latest
[TwistCLI Security Scan/TwistCLI Security Scan]   🐳  docker pull image=catthehacker/ubuntu:act-latest platform= username= forcePull=false
[TwistCLI Security Scan/TwistCLI Security Scan]   🐳  docker create image=catthehacker/ubuntu:act-latest platform= entrypoint=["tail" "-f" "/dev/null"] cmd=[]
[TwistCLI Security Scan/TwistCLI Security Scan]   🐳  docker run image=catthehacker/ubuntu:act-latest platform= entrypoint=["tail" "-f" "/dev/null"] cmd=[]
[TwistCLI Security Scan/TwistCLI Security Scan] ⭐ Run Main Checkout code
[TwistCLI Security Scan/TwistCLI Security Scan]   🐳  docker exec cmd=[node /var/actions/checkout-action@v4/dist/index.js] user= workdir=
[TwistCLI Security Scan/TwistCLI Security Scan]   ✅  Success - Checkout code
[TwistCLI Security Scan/TwistCLI Security Scan] ⭐ Run Main Download TwistCLI
[TwistCLI Security Scan/TwistCLI Security Scan]   🐳  docker exec cmd=[bash --noprofile --norc -e -o pipefail /var/run/act/actions/nektos/act@v0.2.81/actions/nektos/act@v0.2.81/1/0/command.sh] user= workdir=
[TwistCLI Security Scan/TwistCLI Security Scan]   ✅  Success - Download TwistCLI
...
```

That's it! Your TwistCLI pipeline is now running locally with act.
