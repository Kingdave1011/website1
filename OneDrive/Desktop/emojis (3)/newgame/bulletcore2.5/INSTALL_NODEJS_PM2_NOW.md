# 🚀 Install Node.js & PM2 on EC2 (Quick Fix)

## Problem: PM2 command not found

You need to install Node.js and PM2 first.

---

## Quick Installation (Copy These Commands)

**Run these in PowerShell on EC2:**

### Step 1: Install Node.js

```powershell
# Download Node.js LTS installer
Invoke-WebRequest -Uri "https://nodejs.org/dist/v20.10.0/node-v20.10.0-x64.msi" -OutFile "$env:TEMP\nodejs.msi"

# Install Node.js silently
Start-Process msiexec.exe -Wait -ArgumentList "/i $env:TEMP\nodejs.msi /quiet /norestart"

# Close and reopen PowerShell, then verify
node --version
npm --version
```

### Step 2: Install PM2

```powershell
npm install -g pm2
pm2 --version
```

### Step 3: Start Multiplayer Server

```powershell
cd C:\gameservers
pm2 start matchmaking-server.cjs --name "multiplayer-server"
pm2 save
pm2 status
```

### Step 4: Setup Auto-Start

```powershell
pm2 startup
# Copy and run the command it shows
pm2 save
```

---

## Alternative: Quick Chocolatey Install

```powershell
# Install Chocolatey (if not installed)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Node.js via Chocolatey
choco install nodejs-lts -y

# Refresh environment
refreshenv

# Install PM2
npm install -g pm2

# Start server
cd C:\gameservers
pm2 start matchmaking-server.cjs --name "multiplayer-server"
pm2 save
```

---

## After Installation

```powershell
# Verify port 3001 is listening
netstat -ano | findstr :3001

# Check server logs
pm2 logs multiplayer-server --lines 20
```

Then test: https://hideoutads.online/multiplayer-lobby.html

---

*This will install Node.js v20 LTS and PM2, then start your server!*
