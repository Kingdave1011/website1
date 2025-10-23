# 🚀 START MULTIPLAYER SERVER NOW

## Problem: AWS is Online, But Game Shows Offline

This means the **PM2 server didn't auto-start** after reboot.

---

## Quick Fix (5 Minutes)

### Step 1: Connect to EC2 via Remote Desktop

1. **Press Windows Key + R**
2. **Type:** `mstsc` and press Enter
3. **In Remote Desktop Connection:**
   - Computer: `18.116.64.173`
   - Click "Connect"
4. **Enter Credentials:**
   - Username: `Administrator`
   - Password: (your EC2 password)
5. **Click "Yes"** if certificate warning appears

---

### Step 2: Open PowerShell as Administrator

1. **Once connected to EC2 desktop:**
2. **Right-click Start menu**
3. **Select:** "Windows PowerShell (Admin)" or "Terminal (Admin)"
4. **Click "Yes"** if UAC prompt appears

---

### Step 3: Start the Multiplayer Server

**Copy and paste these commands one by one:**

```powershell
# Navigate to server directory
cd C:\gameservers

# Check current PM2 status
pm2 status

# If server is not running, start it:
pm2 start matchmaking-server.cjs --name "multiplayer-server"

# Save PM2 configuration
pm2 save

# Verify server is running
pm2 status
```

**Expected output after `pm2 status`:**
```
┌─────┬───────────────────────┬─────────┬─────────┐
│ id  │ name                  │ status  │ restart │
├─────┼───────────────────────┼─────────┼─────────┤
│ 0   │ multiplayer-server    │ online  │ 0       │
└─────┴───────────────────────┴─────────┴─────────┘
```

---

### Step 4: Verify Port 3001 is Listening

```powershell
netstat -ano | findstr :3001
```

**Expected output:**
```
TCP    0.0.0.0:3001           0.0.0.0:0              LISTENING       1234
```

---

### Step 5: Test From Your Browser

1. **Open:** https://hideoutads.online/multiplayer-lobby.html
2. **Check "Server Status"** - should now show **"Online"** ✅
3. **Player count** should display: "0/32 Players"
4. **Try sending a chat message** to confirm it works

---

## Increase Player Capacity (32 → 100 Players)

**While still in PowerShell on EC2:**

### Update Server Configuration:

```powershell
# Stop the current server
pm2 stop multiplayer-server

# Edit the server file (we'll update it manually)
notepad C:\gameservers\matchmaking-server.cjs
```

**In Notepad, find this line (around line 10-15):**
```javascript
const MAX_PLAYERS = 32;
```

**Change it to:**
```javascript
const MAX_PLAYERS = 100;
```

**Save the file (Ctrl+S) and close Notepad**

**Restart the server:**
```powershell
pm2 restart multiplayer-server
pm2 save
```

---

## Alternative: Quick Script to Change Max Players

**If you can't find the line in Notepad, run this:**

```powershell
# Create a quick update script
$content = Get-Content C:\gameservers\matchmaking-server.cjs
$content = $content -replace 'const MAX_PLAYERS = 32', 'const MAX_PLAYERS = 100'
$content | Set-Content C:\gameservers\matchmaking-server.cjs

# Restart server
pm2 restart multiplayer-server
pm2 logs multiplayer-server --lines 20
```

---

## Setup Auto-Start for Future Reboots

**To prevent this issue in the future:**

```powershell
# Configure PM2 startup
pm2 startup

# This will show you a command to copy and run
# Copy that command and run it

# Save current PM2 process list
pm2 save

# Optional: Install PM2 as Windows Service
npm install -g pm2-windows-service
pm2-service-install -n PM2
```

**After setup, test by rebooting:**
```powershell
Restart-Computer
```

**Wait 3 minutes, then check if PM2 started automatically**

---

## Troubleshooting

### If PM2 command not found:

```powershell
# Install PM2
npm install -g pm2

# Then start server
pm2 start C:\gameservers\matchmaking-server.cjs --name "multiplayer-server"
pm2 save
```

### If Node.js not installed:

```powershell
# Download and install Node.js
winget install OpenJS.NodeJS.LTS

# Close and reopen PowerShell
# Then install PM2 and start server
npm install -g pm2
pm2 start C:\gameservers\matchmaking-server.cjs --name "multiplayer-server"
pm2 save
```

### Check Server Logs:

```powershell
pm2 logs multiplayer-server --lines 50
```

### Restart If Issues:

```powershell
pm2 restart multiplayer-server
pm2 logs multiplayer-server
```

---

## Verify Everything Works

### Checklist:
- [ ] Connected to EC2 via RDP
- [ ] Opened PowerShell as Administrator
- [ ] Ran `pm2 status` - shows "online"
- [ ] Port 3001 is listening (netstat check)
- [ ] Website shows "Server Status: Online"
- [ ] Player capacity increased to 100
- [ ] PM2 auto-start configured for future reboots

---

## Quick Commands Summary

```powershell
# Start server
cd C:\gameservers
pm2 start matchmaking-server.cjs --name "multiplayer-server"
pm2 save

# Check status
pm2 status
pm2 logs multiplayer-server --lines 20

# Restart server
pm2 restart multiplayer-server

# Setup auto-start
pm2 startup
pm2 save
```

---

## After You're Done

1. **Don't close RDP yet** - test the website first
2. **Open browser on your PC:** https://hideoutads.online/multiplayer-lobby.html
3. **Verify "Online" status**
4. **Try chat and joining**
5. **If all works, you can disconnect RDP**

---

*Server should now be online and accept up to 100 players! 🚀*
