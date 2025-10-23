# ❌ Wrong: You're Installing in AWS CloudShell (Won't Work!)

## The Problem:
You're trying to install PM2 in **AWS CloudShell** (a Linux environment), but your game server needs to run on your **EC2 Windows Server** at IP `18.116.64.173`.

AWS CloudShell ≠ Your EC2 Game Server

---

## ✅ Correct Solution: Install on EC2 Windows Server

You need to connect to your **actual EC2 instance** and install there.

---

## Option 1: Connect via Remote Desktop (RDP) - EASIEST

### Step 1: Open Remote Desktop

**On Windows:**
1. Press `Windows Key + R`
2. Type: `mstsc`
3. Press Enter

### Step 2: Connect to EC2

**In Remote Desktop Connection window:**
- Computer: `18.116.64.173`
- Click "Connect"
- Username: `Administrator`
- Password: (your EC2 Windows password)

### Step 3: Install Node.js & PM2 on EC2

**Once connected to EC2 desktop, open PowerShell:**

```powershell
# Download Node.js
Invoke-WebRequest -Uri "https://nodejs.org/dist/v20.10.0/node-v20.10.0-x64.msi" -OutFile "$env:TEMP\nodejs.msi"

# Install Node.js
Start-Process msiexec.exe -Wait -ArgumentList "/i $env:TEMP\nodejs.msi /quiet /norestart"

# IMPORTANT: Close PowerShell and open a NEW PowerShell window

# Install PM2
npm install -g pm2

# Start server
cd C:\gameservers
pm2 start matchmaking-server.cjs --name "multiplayer-server"
pm2 save
pm2 status
```

---

## Option 2: Use Systems Manager (SSM) Session Manager

**If you can't RDP, try this from AWS CloudShell:**

### In CloudShell, run:

```bash
# Start SSM session to your EC2 instance
aws ssm start-session --target i-0b45bbd8105d85e19

# Once connected, switch to PowerShell
powershell

# Then run the installation commands from Option 1
```

---

## Option 3: Fix CloudShell Permission (If You Must Use It)

**This won't help your game server, but if you just want PM2 in CloudShell:**

```bash
# Use sudo for global npm installs
sudo npm install -g pm2

# Or install locally (no sudo needed)
npm install pm2
npx pm2 --version
```

**But remember:** Installing PM2 in CloudShell does NOT start your game server! You must install it on EC2.

---

## Why This Matters:

### AWS CloudShell:
- ❌ Not your game server
- ❌ Players can't connect to it
- ❌ Temporary Linux environment
- ✅ Only for AWS management commands

### EC2 Windows Server (18.116.64.173):
- ✅ Your actual game server
- ✅ Players connect here
- ✅ Where PM2 needs to run
- ✅ Persistent Windows environment

---

## Quick Test After Installation:

**On EC2 (after installing PM2):**

```powershell
# Check if PM2 is running
pm2 status

# Check if port 3001 is listening
netstat -ano | findstr :3001

# View server logs
pm2 logs multiplayer-server --lines 20
```

**On your PC (test connection):**
```powershell
Test-NetConnection -ComputerName 18.116.64.173 -Port 3001
```

---

## Summary:

1. **Close AWS CloudShell** - it won't help you
2. **Connect to EC2 via Remote Desktop** (mstsc → 18.116.64.173)
3. **Install Node.js & PM2 on EC2**
4. **Start your server with PM2**
5. **Test from your website**

---

*You need to install PM2 WHERE your server needs to run (EC2), not where you're managing AWS (CloudShell)!*
