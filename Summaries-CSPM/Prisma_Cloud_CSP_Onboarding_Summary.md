# Prisma Cloud CSP Onboarding Summary

## Overview

This document provides a comprehensive understanding of the process for onboarding the main Cloud Service Providers (AWS, Azure, GCP) to Prisma Cloud Enterprise Edition, based on the official documentation at [https://docs.prismacloud.io/en/enterprise-edition](https://docs.prismacloud.io/en/enterprise-edition).

## Prisma Cloud Enterprise Edition

**Documentation**: [https://docs.prismacloud.io/en/enterprise-edition](https://docs.prismacloud.io/en/enterprise-edition)

Prisma Cloud Enterprise Edition is a Cloud Native Application Protection Platform (CNAPP) that protects applications from code to cloud, reduces risks, and prevents breaches.

### Darwin Release

The current release (Darwin) features:
- **Redesigned UI**: Main navigation aligned along the top of the window
- **Enhanced Security Capabilities**: Improved detection and response features
- **Unified Documentation**: Previously separate admin guides rolled into a single holistic collection
  - Compute SaaS content: **Content Collections > Runtime Security**
  - Application Security content (Bridgecrew/Cider): **Content Collections > Application Security**

### Key Platform Capabilities

#### Cloud Security Posture Management (CSPM)
- **Multi-Cloud Visibility**: Unified view across AWS, Azure, GCP, and other cloud providers
- **Misconfiguration Detection**: Identifies security and compliance misconfigurations
- **Compliance Monitoring**: Continuous compliance checks against industry standards
- **Policy Enforcement**: Automated policy enforcement and remediation

#### Cloud Workload Protection Platform (CWPP)
- **Container Security**: Protection for containerized workloads
- **Host Security**: Security for virtual machines and bare metal servers
- **Serverless Security**: Protection for serverless functions

#### Cloud Infrastructure Entitlement Management (CIEM)
- **Identity and Access Management**: Visibility into permissions and entitlements
- **Least Privilege Enforcement**: Identifies and remediates excessive permissions
- **IAM Risk Assessment**: Identifies risky identities and access patterns

## Cloud Account Onboarding Overview

### Onboarding Purpose

Onboarding cloud accounts to Prisma Cloud enables:
- **Security Posture Assessment**: Continuous monitoring of cloud resources
- **Compliance Monitoring**: Automated compliance checks against regulatory standards
- **Threat Detection**: Real-time detection of security threats and anomalies
- **Visibility**: Comprehensive visibility into cloud resources and configurations
- **Policy Enforcement**: Automated remediation of security and compliance violations

### Onboarding Prerequisites

#### General Prerequisites
- **Prisma Cloud Account**: Active Prisma Cloud Enterprise Edition subscription
- **Administrative Access**: Administrative permissions in Prisma Cloud console
- **Cloud Account Access**: Administrative access to cloud accounts being onboarded
- **Network Connectivity**: Connectivity between Prisma Cloud and cloud provider APIs

#### Permission Requirements
- **AWS**: IAM permissions to create roles and policies
- **Azure**: Permissions to create service principals and assign roles
- **GCP**: Permissions to create service accounts and assign IAM roles

## AWS Account Onboarding

### AWS Onboarding Overview

AWS account onboarding connects AWS accounts to Prisma Cloud for security monitoring, compliance assessment, and threat detection.

### AWS Account Types

#### Individual AWS Account
- **Description**: Single AWS account onboarding
- **Use Case**: Small deployments or testing
- **Authentication**: IAM Role with cross-account access

#### AWS Organization
- **Description**: Onboard multiple AWS accounts under an AWS Organization
- **Use Case**: Enterprise deployments with multiple accounts
- **Authentication**: IAM Role in management account with cross-account access

#### AWS Account Groups
- **Description**: Logical grouping of AWS accounts for policy management
- **Use Case**: Different business units or environments (dev, staging, prod)

### AWS Authentication Methods

#### IAM Role-Based Authentication (Recommended)
- **Method**: Cross-account IAM role with trust relationship
- **Security**: More secure, uses temporary credentials
- **Setup**: CloudFormation template or manual IAM role creation
- **Permissions**: Read-only access to AWS APIs for monitoring

#### Access Key-Based Authentication (Legacy)
- **Method**: AWS access key and secret key
- **Security**: Less secure, uses static credentials
- **Setup**: Manual creation of IAM user with access keys
- **Recommendation**: Not recommended for production use

### AWS Onboarding Process

#### Step 1: Prepare AWS Account
1. **Log in to AWS Console**: Access the AWS account to be onboarded
2. **Verify Permissions**: Ensure you have IAM administrative permissions
3. **Document Account Details**: Record AWS account ID and account name
4. **Plan Account Groups**: Determine how accounts will be organized

#### Step 2: Configure Prisma Cloud
1. **Log in to Prisma Cloud Console**: Access Prisma Cloud Enterprise Edition
2. **Navigate to Cloud Accounts**: Go to **Settings > Cloud Accounts**
3. **Select Add Cloud Account**: Choose AWS as the cloud provider
4. **Choose Onboarding Method**: Select account type (Individual, Organization, etc.)

#### Step 3: CloudFormation Stack Deployment

##### CloudFormation Template Method
```yaml
# CloudFormation template creates:
# - IAM Role for Prisma Cloud
# - Trust relationship with Prisma Cloud
# - Managed policies for read-only access
# - Optional: SNS topics for real-time monitoring
# - Optional: EventBridge rules for event ingestion
```

**Deployment Steps:**
1. **Download CFT**: Prisma Cloud provides CloudFormation template
2. **Deploy Stack**: 
   - Navigate to AWS CloudFormation console
   - Create new stack
   - Upload Prisma Cloud CFT
   - Provide stack parameters (Prisma Cloud account ID, external ID)
3. **Review Permissions**: Review IAM role and policy permissions
4. **Create Stack**: Execute CloudFormation stack creation
5. **Copy Role ARN**: Copy the IAM role ARN from stack outputs

##### Manual IAM Role Creation
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<PRISMA_CLOUD_ACCOUNT_ID>:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "<EXTERNAL_ID>"
        }
      }
    }
  ]
}
```

**Manual Steps:**
1. **Create IAM Role**: Create new IAM role in AWS
2. **Configure Trust Policy**: Add Prisma Cloud as trusted entity
3. **Attach Policies**: Attach required managed policies
4. **Configure External ID**: Set external ID for additional security
5. **Copy Role ARN**: Record the IAM role ARN

#### Step 4: Enable Security Capabilities

##### Configuration Options
- **Misconfigurations**: Enable cloud security posture monitoring
- **Threat Detection**: Enable runtime threat detection
- **Data Security**: Enable data classification and DLP
- **Identity Security**: Enable CIEM for IAM analysis
- **Serverless Function Scanning**: Enable Lambda function scanning
- **Agentless Scanning**: Enable agentless workload scanning

##### Agentless Scanning Configuration
```bash
# Agentless scanning requires additional permissions:
# - EC2 snapshot creation and access
# - EBS volume access
# - KMS key access (if using encrypted volumes)
# - VPC and subnet access for scanner deployment
```

**Agentless Setup:**
1. **Enable Agentless Scanning**: Toggle on during onboarding
2. **Deploy Scanner**: Prisma Cloud deploys scanner instances
3. **Configure Scanning Scope**: Select regions and resources to scan
4. **Set Scan Schedule**: Configure scan frequency and timing

#### Step 5: Complete Onboarding
1. **Validate Role ARN**: Enter IAM role ARN in Prisma Cloud
2. **Test Connection**: Prisma Cloud validates connection to AWS
3. **Select Account Groups**: Assign account to account groups
4. **Review Configuration**: Verify all settings
5. **Save and Onboard**: Complete the onboarding process

### AWS Organization Onboarding

#### Organization Onboarding Benefits
- **Centralized Management**: Onboard all member accounts from one location
- **Automatic Discovery**: Automatically discover new member accounts
- **Consistent Policies**: Apply consistent security policies across accounts
- **StackSet Deployment**: Use CloudFormation StackSets for automation

#### Organization Onboarding Process
1. **Access Management Account**: Log in to AWS Organization management account
2. **Deploy StackSet**: Deploy CloudFormation StackSet to all member accounts
3. **Configure Prisma Cloud**: Select AWS Organization onboarding option
4. **Provide Management Account Role**: Enter management account role ARN
5. **Enable Auto-Discovery**: Enable automatic discovery of new member accounts
6. **Set Default Configuration**: Configure default settings for new accounts

#### StackSet Configuration
```yaml
# StackSet creates IAM roles in all member accounts
# Parameters:
# - Prisma Cloud Account ID
# - External ID
# - Target OUs (Organizational Units)
# - Deployment regions
```

**StackSet Benefits:**
- **Automation**: Automatically deploys to all member accounts
- **Consistency**: Ensures consistent IAM role configuration
- **Scalability**: Easily scales to hundreds of accounts
- **Updates**: Centralized updates to all member accounts

### AWS Monitoring Capabilities

#### Real-Time Monitoring
- **CloudTrail Integration**: Ingests CloudTrail events for activity monitoring
- **EventBridge Integration**: Real-time event ingestion via EventBridge
- **VPC Flow Logs**: Network traffic monitoring and analysis
- **GuardDuty Integration**: Integration with AWS GuardDuty findings

#### Resource Inventory
- **Asset Discovery**: Automatic discovery of AWS resources
- **Configuration Tracking**: Tracks resource configuration changes
- **Relationship Mapping**: Maps relationships between resources
- **Tag Management**: Monitors and enforces tagging policies

## Azure Subscription Onboarding

### Azure Onboarding Overview

Azure subscription onboarding connects Azure subscriptions to Prisma Cloud for security monitoring, compliance assessment, and threat detection.

### Azure Account Types

#### Individual Subscription
- **Description**: Single Azure subscription onboarding
- **Use Case**: Small deployments or testing
- **Authentication**: Service Principal with subscription-level access

#### Tenant (Management Group)
- **Description**: Onboard multiple subscriptions under Azure tenant
- **Use Case**: Enterprise deployments with multiple subscriptions
- **Authentication**: Service Principal with tenant-level access

#### Subscription Groups
- **Description**: Logical grouping of subscriptions for policy management
- **Use Case**: Different business units or environments

### Azure Authentication Methods

#### Service Principal-Based Authentication (Recommended)
- **Method**: Azure AD application with service principal
- **Security**: Secure, uses application credentials
- **Setup**: Azure AD app registration and role assignment
- **Permissions**: Reader role or custom role with required permissions

#### Client Secret Authentication
- **Method**: Service principal with client secret
- **Security**: Secure with secret rotation
- **Credential Type**: Client ID and client secret

#### Certificate-Based Authentication
- **Method**: Service principal with certificate
- **Security**: Most secure option
- **Credential Type**: Client ID and certificate

### Azure Onboarding Process

#### Step 1: Prepare Azure Subscription
1. **Log in to Azure Portal**: Access the Azure subscription to be onboarded
2. **Verify Permissions**: Ensure you have Global Administrator or Application Administrator role
3. **Document Subscription Details**: Record Subscription ID, Tenant ID, and Directory ID
4. **Plan Subscription Groups**: Determine how subscriptions will be organized

#### Step 2: Create Azure AD Application

##### Application Registration
```powershell
# Azure PowerShell commands to create service principal
# Create Azure AD application
New-AzADApplication -DisplayName "PrismaCloudApp"

