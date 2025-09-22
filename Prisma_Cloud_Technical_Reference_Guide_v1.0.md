# Prisma Cloud Technical Reference Guide
**Version 1.0** | **Date: January 2025** | **Purpose: Technical Knowledge Base**

## Document Information
- **Purpose**: Technical reference for understanding Prisma Cloud platform architecture and capabilities
- **Audience**: Technical team members and engineers
- **Scope**: Detailed explanation of platform sections, features, and technical differences
- **Environment**: Based on local Prisma Cloud instance analysis

---

## Table of Contents
1. [Platform Architecture Overview](#platform-architecture-overview)
2. [Radars Section - Visibility & Discovery](#radars-section---visibility--discovery)
3. [Defend Section - Active Protection](#defend-section---active-protection)
4. [Monitor Section - Compliance & Governance](#monitor-section---compliance--governance)
5. [Manage Section - Administration & Configuration](#manage-section---administration--configuration)
6. [Section Interactions & Dependencies](#section-interactions--dependencies)
7. [Technical Deep Dive](#technical-deep-dive)
8. [Common Use Cases & Scenarios](#common-use-cases--scenarios)

---

## Platform Architecture Overview

### Prisma Cloud Console Structure
```
┌─────────────────────────────────────────────────────────────┐
│                    Prisma Cloud Console                     │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐        │
│  │ Radars  │  │ Defend  │  │ Monitor │  │ Manage  │        │
│  │(Visibility)│ (Protection)│ (Governance)│ (Admin) │        │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘        │
└─────────────────────────────────────────────────────────────┘
```

### Core Philosophy
- **Radars**: "What do I have?" (Discovery & Visibility)
- **Defend**: "How do I protect it?" (Active Security Controls)
- **Monitor**: "Am I compliant?" (Governance & Compliance)
- **Manage**: "How do I configure it?" (Administration & Setup)

---

## Radars Section - Visibility & Discovery

### Purpose
**Radars** is the visibility and discovery layer of Prisma Cloud. It answers the fundamental question: "What resources do I have in my cloud environment?"

### What Radars Does
- **Asset Discovery**: Automatically discovers and inventories cloud resources
- **Resource Mapping**: Creates visual representations of infrastructure
- **Network Topology**: Shows communication patterns between resources
- **Vulnerability Scanning**: Identifies security issues in discovered assets
- **Real-time Monitoring**: Continuously tracks resource changes

### Sub-sections Explained

#### 1. Cloud
**Purpose**: Infrastructure-as-a-Service (IaaS) security monitoring
- **What it monitors**: Virtual machines, storage, networking, databases
- **Key capabilities**:
  - VM security posture assessment
  - Storage bucket security analysis
  - Network security group review
  - Database configuration scanning
- **Use cases**: AWS EC2, Azure VMs, Google Compute Engine protection

#### 2. Hosts
**Purpose**: Physical and virtual host security monitoring
- **What it monitors**: Operating systems, installed software, system configurations
- **Key capabilities**:
  - OS vulnerability scanning
  - Installed package analysis
  - System hardening assessment
  - Host-based intrusion detection
- **Use cases**: Bare metal servers, VMs, container hosts

#### 3. Containers (Current View)
**Purpose**: Container runtime security monitoring
- **What it monitors**: Running containers, container images, orchestration platforms
- **Key capabilities**:
  - Container runtime monitoring
  - Image vulnerability scanning
  - Container communication mapping
  - Orchestration security assessment
- **Use cases**: Docker, Kubernetes, OpenShift container protection

#### 4. Serverless
**Purpose**: Function-as-a-Service (FaaS) security monitoring
- **What it monitors**: Serverless functions, event triggers, dependencies
- **Key capabilities**:
  - Function code analysis
  - Event source security
  - Dependency vulnerability scanning
  - Runtime behavior monitoring
- **Use cases**: AWS Lambda, Azure Functions, Google Cloud Functions

### Technical Implementation
- **Agentless Scanning**: Uses cloud provider APIs for discovery
- **Defender Agents**: Lightweight agents for deep monitoring
- **Real-time Updates**: Continuous resource discovery and monitoring
- **Visual Mapping**: Network diagrams and resource relationships

### Key Metrics Shown
- **Resource Counts**: Number of discovered resources by type
- **Vulnerability Status**: Security issues found in resources
- **Network Flows**: Communication patterns between resources
- **Compliance Status**: Resource compliance with security policies

### Important Limitations and Requirements

#### Radars/Cloud Section Limitations
**⚠️ Critical Limitation**: Radars/Cloud only works for assets where you can apply agents
- **Agent Requirement**: Cloud resources must have Defender agents deployed to be monitored
- **Limited Coverage**: Without agents, only basic infrastructure discovery is possible
- **Real-time Monitoring**: Requires agent deployment for continuous monitoring
- **Use Cases**: Best for VMs, containers, and workloads where agents can be installed

#### Radars/Serverless Section Limitations
**⚠️ Platform Restriction**: Radars/Serverless only supports AWS Lambda
- **AWS Lambda Only**: Currently limited to AWS Lambda functions
- **No Multi-Cloud**: Does not support Azure Functions or Google Cloud Functions
- **Agentless Scanning**: Uses AWS APIs for serverless function discovery
- **Defend/Vulnerabilities Alternative**: For multi-cloud serverless, use Defend/Vulnerabilities which works across all cloud providers

#### Network Monitoring Settings Warning
**⚠️ Critical System Impact**: Network monitoring can overwrite iptables
- **iptables Overwrite**: Enabling network monitoring will modify system iptables rules
- **Potential System Crash**: Can lead to system instability if not properly planned
- **Planning Required**: Must coordinate with network administrators before enabling
- **Backup Strategy**: Always backup iptables configuration before enabling network monitoring
- **Testing**: Test in non-production environments first

---

## Defend Section - Active Protection

### Purpose
**Defend** is the active protection layer that implements security controls and policies to prevent threats and enforce security requirements.

### What Defend Does
- **Policy Enforcement**: Applies security policies to protect resources
- **Threat Prevention**: Blocks malicious activities in real-time
- **Runtime Protection**: Monitors and controls application behavior
- **Incident Response**: Automatically responds to security events
- **Behavioral Analysis**: Uses AI/ML to detect anomalous activities

### Sub-sections Explained

#### 1. Vulnerabilities
**Purpose**: Identify and remediate security vulnerabilities across all resources

**Key Features**:
- **Vulnerability Scanning**: Continuous scanning for known CVEs and security issues
- **Risk Assessment**: Prioritize vulnerabilities based on severity and exploitability
- **Remediation Guidance**: Provide step-by-step instructions to fix security issues
- **Patch Management**: Track and manage security updates across environments

**Risk Factors Analysis**:
- **Severity Classification**: Critical, High, Medium, Low risk levels
- **Exploitability Scoring**: CVSS (Common Vulnerability Scoring System) integration
- **Business Impact**: Assessment of potential business disruption
- **Remediation Priority**: AI-powered prioritization based on multiple risk factors
- **False Positive Reduction**: Machine learning to reduce noise and focus on real threats

**Exceptions and Tags**:
- **Exception Management**: Create exceptions for false positives or accepted risks
- **Tag-based Exclusions**: Use resource tags to exclude specific vulnerabilities
- **Temporary Exceptions**: Time-limited exceptions for planned remediation
- **Exception Documentation**: Detailed reasoning and approval workflow
- **Tag Types**:
  - **Environment Tags**: `env:production`, `env:development`
  - **Application Tags**: `app:critical`, `app:legacy`
  - **Owner Tags**: `owner:team-a`, `owner:security`
  - **Custom Tags**: Organization-specific tagging schemes

**Base Images Management**:
- **Base Image Scanning**: Deep vulnerability analysis of container base images
- **Layer-by-Layer Analysis**: Vulnerability tracking through image layers
- **Base Image Recommendations**: Suggested secure alternatives
- **Base Image Updates**: Track and manage base image security updates
- **Custom Base Images**: Support for organization-specific base images

**Registry Scanning Requirements**:
**⚠️ Minimum Requirements for Registry Scanning** (based on [official documentation](https://docs.prismacloud.io/en/compute-edition/34/admin-guide/install/system-requirements#hardware)):

**Hardware Requirements for Registry Scanning**:
- **CPU**: 2 cores minimum for registry scanning functionality
- **Memory**: 2 GB minimum for registry scanning (4 GB with WAAS OOB)
- **Storage**: 20 GB minimum for registry scanning functionality
- **Image Storage Formula**: 1.5 × (size of largest image) × (number of executors)
- **Network**: Stable high-bandwidth connection to registries
- **Disk I/O**: High-performance SSD for vulnerability scanning operations

**System Requirements**:
- **Operating System**: Linux (Ubuntu 18.04+, CentOS 7+, RHEL 7+)
- **Container Runtime**: Docker 19.03+ or containerd 1.3+
- **Kubernetes**: v1.19+ (if using Kubernetes deployment)
- **Network Access**: HTTPS access to Prisma Cloud Console and container registries

**Registry-Specific Requirements**:
- **Authentication**: Registry credentials and permissions
- **API Access**: Registry API endpoints accessible from Prisma Cloud
- **Scan Frequency**: Balance between security coverage and resource usage
- **Storage Growth**: Plan for vulnerability database growth over time

**Performance Considerations**:
- **Concurrent Scans**: Limit concurrent registry scans based on available resources
- **Scan Scheduling**: Schedule scans during low-usage periods
- **Resource Monitoring**: Monitor CPU, memory, and disk usage during scanning
- **Network Bandwidth**: Ensure adequate bandwidth for image pulling and scanning

**Note**: For detailed registry scanning documentation and specific requirements, consult with David or Gabriel Campos for the latest registry scanning images documentation.

#### 2. Compliance
**Purpose**: Ensure adherence to security standards and regulatory requirements
- **Policy Violation Tracking**: Monitor and report compliance violations
- **Framework Support**: Built-in support for SOC 2, PCI DSS, HIPAA, CIS Benchmarks
- **Compliance Scoring**: Calculate compliance percentages across environments
- **Audit Reporting**: Generate compliance reports for auditors and stakeholders

#### 3. Runtime
**Purpose**: Real-time protection for running workloads
- **Process Policies**: Control which processes can execute in containers/hosts
- **Network Policies**: Enforce network segmentation and communication rules
- **File System Policies**: Monitor and protect file system access
- **Anti-malware**: Detect and prevent malicious software execution

#### 4. WAAS (Web Application and API Security)
**Purpose**: Protect web applications and APIs from attacks

**WAAS Policy Types**:
- **Container WAAS**: Protection for containerized applications
  - **In-Line Protection**: Real-time traffic inspection and blocking
  - **Out-of-Band Protection**: Monitoring and alerting without blocking
- **Host WAAS**: Application protection for host-based workloads
- **App-Embedded WAAS**: Protection integrated directly into applications
- **Serverless WAAS**: Protection for serverless functions and APIs
- **Agentless WAAS**: Protection without requiring agents
- **Network Lists**: Manage allowed/blocked network connections and IP addresses
- **Sensitive Data**: Protect and monitor access to sensitive information

**WAAS Rule Management**:
- **Rule Creation**: Create custom WAAS rules for specific protection needs
- **Rule Import/Export**: Import existing rules or export for backup
- **Rule Filtering**: Filter rules by keywords and attributes
- **Rule Scoping**: Apply rules to specific collections or environments
- **Rule Ordering**: Control the order in which rules are evaluated

### WAAS Console Deep Dive

**Based on Console Screenshots**:
The WAAS section provides comprehensive web application and API security management:

#### Container WAAS Policy View:
- **Primary Tabs**: Container, Host, App-Embedded, Serverless, Agentless, Network lists, Sensitive data
- **Container Focus**: Currently viewing container-specific WAAS policies
- **Protection Modes**: 
  - **In-Line**: Active blocking with full protection rules (OWASP Top 10, attack signatures, etc.)
  - **Out-of-Band**: Monitoring only - no protection rules available
- **Policy Description**: 
  - **In-Line**: "WAAS rules are designed to let you tailor the best-suited protection for containers"
  - **Out-of-Band**: "WAAS rules are designed to let you tailor the best-suited out-of-band protection for containers"

#### Critical Difference - Protection Mode Selection:
**Out-of-Band Mode** (Monitoring Only):
- ✅ Basic configuration (scope, auto-detection)
- ✅ API endpoint discovery
- ✅ Port detection
- ❌ **No protection rules available**
- ❌ **No attack blocking**
- ❌ **No OWASP Top 10 protection**

**In-Line Mode** (Active Protection):
- ✅ Basic configuration (scope, auto-detection)
- ✅ API endpoint discovery
- ✅ Port detection
- ✅ **Full protection rules available**
- ✅ **OWASP Top 10 protection**
- ✅ **Attack signature blocking**
- ✅ **Custom rule creation**
- ✅ **Rate limiting**
- ✅ **File upload protection**

#### Rule Management Interface:
- **Filter Bar**: "Filter app firewall rules by keywords and attributes"
- **Action Buttons**: Export all, Import, + Add rule
- **Rule Table Columns**:
  - Rule name
  - Description (optional)
  - Scope
  - Modified (sortable)
  - Entities in scope (sortable)
  - Actions
  - Order

#### Current State Analysis:
- **Empty Rule Set**: "There is no data to show" - No WAAS rules currently configured
- **Ready for Configuration**: Interface ready for rule creation and management
- **Comprehensive Coverage**: Support for all deployment models (container, host, serverless, etc.)

### WAAS Protection Workflow

**Based on "Unprotected web apps" monitoring view**:

#### Step 1: Identify Unprotected Applications
**Monitor → WAAS → Unprotected web apps → Containers**
- **Current Detection**: `twistlock/private:console_34_00_141`
- **Container Count**: 1 container running
- **Listening Ports**: HTTPS port 8083
- **Status**: Not protected by WAAS

#### Step 2: Create WAAS Protection Rule
**Navigate to Defend → WAAS → Container → + Add rule**

**Rule Configuration**:
- **Rule Name**: "Console WAAS Protection"
- **Description**: "Protect twistlock console web application"
- **Scope**: Select collection containing the console container
- **Protection Mode**: 
  - **In-Line**: Real-time blocking (production)
  - **Out-of-Band**: Monitoring only (testing)

#### Step 3: Configure Web Application Protection
**Protection Settings**:
- **Port Configuration**: Target HTTPS port 8083
- **Attack Protection**: Enable OWASP Top 10 protection
- **Custom Rules**: Add application-specific rules if needed
- **Exception Handling**: Configure legitimate traffic exceptions

#### Step 4: Deploy and Verify
**Deployment Process**:
1. **Save Rule**: Deploy the WAAS policy
2. **Wait for Propagation**: Allow 2-5 minutes for policy deployment
3. **Verify Protection**: Return to Monitor → WAAS → Unprotected web apps
4. **Refresh List**: Click "Refresh" to update the unprotected apps list
5. **Confirm Protection**: Protected apps no longer appear in the list

#### Step 5: Monitor WAAS Protection
**Monitor → WAAS → WAAS Explorer**:
- **View Protected Applications**: See all applications under WAAS protection
- **Monitor Events**: Track blocked attacks and security events
- **Performance Metrics**: Monitor impact on application performance
- **Policy Effectiveness**: Analyze protection coverage and effectiveness

### WAAS Protection Troubleshooting

**Common Issues When Apps Remain Unprotected:**

#### Issue 1: Incorrect Collection Scope
**Problem**: Rule created but wrong collection selected
**Solution**:
- **Check Container Location**: Verify which collection contains your application
- **For Console Apps**: Often in "Prisma Cloud resources" collection (scope: `Images: *twistlock*`)
- **Update Rule Scope**: Edit WAAS rule to target correct collection
- **Verify Collection Scope**: Ensure collection includes your specific container/image

#### Issue 2: Incomplete Rule Configuration
**Problem**: Basic rule created but protection rules not configured
**Solution**:
- **Complete Protection Setup**: Add specific attack protection rules after basic setup
- **Configure Protection Mode**: Set In-Line (blocking) or Out-of-Band (monitoring)
- **Enable Attack Protections**: Activate OWASP Top 10, SQL injection, XSS protection
- **Port Configuration**: Ensure correct ports are detected and protected

**Critical Missing Step - Adding Protection Rules:**
1. **Edit Your WAAS Rule**: Click on your "Twistlock" rule to edit it
2. **Add Protection Rules**: Look for sections like:
   - **OWASP Top 10 Protection**: Enable SQL injection, XSS, CSRF protection
   - **Custom Rules**: Add specific attack patterns to block
   - **Rate Limiting**: Configure request rate limits
   - **File Upload Protection**: Block malicious file uploads
3. **Set Protection Mode**: Ensure it's set to "In-Line" (blocking) not just "Out-of-Band" (monitoring)
4. **Save and Deploy**: The rule must have actual protection rules to be effective

#### Issue 3: Rule Not Deployed/Activated
**Problem**: Rule created but not properly deployed
**Solution**:
- **Check Rule Status**: Verify rule is active and deployed
- **Wait for Propagation**: Allow 5-10 minutes for policy deployment
- **Restart Defender**: Restart defender agents if necessary
- **Check Defender Connectivity**: Ensure defenders can communicate with console

#### Issue 4: Application Not Detected as Web App
**Problem**: Application not recognized as web application requiring protection
**Solution**:
- **Enable Auto-Detection**: Ensure "Automatically detect ports" is enabled
- **Manual Port Configuration**: Manually specify listening ports (e.g., 8083)
- **Web App Classification**: Verify application is classified as web application
- **Check Network Traffic**: Ensure application is receiving HTTP/HTTPS traffic

#### Issue 5: Collection Wildcard Error
**Problem**: "Invalid collection [name] - images resource must not be a wildcard"
**Solution**:
- **Fix Collection Scope**: Change from wildcard to specific image names
- **Example Fix**: 
  - ❌ **Invalid**: `Images: *twistlock*` (wildcard)
  - ✅ **Valid**: `Images: twistlock/private:console_34_00_141` (specific)
- **Alternative**: Use existing "Prisma Cloud resources" collection
- **Create New Collection**: Make collection with specific image scope

#### Verification Steps:
1. **Check WAAS Explorer**: Look for your application in protected apps list
2. **Monitor Events**: Check for WAAS-related events and alerts
3. **Test Protection**: Send test attacks to verify protection is working
4. **Review Logs**: Check defender and console logs for WAAS activity

#### 5. CNNS (Cloud Native Network Security)
**Purpose**: Network security for cloud-native environments
- **Network Segmentation**: Isolate workloads and environments
- **Traffic Filtering**: Control inbound and outbound traffic
- **Port Management**: Monitor and control port usage
- **Protocol Analysis**: Deep packet inspection and analysis

#### 6. Access
**Purpose**: Control and monitor access to resources
- **Access Policies**: Define who can access what resources
- **Authentication Monitoring**: Track login attempts and authentication events
- **Authorization Controls**: Enforce role-based access controls
- **Privileged Access Management**: Monitor and control elevated access

#### 7. Custom Rules
**Purpose**: Create organization-specific security rules
- **Custom Policies**: Define custom security rules using RQL (Resource Query Language)
- **Policy Testing**: Validate custom rules before deployment
- **Rule Templates**: Create reusable policy templates
- **Advanced Logic**: Complex rule conditions and responses

### Technical Implementation
- **Defender Agents**: Deployed on protected resources
- **Policy Engine**: Centralized policy management and enforcement
- **Threat Intelligence**: Integration with threat feeds and AI models
- **Real-time Monitoring**: Continuous behavior analysis and threat detection

### Key Features
- **Zero-trust Architecture**: Continuous verification and validation
- **Automated Response**: Automatic threat blocking and incident response
- **Machine Learning**: AI-powered threat detection and prevention
- **Integration APIs**: Connect with SIEMs and other security tools

---

## Monitor Section - Compliance & Governance

### Purpose
**Monitor** is the governance and compliance layer that ensures your cloud environment meets regulatory requirements and organizational policies.

### What Monitor Does
- **Compliance Assessment**: Continuous evaluation against security standards
- **Policy Violation Tracking**: Monitor and report policy violations
- **Audit Reporting**: Generate compliance reports for auditors
- **Risk Management**: Assess and track security risks
- **Governance Controls**: Enforce organizational security policies

### Sub-sections Explained

#### 1. Events
**Purpose**: Real-time security event monitoring and analysis
- **Event Logs**: Comprehensive logging of all security-related activities
- **Event Correlation**: Connect related security events across systems
- **Real-time Alerts**: Immediate notification of security incidents
- **Event Forensics**: Detailed analysis of security events and incidents

#### 2. Runtime
**Purpose**: Monitor runtime behavior and compliance
- **Behavioral Monitoring**: Track application and system behavior patterns
- **Runtime Compliance**: Ensure running workloads meet compliance requirements
- **Performance Impact**: Monitor security controls' impact on performance
- **Runtime Analytics**: Analyze runtime security metrics and trends

#### 3. Vulnerabilities
**Purpose**: Track and manage security vulnerabilities
- **Vulnerability Discovery**: Identify security issues in deployed resources
- **Risk Prioritization**: Rank vulnerabilities by severity and business impact
- **Remediation Tracking**: Monitor progress in fixing security issues
- **Vulnerability Trends**: Analyze vulnerability patterns over time

#### 4. Compliance
**Purpose**: Ensure adherence to security standards and regulatory requirements
- **Compliance Dashboards**: Real-time compliance status across frameworks
- **SOC 2 Type II**: Service organization control compliance
- **PCI DSS**: Payment card industry data security standards
- **HIPAA**: Healthcare information portability and accountability
- **GDPR**: General data protection regulation compliance
- **CIS Benchmarks**: Center for internet security benchmarks
- **NIST Framework**: National institute of standards technology
- **Policy Violation Tracking**: Monitor and report compliance violations

#### 5. WAAS (Web Application and API Security)
**Purpose**: Monitor web application and API security posture

**WAAS Monitoring Tabs**:
- **WAAS Explorer**: View and analyze protected web applications and their security events
- **API Discovery**: Automatically discover APIs in your environment and their usage patterns
- **API Definition Scan**: Scan API definitions for security vulnerabilities and misconfigurations
- **Unprotected web apps**: Identify web applications that are not currently protected by WAAS

**Key Monitoring Capabilities**:
- **Application Security Monitoring**: Track application-level security events
- **API Security**: Monitor API usage and potential security issues
- **Web Application Firewall**: Monitor WAF rules and blocked requests
- **Application Performance**: Track security controls' impact on application performance
- **Protection Coverage**: Identify gaps in WAAS protection coverage

#### 6. ATT&CK (MITRE ATT&CK Framework)
**Purpose**: Map security events to MITRE ATT&CK framework for threat intelligence

**ATT&CK Explorer Features**:
- **Interactive Matrix**: Visual grid showing ATT&CK tactics and techniques
- **Event Correlation**: Correlates audits from cloud native apps to ATT&CK framework
- **Tactic Overview**: Track events across all 11 ATT&CK tactics:
  - Initial Access, Execution, Persistence, Privilege Escalation
  - Defense Evasion, Credential Access, Discovery, Lateral Movement
  - Collection, Command and Control, Exfiltration, Impact

**Technique Analysis**:
- **Event Counts**: Shows number of events detected for each technique
- **Technique Details**: Specific attack techniques under each tactic
- **Defense Evasion Focus**: Special attention to evasion techniques (e.g., "Obfuscated Files")
- **Filtering**: Filter techniques by attributes and time ranges

**Key Capabilities**:
- **Threat Intelligence**: Understand attack patterns and techniques in use
- **Defense Planning**: Identify gaps in security controls
- **Incident Response**: Map security events to known attack frameworks
- **Compliance**: Demonstrate security monitoring capabilities to auditors

### Technical Implementation
- **Continuous Monitoring**: Real-time compliance assessment
- **Automated Reporting**: Scheduled report generation and distribution
- **Integration APIs**: Connect with GRC (Governance, Risk, Compliance) tools
- **Data Retention**: Long-term storage of compliance and audit data

### Key Features
- **Multi-framework Support**: Support for multiple compliance standards
- **Automated Remediation**: Guidance for fixing compliance issues
- **Historical Tracking**: Long-term compliance trend analysis
- **Custom Policies**: Organization-specific compliance requirements

### ATT&CK Explorer Deep Dive

**Based on Console Screenshots**:
The ATT&CK Explorer shows a comprehensive view of security events mapped to the MITRE ATT&CK framework:

#### Current View Analysis:
- **Filter Applied**: "Time: Last 7 days" - Shows events from the past week
- **Total Events**: "3 total entries (filtered)" - Three security events detected
- **Active Tactics**: Most tactics show "0 events" indicating clean security posture
- **Defense Evasion**: Shows "3 Events" specifically under "Obfuscated Files" technique

#### Key Insights:
- **Obfuscated Files Detection**: The system detected 3 instances of obfuscated files
- **Clean Environment**: No events detected in most attack categories
- **Focused Monitoring**: Events are concentrated in defense evasion techniques
- **Real-time Correlation**: Events are automatically mapped to ATT&CK framework

#### Practical Applications:
- **Threat Hunting**: Use ATT&CK mapping to identify attack patterns
- **Incident Response**: Understand attack progression and techniques used
- **Security Posture**: Assess coverage against known attack techniques
- **Compliance Reporting**: Demonstrate comprehensive threat monitoring

---

## Manage Section - Administration & Configuration

### Purpose
**Manage** is the administration and configuration layer that controls how Prisma Cloud operates, who has access, and how it integrates with your environment.

### What Manage Does
- **User Management**: Control user access and permissions
- **System Configuration**: Configure platform settings and integrations
- **Integration Setup**: Connect with external tools and systems
- **Policy Management**: Create and manage security policies
- **System Administration**: Maintain and update the platform

### Sub-sections Explained

#### 1. Users and Access
**Purpose**: Manage user accounts and access control
- **User Accounts**: Create and manage user profiles
- **Role-based Access Control (RBAC)**: Define user permissions
- **Single Sign-On (SSO)**: Integration with identity providers
- **Multi-factor Authentication**: Enhanced security for user access
- **API Keys**: Manage programmatic access credentials

#### 2. Collections
**Purpose**: Organize resources for policy application
- **Resource Grouping**: Group resources by environment, application, or team
- **Policy Scoping**: Apply policies to specific resource groups
- **Dynamic Collections**: Automatically update based on resource attributes
- **Collection Hierarchy**: Nested collections for complex organizations

#### 3. System Settings
**Purpose**: Configure platform behavior and capabilities
- **Defender Configuration**: Configure agent behavior and settings
- **Scanning Settings**: Control vulnerability scanning frequency and scope
- **Notification Settings**: Configure alerting and notification preferences
- **Integration Settings**: Configure third-party tool integrations

#### 4. Integrations
**Purpose**: Connect with external systems and tools
- **SIEM Integration**: Send security events to SIEM platforms
- **Ticketing Systems**: Create tickets for security incidents
- **CI/CD Pipelines**: Integrate security into development workflows
- **Cloud Platforms**: Connect with cloud provider services

#### 5. Policies
**Purpose**: Create and manage security policies
- **Policy Templates**: Pre-built policies for common security requirements
- **Custom Policies**: Create organization-specific security rules
- **Policy Testing**: Validate policies before deployment
- **Policy Versioning**: Track changes to security policies

### Technical Implementation
- **REST APIs**: Programmatic access to all management functions
- **Configuration Management**: Centralized configuration storage and management
- **Integration Framework**: Extensible framework for third-party integrations
- **Audit Logging**: Comprehensive logging of all administrative actions

### Key Features
- **Automated Provisioning**: Automated user and resource provisioning
- **Policy as Code**: Version control and automation for security policies
- **Integration Marketplace**: Pre-built integrations with popular tools
- **Compliance Automation**: Automated compliance policy deployment

---

## Section Interactions & Dependencies

### How Sections Work Together

#### 1. Radars → Defend Flow
```
Radars discovers resources → Defend applies protection policies
```
- **Radars** discovers a new container
- **Defend** automatically applies runtime policies based on collection membership
- **Monitor** tracks compliance with applied policies
- **Manage** configures which policies apply to which collections

#### 2. Defend → Monitor Flow
```
Defend blocks threat → Monitor records incident → Manage configures response
```
- **Defend** blocks a malicious process
- **Monitor** records the incident and updates compliance status
- **Manage** sends notification to security team via integration

#### 3. Monitor → Manage Flow
```
Monitor finds violation → Manage creates ticket → Radars shows updated status
```
- **Monitor** identifies a compliance violation
- **Manage** creates a ticket in ticketing system
- **Radars** shows updated vulnerability status

### Data Flow Between Sections

#### Real-time Data Flow
1. **Radars** continuously discovers and monitors resources
2. **Defend** receives resource information and applies protection
3. **Monitor** receives security events and updates compliance status
4. **Manage** receives administrative requests and updates configuration

#### Batch Processing
1. **Radars** performs scheduled vulnerability scans
2. **Defend** updates threat intelligence and policy rules
3. **Monitor** generates compliance reports
4. **Manage** processes user access requests and policy changes

### Dependencies
- **Radars** is foundational - other sections depend on resource discovery
- **Defend** requires **Radars** for resource targeting
- **Monitor** requires both **Radars** and **Defend** for comprehensive coverage
- **Manage** controls configuration for all other sections

---

## Technical Deep Dive

### Architecture Components

#### 1. Console Interface
- **Web-based UI**: Browser-accessible management interface
- **REST APIs**: Programmatic access to all functions
- **Real-time Updates**: WebSocket connections for live data
- **Role-based UI**: Interface adapts based on user permissions

#### 2. Backend Services
- **Discovery Engine**: Automatically discovers cloud resources
- **Policy Engine**: Evaluates and enforces security policies
- **Threat Detection Engine**: AI/ML-powered threat analysis
- **Compliance Engine**: Continuous compliance assessment

#### 3. Data Storage
- **Resource Inventory**: Database of discovered cloud resources
- **Security Events**: Logs of all security-related activities
- **Compliance Data**: Historical compliance and audit information
- **Configuration Data**: Platform and policy configuration

#### 4. Integration Layer
- **Cloud APIs**: Integration with AWS, Azure, Google Cloud
- **SIEM Connectors**: Integration with security information systems
- **Ticketing Systems**: Integration with incident management
- **CI/CD Tools**: Integration with development pipelines

### Performance Characteristics

#### Scalability
- **Horizontal Scaling**: Supports large cloud environments
- **Multi-tenant**: Supports multiple organizations
- **Resource Optimization**: Efficient resource utilization
- **Load Balancing**: Distributed processing across multiple nodes

#### Reliability
- **High Availability**: Redundant components and failover
- **Data Backup**: Regular backup of configuration and data
- **Disaster Recovery**: Geographic redundancy and recovery procedures
- **Monitoring**: Comprehensive system health monitoring

#### Security
- **Encryption**: Data encrypted at rest and in transit
- **Authentication**: Multi-factor authentication support
- **Authorization**: Role-based access control
- **Audit Logging**: Comprehensive audit trail of all activities

### System Requirements

**Based on [official Prisma Cloud documentation](https://docs.prismacloud.io/en/compute-edition/34/admin-guide/install/system-requirements#hardware):**

#### Hardware Requirements

**CPU Requirements by Scale:**
| Defender Count | CPU Cores |
|----------------|-----------|
| < 1,000 Defenders | 4 cores |
| 1,001 - 10,000 Defenders | 8 cores |
| > 10,000 Defenders | > 8 cores |

**RAM Requirements by Feature Set:**
| Configuration | RAM Requirement |
|---------------|-----------------|
| Minimum Without Registry Scanning | 512MB |
| Minimum With Registry Scanning | 2 GB |
| Minimum with WAAS Out-of-Band | 4 GB |
| < 1,000 Defenders | 8 GB |
| 1,001 - 10,000 Defenders | 30 GB |
| > 10,000 Defenders | > 30 GB |

**Storage Requirements by Scale:**
| Defender Count | Storage Requirement |
|----------------|---------------------|
| < 1,000 Defenders | 100 GB |
| 1,001 - 10,000 Defenders | 500 GB |
| > 10,000 Defenders | > 500 GB |

**Registry Scanning Storage Formula:**
- **Storage per image scanned**: 1.5 × (size of largest image) × (number of executors)
- **Additional Storage**: 20GB minimum for registry scanning functionality

**Additional Hardware Considerations:**
- **Network**: Stable high-bandwidth connection to cloud providers and registries
- **Disk I/O**: High-performance SSD for scanning and database operations
- **Memory**: Additional RAM required for concurrent scanning operations

#### Software Requirements
- **Operating System**: Linux (Ubuntu 18.04+, CentOS 7+, RHEL 7+)
- **Container Runtime**: Docker 19.03+ or containerd 1.3+
- **Kubernetes**: v1.19+ (if using Kubernetes deployment)
- **Network Access**: HTTPS access to cloud providers and container registries

#### Network Requirements
- **Internet Connectivity**: Stable connection to Prisma Cloud services
- **Cloud Provider APIs**: Access to AWS, Azure, Google Cloud APIs
- **Registry Access**: Connectivity to container registries (Docker Hub, ECR, ACR, GCR)
- **Bandwidth**: Adequate bandwidth for image scanning and data transfer

#### Defender Agent Requirements
- **Resource Usage**: 50-200MB RAM, 1-2 CPU cores per agent
- **Network**: HTTPS outbound to Prisma Cloud Console
- **Storage**: Minimal local storage for logs and cache
- **Permissions**: Cloud provider IAM roles and policies

---

## Common Use Cases & Scenarios

### Scenario 1: New Cloud Environment Setup

#### Step 1: Radars - Discovery
- Connect to cloud accounts via APIs
- Automatically discover all resources
- Map network topology and dependencies
- Identify security vulnerabilities

#### Step 2: Manage - Configuration
- Create collections for resource grouping
- Set up user accounts and permissions
- Configure integrations with existing tools
- Create initial security policies

#### Step 3: Defend - Protection
- Deploy defender agents to critical resources
- Apply runtime policies to protect workloads
- Configure threat detection rules
- Set up automated response actions

#### Step 4: Monitor - Compliance
- Enable compliance frameworks (SOC 2, PCI DSS)
- Set up compliance monitoring and reporting
- Configure risk assessment and tracking
- Establish audit procedures

### Scenario 2: Security Incident Response

#### Detection (Radars + Defend)
- **Radars** identifies unusual network traffic
- **Defend** detects malicious process execution
- **Monitor** flags compliance violation

#### Response (Defend + Manage)
- **Defend** automatically blocks malicious activity
- **Manage** creates incident ticket and notifies team
- **Monitor** updates risk assessment and compliance status

#### Investigation (All Sections)
- **Radars** provides resource and network context
- **Defend** provides detailed incident forensics
- **Monitor** shows compliance impact assessment
- **Manage** tracks response actions and timeline

### Scenario 3: Compliance Audit Preparation

#### Preparation (Monitor + Manage)
- **Monitor** generates compliance reports
- **Manage** ensures proper user access controls
- **Radars** provides resource inventory
- **Defend** shows security control implementation

#### Audit Support (All Sections)
- **Monitor** provides detailed compliance evidence
- **Manage** shows administrative controls and procedures
- **Radars** demonstrates resource discovery and monitoring
- **Defend** shows active security controls and policies

---

## Version History

### Version 1.0 (January 2025)
- **Initial Creation**: Complete technical reference for Prisma Cloud sections
- **Section Analysis**: Detailed explanation of Radars, Defend, Monitor, Manage
- **Technical Deep Dive**: Architecture and implementation details
- **Use Case Scenarios**: Common operational scenarios and workflows

### Future Versions
- **Version 1.1**: Updates based on platform changes and feedback
- **Version 1.2**: Additional technical details and advanced use cases
- **Version 2.0**: Major updates for new platform features and capabilities

---

## Document Maintenance

### Regular Updates Required
- **Quarterly**: Review and update technical specifications
- **After Platform Updates**: Update feature descriptions and capabilities
- **User Feedback**: Incorporate lessons learned from operations
- **New Features**: Document new capabilities and use cases

### Review Checklist
- [ ] Technical specifications accurate and current
- [ ] Feature descriptions match actual platform capabilities
- [ ] Use case scenarios reflect real-world operations
- [ ] Architecture diagrams up to date
- [ ] Integration details verified and current

---
