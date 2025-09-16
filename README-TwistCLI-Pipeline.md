# TwistCLI Security Pipeline Documentation

This repository includes a GitHub Actions workflow that uses TwistCLI to perform security scans on Terraform files and Docker images.

## Overview

The pipeline provides automated security scanning for:
- **Terraform IaC files** - Infrastructure as Code security analysis
- **Docker images** - Container vulnerability scanning
- **Docker Compose services** - Multi-service container scanning

## Prerequisites

### Prisma Cloud Setup
1. **Prisma Cloud Console Access**: You need access to a Prisma Cloud Console instance
2. **Authentication Credentials**: Username/password for Prisma Cloud
3. **CI Policies**: Configure appropriate CI policies in Prisma Cloud Console

### Required Tools
- **Docker**: For building and scanning container images
- **TwistCLI**: Automatically downloaded by the pipeline
- **Bash**: For local script execution (Linux/macOS)

## Pipeline Configuration

### GitHub Actions Workflow

**File**: `.github/workflows/twistcli-scan.yml`

**Features**:
- Triggers on push/PR to main/develop branches
- Scans only when relevant files are changed
- Automated TwistCLI setup and configuration
- Comprehensive scanning with detailed reporting
- Artifact collection and security summary generation

**Setup**:
1. Add the following secrets to your GitHub repository:
   - `PRISMA_CLOUD_URL`: Your Prisma Cloud Console URL
   - `PRISMA_CLOUD_USERNAME`: Prisma Cloud username
   - `PRISMA_CLOUD_PASSWORD`: Prisma Cloud password

2. The workflow will automatically trigger on relevant file changes

### Local Scripts

**Files**: 
- `scripts/setup-twistcli.sh`: Setup and configuration
- `scripts/scan-with-twistcli.sh`: Local scanning execution

**Features**:
- Automated TwistCLI download and setup
- Comprehensive scanning options
- Detailed reporting and summaries
- Environment variable configuration

## Usage

### GitHub Actions

The workflow runs automatically when:
- Code is pushed to `main` or `develop` branches
- Pull requests are created targeting `main` or `develop`
- Files in `terraform/`, `Dockerfile*`, or `docker-compose.yml` are modified

### Local Execution

#### Setup (First Time)
```bash
# Download and configure TwistCLI
chmod +x scripts/setup-twistcli.sh
./scripts/setup-twistcli.sh "https://your-prisma-cloud-url" "your-username" "your-password"
```

#### Running Scans
```bash
# Set environment variables
export PRISMA_CLOUD_URL="https://your-prisma-cloud-url"
export PRISMA_CLOUD_USERNAME="your-username"
export PRISMA_CLOUD_PASSWORD="your-password"

# Scan all (Terraform + Docker + Docker Compose)
chmod +x scripts/scan-with-twistcli.sh
./scripts/scan-with-twistcli.sh

# Or set specific scan types
export SCAN_TERRAFORM="true"
export SCAN_DOCKER="false"
export SCAN_DOCKER_COMPOSE="false"
./scripts/scan-with-twistcli.sh
```

## Scan Types

### 1. Terraform IaC Scan

**What it scans**:
- All `.tf` files in the `terraform/` directory
- Infrastructure configuration security issues
- Compliance violations
- Misconfigurations

**Command**:
```bash
twistcli iac scan --address <PRISMA_CLOUD_URL> --user <USERNAME> --password <PASSWORD> --template-type terraform --template-version 1.0 --policy-enforcement terraform/
```

### 2. Docker Image Scan

**What it scans**:
- Container images built from `Dockerfile`
- Vulnerabilities in base images and dependencies
- Security misconfigurations
- Compliance issues

**Command**:
```bash
twistcli images scan --address <PRISMA_CLOUD_URL> --user <USERNAME> --password <PASSWORD> --policy-enforcement test-app:latest
```

### 3. Docker Compose Scan

**What it scans**:
- All services defined in `docker-compose.yml`
- Individual container images for each service
- Multi-service security posture

**Process**:
1. Builds all services using `docker-compose build`
2. Scans each service image individually
3. Generates separate reports for each service

## Output and Reporting

