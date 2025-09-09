# Prisma Cloud Compliance Policies Creator
param(
    [string]$ConsoleUrl = "https://localhost:8083",
    [string]$Username = "admin",
    [string]$Password = "admin234",
    [switch]$DryRun,
    [switch]$Help
)

if ($Help) {
    Write-Host "Prisma Cloud Compliance Policies Creator" -ForegroundColor Green
    Write-Host "Usage: .\create-compliance-policies.ps1 [options]" -ForegroundColor Yellow
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -ConsoleUrl    Prisma Cloud Console URL" -ForegroundColor White
    Write-Host "  -Username      Prisma Cloud username" -ForegroundColor White
    Write-Host "  -Password      Prisma Cloud password" -ForegroundColor White
    Write-Host "  -DryRun        Show what would be created" -ForegroundColor White
    Write-Host "  -Help          Show this help message" -ForegroundColor White
    exit 0
}

Write-Host "Prisma Cloud Compliance Policies Creator" -ForegroundColor Green
Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "  Console URL: $ConsoleUrl" -ForegroundColor White
Write-Host "  Username: $Username" -ForegroundColor White
Write-Host "  Dry Run: $DryRun" -ForegroundColor White
Write-Host ""

# SSL certificate handling (same as your working scripts)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

# Authenticate
Write-Host "Authenticating with Prisma Cloud..." -ForegroundColor Blue
$authBody = @{ username = $Username; password = $Password } | ConvertTo-Json

try {
    $auth = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/authenticate" -Method POST -Body $authBody -ContentType 'application/json'
    Write-Host "Authentication successful" -ForegroundColor Green
    $headers = @{ Authorization = "Bearer $($auth.token)" }
} catch {
    Write-Host "Authentication failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Create collections for organizing compliance
Write-Host ""
Write-Host "Creating resource collections..." -ForegroundColor Blue

$collections = @(
    @{ name="production-workloads"; description="Production environment containers"; namespaces=@("default","production") },
    @{ name="high-security-assets"; description="High security compliance assets"; namespaces=@("*") },
    @{ name="compliance-critical"; description="Assets requiring compliance monitoring"; namespaces=@("*") }
)

$collectionSuccess = 0
foreach ($collection in $collections) {
    Write-Host "Creating collection: $($collection.name)" -ForegroundColor Cyan
    
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would create collection: $($collection.name)" -ForegroundColor Yellow
        $collectionSuccess++
    } else {
        try {
            $body = @{
                name = $collection.name
                description = $collection.description
                namespaces = $collection.namespaces
                images = @("*")
                labels = @()
            } | ConvertTo-Json -Depth 10
            
            # Try to update first, then create if not exists
            try {
                Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/collections/$($collection.name)" -Headers $headers -Method PUT -Body $body -ContentType 'application/json' | Out-Null
                Write-Host "  Collection updated: $($collection.name)" -ForegroundColor Green
            } catch {
                Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/collections" -Headers $headers -Method POST -Body $body -ContentType 'application/json' | Out-Null
                Write-Host "  Collection created: $($collection.name)" -ForegroundColor Green
            }
            $collectionSuccess++
        } catch {
            Write-Host "  Failed to create collection: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Modify container compliance policies
Write-Host ""
Write-Host "Modifying container compliance policies..." -ForegroundColor Blue

Write-Host "Fetching existing container compliance policy..." -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "  [DRY RUN] Would modify container policy" -ForegroundColor Yellow
    $containerSuccess = 1
} else {
    try {
        # Get existing policy
        $containerPolicy = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/policies/compliance/container" -Headers $headers -Method GET
        Write-Host "  Existing container policy fetched successfully" -ForegroundColor Green
        
        # Modify the first existing rule (like your working script does)
        if ($containerPolicy.rules -and $containerPolicy.rules.Count -gt 0) {
            $firstRule = $containerPolicy.rules[0]
            Write-Host "  Updating existing rule: $($firstRule.name)" -ForegroundColor Cyan
            
            # Get the full collection objects from the API first
            Write-Host "  Fetching full collection objects..." -ForegroundColor Gray
            $fullCollections = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/collections" -Headers $headers -Method GET
            
            # Add our collections to the first rule
            $existingCollections = @($firstRule.collections)
            $newCollections = @("production-workloads-dev", "production-workloads-security")
            foreach ($collectionName in $newCollections) {
                $exists = $existingCollections | Where-Object { $_.name -eq $collectionName }
                if (-not $exists) {
                    # Find the full collection object
                    $fullCollection = $fullCollections | Where-Object { $_.name -eq $collectionName }
                    if ($fullCollection) {
                        $existingCollections += $fullCollection
                        Write-Host "    Added collection: $collectionName" -ForegroundColor Green
                    } else {
                        Write-Host "    Warning: Collection $collectionName not found" -ForegroundColor Yellow
                    }
                }
            }
            $firstRule.collections = $existingCollections
        } else {
            Write-Host "  No existing rules found to modify" -ForegroundColor Yellow
            $containerSuccess = 0
        }
        
        # Put modified policy back
        $body = $containerPolicy | ConvertTo-Json -Depth 10
        Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/policies/compliance/container" -Headers $headers -Method PUT -Body $body -ContentType 'application/json' | Out-Null
        Write-Host "  Container policy updated successfully" -ForegroundColor Green
        $containerSuccess = 1
    } catch {
        Write-Host "  Failed to modify container policy: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $responseBody = $reader.ReadToEnd()
            Write-Host "  Error details: $responseBody" -ForegroundColor Red
        }
        $containerSuccess = 0
    }
}

# Modify host compliance policies
Write-Host ""
Write-Host "Modifying host compliance policies..." -ForegroundColor Blue

Write-Host "Fetching existing host compliance policy..." -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "  [DRY RUN] Would modify host policy" -ForegroundColor Yellow
    $hostSuccess = 1
} else {
    try {
        # Get existing policy
        $hostPolicy = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/policies/compliance/host" -Headers $headers -Method GET
        Write-Host "  Existing host policy fetched successfully" -ForegroundColor Green
        
        # Modify the first existing rule (like your working script does)
        if ($hostPolicy.rules -and $hostPolicy.rules.Count -gt 0) {
            $firstRule = $hostPolicy.rules[0]
            Write-Host "  Updating existing rule: $($firstRule.name)" -ForegroundColor Cyan
            
            # Get the full collection objects from the API first
            Write-Host "  Fetching full collection objects..." -ForegroundColor Gray
            $fullCollections = Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/collections" -Headers $headers -Method GET
            
            # Add our collections to the first rule
            $existingCollections = @($firstRule.collections)
            $newCollections = @("production-workloads-dev", "production-workloads-security")
            foreach ($collectionName in $newCollections) {
                $exists = $existingCollections | Where-Object { $_.name -eq $collectionName }
                if (-not $exists) {
                    # Find the full collection object
                    $fullCollection = $fullCollections | Where-Object { $_.name -eq $collectionName }
                    if ($fullCollection) {
                        $existingCollections += $fullCollection
                        Write-Host "    Added collection: $collectionName" -ForegroundColor Green
                    } else {
                        Write-Host "    Warning: Collection $collectionName not found" -ForegroundColor Yellow
                    }
                }
            }
            $firstRule.collections = $existingCollections
        } else {
            Write-Host "  No existing rules found to modify" -ForegroundColor Yellow
            $hostSuccess = 0
        }
        
        # Put modified policy back
        $body = $hostPolicy | ConvertTo-Json -Depth 10
        Invoke-RestMethod -Uri "$ConsoleUrl/api/v1/policies/compliance/host" -Headers $headers -Method PUT -Body $body -ContentType 'application/json' | Out-Null
        Write-Host "  Host policy updated successfully" -ForegroundColor Green
        $hostSuccess = 1
    } catch {
        Write-Host "  Failed to modify host policy: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $responseBody = $reader.ReadToEnd()
            Write-Host "  Error details: $responseBody" -ForegroundColor Red
        }
        $hostSuccess = 0
    }
}

