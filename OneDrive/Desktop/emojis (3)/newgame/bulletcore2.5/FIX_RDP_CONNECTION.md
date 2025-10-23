# Fix RDP Connection to EC2

## Problem
You can't connect to EC2 via Remote Desktop anymore.

## Common Causes & Solutions

### Solution 1: Check if EC2 Instance is Running

1. Go to **AWS Console** → **EC2** → **Instances**

2. Find instance: **i-03ef2c768872f8af0**

3. Check **Instance State** column:

**If it shows "Stopped":**
- Click the checkbox next to the instance
- Click **"Instance state"** → **"Start instance"**
- Wait 2 minutes for it to start
- Try RDP again: `mstsc /v:13.59.157.124`

**If it shows "Running":** Continue to Solution 2

### Solution 2: Check Security Group for RDP Port

The Security Group might have lost the RDP rule when you edited it.

1. Click on instance **i-03ef2c768872f8af0**

2. Click **Security** tab

3. Click Security Group: **sg-0e8e5d86ead4bc7ea**

4. Click **"Inbound rules"** tab

5. **Look for Port 3389** (RDP port)

**If Port 3389 is missing:**
1. Click **"Edit inbound rules"**
2. Click **"Add rule"**
3. Set:
   - **Type**: RDP
   - **Port**: 3389
   - **Source**: My IP (or 0.0.0.0/0 for anywhere)
4. Click **"Save rules"**

### Solution 3: Get New RDP File

1. In AWS Console, click instance **i-03ef2c768872f8af0**

2. Click **"Connect"** button at the top

3. Go to **"RDP client"** tab

4. Click **"Download remote desktop file"**

5. Open the downloaded .rdp file

6. Enter password and connect

### Solution 4: Connect Using Windows Remote Desktop

1. Press **Windows Key + R**

2. Type: `mstsc`

3. Press Enter

4. Enter: `13.59.157.124`

5. Click **Connect**

6. Enter username: **Administrator**

7. Enter your password

---

## After You Reconnect to EC2

Run these commands in Command Prompt on EC2:

```
cd C:\GameServers
pm2 start matchmaking-server.cjs --name matchmaking-server
pm2 save
pm2 status
```

Should show: `matchmaking-server | online`

Then test: `curl http://13.59.157.124:3001`

---

## Quick Fix Checklist

- [ ] EC2 instance is "Running" in AWS Console
- [ ] Security Group has port 3389 (RDP) rule
- [ ] Security Group has port 3001 (WebSocket) rule
- [ ] Can connect via RDP
- [ ] PM2 server is started
- [ ] Curl test passes

Most likely the Security Group lost the RDP port rule when you added port 3001!
