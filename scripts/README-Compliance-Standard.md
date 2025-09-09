# Custom Compliance Standard for Prisma Cloud

This PowerShell script creates a custom compliance standard in Prisma Cloud with comprehensive controls, requirements, policy mappings, and assessment criteria.

## 🎯 Features

- **Custom Compliance Framework**: Define your own compliance requirements and controls
- **Policy Mapping**: Map Prisma Cloud policies to compliance controls
- **Cloud Type Filtering**: Support for AWS, Azure, GCP, and other cloud providers
- **Assessment Criteria**: Automated validation rules and remediation guidance
- **API Integration**: Direct interaction with Prisma Cloud API

## 📋 Compliance Controls

The script creates 5 comprehensive security controls:

### CC-001: Data Encryption at Rest
- **Category**: Data Protection
- **Severity**: High
- **Cloud Types**: AWS, Azure, GCP
- **Requirements**:
  - Encryption Key Management
  - Encryption Algorithm Standards

### CC-002: Network Security Groups
- **Category**: Network Security
- **Severity**: High
- **Cloud Types**: AWS, Azure, GCP
- **Requirements**:
  - Network Segmentation

### CC-003: Access Control
- **Category**: Identity & Access Management
- **Severity**: Critical
- **Cloud Types**: AWS, Azure, GCP
- **Requirements**:
  - Multi-Factor Authentication

### CC-004: Logging and Monitoring
- **Category**: Monitoring & Logging
- **Severity**: Medium
- **Cloud Types**: AWS, Azure, GCP
- **Requirements**:
  - Security Event Logging

### CC-005: Vulnerability Management
- **Category**: Vulnerability Management
- **Severity**: High
- **Cloud Types**: AWS, Azure, GCP
- **Requirements**:
  - Regular Vulnerability Scans

## 🚀 Usage

### Prerequisites

1. **PowerShell** (Windows) - for script execution
2. **Prisma Cloud Compute** instance running and accessible
3. **API access** enabled on your Prisma Cloud Compute instance
4. **Valid credentials** for Prisma Cloud Compute console

### Basic Usage

1. **Navigate to scripts directory**:
   ```powershell
   cd scripts
   ```

2. **Run the script**:
   ```powershell
   .\create-compliance-standard.ps1
   ```

3. **Dry run to see what would be created**:
   ```powershell
   .\create-compliance-standard.ps1 -DryRun
   ```

### Advanced Usage

```powershell
# Custom parameters
.\create-compliance-standard.ps1 -ConsoleUrl "https://your-console-url" -Username "your-username" -Password "your-password" -StandardName "My Custom Framework" -DryRun

# Show help
.\create-compliance-standard.ps1 -Help
```

### Parameters

- `-ConsoleUrl`: Prisma Cloud Console URL (default: https://localhost:8083)
- `-Username`: Prisma Cloud username (default: admin)
- `-Password`: Prisma Cloud password (default: admin234)
- `-StandardName`: Name of the compliance standard
- `-StandardDescription`: Description of the compliance standard
- `-Framework`: Framework type (default: CUSTOM)
- `-Version`: Version of the standard (default: 1.0)
- `-DryRun`: Show what would be created without making changes
- `-Help`: Show help message

## 🔧 Policy Mapping

The script maps Prisma Cloud policies to compliance controls:

| Control | Policy | Cloud Type | Description |
|---------|--------|------------|-------------|
| CC-001 | aws-s3-bucket-encryption | AWS | S3 bucket encryption validation |
| CC-002 | aws-security-group-open-port | AWS | Security group port validation |
| CC-003 | aws-iam-mfa-enabled | AWS | MFA requirement validation |
| CC-004 | aws-cloudtrail-enabled | AWS | CloudTrail logging validation |
| CC-005 | aws-guardduty-enabled | AWS | GuardDuty monitoring validation |

## 🌐 Cloud Type Filtering

The script supports filtering policies by cloud type:

- **AWS**: Full support for all controls
- **Azure**: Full support for all controls  
- **GCP**: Full support for all controls
- **Alibaba Cloud**: Framework ready
- **OCI**: Framework ready

## 📊 Assessment Criteria

Each control includes automated assessment criteria:

### Automated Validation Rules
- **Data Encryption**: Checks for encryption at rest, KMS usage, default encryption
- **Network Security**: Validates security group rules, network ACLs
- **Access Control**: Verifies MFA configuration, IAM policies
- **Logging**: Ensures comprehensive logging is enabled
- **Vulnerability Management**: Validates scanning and monitoring tools

### Remediation Guidance
- Specific steps to fix compliance issues
- Best practices for each control
- Cloud provider-specific recommendations

## 🔍 Monitoring and Reporting

After deployment, you can:

1. **View in Prisma Cloud Console**:
   - Navigate to Compliance → Standards
   - Find your custom standard
   - Review control status and violations

2. **Monitor Policy Violations**:
   - Check policy compliance status
   - Review violation details
   - Track remediation progress

3. **Generate Reports**:
   - Export compliance reports
   - Track control effectiveness
   - Monitor cloud type coverage

## 🛠️ Troubleshooting

### Common Issues

1. **Authentication Failed**:
   - Verify console URL and credentials
   - Check network connectivity
   - Ensure API access is enabled

2. **Policy Mapping Errors**:
   - Verify policy IDs exist in Prisma Cloud
   - Check cloud type compatibility
   - Ensure policies are enabled

3. **PowerShell Execution Policy**:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

### Debug Mode

Run with verbose output:
```powershell
.\create-compliance-standard.ps1 -Verbose
```

## 📚 API Endpoints Used

The script interacts with these Prisma Cloud API endpoints:

- `POST /api/v1/authenticate` - Authentication
- `POST /api/v1/compliance` - Create compliance standard
- `POST /api/v1/compliance/{id}/requirements` - Create requirements
- `POST /api/v1/compliance/{id}/policy-mappings` - Map policies
- `POST /api/v1/compliance/{id}/assessment-criteria` - Create criteria

## 🔒 Security Considerations

- **Credentials**: Store securely, use environment variables in production
- **API Access**: Ensure proper RBAC permissions
- **Network**: Use secure connections (HTTPS)
- **Audit**: Monitor API usage and changes

## 📈 Extending the Framework

To add new controls:

1. **Update the script**:
   - Add to `$complianceControls` array
   - Add requirements to `$complianceRequirements`
   - Create policy mappings in `$policyMappings`

2. **Test thoroughly**:
   - Use dry run mode first
   - Validate in Prisma Cloud console
   - Test policy mappings

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This script is for educational and testing purposes. Ensure compliance with your organization's policies and Prisma Cloud licensing terms.