# Create service principal
New-AzADServicePrincipal -ApplicationId <APP_ID>

# Create client secret
$secret = New-AzADAppCredential -ApplicationId <APP_ID>
```

**Registration Steps:**
1. **Navigate to Azure AD**: Go to **Azure Active Directory > App registrations**
2. **New Registration**: Click **New registration**
3. **Application Name**: Enter name (e.g., "Prisma Cloud Service Principal")
4. **Supported Account Types**: Select **Accounts in this organizational directory only**
5. **Register Application**: Complete registration

##### Client Secret Creation
1. **Navigate to Certificates & Secrets**: Go to app registration
2. **New Client Secret**: Click **New client secret**
3. **Add Description**: Enter description (e.g., "Prisma Cloud Access")
4. **Set Expiration**: Select expiration period (recommended: 24 months)
5. **Copy Secret Value**: **Important**: Copy secret value immediately (not shown again)

#### Step 3: Assign Permissions to Service Principal

##### Azure RBAC Role Assignment
```bash
# Azure CLI command to assign Reader role
az role assignment create \
  --assignee <SERVICE_PRINCIPAL_ID> \
  --role "Reader" \
  --scope /subscriptions/<SUBSCRIPTION_ID>
```

**Permission Assignment Steps:**
1. **Navigate to Subscriptions**: Go to **Subscriptions** in Azure Portal
2. **Select Subscription**: Choose subscription to onboard
3. **Access Control (IAM)**: Click **Access Control (IAM)**
4. **Add Role Assignment**: Click **Add > Add role assignment**
5. **Select Role**: Choose **Reader** role (minimum required)
6. **Assign to Service Principal**: Search and select the service principal
7. **Review and Assign**: Complete role assignment

##### Required Permissions
```json
{
  "permissions": [
    {
      "actions": [
        "*/read",
        "Microsoft.Security/*/read",
        "Microsoft.Security/pricings/read",
        "Microsoft.PolicyInsights/policyStates/queryResults/action"
      ],
      "notActions": [],
      "dataActions": [],
      "notDataActions": []
    }
  ]
}
```

#### Step 4: Configure API Permissions

##### Microsoft Graph API Permissions
1. **Navigate to API Permissions**: Go to app registration
2. **Add Permission**: Click **Add a permission**
3. **Select Microsoft Graph**: Choose **Microsoft Graph**
4. **Application Permissions**: Select **Application permissions**
5. **Add Required Permissions**:
   - `Directory.Read.All` - Read directory data
   - `Policy.Read.All` - Read all policies
   - `SecurityEvents.Read.All` - Read security events
6. **Grant Admin Consent**: Click **Grant admin consent** for tenant

#### Step 5: Configure Prisma Cloud
1. **Log in to Prisma Cloud Console**: Access Prisma Cloud Enterprise Edition
2. **Navigate to Cloud Accounts**: Go to **Settings > Cloud Accounts**
3. **Select Add Cloud Account**: Choose **Azure** as the cloud provider
4. **Choose Onboarding Method**: Select subscription type (Individual or Tenant)

#### Step 6: Enter Azure Credentials
1. **Directory (Tenant) ID**: Enter Azure AD tenant ID
2. **Subscription ID**: Enter Azure subscription ID
3. **Application (Client) ID**: Enter service principal application ID
4. **Client Secret**: Enter the client secret value
5. **Account Name**: Provide a descriptive name for the account

#### Step 7: Enable Security Capabilities

##### Configuration Options
- **Misconfigurations**: Enable cloud security posture monitoring
- **Identity Security**: Enable CIEM for Azure AD analysis
- **Data Security**: Enable data classification and DLP
- **Threat Detection**: Enable runtime threat detection
- **Agentless Scanning**: Enable agentless VM scanning
- **Defender for Cloud Integration**: Integrate with Microsoft Defender for Cloud

##### Agentless Scanning Configuration
```bash
# Agentless scanning for Azure requires:
# - Snapshot creation permissions
# - Disk access permissions
# - Virtual network access for scanner deployment
# - Resource group permissions
```

**Azure Agentless Setup:**
1. **Enable Agentless Scanning**: Toggle on during onboarding
2. **Grant Additional Permissions**: Assign required permissions for snapshot access
3. **Configure Scanner Deployment**: Select regions for scanner deployment
4. **Set Scan Schedule**: Configure scan frequency

#### Step 8: Complete Onboarding
1. **Test Connection**: Prisma Cloud validates connection to Azure
2. **Select Account Groups**: Assign subscription to account groups
3. **Review Configuration**: Verify all settings
4. **Save and Onboard**: Complete the onboarding process

### Azure Tenant Onboarding

#### Tenant Onboarding Benefits
- **Multi-Subscription Coverage**: Onboard all subscriptions from tenant
- **Automatic Discovery**: Automatically discover new subscriptions
- **Centralized Management**: Manage all subscriptions from one configuration
- **Consistent Policies**: Apply policies across all subscriptions

#### Tenant Onboarding Process
1. **Create Tenant-Level Service Principal**: Register app in Azure AD
2. **Assign Tenant-Level Permissions**: Grant Reader role at tenant level
3. **Configure Prisma Cloud**: Select Azure Tenant onboarding option
4. **Provide Tenant Credentials**: Enter tenant ID and service principal details
5. **Enable Auto-Discovery**: Automatically discover all subscriptions
6. **Set Default Configuration**: Configure default settings for subscriptions

### Azure Monitoring Capabilities

#### Real-Time Monitoring
- **Activity Log Integration**: Ingests Azure Activity Logs
- **Security Center Integration**: Integrates with Microsoft Defender for Cloud
- **Network Watcher**: Network traffic monitoring via NSG flow logs
- **Azure Policy Integration**: Monitors Azure Policy compliance

#### Resource Inventory
- **Resource Discovery**: Automatic discovery of Azure resources
- **Configuration Tracking**: Tracks resource configuration changes
- **Relationship Mapping**: Maps resource relationships and dependencies
- **Tag Management**: Enforces tagging standards

## GCP Project Onboarding

### GCP Onboarding Overview

GCP project onboarding connects Google Cloud Platform projects to Prisma Cloud for security monitoring, compliance assessment, and threat detection.

### GCP Account Types

#### Individual Project
- **Description**: Single GCP project onboarding
- **Use Case**: Small deployments or testing
- **Authentication**: Service account with project-level access

#### Organization
- **Description**: Onboard multiple projects under GCP organization
- **Use Case**: Enterprise deployments with multiple projects
- **Authentication**: Service account with organization-level access

#### Folder
- **Description**: Onboard projects within a specific folder
- **Use Case**: Department or team-level deployments

### GCP Authentication Methods

#### Service Account-Based Authentication (Recommended)
- **Method**: GCP service account with JSON key
- **Security**: Secure, uses service account credentials
- **Setup**: Create service account and download JSON key
- **Permissions**: Viewer role or custom role with required permissions

#### Workload Identity Federation (Advanced)
- **Method**: Federated identity without service account keys
- **Security**: Most secure, no static credentials
- **Setup**: Configure workload identity pool and provider
- **Use Case**: Advanced deployments requiring keyless authentication

### GCP Onboarding Process

#### Step 1: Prepare GCP Project
1. **Log in to GCP Console**: Access the GCP project to be onboarded
2. **Verify Permissions**: Ensure you have Project Editor or Owner role
3. **Document Project Details**: Record Project ID, Project Number, and Organization ID
4. **Enable Required APIs**: Enable Cloud Asset API, Security Command Center API

#### Step 2: Enable Required APIs

##### Enable APIs via Console
```bash
# Required APIs for Prisma Cloud integration:
# - Cloud Asset API (cloudasset.googleapis.com)
# - Cloud Resource Manager API (cloudresourcemanager.googleapis.com)
# - Compute Engine API (compute.googleapis.com)
# - Kubernetes Engine API (container.googleapis.com)
# - Security Command Center API (securitycenter.googleapis.com)
# - IAM API (iam.googleapis.com)
```

**API Enablement Steps:**
1. **Navigate to APIs & Services**: Go to **APIs & Services > Library**
2. **Search for APIs**: Search for required APIs
3. **Enable Each API**: Click **Enable** for each required API
4. **Verify Enablement**: Confirm all APIs are enabled

##### Enable APIs via gcloud CLI
```bash
# Enable all required APIs
gcloud services enable cloudasset.googleapis.com \
  cloudresourcemanager.googleapis.com \
  compute.googleapis.com \
  container.googleapis.com \
  securitycenter.googleapis.com \
  iam.googleapis.com
