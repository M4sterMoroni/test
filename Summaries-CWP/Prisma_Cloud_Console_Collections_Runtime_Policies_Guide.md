# Prisma Cloud Console: Collections and Runtime Policies Configuration Guide

## Overview
This guide provides step-by-step instructions for configuring collections and runtime policies in the Prisma Cloud Console, specifically focusing on Container Runtime policies for containerized workload protection.

**Scope:** Prisma Cloud Console Configuration, Collections Management, Container Runtime Policies  
**Target:** Containerized Workload Protection, Process Policies, Network Policies, File System Policies  

## Prerequisites

### **Access Requirements**
- Prisma Cloud Console access with appropriate permissions
- Admin or Security Admin role for policy configuration
- Compute Edition (PCCE) license for runtime protection features

### **Environment Setup**
- Prisma Cloud Compute Console deployed and accessible
- Defender agents deployed on target hosts/containers
- Container runtime environment (Docker, Kubernetes, etc.)

## Part 1: Collection Configuration

### **Step 1: Access Collections Management**

1. **Login to Prisma Cloud Console**
   - Navigate to your Prisma Cloud Console URL
   - Login with your credentials

2. **Navigate to Collections**
   - Go to **Manage** → **Collections** (Collections are typically under the Manage section)
   - Click **"Create Collection"** or **"+"** button

### **Step 2: Create a New Collection**

1. **Basic Collection Information**
   ```
   Collection Name: production-workloads
   Description: Production containerized workloads requiring runtime protection
   Color: #FF5733 (or your preferred color)
   ```

2. **Collection Scope Configuration**
   - **Images**: `*` (all images) or specific patterns like `nginx:*, app-*`
   - **Containers**: `*` (all containers) or specific container names
   - **Namespaces**: `production, default` (Kubernetes namespaces)
   - **Clusters**: `*` (all clusters) or specific cluster names
   - **Hosts**: `*` (all hosts) or specific host patterns

3. **Advanced Scoping Options**
   - **Labels**: Add label-based scoping
     - `env:production`
     - `workload:critical`
     - `security:high`
   - **Custom Queries**: Use RQL (Resource Query Language) for complex scoping

### **Step 3: Collection Validation and Testing**

1. **Preview Collection Scope**
   - Click **"Preview"** to see which resources will be included
   - Verify the scope matches your requirements

2. **Test Collection**
   - Deploy the collection in **Monitor** mode first
   - Verify resources are being discovered correctly

3. **Save Collection**
   - Click **"Save"** to create the collection
   - Note the Collection ID for policy scoping

**What we accomplished:** We created a collection that groups and organizes your containerized workloads. Collections act as logical containers that help you apply policies to specific sets of resources (containers, images, namespaces, etc.) rather than managing them individually. This makes policy management much more efficient and organized.

## Part 2: Container Runtime Policy Setup

### **Step 1: Access Runtime Policies**

1. **Navigate to Runtime Policies**
   - Go to **Defend** → **Runtime** (as shown in the console navigation)
   - Click **"+ Add rule"** button

2. **Select Policy Type**
   - The page shows tabs for different policy types:
     - **Anti-malware**
     - **Processes** (currently active and highlighted)
     - **Networking**
     - **File system**
     - **Custom rules (0)**
   - **Processes** tab should already be selected (highlighted with blue underline)
   - If not, click on the **"Processes"** tab

### **Step 2: Process Policies Configuration**

#### **A. Process Whitelisting Policy**

1. **Create Process Whitelist Policy**
   - **Rule name**: Enter "Container Process Whitelist"
   - **Notes**: Enter "Allow only approved processes in containers"
   - **Scope**: Click "All Click to select collections" to select your collection

2. **Configure Process Monitoring (Processes Tab)**
   - **Process monitoring**: Toggle **ON** (blue switch)
   
   **Left Pane - "Allowed" (Green checkmark)**
   - **Learned models**: Shows "Included" with green checkmark
   - **Allow learned processes only from parents identified in the model**: Toggle OFF
   - **Processes list**: Enter allowed processes:
     ```
     /bin/sh
     /bin/bash
     /usr/bin/nginx
     /usr/bin/python3
     /usr/bin/node
     /usr/bin/java
     ```
   - **Allow all activity in attached sessions**: Toggle OFF

   **Right Pane - "Denied & all other processes" (Red X)**
   - **Explicitly denied processes**:
     - **Processes list**: Enter blocked processes:
       ```
       /bin/su
       /usr/bin/sudo
       /bin/mount
       /usr/bin/umount
       ```
     - **Processes effect**: Select "Block"
   - **All other processes**:
     - **All other processes effect**: Select "Alert" (yellow highlight)

**What we accomplished:** We configured a process whitelisting policy that controls which processes can run in your containers. This policy allows only approved processes (like nginx, python, node) while blocking dangerous ones (like su, sudo, mount). This prevents malicious processes from executing and helps maintain a secure container runtime environment.

#### **B. Process Monitoring Policy**

The Process Monitoring Policy is actually configured within the same "Processes" tab interface shown above. The process monitoring functionality is controlled by the "Process monitoring" toggle switch and the various options in the "Allowed" and "Denied & all other processes" sections.

