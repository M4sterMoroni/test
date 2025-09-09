# Prisma Cloud Security Policies Creator
# Alternative to compliance standards - creates security policies

param(
    [string]$ConsoleUrl = "https://localhost:8083",
    [string]$Username = "admin",
    [string]$Password = "admin234",
    [switch]$DryRun,
    [switch]$Help
)

if ($Help) {
    Write-Host "Prisma Cloud Security Policies Creator" -ForegroundColor Green
    Write-Host "Usage: .\create-security-policies.ps1 [options]" -ForegroundColor Yellow
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -ConsoleUrl    Prisma Cloud Console URL" -ForegroundColor White
    Write-Host "  -Username      Prisma Cloud username" -ForegroundColor White
    Write-Host "  -Password      Prisma Cloud password" -ForegroundColor White
    Write-Host "  -DryRun        Show what would be created" -ForegroundColor White
    Write-Host "  -Help          Show this help message" -ForegroundColor White
    exit 0
}

Write-Host "Prisma Cloud Security Policies Creator" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "  Console URL: $ConsoleUrl" -ForegroundColor White
Write-Host "  Username: $Username" -ForegroundColor White
Write-Host "  Dry Run: $DryRun" -ForegroundColor White
Write-Host ""

# Handle SSL certificates
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

# Authenticate
Write-Host "Authenticating with Prisma Cloud..." -ForegroundColor Blue
$authBody = @{ username = $Username; password = $Password } | ConvertTo-Json

try {
    $authResult = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/authenticate" -Method POST -Body $authBody -ContentType "application/json"
    $token = $authResult.token
    Write-Host "✓ Authentication successful" -ForegroundColor Green
} catch {
    Write-Host "✗ Authentication failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test what endpoints are available
Write-Host ""
Write-Host "Discovering available endpoints..." -ForegroundColor Blue

$testEndpoints = @("/api/v1/policies", "/api/v1/collections", "/api/v1/rules")
$availableEndpoints = @()

foreach ($endpoint in $testEndpoints) {
    try {
        $response = Invoke-RestMethod -Uri "$ConsoleUrl$endpoint" -Headers @{Authorization="Bearer $token"}
        Write-Host "✓ $endpoint is available" -ForegroundColor Green
        $availableEndpoints += $endpoint
    } catch {
        Write-Host "✗ $endpoint not available" -ForegroundColor Red
    }
}

if ($availableEndpoints.Count -eq 0) {
    Write-Host ""
    Write-Host "No standard endpoints available. This might be:" -ForegroundColor Yellow
    Write-Host "• A different version of Prisma Cloud Compute" -ForegroundColor White
    Write-Host "• A limited edition or trial version" -ForegroundColor White
    Write-Host "• Different API structure" -ForegroundColor White
    Write-Host ""
    Write-Host "Try checking the Prisma Cloud console manually to see available features." -ForegroundColor Cyan
    exit 1
}

# If policies endpoint is available, try to create security policies
if ("/api/v1/policies" -in $availableEndpoints) {
    Write-Host ""
    Write-Host "Creating security policies..." -ForegroundColor Blue
    
    $policies = @(
        @{
            name = "Container Image Vulnerability Policy"
            description = "Ensures container images are scanned for vulnerabilities"
            type = "image"
            enabled = $true
            enforcement = "block"
        },
        @{
            name = "Runtime Security Policy"
            description = "Monitors runtime behavior for security threats"
            type = "runtime"
            enabled = $true
            enforcement = "alert"
        },
        @{
            name = "Network Security Policy"
            description = "Controls network access and communication"
            type = "network"
            enabled = $true
            enforcement = "block"
        }
    )
    
    $policySuccess = 0
    foreach ($policy in $policies) {
        Write-Host "Creating policy: $($policy.name)" -ForegroundColor Cyan
        
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would create: $($policy.name)" -ForegroundColor Yellow
            $policySuccess++
        } else {
            try {
                $policyBody = $policy | ConvertTo-Json
                $result = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/policies" -Method POST -Headers @{Authorization="Bearer $token"} -Body $policyBody -ContentType "application/json"
                Write-Host "  ✓ Policy created: $($policy.name)" -ForegroundColor Green
                $policySuccess++
            } catch {
                Write-Host "  ✗ Failed to create policy: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    
    Write-Host ""
    Write-Host "Policy creation summary:" -ForegroundColor Green
    Write-Host "Policies created: $policySuccess/$($policies.Count)" -ForegroundColor White
}

# If collections endpoint is available, create collections
if ("/api/v1/collections" -in $availableEndpoints) {
    Write-Host ""
    Write-Host "Creating resource collections..." -ForegroundColor Blue
    
    $collections = @(
        @{
            name = "Production Workloads"
            description = "Production environment containers and hosts"
            query = "environment:production"
        },
        @{
            name = "High Security Assets"
            description = "Assets requiring high security controls"
            query = "label:security=high"
        }
    )
    
    $collectionSuccess = 0
    foreach ($collection in $collections) {
        Write-Host "Creating collection: $($collection.name)" -ForegroundColor Cyan
        
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would create: $($collection.name)" -ForegroundColor Yellow
            $collectionSuccess++
        } else {
            try {
                $collectionBody = $collection | ConvertTo-Json
                $result = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/collections" -Method POST -Headers @{Authorization="Bearer $token"} -Body $collectionBody -ContentType "application/json"
                Write-Host "  ✓ Collection created: $($collection.name)" -ForegroundColor Green
                $collectionSuccess++
            } catch {
                Write-Host "  ✗ Failed to create collection: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    
    Write-Host ""
    Write-Host "Collection creation summary:" -ForegroundColor Green
    Write-Host "Collections created: $collectionSuccess/$($collections.Count)" -ForegroundColor White
}

Write-Host ""
Write-Host "Summary" -ForegroundColor Green
Write-Host "=======" -ForegroundColor Green
Write-Host "Available endpoints: $($availableEndpoints -join ', ')" -ForegroundColor White

if ($DryRun) {
    Write-Host "This was a dry run. No actual changes were made." -ForegroundColor Yellow
} else {
    Write-Host "Security configuration completed!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Note: This creates security policies instead of compliance standards," -ForegroundColor Cyan
Write-Host "which provides similar functionality for cloud security management." -ForegroundColor Cyan