```

#### Step 3: Create Service Account

##### Service Account Creation via Console
1. **Navigate to IAM & Admin**: Go to **IAM & Admin > Service Accounts**
2. **Create Service Account**: Click **Create Service Account**
3. **Service Account Name**: Enter name (e.g., "prisma-cloud-service-account")
4. **Service Account ID**: Auto-generated (e.g., "prisma-cloud-service-account@project-id.iam.gserviceaccount.com")
5. **Description**: Enter description (e.g., "Prisma Cloud Integration")

##### Service Account Creation via gcloud CLI
```bash
# Create service account
gcloud iam service-accounts create prisma-cloud-sa \
  --display-name="Prisma Cloud Service Account" \
  --description="Service account for Prisma Cloud integration"
```

#### Step 4: Assign Permissions to Service Account

##### IAM Role Assignment
```bash
# Assign Viewer role (minimum required)
gcloud projects add-iam-policy-binding <PROJECT_ID> \
  --member="serviceAccount:prisma-cloud-sa@<PROJECT_ID>.iam.gserviceaccount.com" \
  --role="roles/viewer"

# Assign Security Reviewer role (for security findings)
gcloud projects add-iam-policy-binding <PROJECT_ID> \
  --member="serviceAccount:prisma-cloud-sa@<PROJECT_ID>.iam.gserviceaccount.com" \
  --role="roles/iam.securityReviewer"
