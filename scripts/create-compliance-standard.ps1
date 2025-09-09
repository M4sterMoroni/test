# Prisma Cloud Custom Compliance Standard Creator
param(
    [string]$ConsoleUrl = "https://localhost:8083",
    [string]$Username = "admin",
    [string]$Password = "admin234",
    [string]$StandardName = "Custom Security Framework v1.0",
    [switch]$DryRun,
    [switch]$Help
)

if ($Help) {
    Write-Host "Prisma Cloud Custom Compliance Standard Creator" -ForegroundColor Green
    Write-Host "Usage: .\create-compliance-standard.ps1 [options]" -ForegroundColor Yellow
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -ConsoleUrl    Prisma Cloud Console URL" -ForegroundColor White
    Write-Host "  -Username      Prisma Cloud username" -ForegroundColor White
    Write-Host "  -Password      Prisma Cloud password" -ForegroundColor White
    Write-Host "  -StandardName  Name of the compliance standard" -ForegroundColor White
    Write-Host "  -DryRun        Show what would be created" -ForegroundColor White
    Write-Host "  -Help          Show this help message" -ForegroundColor White
    exit 0
}

Write-Host "Prisma Cloud Custom Compliance Standard Creator" -ForegroundColor Green
Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "  Console URL: $ConsoleUrl" -ForegroundColor White
Write-Host "  Username: $Username" -ForegroundColor White
Write-Host "  Standard Name: $StandardName" -ForegroundColor White
Write-Host "  Dry Run: $DryRun" -ForegroundColor White
Write-Host ""

if ($DryRun) {
    Write-Host "DRY RUN MODE - No changes will be made" -ForegroundColor Yellow
    Write-Host ""
}

# Define compliance controls
$controls = @(
    @{ id="CC-001"; name="Data Encryption at Rest"; category="Data Protection"; severity="High" },
    @{ id="CC-002"; name="Network Security Groups"; category="Network Security"; severity="High" },
    @{ id="CC-003"; name="Access Control"; category="Identity & Access Management"; severity="Critical" },
    @{ id="CC-004"; name="Logging and Monitoring"; category="Monitoring & Logging"; severity="Medium" },
    @{ id="CC-005"; name="Vulnerability Management"; category="Vulnerability Management"; severity="High" }
)

# Authenticate with Prisma Cloud
Write-Host "Authenticating with Prisma Cloud..." -ForegroundColor Blue

# Handle SSL certificate validation for self-signed certificates
if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type) {
    $certCallback = @"
        using System;
        using System.Net;
        using System.Net.Security;
        using System.Security.Cryptography.X509Certificates;
        public class ServerCertificateValidationCallback
        {
            public static void Ignore()
            {
                if(ServicePointManager.ServerCertificateValidationCallback ==null)
                {
                    ServicePointManager.ServerCertificateValidationCallback += 
                        delegate
                        (
                            Object obj, 
                            X509Certificate certificate, 
                            X509Chain chain, 
                            SslPolicyErrors errors
                        )
                        {
                            return true;
                        };
                }
            }
        }
"@
    Add-Type $certCallback
}
[ServerCertificateValidationCallback]::Ignore()

$authBody = @{ username = $Username; password = $Password } | ConvertTo-Json
$authResult = $null