### Scan Results
- **JSON format**: Detailed scan results in JSON files
- **Artifact collection**: All results are collected as build artifacts
- **Security summary**: Human-readable markdown summary

### File Locations
- **GitHub Actions**: Available in Actions tab as artifacts
- **Jenkins**: Available in build artifacts section
- **Local execution**: Saved in `.\scan-results\` directory

### Summary Report
Each scan generates a `security-summary.md` file containing:
- Scan execution status
- Files/images scanned
- Issue counts by severity
- Next steps and recommendations

## Configuration Options

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `PRISMA_CLOUD_URL` | Prisma Cloud Console URL | Yes |
| `PRISMA_CLOUD_USERNAME` | Prisma Cloud username | Yes |
| `PRISMA_CLOUD_PASSWORD` | Prisma Cloud password | Yes |
| `PRISMA_CLOUD_ACCESS_KEY` | Prisma Cloud access key | No |
| `PRISMA_CLOUD_SECRET_KEY` | Prisma Cloud secret key | No |

### Policy Enforcement

When `--policy-enforcement` is enabled:
- Scans are evaluated against Prisma Cloud CI policies
- Builds can be blocked if policies fail
- Real-time policy decisions from Prisma Cloud Console

### Customization

#### GitHub Actions
- Modify trigger conditions in `.github/workflows/twistcli-scan.yml`
- Add additional scan types or modify existing ones
- Customize artifact collection and reporting

#### Jenkins
- Modify the `Jenkinsfile` for different trigger conditions
- Add additional stages or steps
- Customize credential management

#### Local Scripts
- Modify scan parameters in `scripts/twistcli-scan.ps1`
- Add custom scan types or reporting
- Integrate with other security tools

## Troubleshooting

### Common Issues

1. **Authentication Failures**
   - Verify Prisma Cloud credentials
   - Check network connectivity to Prisma Cloud Console
   - Ensure user has appropriate permissions

2. **TwistCLI Download Issues**
   - Verify Prisma Cloud URL is correct
   - Check network connectivity
   - Ensure Prisma Cloud Console is accessible

3. **Docker Build Failures**
   - Verify Docker is running
   - Check Dockerfile syntax
   - Ensure all required files are present

4. **Scan Failures**
   - Check TwistCLI version compatibility
   - Verify Prisma Cloud policies are configured
   - Review scan logs for specific error messages

### Debug Mode

Enable debug output by adding `--debug` flag to TwistCLI commands:

```bash
twistcli images scan --debug --address <URL> --user <USER> --password <PASS> <IMAGE>
```

### Logs and Artifacts

- **GitHub Actions**: Check Actions tab for detailed logs
- **Jenkins**: Review build console output
- **Local execution**: Check PowerShell output and scan-results directory

## Best Practices

### Security
1. **Credential Management**: Use secure credential storage (GitHub Secrets, Jenkins Credentials)
2. **Network Security**: Ensure secure communication with Prisma Cloud
3. **Access Control**: Limit access to scan results and credentials

### Performance
1. **Parallel Scanning**: Use parallel execution for multiple scan types
2. **Caching**: Implement appropriate caching strategies
3. **Resource Management**: Allocate sufficient resources for scanning

### Maintenance
1. **Regular Updates**: Keep TwistCLI and Prisma Cloud policies updated
2. **Policy Review**: Regularly review and update security policies
3. **Monitoring**: Monitor scan results and address issues promptly

## Integration Examples

### Slack Notifications
Add to GitHub Actions workflow:
```yaml
- name: Notify Slack
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: failure
    text: "Security scan failed for ${{ github.repository }}"
```

### Custom Reporting
Extend the bash scripts to generate custom reports:
```bash
# Add custom report generation
generate_custom_report() {
    # Custom reporting logic here
}
```

## Support and Resources

- **Prisma Cloud Documentation**: https://docs.prismacloud.io/
- **TwistCLI Reference**: Available in Prisma Cloud Console
- **GitHub Actions Documentation**: https://docs.github.com/en/actions
- **Jenkins Pipeline Documentation**: https://www.jenkins.io/doc/book/pipeline/

## Contributing

To contribute to this pipeline:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This pipeline configuration is provided as-is for educational and operational purposes. Please review and adapt according to your organization's security policies and requirements.