```

**Required Roles:**
- **roles/viewer**: Read access to all resources
- **roles/iam.securityReviewer**: Access to security-related configurations
- **roles/compute.networkViewer**: Network configuration visibility (optional)
- **roles/browser**: Project and folder visibility (for organization onboarding)

##### Custom Role for Minimal Permissions
```json
{
  "title": "Prisma Cloud Read Only",
  "description": "Minimal permissions for Prisma Cloud integration",
  "stage": "GA",
  "includedPermissions": [
    "cloudasset.assets.listResource",
    "cloudasset.assets.searchAllResources",
    "compute.instances.list",
    "compute.networks.list",
    "container.clusters.list",
    "iam.serviceAccountKeys.list",
    "resourcemanager.projects.get",
    "securitycenter.findings.list"
  ]
}
```

#### Step 5: Create and Download Service Account Key

##### Key Creation via Console
1. **Navigate to Service Account**: Go to service account details
2. **Add Key**: Click **Keys > Add Key > Create new key**
3. **Key Type**: Select **JSON**
4. **Create**: Click **Create** to download JSON key file
5. **Secure Key**: Store JSON key securely (required for Prisma Cloud)

##### Key Creation via gcloud CLI
```bash
# Create JSON key file
gcloud iam service-accounts keys create prisma-cloud-key.json \
  --iam-account=prisma-cloud-sa@<PROJECT_ID>.iam.gserviceaccount.com
