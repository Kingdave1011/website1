# Fix EC2 WebSocket Connection Issue

## Problem
Your matchmaking server (PM2) shows "online" but the game can't connect. You're seeing:
- ❌ "Connection error. Server may be starting..."
- ❌ "Disconnected from server. Reconnecting..."

## Root Cause
Your EC2 Security Group doesn't allow incoming connections on port 3001 (your WebSocket server port).

---

## Solution: Add Security Group Rule for Port 3001

### Step 1: Go to Security Groups
1. In AWS Console, go to **EC2 Dashboard**
2. Click **Security Groups** in the left sidebar (under "Network & Security")
3. Find your security group: **launch-wizard-4** (or **sg-0acaef97ccdded333**)
4. Click on it

### Step 2: Add Inbound Rule
1. Click the **Inbound rules** tab at the bottom
2. Click **Edit inbound rules** button
3. Click **Add rule**
4. Configure the new rule:
   - **Type**: Custom TCP
   - **Port range**: 3001
   - **Source**: Custom - 0.0.0.0/0 (allows all IPs)
   - **Description**: WebSocket Matchmaking Server

5. Click **Save rules**

### Step 3: Add Windows Firewall Rule (On EC2 Server)

Connect to your EC2 via RDP and run this in Command Prompt:

```bash
netsh advfirewall firewall add rule name="WebSocket Port 3001" dir=in action=allow protocol=TCP localport=3001
```

---

## Visual Guide

**Current Security Group Rules** (What you probably have):
```
Port 3389 (RDP) - ✅ Working
Port 80 (HTTP) - Maybe
Port 443 (HTTPS) - Maybe
```

**What You Need to Add**:
```
Port 3001 (WebSocket) - ❌ MISSING!
```

---

## Quick Fix Steps:

1. **AWS Console** → **EC2** → **Security Groups**
2. Select **launch-wizard-4**
3. **Inbound rules** tab → **Edit inbound rules**
4. **Add rule**:
   - Type: Custom TCP
   - Port: 3001
   - Source: 0.0.0.0/0
5. **Save rules**
6. **RDP into EC2** and run the Windows Firewall command above
7. **Test**: Refresh your multiplayer-lobby.html page

---

## After Adding the Rule

Your connection error messages should disappear and you'll see:
- ✅ "Server Online! Connected to chat."
- ✅ Ping shows "5ms" instead of "Offline"
- ✅ Chat works properly

---

## Verification

After adding the rule, test the connection:

1. Open: `https://kingdave1011.github.io/website1/HideoutAdsWebsite/multiplayer-lobby.html`
2. Check the chat box
3. You should see: "✅ Server Online! Connected to chat."
4. If you still see errors, wait 1-2 minutes and refresh

---

## Common Issues

**Still not working after adding rule?**
- Wait 1-2 minutes for AWS to apply the rule
- Make sure you clicked "Save rules"
- Verify the PM2 server is still running: `pm2 status`
- Check Windows Firewall was configured
- Try restarting the matchmaking server: `pm2 restart matchmaking-server`

**Wrong security group?**
- Your instance might have multiple security groups
- In EC2 Instances, select your instance
- Look at "Security" tab
- Check all listed security groups and add the rule to each one

---

## Current Server Details

- **Server Address**: ec2-18-116-64-173.us-east-2.compute.amazonaws.com
- **WebSocket Port**: 3001
- **Protocol**: ws:// (WebSocket)
- **Security Group ID**: sg-0acaef97ccdded333
- **Security Group Name**: launch-wizard-4

---

## Expected Result

After fixing, the multiplayer lobby should show:
```
✅ Server Online! Connected to chat.
US East - Ohio: 1/32 Players | Ping: 5ms
```

And you should be able to send chat messages!
