@echo off
echo ================================================
echo Setting Up Matchmaking Server on EC2
echo ================================================
echo.

REM Install Chocolatey
echo Installing Chocolatey...
powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"

echo.
echo Installing Node.js...
choco install nodejs -y

echo.
echo Creating GameServers directory...
mkdir C:\GameServers
cd C:\GameServers

echo.
echo ================================================
echo IMPORTANT: Copy matchmaking-server.cjs to C:\GameServers
echo ================================================
echo.
pause

echo Installing dependencies...
npm install ws

echo Installing PM2...
npm install -g pm2

echo Starting matchmaking server...
pm2 start matchmaking-server.cjs --name "matchmaking"
pm2 save
pm2 startup

echo.
echo Opening firewall port 3001...
netsh advfirewall firewall add rule name="Match" dir=in action=allow protocol=TCP localport=3001

echo.
echo ================================================
echo SUCCESS! Matchmaking server is running!
echo ================================================
echo.
echo Server IP: 13.59.157.124
echo Port: 3001
echo.
echo To check status: pm2 status
echo To view logs: pm2 logs matchmaking
echo.
pause