```

**Key Security Best Practices:**
- Store keys securely (encrypted storage, secret management)
- Rotate keys periodically (recommended: every 90 days)
- Limit key access to authorized personnel
- Monitor key usage via audit logs

#### Step 6: Configure Prisma Cloud
1. **Log in to Prisma Cloud Console**: Access Prisma Cloud Enterprise Edition
2. **Navigate to Cloud Accounts**: Go to **Settings > Cloud Accounts**
3. **Select Add Cloud Account**: Choose **GCP** as the cloud provider
4. **Choose Onboarding Method**: Select project type (Individual, Organization, or Folder)

#### Step 7: Upload Service Account Key
1. **Account Name**: Provide a descriptive name for the account
2. **Upload JSON Key**: Upload the service account JSON key file
3. **Verify Project ID**: Prisma Cloud extracts project ID from key
4. **Verify Permissions**: Prisma Cloud validates service account permissions

#### Step 8: Enable Security Capabilities

##### Configuration Options
- **Misconfigurations**: Enable cloud security posture monitoring
- **Data Security**: Enable data classification and DLP
- **Identity Security**: Enable CIEM for GCP IAM analysis
- **Threat Detection**: Enable runtime threat detection
- **Agentless Scanning**: Enable agentless VM scanning
- **Flow Log Analysis**: Enable VPC flow log analysis

##### Agentless Scanning Configuration
```bash
# Agentless scanning for GCP requires:
# - Compute Engine API enabled
# - Snapshot creation permissions
# - Disk access permissions
# - VPC and subnet access for scanner deployment
```

**GCP Agentless Setup:**
1. **Enable Agentless Scanning**: Toggle on during onboarding
2. **Grant Snapshot Permissions**: Ensure service account has snapshot permissions
3. **Configure Scanner Deployment**: Select regions for scanner deployment
4. **Set Scan Schedule**: Configure scan frequency

#### Step 9: Complete Onboarding
1. **Test Connection**: Prisma Cloud validates connection to GCP
2. **Select Account Groups**: Assign project to account groups
3. **Review Configuration**: Verify all settings
4. **Save and Onboard**: Complete the onboarding process

### GCP Organization Onboarding

#### Organization Onboarding Benefits
- **Multi-Project Coverage**: Onboard all projects in organization
- **Automatic Discovery**: Automatically discover new projects
- **Hierarchy Visibility**: Maintain GCP organizational hierarchy
- **Centralized Management**: Manage all projects from one configuration

#### Organization Onboarding Process
1. **Create Organization-Level Service Account**: Create in a central project
2. **Assign Organization-Level Permissions**: Grant roles at organization level
3. **Grant Browser Role**: Required for project discovery
4. **Configure Prisma Cloud**: Select GCP Organization onboarding option
5. **Upload Service Account Key**: Provide JSON key with organization access
6. **Enable Auto-Discovery**: Automatically discover all projects
7. **Set Exclusions**: Optionally exclude specific projects or folders

##### Organization-Level Permissions
```bash
# Assign Viewer role at organization level
gcloud organizations add-iam-policy-binding <ORGANIZATION_ID> \
  --member="serviceAccount:prisma-cloud-sa@<PROJECT_ID>.iam.gserviceaccount.com" \
  --role="roles/viewer"