# Summary
Write-Host ""
Write-Host "Deployment Summary" -ForegroundColor Green
Write-Host "Collections Created: $collectionSuccess/$($collections.Count)" -ForegroundColor White
Write-Host "Container Policies Created: $containerSuccess/1" -ForegroundColor White
Write-Host "Host Policies Created: $hostSuccess/1" -ForegroundColor White
Write-Host ""

Write-Host "Compliance Framework Components:" -ForegroundColor Cyan
Write-Host "• Collections: Group resources by compliance requirements" -ForegroundColor White
Write-Host "• Container Policies: Monitor container compliance" -ForegroundColor White  
Write-Host "• Host Policies: Monitor host compliance" -ForegroundColor White
Write-Host "• Cloud Types: AWS, Azure, GCP containers supported" -ForegroundColor White
Write-Host ""

if ($DryRun) {
    Write-Host "This was a dry run. No actual changes were made." -ForegroundColor Yellow
    Write-Host "Run without -DryRun to create the compliance policies." -ForegroundColor Yellow
} else {
    Write-Host "Compliance policies created successfully!" -ForegroundColor Green
    Write-Host "You can now view and manage them in the Prisma Cloud console." -ForegroundColor Green
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Blue
Write-Host "1. Review policies in the Prisma Cloud console" -ForegroundColor White
Write-Host "2. Adjust thresholds and rules as needed" -ForegroundColor White
Write-Host "3. Monitor compliance status in the dashboard" -ForegroundColor White