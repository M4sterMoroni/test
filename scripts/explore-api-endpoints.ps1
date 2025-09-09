# Prisma Cloud API Explorer
# This script helps identify available API endpoints

param(
    [string]$ConsoleUrl = "https://localhost:8083",
    [string]$Username = "admin",
    [string]$Password = "admin234"
)

Write-Host "Prisma Cloud API Explorer" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green
Write-Host ""

# Handle SSL certificate validation
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
    $authResult = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/authenticate" -Method POST -Body $authBody -ContentType "application/json" -ErrorAction Stop
    if ($authResult.token) {
        Write-Host "✓ Authentication successful" -ForegroundColor Green
        $token = $authResult.token
    } else {
        Write-Host "✗ Authentication failed - no token received" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Authentication failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test various API endpoints that might be related to compliance
$testEndpoints = @(
    "/api/v1/policies",
    "/api/v1/compliance",
    "/api/v1/compliance-standards",
    "/api/v1/compliance/standards",
    "/api/v1/standards",
    "/api/v1/config",
    "/api/v1/version",
    "/api/v1/info",
    "/api/v1/settings",
    "/api/v1/audits",
    "/api/v1/rules",
    "/api/v1/collections",
    "/api/v1/tags",
    "/api/v1"
)

Write-Host ""
Write-Host "Testing API endpoints..." -ForegroundColor Blue
Write-Host ""

$workingEndpoints = @()

foreach ($endpoint in $testEndpoints) {
    try {
        Write-Host "Testing: $endpoint" -ForegroundColor Cyan
        $response = Invoke-RestMethod -Uri "$ConsoleUrl$endpoint" -Method GET -Headers @{Authorization="Bearer $token"} -ErrorAction Stop
        Write-Host "  ✓ Success - Endpoint exists" -ForegroundColor Green
        $workingEndpoints += $endpoint
        
        # If it's the base API endpoint, show available paths
        if ($endpoint -eq "/api/v1" -and $response -is [PSCustomObject]) {
            Write-Host "    Available paths:" -ForegroundColor Yellow
            $response.PSObject.Properties | ForEach-Object {
                Write-Host "      - $($_.Name): $($_.Value)" -ForegroundColor White
            }
        }
        
        # Show some sample data for smaller responses
        if ($response -is [Array] -and $response.Count -lt 10) {
            Write-Host "    Sample data: $($response.Count) items" -ForegroundColor Yellow
        } elseif ($response -is [PSCustomObject]) {
            $propCount = ($response.PSObject.Properties | Measure-Object).Count
            Write-Host "    Response contains $propCount properties" -ForegroundColor Yellow
        }
        
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.Value__
        if ($statusCode -eq 404) {
            Write-Host "  ✗ 404 - Not Found" -ForegroundColor Red
        } elseif ($statusCode -eq 403) {
            Write-Host "  ✗ 403 - Forbidden (endpoint exists but no permission)" -ForegroundColor Yellow
        } elseif ($statusCode -eq 405) {
            Write-Host "  ✗ 405 - Method not allowed (try POST)" -ForegroundColor Yellow
        } else {
            Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "Summary" -ForegroundColor Green
Write-Host "=======" -ForegroundColor Green
Write-Host "Working endpoints:" -ForegroundColor Cyan
foreach ($endpoint in $workingEndpoints) {
    Write-Host "  - $endpoint" -ForegroundColor White
}

if ($workingEndpoints.Count -eq 0) {
    Write-Host "No working endpoints found. This might indicate:" -ForegroundColor Yellow
    Write-Host "  - API version differences" -ForegroundColor White
    Write-Host "  - Different authentication requirements" -ForegroundColor White
    Write-Host "  - Feature not available in this Prisma Cloud version" -ForegroundColor White
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Blue
Write-Host "1. Check Prisma Cloud documentation for your version" -ForegroundColor White
Write-Host "2. Look for compliance-related endpoints in working paths" -ForegroundColor White
Write-Host "3. Try different API versions (v2, v3, etc.)" -ForegroundColor White
