# Prisma Cloud Custom Runtime Rules - Engineer's Guide

## Overview
This guide provides comprehensive information about creating custom Runtime Rules in Prisma Cloud Enterprise Edition, including syntax for Processes, File System, and Networking rules, and practical examples for rule creation.

**Scope:** Custom Runtime Rules, Process Monitoring, File System Monitoring, Network Monitoring  
**Tools:** Prisma Cloud Enterprise Edition, Runtime Security Policies  
**Documentation Source:** [Prisma Cloud Enterprise Edition](https://docs.prismacloud.io/en/enterprise-edition)  
**Last Updated:** January 2025  

## Custom Runtime Rules Overview

### **1. What are Custom Runtime Rules?**

Custom Runtime Rules in Prisma Cloud Enterprise Edition allow you to define specific security policies that monitor and control:

- **Process Execution**: Monitor which processes can run on your systems
- **File System Access**: Control file and directory access permissions
- **Network Communications**: Monitor and control network traffic

### **2. Rule Types and Categories**

Based on the [Prisma Cloud Enterprise Edition documentation](https://docs.prismacloud.io/en/enterprise-edition), custom runtime rules fall into three main categories:

#### **Process Rules**
- Monitor process execution and termination
- Control which processes can run
- Detect unauthorized process activities

#### **File System Rules**
- Monitor file and directory access
- Control read/write permissions
- Detect unauthorized file modifications

#### **Network Rules**
- Monitor network communications
- Control inbound and outbound connections
- Detect suspicious network activities

## Rule Syntax and Configuration

### **1. Process Rules Syntax**

#### **Basic Process Rule Structure**
```yaml
process:
  - name: "rule_name"
    description: "Rule description"
    process: "process_name_or_pattern"
    action: "allow|deny|alert"
    conditions:
      - user: "username_or_pattern"
      - group: "group_name_or_pattern"
      - working_dir: "directory_path"
```

#### **Process Rule Examples**
```yaml
# Allow specific process
process:
  - name: "allow_nginx"
    description: "Allow nginx process"
    process: "nginx"
    action: "allow"

# Deny specific process
process:
  - name: "deny_malicious"
    description: "Deny malicious process"
    process: "malware.exe"
    action: "deny"

# Alert on suspicious process
process:
  - name: "alert_suspicious"
    description: "Alert on suspicious process"
    process: "*.exe"
    action: "alert"
    conditions:
      - working_dir: "/tmp"
```

### **2. File System Rules Syntax**

#### **Basic File System Rule Structure**
```yaml
filesystem:
  - name: "rule_name"
    description: "Rule description"
    path: "file_or_directory_path"
    operation: "read|write|execute|delete"
    action: "allow|deny|alert"
    conditions:
      - process: "process_name"
      - user: "username"
      - group: "group_name"
```

#### **File System Rule Examples**
```yaml
# Allow specific file access
filesystem:
  - name: "allow_config_read"
    description: "Allow reading config files"
    path: "/etc/config/*"
    operation: "read"
    action: "allow"

# Deny specific file modification
filesystem:
  - name: "deny_system_modification"
    description: "Deny system file modification"
    path: "/etc/passwd"
    operation: "write"
    action: "deny"

# Alert on suspicious file access
filesystem:
  - name: "alert_suspicious_access"
    description: "Alert on suspicious file access"
    path: "/home/*/.ssh/*"
    operation: "read"
    action: "alert"
```

### **3. Network Rules Syntax**

#### **Basic Network Rule Structure**
```yaml
network:
  - name: "rule_name"
    description: "Rule description"
    protocol: "tcp|udp|icmp"
    port: "port_number_or_range"
    direction: "inbound|outbound|both"
    action: "allow|deny|alert"
    conditions:
      - process: "process_name"
      - remote_ip: "ip_address_or_range"
```

#### **Network Rule Examples**
```yaml
# Allow specific network connection
network:
  - name: "allow_http"
    description: "Allow HTTP connections"
    protocol: "tcp"
    port: "80"
    direction: "both"
    action: "allow"

# Deny specific network connection
network:
  - name: "deny_suspicious_port"
    description: "Deny suspicious port"
    protocol: "tcp"
    port: "4444"
    direction: "both"
    action: "deny"

# Alert on suspicious network activity
network:
  - name: "alert_suspicious_connection"
    description: "Alert on suspicious connection"
    protocol: "tcp"
    port: "1-1023"
    direction: "outbound"
    action: "alert"
```

## Wildcards and Pattern Matching

### **1. Supported Wildcards**

#### **Asterisk (*) Wildcard**
- Matches any number of characters
- Example: `*.exe` matches any file ending with `.exe`

#### **Question Mark (?) Wildcard**
- Matches exactly one character
- Example: `file?.txt` matches `file1.txt`, `file2.txt`, etc.

#### **Bracket Notation**
- Matches any character within brackets
- Example: `file[123].txt` matches `file1.txt`, `file2.txt`, `file3.txt`

### **2. Path Patterns**

#### **Directory Patterns**
```yaml
# Match all files in a directory
path: "/var/log/*"

# Match all files in subdirectories
path: "/var/log/**/*"

# Match specific file types
path: "*.log"
```

#### **Process Patterns**
```yaml
# Match any process
process: "*"

# Match processes with specific pattern
process: "nginx*"

# Match processes in specific directory
process: "/usr/bin/*"
```

## Practical Example: Allow Specific Process to Write to Specific File Path

### **1. Scenario**
Allow the `backup_script.sh` process to write to the `/backup/` directory while denying other processes from writing to this directory.

### **2. Rule Configuration**

#### **Step 1: Create File System Rule for Backup Directory**
```yaml
filesystem:
  - name: "allow_backup_script_write"
    description: "Allow backup script to write to backup directory"
    path: "/backup/*"
    operation: "write"
    action: "allow"
    conditions:
      - process: "backup_script.sh"

  - name: "deny_other_backup_write"
    description: "Deny other processes from writing to backup directory"
    path: "/backup/*"
    operation: "write"
    action: "deny"
    conditions:
      - process: "!backup_script.sh"
```

#### **Step 2: Create Process Rule for Backup Script**
```yaml
process:
  - name: "allow_backup_script"
    description: "Allow backup script execution"
    process: "backup_script.sh"
    action: "allow"
    conditions:
      - working_dir: "/scripts"
```

#### **Step 3: Create Network Rule for Backup Process**
```yaml
network:
  - name: "allow_backup_network"
    description: "Allow backup script network access"
    protocol: "tcp"
    port: "22,80,443"
    direction: "outbound"
    action: "allow"
    conditions:
      - process: "backup_script.sh"
```

### **3. Complete Rule Set**
```yaml
# Custom Runtime Rules for Backup Process
rules:
  # File System Rules
  filesystem:
    - name: "allow_backup_script_write"
      description: "Allow backup script to write to backup directory"
      path: "/backup/*"
      operation: "write"
      action: "allow"
      conditions:
        - process: "backup_script.sh"

    - name: "deny_other_backup_write"
      description: "Deny other processes from writing to backup directory"
      path: "/backup/*"
      operation: "write"
      action: "deny"
      conditions:
        - process: "!backup_script.sh"

  # Process Rules
  process:
    - name: "allow_backup_script"
      description: "Allow backup script execution"
      process: "backup_script.sh"
      action: "allow"
      conditions:
        - working_dir: "/scripts"

  # Network Rules
  network:
    - name: "allow_backup_network"
      description: "Allow backup script network access"
      protocol: "tcp"
      port: "22,80,443"
      direction: "outbound"
      action: "allow"
      conditions:
        - process: "backup_script.sh"
```

## Rule Management and Best Practices

### **1. Rule Creation Process**

#### **Step 1: Define Requirements**
- Identify what needs to be monitored or controlled
- Determine the scope and conditions
- Choose appropriate actions (allow, deny, alert)

#### **Step 2: Create Rules**
- Use the Prisma Cloud console or API
- Test rules in a controlled environment
- Validate rule syntax and logic

#### **Step 3: Deploy and Monitor**
- Deploy rules to target environments
- Monitor rule effectiveness
- Adjust rules based on feedback

### **2. Best Practices**

#### **Rule Design**
- **Clear Naming**: Use descriptive names for rules
- **Specific Conditions**: Be as specific as possible with conditions
- **Appropriate Actions**: Choose the right action for each rule
- **Regular Review**: Periodically review and update rules

#### **Testing and Validation**
- **Test in Staging**: Test rules in staging environments first
- **Monitor Performance**: Monitor rule performance and impact
- **Validate Logic**: Ensure rules work as expected

#### **Documentation**
- **Document Purpose**: Clearly document the purpose of each rule
- **Maintain Records**: Keep records of rule changes and updates
- **Version Control**: Use version control for rule configurations

## Integration with Prisma Cloud Enterprise Edition

### **1. Console Integration**

#### **Runtime Security Section**
- Access through Prisma Cloud console under 'Runtime Security'
- Create, modify, and manage custom runtime rules
- Monitor rule performance and violations
- Generate reports on security events

#### **Content Collections**
- **Runtime Security**: Available in Prisma Cloud Enterprise Edition under Content Collections > Runtime Security
- **Application Security**: Available under Content Collections > Application Security
- **Unified Interface**: Single holistic collection for comprehensive security management

### **2. API Integration**

#### **REST API**
- Create and manage rules programmatically
- Integrate with existing automation tools
- Automate rule deployment and updates

#### **Terraform Integration**
- Use Terraform providers for rule management
- Version control rule configurations
- Automate rule deployment

## Troubleshooting and Maintenance

### **1. Common Issues**

#### **Rule Not Working**
- **Issue**: Rule not enforcing as expected
- **Solution**: Check rule syntax and conditions
- **Prevention**: Test rules thoroughly before deployment

#### **False Positives**
- **Issue**: Legitimate activities being blocked
- **Solution**: Adjust rule conditions and scope
- **Prevention**: Regular rule review and adjustment

#### **Performance Impact**
- **Issue**: Rules causing performance degradation
- **Solution**: Optimize rule conditions and scope
- **Prevention**: Monitor rule performance regularly

### **2. Maintenance Activities**

#### **Regular Maintenance**
- **Rule Reviews**: Periodically review rule effectiveness
- **Performance Monitoring**: Monitor rule performance and impact
- **Updates**: Update rules to address new threats and requirements

#### **Documentation and Auditing**
- **Configuration Records**: Maintain detailed rule configuration records
- **Change Tracking**: Track all rule modifications and updates
- **Compliance Support**: Support audit and compliance requirements

## Conclusion

Custom Runtime Rules in Prisma Cloud Enterprise Edition provide powerful capabilities for securing containerized environments. Based on the [official Prisma Cloud Enterprise Edition documentation](https://docs.prismacloud.io/en/enterprise-edition), these rules enable organizations to:

### **Key Benefits:**
- **Granular Control**: Fine-grained control over process, file, and network activities
- **Flexible Configuration**: Support for wildcards, patterns, and complex conditions
- **Comprehensive Monitoring**: Monitor all aspects of runtime security
- **Automated Enforcement**: Automatically enforce security policies

### **Best Practices:**
- **Clear Rule Design**: Design clear and specific rules
- **Thorough Testing**: Test rules in controlled environments
- **Regular Review**: Periodically review and update rules
- **Performance Monitoring**: Monitor rule performance and impact

By leveraging Prisma Cloud's Custom Runtime Rules capabilities as documented in the [Enterprise Edition](https://docs.prismacloud.io/en/enterprise-edition), organizations can achieve effective runtime security that adapts to their specific requirements while maintaining protection against threats.

## References and Resources

- **Prisma Cloud Enterprise Edition Documentation**: https://docs.prismacloud.io/en/enterprise-edition
- **Runtime Security (Content Collections)**: Available in Prisma Cloud Enterprise Edition under Content Collections > Runtime Security
- **Application Security (Content Collections)**: Available in Prisma Cloud Enterprise Edition under Content Collections > Application Security