#### **C. Anti-Malware Detection Policy**

1. **Create Anti-Malware Policy**
   - **Rule name**: Enter "Container Anti-Malware Detection"
   - **Notes**: Enter "Detect malicious activities in containers"
   - **Scope**: Click "All Click to select collections" to select your collection

2. **Configure Anti-Malware Detection (Anti-malware Tab)**
   - Click on the **"Anti-malware"** tab (highlighted with blue underline)
   
   **Anti-malware monitoring section:**
   - **Prisma Cloud advanced threat protection**: Select "Alert" (yellow highlight)
   - **Kubernetes attacks**: Select "Alert" (yellow highlight) 
   - **Suspicious queries to cloud provider APIs**: Select "Alert" (yellow highlight)
   
   **Advanced malware analysis section:**
   - **Use WildFire malware analysis**: Select "Alert" (yellow highlight)
   - Note: WildFire must be enabled for runtime protection under Manage > System > WildFire

**What we accomplished:** We set up anti-malware detection that monitors for advanced threats in your containers. This includes detecting Prisma Cloud advanced threats, Kubernetes-specific attacks, suspicious cloud API queries, and using WildFire for deep malware analysis. This provides comprehensive protection against sophisticated malware and attack techniques.

### **Step 3: Network Policies Configuration**

#### **A. Network Segmentation Policy**

1. **Create Network Segmentation Policy**
   - **Rule name**: Enter "Container Network Segmentation"
   - **Notes**: Enter "Enforce network segmentation rules"
   - **Scope**: Click "All Click to select collections" to select your collection

2. **Configure Network Rules (Networking Tab)**
   - Click on the **"Networking"** tab (highlighted with blue underline)
   
   **IP connectivity section:**
   - **IP connectivity**: Toggle **ON** (blue switch)
   
   **Left Pane - "Allowed" (Green checkmark)**
   - **Learned models**: Check "Included" checkbox
   - **Listening ports**: Enter allowed listening ports (e.g., `80, 443, 8080`)
   - **Outbound internet ports**: Enter allowed outbound ports (e.g., `80, 443, 53, 123`)
   - **Outbound IPs**: Enter allowed outbound IPs (e.g., `10.0.0.8, 10.0.0.8/24`)
   
   **Right Pane - "Denied & all other network activity" (Red X)**
   - **Anti-malware and exploit prevention**:
     - **Networking activity from modified binaries**: Select "Alert" (yellow highlight)
     - **Port scanning**: Select "Alert" (yellow highlight)
     - **Raw sockets**: Select "Alert" (yellow highlight)
   - **Explicitly denied lists**:
     - **Listening ports**: Enter denied listening ports (e.g., `22, 23, 135-139, 445`)
     - **Listening ports effect**: Select "Block"
     - **Outbound internet ports**: Enter denied outbound ports
     - **Outbound internet ports effect**: Select "Block"
     - **Outbound IPs**: Enter denied outbound IPs
     - **Outbound IPs effect**: Select "Block"
   - **All other network activity**:
     - **All other activity effect**: Select "Alert" (yellow highlight)
   
   **DNS section:**
   - **DNS**: Toggle **ON** if you want to enable DNS monitoring
   - Note: Currently shows "Disabled" (grey switch) - enable if needed

**What we accomplished:** We configured network segmentation policies that control which ports and IP addresses your containers can communicate with. This includes allowing specific listening ports (like 80, 443), controlling outbound internet access, and blocking dangerous network activities like port scanning and raw socket usage. This creates network boundaries that prevent unauthorized network access and data exfiltration.

#### **B. Additional Network Policies**

The Networking tab in Prisma Cloud Console provides all the network policy functionality in one interface. The IP connectivity and DNS sections shown above cover the main network policy capabilities available in the console.

### **Step 4: File System Policies Configuration**

#### **A. File System Protection Policy**

1. **Create File System Protection Policy**
   - **Rule name**: Enter "Container File System Protection"
   - **Notes**: Enter "Protect file system and monitor changes"
   - **Scope**: Click "All Click to select collections" to select your collection

2. **Configure File System Rules (File system Tab)**
   - Click on the **"File system"** tab (highlighted with blue underline)
   
   **File system monitoring section:**
   - **File system monitoring**: Toggle **ON** (blue switch)
   
   **Left Pane - "Allowed" (Green checkmark)**
   - **Learned models**: Check "Included" checkbox
   - **Paths**: Enter allowed file system paths (e.g., `/app`, `/var/log`, `/tmp`)
   
   **Right Pane - "Denied & all other paths" (Red X)**
   - **Anti-malware and exploit prevention**:
     - **Changes to binaries**: Select "Alert" (yellow highlight)
     - **Detection of encrypted/packed binaries**: Select "Alert" (yellow highlight)
     - **Changes to SSH and admin account configuration files**: Select "Alert" (yellow highlight)
     - **Binaries with suspicious ELF headers**: Select "Alert" (yellow highlight)
   - **Explicitly denied paths**:
     - **Paths list**: Enter denied file system paths (e.g., `/etc/shadow`, `/root`, `/proc`)
     - **Paths effect**: Select "Block"
   - **All other paths**:
     - **All other paths effect**: Select "Alert" (yellow highlight)

