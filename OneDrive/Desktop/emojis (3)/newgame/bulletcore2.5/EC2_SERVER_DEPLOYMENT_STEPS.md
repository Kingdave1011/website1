# EC2 Server Deployment - Step by Step Guide

You're now connected to EC2 via RDP. Follow these exact steps to deploy your matchmaking server for 24/7 operation:

## Step 1: Transfer Files to EC2

1. **On your LOCAL PC** (not EC2), navigate to:
   ```
   c:\Users\kinlo\OneDrive\Desktop\emojis (3)\newgame\bulletcore2.5
   ```

2. **Copy these 2 files**:
   - `matchmaking-server.cjs`
   - `setup-ec2-server.bat`

3. **On the EC2 desktop** (in your RDP window):
   - Right-click on the Desktop
   - Click **Paste**
   - The 2 files should appear on EC2 Desktop

## Step 2: Run the Setup Script

1. **On EC2 Desktop**, find `setup-ec2-server.bat`

2. **Right-click** on `setup-ec2-server.bat`

3. Select **"Run as administrator"**

4. Click **"Yes"** when Windows asks for permission

5. **Watch the installation process**:
   - It will install Node.js (if not already installed)
   - It will install PM2 globally
   - It will install WebSocket dependencies
   - It will start the server with PM2
   - It will set PM2 to auto-start on Windows boot

6. **Wait for it to complete** - you'll see:
   ```
   Server is now running 24/7!
   Press any key to continue...
   ```

## Step 3: Verify Server is Running

1. **On EC2**, open Command Prompt or PowerShell

2. Type:
   ```
   pm2 status
   ```

3. **You should see**:
   ```
   ┌─────┬───────────────────────┬─────────┬─────────┬──────────┐
   │ id  │ name                  │ status  │ restart │ uptime   │
   ├─────┼───────────────────────┼─────────┼─────────┼──────────┤
   │ 0   │ matchmaking-server    │ online  │ 0       │ 0s       │
   └─────┴───────────────────────┴─────────┴─────────┴──────────┘
   ```

4. **Check logs** (optional):
   ```
   pm2 logs matchmaking-server
   ```
   - You should see: "Matchmaking server running on port 3001"

## Step 4: Configure Windows Firewall on EC2

1. **On EC2**, open Command Prompt **as administrator**

2. Run this command:
   ```
   netsh advfirewall firewall add rule name="WebSocket Port 3001" dir=in action=allow protocol=TCP localport=3001
   ```

3. You should see: **"Ok."**

## Step 5: Configure AWS Security Group

1. **On your LOCAL PC**, open AWS Console in browser:
   - Go to EC2 Dashboard
   - Click **"Instances"**
   - Find your instance: `i-03ef2c768872f8af0` (IP: 13.59.157.124)

2. Click on the **Security tab**

3. Click on the **Security Group link** (e.g., sg-xxxxxxxxx)

4. Click **"Edit inbound rules"**

5. Click **"Add rule"**:
   - **Type**: Custom TCP
   - **Port range**: 3001
   - **Source**: Anywhere-IPv4 (0.0.0.0/0)
   - **Description**: "WebSocket matchmaking server"

6. Click **"Save rules"**

## Step 6: Test Connection

1. **On your LOCAL PC**, open Command Prompt

2. Test the connection:
   ```
   curl http://13.59.157.124:3001
   ```

3. **Expected response**:
   ```
   Cannot GET /
   ```
   - This is GOOD! It means the server is reachable (WebSocket servers don't respond to HTTP GET)

## Step 7: Update Game Code (Optional - for later)

To connect your game to the EC2 server instead of localhost, edit:
- File: `HideoutAdsWebsite/game/index.tsx`
- Line 1583: Change `ws://localhost:3001` to `ws://13.59.157.124:3001`

## Troubleshooting

### If PM2 shows "errored" status:
```
pm2 logs matchmaking-server
pm2 restart matchmaking-server
```

### If port 3001 is already in use:
```
netstat -ano | findstr :3001
taskkill /PID [process_id] /F
pm2 restart matchmaking-server
```

### If you need to stop the server:
```
pm2 stop matchmaking-server
```

### If you need to remove the server:
```
pm2 delete matchmaking-server
```

### To restart EC2 and verify auto-start works:
1. Restart EC2 from Windows
2. Wait 2 minutes for boot
3. Reconnect via RDP
4. Run: `pm2 status`
5. Server should be "online" automatically!

## Server is now running 24/7!

Your matchmaking server is now:
- ✅ Running on EC2 at 13.59.157.124:3001
- ✅ Configured with PM2 to restart on crashes
- ✅ Configured to auto-start when EC2 boots
- ✅ Accessible from the internet (after Security Group config)

Players can now connect to your multiplayer game!