# Assign Browser role for project discovery
gcloud organizations add-iam-policy-binding <ORGANIZATION_ID> \
  --member="serviceAccount:prisma-cloud-sa@<PROJECT_ID>.iam.gserviceaccount.com" \
  --role="roles/browser"
```

### GCP Monitoring Capabilities

#### Real-Time Monitoring
- **Cloud Logging Integration**: Ingests GCP Cloud Logging events
- **Security Command Center**: Integrates with GCP Security Command Center
- **VPC Flow Logs**: Network traffic monitoring and analysis
- **Cloud Audit Logs**: Monitors administrative and data access activities

#### Resource Inventory
- **Asset Discovery**: Automatic discovery of GCP resources
- **Configuration Tracking**: Tracks resource configuration changes via Cloud Asset Inventory
- **Relationship Mapping**: Maps relationships between resources
- **Label Management**: Enforces labeling standards

## Post-Onboarding Configuration

### Account Groups and Hierarchy

#### Account Group Management
- **Purpose**: Organize cloud accounts for policy management
- **Hierarchy**: Create groups based on business units, environments, or compliance requirements
- **Assignment**: Assign accounts to one or more account groups
- **Policy Scoping**: Scope policies to specific account groups

#### Account Group Best Practices
```yaml
# Example account group structure:
Account Groups:
  - Production:
      - AWS-Prod
      - Azure-Prod
      - GCP-Prod
  - Development:
      - AWS-Dev
      - Azure-Dev
      - GCP-Dev
  - Compliance:
      - PCI-DSS-Accounts
      - HIPAA-Accounts
      - SOC2-Accounts
```

### Policy Configuration

#### Default Policies
- **Automatic Enablement**: Default policies enabled upon onboarding
- **Compliance Frameworks**: Pre-built policies for regulatory compliance
- **Custom Policies**: Create custom policies for specific requirements
- **Alert Rules**: Configure alert rules for policy violations

#### Policy Types
- **Config Policies**: Monitor cloud resource configurations
- **Audit Event Policies**: Monitor cloud activity logs
- **Network Policies**: Monitor network traffic and connectivity
- **IAM Policies**: Monitor identity and access configurations
- **Data Policies**: Monitor data security and privacy

### Alert Configuration

#### Alert Channels
- **Email Notifications**: Send alerts via email
- **SIEM Integration**: Forward alerts to SIEM platforms (Splunk, QRadar, etc.)
- **Ticketing Integration**: Create tickets in JIRA, ServiceNow, etc.
- **Webhooks**: Send alerts to custom endpoints
- **Slack/Teams**: Real-time notifications to collaboration platforms

#### Alert Rules
```yaml
# Example alert rule configuration:
Alert Rule:
  Name: "High Severity Misconfigurations"
  Policies:
    - "AWS S3 Bucket Publicly Accessible"
    - "Azure Storage Account Publicly Accessible"
    - "GCP Storage Bucket Publicly Accessible"
  Account Groups:
    - Production
  Alert Channels:
    - Email: security-team@company.com
    - Slack: #security-alerts
