# Prisma Cloud Custom Runtime Rules - Engineer's Guide

## Overview
This guide provides comprehensive information about custom Runtime Rules in Prisma Cloud Enterprise Edition based on the official documentation.

**Documentation Source:** [Prisma Cloud Enterprise Edition - Custom Runtime Rules](https://docs.prismacloud.io/en/enterprise-edition/content-collections/runtime-security/runtime-defense/custom-runtime-rules)  
**Last Updated:** June 11, 2025  

## Custom Runtime Rules Overview

Prisma Cloud models runtime behavior with machine learning to scale runtime defense in big and fluid environments. When machine learning doesn't fully capture the range of acceptable runtime behaviors, custom rules provide a way to declaratively augment models with exceptions and additions.

### **What Custom Runtime Rules Do**
- **Machine Learning Integration**: Work alongside ML models to provide precise control
- **Discrete Behavior Detection**: Detect specific runtime behaviors with expressions
- **Event Processing**: Examine process, file system, and network events programmatically
- **Action Execution**: Take specific actions when expressions evaluate to true
- **Multi-Platform Support**: Apply to both hosts and containers

### **Rule Types Available**

#### **Process Rules**
- Monitor process execution and termination
- Control which processes can run
- Detect unauthorized process activities

#### **File System Rules**
- Monitor file and directory access
- Control read/write permissions
- Detect unauthorized file modifications

#### **Networking Rules (Outgoing)**
- Monitor outbound network connections
- Control network communications
- Detect suspicious network activities

## Expression Grammar

Custom rules use expressions to examine various facets of runtime events. The expression grammar supports:

### **Basic Syntax**
```
expression: term (op term | in )*
term: integer | string | keyword | event | '(' expression ')' | unaryOp
op: and | or | > | < | >= | <= | = | !=
in: '(' integer | string (',' integer | string)*)?
unaryOp: not
keyword: startswith | contains
string: strings must be enclosed in double quotes
integer: int
event: process, file system, or network
```

### **Expression Examples**
```
# Network connection to specific IPs
net.outgoing_ip = "169.254.169.254" or net.outgoing_ip = "169.254.170.2"

# Process with specific parent and different name
proc.pname in ("mysql", "sqlplus", "postgres") and proc.pname != proc.name

# File path starting with specific directory
file.path startswith "/etc"
```

## Event Attributes

### **Process Events**
Process events fire when new processes are forked. Available attributes:

| Attribute | Type | Description |
|-----------|------|-------------|
| `proc.name` | string | Process name |
| `proc.pname` | string | Parent process name |
| `proc.path` | string | Full path to the program |
| `proc.user` | string | User to whom the process belongs |
| `proc.interactive` | bool | Interactive process (Not supported in App-Embedded runtime) |
| `proc.cmdline` | string | Command line |
| `proc.service` | string | Only for host rules |

### **File System Events**
File system events fire on write operations to disk. Available attributes:

| Attribute | Type | Description |
|-----------|------|-------------|
| `file.path` | string | Path of the file being written |
| `file.dir` | string | Directory of the file being written |
| `file.type` | enum | File type (elf, secret, regular, folder) |
| `file.md5` | string | MD5 hash of the file (ELF files only) |

### **Networking Events**
Network events fire when processes establish outbound connections. Available attributes:

| Attribute | Type | Description |
|-----------|------|-------------|
| `proc.name` | string | Name of process initiating connection |
| `net.outgoing_port` | string | Outbound port |
| `net.outgoing_ip` | string | Outgoing IP address |
| `net.private_subnet` | bool | Private subnet |

## Rule Library and Management

### **Rule Library**
- **Central Storage**: Custom rules are stored in a central library for reuse
- **Intelligence Stream**: Prisma Cloud Labs distributes rules via Intelligence Stream
- **Default State**: Rules are shipped in disabled state by default
- **Management**: Review and apply rules at any time

### **Access Method**
Navigate to: **Defend > Custom Rules > Runtime**
- Select **Add rule** to create new custom rules
- Filter rules by Type (processes, filesystem, network-outgoing)
- Filter by Owner (system) to see Prisma Cloud Labs rules

## Activating Custom Rules

### **Runtime Policy Integration**
Custom rules are integrated into runtime policies at:
**Defend > Runtime > {Container policy | Host policy | Serverless policy | App-Embedded Policy}**

### **Rule Processing Order**
1. **Custom rules are processed first** and take precedence over other settings
2. **Host Runtime Defense** has specific evaluation order:
   - **Process events**: Activities > Host activity monitoring → process types custom rules → Anti-malware settings
   - **Filesystem events**: Filesystem types custom rules → Anti-malware settings
   - **Networking events**: Network-outgoing type custom rules take precedence over Outbound internet ports and Outbound IPs settings

### **Available Actions**
- **allow**: Permit the action
- **alert**: Generate an alert
- **prevent**: Block the action
- **block**: Block the action (not supported in App-Embedded)

### **Logging Options**
- **Audit**: Log as audit event
- **Incident**: Log as incident

## Configuration Steps

### **Adding Custom Rules to Runtime Policy**
1. Open Console and go to **Defend > Runtime > {Container policy | Host policy | Serverless policy | App-Embedded policy}**
2. Select **Add rule**
3. Enter a **Rule name**
4. Select the **Scope** of the rule on a set of collections
5. Select **Custom Rules**
6. Under **Select rules**, select the rules to add and select **Apply**
7. Specify an **Effect** for each rule
8. Specify how to **log the event** for each rule
9. Select **Save**

## Limitations

### **Prevent Mode Limitations**
- `proc.cmdline` and `file.type` fields are not supported in prevent mode
- Error occurs if trying to attach custom rules with these fields and action set to Prevent

### **Process Prevention Logic**
- Prisma Cloud cannot inspect command line arguments before a process starts
- If a process is explicitly denied with Prevent effect, it will never run
- Cannot allow processes prevented by other policies using `proc.cmdline` analysis

### **App-Embedded Limitations**
- Supports **Processes** and **Outbound Connection** rule types only
- **Block action** is not supported
- **Prevent** is supported for both Processes and Outbound Connection rule types
- **Prevent effect** isn't supported when using `file.type` or `file.md5` properties

## Practical Example: Allow Process to Write to Specific File Path

### **Scenario**
Allow user Jake to run binary `netcat` with parameter `-l` and log an alert.

### **Expression**
```
proc.user = "Jake" and proc.name = "netcat" and proc.cmdline contains "-l"
```

### **Configuration**
1. Create custom rule with the expression above
2. Set action to **alert**
3. Set logging to **incident** or **audit**
4. Add to runtime policy with appropriate scope

## References and Resources

- **Custom Runtime Rules Documentation**: https://docs.prismacloud.io/en/enterprise-edition/content-collections/runtime-security/runtime-defense/custom-runtime-rules
- **Prisma Cloud Enterprise Edition**: https://docs.prismacloud.io/en/enterprise-edition
