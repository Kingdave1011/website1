# PowerShell script to add Windows Firewall rule for port 3001
# This script will automatically request administrator privileges if needed

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "================================================" -ForegroundColor Yellow
    Write-Host "Requesting Administrator Privileges..." -ForegroundColor Yellow
    Write-Host "================================================" -ForegroundColor Yellow
    Write-Host ""
    
    # Re-launch the script with administrator privileges
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Adding Windows Firewall Rule for Port 3001" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Add the firewall rule
Write-Host "Adding firewall rule..." -ForegroundColor Yellow
netsh advfirewall firewall add rule name="WebSocket Port 3001" dir=in action=allow protocol=TCP localport=3001

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "SUCCESS! Firewall rule added successfully!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Port 3001 is now open for WebSocket connections" -ForegroundColor Green
    Write-Host "Players can now connect to your game at hideoutads.online" -ForegroundColor Green
    Write-Host ""
    
    # Verify the rule was created
    Write-Host "Verifying the rule was created..." -ForegroundColor Yellow
    netsh advfirewall firewall show rule name="WebSocket Port 3001"
} else {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Red
    Write-Host "ERROR: Failed to add firewall rule" -ForegroundColor Red
    Write-Host "================================================" -ForegroundColor Red
    Write-Host ""
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