```

### Compliance Monitoring

#### Compliance Standards
- **Regulatory Standards**: PCI DSS, HIPAA, GDPR, SOC 2, ISO 27001
- **Industry Benchmarks**: CIS Benchmarks, NIST, FedRAMP
- **Custom Frameworks**: Create custom compliance frameworks

#### Compliance Dashboards
- **Overall Compliance Score**: Visual representation of compliance posture
- **Compliance by Standard**: Breakdown by compliance framework
- **Compliance by Account**: Compliance status per cloud account
- **Compliance Trends**: Historical compliance trends

### Remediation

#### Manual Remediation
- **Remediation Steps**: Guided remediation steps for each policy violation
- **Resource Details**: Link to cloud resource for direct remediation
- **Documentation**: Links to relevant documentation

#### Automated Remediation
- **Auto-Remediation Policies**: Automatically remediate specific violations
- **Approval Workflows**: Require approval before remediation
- **Remediation Logs**: Audit trail of all remediation actions
- **Rollback Capability**: Ability to rollback remediation actions

## Troubleshooting

### Common Onboarding Issues

#### AWS Onboarding Issues

**Issue: IAM Role Trust Relationship Error**
```bash
# Error: "Prisma Cloud cannot assume the IAM role"
# Resolution:
# 1. Verify external ID matches
# 2. Check trust policy includes Prisma Cloud account
# 3. Verify role ARN is correct
# 4. Check IAM role permissions
```

**Issue: CloudFormation Stack Creation Failed**
```bash
# Error: "CloudFormation stack creation failed"
# Resolution:
# 1. Check IAM permissions for CloudFormation
# 2. Review stack events for specific error
# 3. Verify account limits not exceeded
# 4. Check for naming conflicts
```

**Issue: Incomplete Resource Discovery**
```bash
# Error: "Some AWS resources not discovered"
# Resolution:
# 1. Verify IAM role has required read permissions
# 2. Check if services are enabled in AWS regions
# 3. Verify API throttling limits not hit
# 4. Wait for initial scan to complete (can take 1-2 hours)
```

#### Azure Onboarding Issues

**Issue: Service Principal Authentication Failed**
```bash
# Error: "Unable to authenticate with service principal"
# Resolution:
# 1. Verify client ID and tenant ID are correct
# 2. Check client secret hasn't expired
# 3. Verify client secret was copied correctly
# 4. Check service principal is not disabled
```

**Issue: Insufficient Permissions**
```bash
# Error: "Service principal lacks required permissions"
# Resolution:
# 1. Verify Reader role assigned at subscription level
# 2. Check API permissions granted in Azure AD
# 3. Ensure admin consent granted for API permissions
# 4. Wait for permission propagation (5-10 minutes)
```

**Issue: Subscription Not Found**
```bash
# Error: "Azure subscription not found"
# Resolution:
# 1. Verify subscription ID is correct
# 2. Check subscription is active
# 3. Verify service principal has access to subscription
# 4. Check subscription isn't in different tenant
```

#### GCP Onboarding Issues

**Issue: Service Account Key Invalid**
```bash
# Error: "Invalid service account key"
# Resolution:
# 1. Verify JSON key file is not corrupted
# 2. Check key hasn't been deleted in GCP
# 3. Ensure service account is enabled
# 4. Re-download key if necessary
```

**Issue: API Not Enabled**
```bash
# Error: "Required API not enabled"
# Resolution:
# 1. Enable Cloud Asset API
# 2. Enable Cloud Resource Manager API
# 3. Enable Compute Engine API
# 4. Wait for API enablement propagation
```

**Issue: Permission Denied**
```bash
# Error: "Permission denied on GCP resources"
# Resolution:
# 1. Verify service account has Viewer role
# 2. Check if custom role has required permissions
# 3. Verify role binding at correct level (project/org)
# 4. Wait for IAM propagation (1-2 minutes)
```

### Validation and Testing

#### Connection Testing
```bash
# Test cloud account connectivity:
# 1. Navigate to Settings > Cloud Accounts
# 2. Select cloud account
# 3. Click "Test Connection"
# 4. Review test results
```

#### Resource Discovery Verification
```bash
# Verify resource discovery:
# 1. Navigate to Inventory
# 2. Filter by cloud account
# 3. Verify resources are discovered
# 4. Check discovery timestamp
```

#### Policy Evaluation Testing
```bash
# Test policy evaluation:
# 1. Navigate to Policies
# 2. Run specific policy
# 3. View results
# 4. Verify expected violations appear
```

## Best Practices

### Security Best Practices

#### Credential Management
- **Rotate Credentials**: Regular rotation of cloud credentials (90 days)
- **Least Privilege**: Grant minimum required permissions
- **Secure Storage**: Store credentials securely (never commit to source control)
- **Audit Access**: Monitor who has access to cloud account credentials

#### Authentication Methods
- **Prefer IAM Roles**: Use IAM roles over access keys (AWS)
- **Service Principals**: Use service principals with certificate auth (Azure)
- **Service Accounts**: Use service accounts with key rotation (GCP)
- **Workload Identity**: Use workload identity federation when possible

### Operational Best Practices

#### Account Organization
- **Consistent Naming**: Use consistent naming conventions for accounts
- **Account Groups**: Organize accounts into logical groups
- **Tagging**: Implement consistent tagging across cloud resources
- **Documentation**: Document account purpose and ownership

#### Monitoring and Alerting
- **Alert Tuning**: Tune alerts to reduce noise
- **Escalation Procedures**: Define escalation procedures for critical alerts
- **On-Call Rotation**: Implement on-call rotation for security team
- **Regular Reviews**: Regularly review and update alert configurations

### Compliance Best Practices

#### Compliance Frameworks
- **Map Requirements**: Map cloud resources to compliance requirements
- **Regular Audits**: Conduct regular compliance audits
- **Evidence Collection**: Automate evidence collection for audits
- **Continuous Monitoring**: Enable continuous compliance monitoring

#### Remediation Workflows
- **Prioritization**: Prioritize remediation based on risk
- **Change Management**: Integrate with change management processes
- **Testing**: Test remediation in non-production first
- **Documentation**: Document remediation actions

## Integration and Automation

### API Integration

#### Prisma Cloud API
- **Authentication**: API key-based authentication
- **Endpoints**: RESTful API for all operations
- **Use Cases**: Automation, reporting, integration with other tools
- **Documentation**: Complete API documentation available

#### Automation Examples
```bash
# Example: Onboard multiple AWS accounts via API
curl -X POST "https://api.prismacloud.io/cloud/aws" \
  -H "x-redlock-auth: $AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "accountId": "123456789012",
    "enabled": true,
    "name": "Production AWS Account",
    "roleArn": "arn:aws:iam::123456789012:role/PrismaCloudRole"
  }'
