@echo off
echo ================================================
echo Adding Windows Firewall Rule for Port 3001
echo ================================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: This script must be run as Administrator!
    echo.
    echo Right-click this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo Adding firewall rule...
netsh advfirewall firewall add rule name="WebSocket Port 3001" dir=in action=allow protocol=TCP localport=3001

if %errorlevel% equ 0 (
    echo.
    echo ================================================
    echo SUCCESS! Firewall rule added successfully!
    echo ================================================
    echo.
    echo Port 3001 is now open for WebSocket connections
    echo Players can now connect to your game at hideoutads.online
    echo.
) else (
    echo.
    echo ================================================
    echo ERROR: Failed to add firewall rule
    echo ================================================
    echo.
)

pause
