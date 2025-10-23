# Install Node.js on EC2 - Simplest Method

I cannot remotely install Node.js on your EC2, but here's the EASIEST way for you to do it:

## Method 1: Download Node.js Installer (EASIEST)

**On EC2 (via RDP when connection is better):**

1. Open **Microsoft Edge** browser on EC2

2. Go to: **https://nodejs.org**

3. Click **"Download Node.js (LTS)"** - the big green button

4. Wait for `node-v20.x.x-x64.msi` to download

5. **Double-click** the downloaded .msi file

6. Click **"Next"** through all the installation steps

7. Make sure **"Add to PATH"** is checked ✅

8. Click **"Install"**

9. Wait 2-3 minutes for installation

10. **Close and reopen** PowerShell

11. Test: `node --version` (should show v20.x.x)

12. Test: `npm --version` (should show 10.x.x)

**Then run:**
```
cd C:\Users\Administrator\Desktop
node matchmaking-server.cjs
```

Server will start! Keep the window open.

---

## Method 2: Use Chocolatey Package Manager (Alternative)

**On EC2, in PowerShell as Administrator:**

```
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

Wait for Chocolatey to install, then:

```
choco install nodejs-lts -y
```

Wait 5 minutes, then close and reopen PowerShell.

---

## After Node.js is Installed

1. Navigate to Desktop:
```
cd C:\Users\Administrator\Desktop
```

2. Start the server:
```
node matchmaking-server.cjs
```

3. You should see: **"Matchmaking server running on port 3001"**

4. Test from your LOCAL PC:
```
curl http://13.59.157.124:3001
```

Should return: **"Cannot GET /"** ✅

---

## For 24/7 Operation (After Node.js is installed)

Once Node.js works, install PM2:
```
npm install -g pm2
pm2 start matchmaking-server.cjs --name matchmaking-server
pm2 save
pm2 startup
```

---

**SORRY:** I cannot remotely install software on your EC2 instance. You need to do it via RDP when the connection is better, or wait until EC2 performance improves!
