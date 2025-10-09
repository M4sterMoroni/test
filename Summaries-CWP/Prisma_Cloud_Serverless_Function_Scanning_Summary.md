# Prisma Cloud Serverless Function Scanning Summary

## Overview

This document provides a comprehensive understanding of how to configure serverless function scanning for AWS, Azure, and GCP serverless functions using Prisma Cloud Compute Edition 34, based on the official documentation at [https://docs.prismacloud.io/en/compute-edition/34](https://docs.prismacloud.io/en/compute-edition/34).

## Prisma Cloud Compute Edition 34

**Release Date**: September 2025  
**Documentation**: [https://docs.prismacloud.io/en/compute-edition/34](https://docs.prismacloud.io/en/compute-edition/34)

Prisma Cloud Compute Edition (PCCE) is downloadable, self-hosted software that protects hosts, containers, and serverless infrastructure running in any cloud, including on-premises and fully air-gapped environments.

### Key Features

- **Comprehensive Protection**: Security for hosts, containers, and serverless deployments throughout the software lifecycle
- **Cloud-Native and API-Enabled**: Protection across all workloads regardless of underlying compute technology
- **Self-Hosted Console**: Users must deploy and operate the Console themselves
- **Agentless Scanning**: Option to use agentless scanning for vulnerability and compliance assessments
- **Defender Deployment**: Deploy Defenders to enforce runtime security

## Serverless Function Scanning Overview

Prisma Cloud Compute Edition offers comprehensive serverless function scanning capabilities for AWS Lambda, Azure Functions, and Google Cloud Functions. This ensures that serverless applications are secure throughout their lifecycle.

### Supported Serverless Platforms

#### 1. AWS Lambda
- **Platform**: Amazon Web Services
- **Service**: AWS Lambda
- **Integration**: Native AWS integration
- **Scanning**: Automatic vulnerability and compliance scanning

#### 2. Azure Functions
- **Platform**: Microsoft Azure
- **Service**: Azure Functions
- **Integration**: Azure Active Directory integration
- **Scanning**: Security vulnerability detection and compliance assessment

#### 3. Google Cloud Functions
- **Platform**: Google Cloud Platform
- **Service**: Google Cloud Functions
- **Integration**: Google Cloud IAM integration
- **Scanning**: Vulnerability scanning and compliance monitoring

## Configuration Guide

### AWS Lambda Configuration

#### Prerequisites
- AWS account with Lambda functions deployed
- IAM permissions for Prisma Cloud access
- Prisma Cloud Compute Console access

#### Step-by-Step Configuration

**1. Create IAM Policy**
- Navigate to the IAM service in the AWS Management Console
- Select "Policies" and click "Create Policy"
- Use the JSON tab to define a policy granting necessary permissions for Prisma Cloud to access and scan Lambda functions

**2. Attach Policy to User**
- Assign the newly created policy to an IAM user whose credentials will be used by Prisma Cloud
- Ensure the user has appropriate permissions for Lambda function access

**3. Configure Prisma Cloud**
- In the Prisma Cloud Compute console, navigate to **Defend > Vulnerabilities > Functions > Functions**
- Click "Add the first item" and provide the AWS credentials of the user with the attached policy
- Save the configuration to enable scanning of your AWS Lambda functions

**4. Optional: Scan Only Latest Versions**
- Under **Defend > Vulnerabilities > Functions > Functions > Add scope > Scan only latest versions**
- Enable this option to reduce scanning time by scanning only the latest version of each function

#### Required AWS Permissions
- `lambda:ListFunctions` - List Lambda functions
- `lambda:GetFunction` - Get function details
- `lambda:GetFunctionConfiguration` - Get function configuration
- `lambda:ListVersionsByFunction` - List function versions
- `lambda:GetLayerVersion` - Access function layers

### Azure Functions Configuration

#### Prerequisites
- Azure subscription with Function Apps deployed
- Azure Active Directory service principal
- Prisma Cloud Compute Console access

#### Step-by-Step Configuration

**1. Set Up Service Principal**
- In the Azure portal, create a Service Principal with a role that has sufficient permissions to read and manage Azure Functions
- Assign appropriate Azure RBAC roles (e.g., Reader, Contributor)

**2. Configure Prisma Cloud**
- In the Prisma Cloud Compute console, go to **Defend > Vulnerabilities > Functions > Functions**
- Click "Add the first item" and enter the Service Principal credentials
- Save the configuration to initiate scanning of your Azure Functions

**3. Register Function Apps**
- Register your Azure Function Apps with Prisma Cloud to enable scanning
- Configure scanning scope and frequency

#### Required Azure Permissions
- `Microsoft.Web/sites/read` - Read Function App details
- `Microsoft.Web/sites/list` - List Function Apps
- `Microsoft.Web/sites/config/read` - Read Function App configuration
- `Microsoft.Web/sites/functions/read` - Read function details

### Google Cloud Functions Configuration

#### Prerequisites
- Google Cloud Platform project with Cloud Functions deployed
- Google Cloud service account
- Prisma Cloud Compute Console access

#### Step-by-Step Configuration

**1. Create Service Account**
- In the Google Cloud Console, create a Service Account with roles that grant read access to Cloud Functions
- Assign appropriate IAM roles (e.g., Cloud Functions Viewer, Cloud Functions Admin)

**2. Generate and Download Key**
- Generate a JSON key for the Service Account and securely store it
- Ensure the key has the necessary permissions for Cloud Functions access

**3. Configure Prisma Cloud**
- In the Prisma Cloud Compute console, navigate to **Defend > Vulnerabilities > Functions > Functions**
- Click "Add the first item" and upload the JSON key file
- Save the configuration to enable scanning of your Google Cloud Functions

**4. Configure Function Scanning**
- Set up scanning scope and frequency for your Cloud Functions
- Configure vulnerability and compliance policies

#### Required GCP Permissions
- `cloudfunctions.functions.list` - List Cloud Functions
- `cloudfunctions.functions.get` - Get function details
- `cloudfunctions.functions.getIamPolicy` - Get function IAM policy
- `cloudfunctions.operations.get` - Get operation details

## Scanning Features

### Vulnerability Scanning
- **Code Analysis**: Deep scanning of function code for known vulnerabilities
- **Dependency Scanning**: Analysis of function dependencies and libraries
- **Configuration Scanning**: Review of function configuration settings
- **Runtime Scanning**: Monitoring of function execution behavior

### Compliance Assessment
- **Industry Standards**: CIS, NIST, PCI DSS compliance checks
- **Cloud Provider Standards**: AWS Well-Architected, Azure Security Center, GCP Security Command Center
- **Custom Policies**: Organization-specific compliance requirements
- **Continuous Monitoring**: Ongoing compliance assessment

### Security Policies
- **Function Policies**: Define allowed/disallowed functions based on vulnerabilities
- **Scanning Policies**: Configure scanning frequency and depth
- **Enforcement**: Block deployment of non-compliant functions
- **Alerting**: Real-time notifications for security issues

## Best Practices

### Security Configuration
- **Principle of Least Privilege**: Grant only necessary permissions to Prisma Cloud
- **Regular Permission Review**: Periodically review and update permissions
- **Secure Credential Storage**: Use secure methods for storing cloud provider credentials
- **Multi-Factor Authentication**: Enable MFA for cloud provider accounts

### Scanning Strategy
- **Comprehensive Coverage**: Scan all functions before deployment
- **Regular Updates**: Update vulnerability databases regularly
- **Policy Enforcement**: Implement strict policies for vulnerable functions
- **Monitoring**: Continuous monitoring of scan results

### Integration
- **CI/CD Integration**: Integrate scanning into deployment pipelines
- **Automated Remediation**: Automate vulnerability remediation where possible
- **Reporting**: Regular security and compliance reporting
- **Training**: Train teams on secure serverless practices

## Performance Optimization

### Scanning Performance
- **Console Resources**: Ensure the Prisma Cloud Console has adequate resources
- **Scanning Scope**: Configure scanning scope to optimize performance
- **Latest Versions**: Use "Scan only latest versions" option for AWS Lambda to reduce scanning time
- **Scheduled Scanning**: Use scheduled scanning to avoid peak usage times

### Resource Management
- **Memory Allocation**: Allocate sufficient memory for scanning operations
- **CPU Resources**: Ensure adequate CPU resources for scanning processes
- **Storage**: Provide sufficient storage for scan results and reports
- **Network**: Ensure proper network connectivity to cloud providers

## Troubleshooting

### Common Issues
- **Authentication Failures**: Verify credentials and permissions
- **Network Connectivity**: Check network access to cloud providers
- **Scan Failures**: Review scan logs and cloud provider compatibility
- **Performance Issues**: Optimize scanning schedules and resources

### AWS Lambda Issues
- **IAM Permission Errors**: Verify IAM policy permissions
- **Function Access**: Ensure functions are accessible and not deleted
- **Region Configuration**: Verify correct AWS region configuration

### Azure Functions Issues
- **Service Principal Errors**: Verify service principal permissions
- **Function App Access**: Ensure Function Apps are accessible
- **Subscription Access**: Verify subscription-level permissions

### Google Cloud Functions Issues
- **Service Account Errors**: Verify service account permissions
- **Project Access**: Ensure project-level permissions
- **API Enablement**: Verify required APIs are enabled

## Support Resources

- **Documentation**: [https://docs.prismacloud.io/en/compute-edition/34](https://docs.prismacloud.io/en/compute-edition/34)
- **Configuration Guides**: Available for AWS, GCP, and Azure integration
- **Community Support**: Palo Alto Networks LIVE community
- **Knowledge Base**: Comprehensive troubleshooting articles

## References

- **Prisma Cloud Compute Edition 34 Documentation**: [https://docs.prismacloud.io/en/compute-edition/34](https://docs.prismacloud.io/en/compute-edition/34)
- **Palo Alto Networks Knowledge Base**: [https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA14u000000oMrbCAE](https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA14u000000oMrbCAE)
- **Palo Alto Networks Resources**: [https://www.paloaltonetworks.com/resources/datasheets/prisma-cloud-compute-edition-aag](https://www.paloaltonetworks.com/resources/datasheets/prisma-cloud-compute-edition-aag)
- **Community Support**: [https://live.paloaltonetworks.com/t5/prisma-cloud-articles/tkb-p/Prisma_Cloud_Articles/label-name/prisma%20cloud%20compute%20edition](https://live.paloaltonetworks.com/t5/prisma-cloud-articles/tkb-p/Prisma_Cloud_Articles/label-name/prisma%20cloud%20compute%20edition)

---

*This summary is based on the official Prisma Cloud Compute Edition 34 documentation and general knowledge of serverless function scanning capabilities. For the most current and detailed information, please refer to the official documentation.*
