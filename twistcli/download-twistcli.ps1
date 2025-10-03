# Download TwistCLI from Prisma Cloud Console

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

$ConsoleUrl = 'https://localhost:8083'
$Username = 'admin'
$Password = 'admin234'

# Create credentials
$cred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$Username`:$Password"))

try {
    Write-Host "Downloading TwistCLI from $ConsoleUrl..." -ForegroundColor Cyan
    
    # Download TwistCLI
    $response = Invoke-WebRequest -Uri "$ConsoleUrl/api/v1/util/twistcli" `
                                 -Headers @{Authorization="Basic $cred"} `
                                 -OutFile "twistcli.exe" `
                                 -ErrorAction Stop
    
    Write-Host "✅ TwistCLI downloaded successfully!" -ForegroundColor Green
    
    # Check if file was created
    if (Test-Path "twistcli.exe") {
        $fileSize = (Get-Item "twistcli.exe").Length
        Write-Host "File size: $fileSize bytes" -ForegroundColor White
        
        # Make executable (if needed)
        Write-Host "TwistCLI is ready to use!" -ForegroundColor Green
    } else {
        Write-Host "❌ TwistCLI download failed - file not found" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Failed to download TwistCLI: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please download manually from: $ConsoleUrl" -ForegroundColor Yellow
    Write-Host "Navigate to: Settings → System → Downloads" -ForegroundColor Yellow
}