try {
    $authResult = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/authenticate" -Method POST -Body $authBody -ContentType "application/json" -ErrorAction Stop
    if ($authResult.token) {
        Write-Host "Authentication successful" -ForegroundColor Green
        $token = $authResult.token
    } else {
        Write-Host "Authentication failed - no token received" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Authentication failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Create compliance standard
Write-Host "Creating compliance standard: $StandardName" -ForegroundColor Blue
$standardBody = @{
    name = $StandardName
    description = "Custom compliance framework for cloud infrastructure"
    framework = "CUSTOM"
    version = "1.0"
    controls = $controls
} | ConvertTo-Json -Depth 10

if ($DryRun) {
    Write-Host "[DRY RUN] Would create compliance standard with $($controls.Count) controls" -ForegroundColor Yellow
    $standardId = "dry-run-id"
} else {
    try {
        $standardResult = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/compliance" -Method POST -Headers @{Authorization="Bearer $token"} -Body $standardBody -ContentType "application/json" -ErrorAction Stop
        Write-Host "Compliance standard created successfully" -ForegroundColor Green
        $standardId = $standardResult.id
    } catch {
        Write-Host "Failed to create compliance standard: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# Create requirements
Write-Host "Creating compliance requirements..." -ForegroundColor Blue
$requirements = @(
    @{ name="Encryption Key Management"; control_id="CC-001"; severity="High" },
    @{ name="Network Segmentation"; control_id="CC-002"; severity="High" },
    @{ name="Multi-Factor Authentication"; control_id="CC-003"; severity="Critical" },
    @{ name="Security Event Logging"; control_id="CC-004"; severity="Medium" },
    @{ name="Regular Vulnerability Scans"; control_id="CC-005"; severity="High" }
)

$reqSuccess = 0
foreach ($req in $requirements) {
    Write-Host "Creating requirement: $($req.name)" -ForegroundColor Blue
    if ($DryRun) {
        Write-Host "[DRY RUN] Would create requirement: $($req.name)" -ForegroundColor Yellow
        $reqSuccess++
    } else {
        $reqBody = $req | ConvertTo-Json
        try {
            $null = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/compliance/$standardId/requirements" -Method POST -Headers @{Authorization="Bearer $token"} -Body $reqBody -ContentType "application/json" -ErrorAction Stop
            Write-Host "Requirement created: $($req.name)" -ForegroundColor Green
            $reqSuccess++
        } catch {
            Write-Host "Failed to create requirement: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Create policy mappings
Write-Host "Creating policy mappings..." -ForegroundColor Blue
$mappings = @(
    @{ policy_id="aws-s3-bucket-encryption"; control_id="CC-001"; cloud_type="aws"; enabled=$true },
    @{ policy_id="aws-security-group-open-port"; control_id="CC-002"; cloud_type="aws"; enabled=$true },
    @{ policy_id="aws-iam-mfa-enabled"; control_id="CC-003"; cloud_type="aws"; enabled=$true },
    @{ policy_id="aws-cloudtrail-enabled"; control_id="CC-004"; cloud_type="aws"; enabled=$true },
    @{ policy_id="aws-guardduty-enabled"; control_id="CC-005"; cloud_type="aws"; enabled=$true }
)

$mapSuccess = 0
foreach ($mapping in $mappings) {
    Write-Host "Creating policy mapping: $($mapping.policy_id)" -ForegroundColor Blue
    if ($DryRun) {
        Write-Host "[DRY RUN] Would create policy mapping: $($mapping.policy_id)" -ForegroundColor Yellow
        $mapSuccess++
    } else {
        $mapBody = $mapping | ConvertTo-Json
        try {
            $null = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/compliance/$standardId/policy-mappings" -Method POST -Headers @{Authorization="Bearer $token"} -Body $mapBody -ContentType "application/json" -ErrorAction Stop
            Write-Host "Policy mapping created: $($mapping.policy_id)" -ForegroundColor Green
            $mapSuccess++
        } catch {
            Write-Host "Failed to create policy mapping: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Create assessment criteria
Write-Host "Creating assessment criteria..." -ForegroundColor Blue
$criteria = @(
    @{ control_id="CC-001"; assessment_type="Automated"; criteria="Check encryption settings" },
    @{ control_id="CC-002"; assessment_type="Automated"; criteria="Verify network security" },
    @{ control_id="CC-003"; assessment_type="Automated"; criteria="Check MFA configuration" }
)

$critSuccess = 0
foreach ($criterion in $criteria) {
    Write-Host "Creating assessment criteria: $($criterion.control_id)" -ForegroundColor Blue
    if ($DryRun) {
        Write-Host "[DRY RUN] Would create assessment criteria: $($criterion.control_id)" -ForegroundColor Yellow
        $critSuccess++
    } else {
        $critBody = $criterion | ConvertTo-Json
        try {
            $null = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/compliance/$standardId/assessment-criteria" -Method POST -Headers @{Authorization="Bearer $token"} -Body $critBody -ContentType "application/json" -ErrorAction Stop
            Write-Host "Assessment criteria created: $($criterion.control_id)" -ForegroundColor Green
            $critSuccess++
        } catch {
            Write-Host "Failed to create assessment criteria: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Summary
Write-Host ""
Write-Host "Deployment Summary" -ForegroundColor Green
Write-Host "Compliance Standard: $StandardName" -ForegroundColor White
Write-Host "Requirements Created: $reqSuccess/$($requirements.Count)" -ForegroundColor White
Write-Host "Policy Mappings Created: $mapSuccess/$($mappings.Count)" -ForegroundColor White
Write-Host "Assessment Criteria Created: $critSuccess/$($criteria.Count)" -ForegroundColor White
Write-Host ""

# Cloud Type Information
Write-Host "Cloud Type Filtering:" -ForegroundColor Cyan
Write-Host "Supported Cloud Types: AWS, Azure, GCP" -ForegroundColor White
Write-Host "AWS Controls:" -ForegroundColor Yellow
foreach ($control in $controls) {
    Write-Host "  - $($control.name)" -ForegroundColor White
}
Write-Host ""

if ($DryRun) {
    Write-Host "This was a dry run. No actual changes were made." -ForegroundColor Yellow
    Write-Host "Run without -DryRun to create the compliance standard." -ForegroundColor Yellow
} else {
    Write-Host "Custom compliance standard created successfully!" -ForegroundColor Green
    Write-Host "You can now view and manage it in the Prisma Cloud console." -ForegroundColor Green
}