**What we accomplished:** We set up file system protection that monitors and controls file access within your containers. This includes allowing specific file paths, detecting changes to critical binaries and configuration files, identifying encrypted/packed binaries, and blocking access to sensitive system files. This prevents unauthorized file modifications and protects against file-based attacks.

## Part 3: Policy Scoping and Collection Assignment

### **Step 1: Scope Policies to Collections**

1. **Access Policy for Scoping**
   - Go to **Defend** → **Runtime**
   - Click on your existing policy name (e.g., "Testing") in the rules table
   - This opens the **"Edit [Policy Name]"** window

2. **Configure Scope in Policy Edit Window**
   - In the **"Scope"** section at the top, click **"All Click to select collections"**
   - This opens the collection selection interface
   - Choose your target collection (e.g., `production-workloads`)
   - Verify the scope includes the intended resources

3. **Save Policy Changes**
   - Click **"Save"** to apply the scoping changes
   - The policy will now apply to the selected collection

**What we accomplished:** We connected our runtime policies to specific collections, ensuring that the security rules we created will only apply to the containerized workloads we want to protect. This targeted approach allows us to have different security policies for different types of workloads (e.g., production vs. development) and ensures we're not applying overly restrictive policies to all containers.

### **Step 2: Policy Testing and Validation**

1. **Test Policy in Monitor Mode**
   - Set policy to **Monitor** mode initially
   - Deploy to a small subset of containers
   - Monitor for false positives

2. **Validate Policy Effectiveness**
   - Check policy violation logs
   - Verify alerts are being generated
   - Test policy enforcement actions

3. **Tune Policy Parameters**
   - Adjust thresholds based on monitoring results
   - Add exceptions for legitimate activities
   - Fine-tune detection rules

### **Step 3: Policy Deployment**

1. **Deploy to Production**
   - Change policy mode to **Enforce**
   - Deploy to all target containers
   - Monitor for any issues

2. **Monitor Policy Performance**
   - Check policy performance metrics
   - Monitor resource usage impact
   - Verify security effectiveness

**What we accomplished:** We successfully deployed our runtime policies to production and established monitoring to ensure they're working effectively. This includes tracking policy violations, measuring performance impact, and verifying that our security controls are actually protecting our containerized workloads without causing operational issues.

## Part 4: Advanced Configuration

### **Step 1: Policy Templates and Customization**

1. **Use Policy Templates**
   - Start with built-in templates
   - Customize templates for your environment
   - Create custom templates for reuse

2. **Custom Policy Rules**
   - Create custom RQL queries
   - Define custom detection rules
   - Implement custom response actions

### **Step 2: Integration and Automation**

1. **SIEM Integration**
   - Configure SIEM integration
   - Set up log forwarding
   - Configure alert forwarding

2. **API Integration**
   - Use Prisma Cloud APIs for automation
   - Integrate with CI/CD pipelines
   - Automate policy deployment

### **Step 3: Monitoring and Reporting**

1. **Real-Time Monitoring**
   - Set up real-time dashboards
   - Configure alerting rules
   - Monitor policy effectiveness

2. **Reporting and Analytics**
   - Generate compliance reports
   - Analyze security trends
   - Track policy performance

## Part 5: Best Practices and Troubleshooting

### **Best Practices**

1. **Policy Design**
   - Start with broad policies and narrow down
   - Use multiple layers of protection
   - Implement defense in depth

2. **Collection Management**
   - Use descriptive collection names
   - Implement proper scoping
   - Regular collection review and cleanup

3. **Policy Management**
   - Version control policies
   - Document policy purposes
   - Regular policy review and updates

### **Common Issues and Solutions**

1. **False Positives**
   - Tune policy thresholds
   - Add exception rules
   - Review and update baselines

2. **Performance Impact**
   - Optimize policy rules
   - Use efficient queries
   - Monitor resource usage

3. **Policy Conflicts**
   - Review policy priorities
   - Resolve conflicting rules
   - Use policy hierarchy

## Conclusion

This guide provides comprehensive instructions for configuring collections and runtime policies in the Prisma Cloud Console. By following these steps, you can:

- **Create and configure collections** with proper scoping for runtime policy targeting
- **Set up Container Runtime policies** including process, network, and file system protection
- **Scope collections to policies** for effective containerized workload protection
- **Monitor and maintain** the security posture of your containerized environments

The configuration ensures comprehensive protection for containerized workloads while maintaining operational efficiency and compliance with security standards.

## References and Resources

- **Prisma Cloud Documentation**: https://docs.prismacloud.io
- **Collections Management**: https://docs.prismacloud.io/compute/collections
- **Runtime Policies**: https://docs.prismacloud.io/compute/runtime-policies
- **Container Security**: https://docs.prismacloud.io/compute/container-security
- **Policy Management**: https://docs.prismacloud.io/compute/policy-management