```

### Infrastructure as Code

#### Terraform Integration
```hcl
# Example Terraform configuration for AWS onboarding
resource "prismacloud_cloud_account" "aws_account" {
  name         = "Production AWS Account"
  cloud_type   = "aws"
  account_id   = "123456789012"
  role_arn     = aws_iam_role.prisma_cloud_role.arn
  group_ids    = [prismacloud_account_group.production.id]
  enabled      = true
}
```

#### CloudFormation/ARM/Deployment Manager
- **AWS CloudFormation**: Automate AWS account onboarding
- **Azure ARM Templates**: Automate Azure subscription onboarding
- **GCP Deployment Manager**: Automate GCP project onboarding

### CI/CD Integration

#### Pipeline Integration
```yaml
# Example GitHub Actions workflow for cloud account onboarding
name: Onboard Cloud Account
on:
  workflow_dispatch:
    inputs:
      cloud_provider:
        description: 'Cloud Provider'
        required: true
        type: choice
        options:
          - aws
          - azure
          - gcp

jobs:
  onboard:
    runs-on: ubuntu-latest
    steps:
      - name: Onboard to Prisma Cloud
        run: |
          # Call Prisma Cloud API to onboard account
          # Implement appropriate authentication and error handling
```

## Monitoring and Reporting

### Dashboards

#### Executive Dashboard
- **Security Score**: Overall security posture score
- **Compliance Status**: Compliance across all frameworks
- **Critical Alerts**: Number of critical security alerts
- **Trend Analysis**: Historical trends and improvements

#### Operational Dashboard
- **Resource Inventory**: Total resources by cloud provider
- **Policy Violations**: Active policy violations by severity
- **Remediation Status**: Open vs. resolved violations
- **Cost Insights**: Security-related cost optimization opportunities

### Reports

#### Compliance Reports
- **Regulatory Compliance**: PCI DSS, HIPAA, GDPR compliance reports
- **Industry Benchmarks**: CIS Benchmark compliance reports
- **Custom Reports**: Custom compliance reports for internal standards
- **Audit Evidence**: Evidence collection for audits

#### Security Reports
- **Vulnerability Reports**: Vulnerability assessment reports
- **Threat Detection**: Threat detection and incident reports
- **Misconfiguration Reports**: Cloud misconfiguration reports
- **Executive Summaries**: High-level security summaries

## Support Resources

### Documentation
- **Enterprise Edition Documentation**: [https://docs.prismacloud.io/en/enterprise-edition](https://docs.prismacloud.io/en/enterprise-edition)
- **API Documentation**: Available in Prisma Cloud Console
- **Video Tutorials**: Available on Palo Alto Networks portal
- **Knowledge Base**: Comprehensive troubleshooting articles

### Community and Support
- **Palo Alto Networks LIVE Community**: Community forums and discussions
- **Technical Support**: 24/7 technical support for licensed customers
- **Professional Services**: Onboarding and optimization services available
- **Partner Ecosystem**: Network of certified partners

### Training and Certification
- **Prisma Cloud Training**: Official training courses
- **Certification Programs**: Prisma Cloud Certified Security Engineer
- **Hands-On Labs**: Practical exercises and scenarios
- **Webinars**: Regular webinars on new features and best practices

## References

- **Prisma Cloud Enterprise Edition**: [https://docs.prismacloud.io/en/enterprise-edition](https://docs.prismacloud.io/en/enterprise-edition)
- **Prisma Cloud Darwin Release**: Enterprise Edition with redesigned UI and enhanced security capabilities
- **Cloud Security Posture Management (CSPM)**: Multi-cloud security and compliance monitoring
- **Cloud Workload Protection Platform (CWPP)**: Runtime protection for containers, hosts, and serverless
- **Cloud Infrastructure Entitlement Management (CIEM)**: Identity and access management visibility

---

*This summary provides a comprehensive overview of onboarding AWS, Azure, and GCP cloud accounts to Prisma Cloud Enterprise Edition for Cloud Security Posture Management (CSPM). For the most current and detailed information, please refer to the official documentation at [https://docs.prismacloud.io/en/enterprise-edition](https://docs.prismacloud.io/en/enterprise-edition).*
