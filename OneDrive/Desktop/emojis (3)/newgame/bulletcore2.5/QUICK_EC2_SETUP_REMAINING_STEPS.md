# Quick Setup - Remaining Steps (You're on EC2 now!)

You've completed the firewall step! ✅ Now complete these final steps:

## Step 1: Copy Files to EC2 (RIGHT NOW)

1. **On your LOCAL PC** (not EC2), navigate to:
   ```
   c:\Users\kinlo\OneDrive\Desktop\emojis (3)\newgame\bulletcore2.5
   ```

2. **Select and copy these 2 files** (Ctrl+C):
   - `matchmaking-server.cjs`
   - `setup-ec2-server.bat`

3. **Switch to EC2 window** (your RDP session)

4. **On EC2 Desktop**, right-click → **Paste** (Ctrl+V)

5. Verify both files are now on EC2 Desktop

## Step 2: Run Setup Script on EC2

1. **On EC2 Desktop**, find `setup-ec2-server.bat`

2. **Right-click** → Select **"Run as administrator"**

3. Click **"Yes"** when prompted

4. **Watch the installation** (takes 2-3 minutes):
   - Installs Node.js
   - Installs PM2
   - Installs WebSocket library
   - Starts server with PM2
   - Configures auto-start on boot

5. Wait until you see: **"Server is now running 24/7!"**

## Step 3: Verify Server is Running

On EC2, open Command Prompt and type:
```
pm2 status
```

**Expected output:**
```
┌─────┬────────────────────┬─────────┬─────────┬──────────┐
│ id  │ name               │ status  │ restart │ uptime   │
├─────┼────────────────────┼─────────┼─────────┼──────────┤
│ 0   │ matchmaking-server │ online  │ 0       │ 5s       │
└─────┴────────────────────┴─────────┴─────────┴──────────┘
```

If you see **"online"** - SUCCESS! ✅

## Step 4: Configure AWS Security Group (Do this on LOCAL PC)

1. **On your LOCAL PC**, open browser and go to AWS Console

2. Navigate to **EC2 Dashboard** → **Instances**

3. Find your instance: **i-03ef2c768872f8af0** (13.59.157.124)

4. Click on the **Security** tab

5. Click on the **Security Group** link (looks like sg-xxxxxxxxx)

6. Click **"Edit inbound rules"**

7. Click **"Add rule"**:
   - **Type**: Custom TCP
   - **Port range**: 3001
   - **Source**: Anywhere-IPv4 (0.0.0.0/0)
   - **Description**: WebSocket matchmaking server

8. Click **"Save rules"**

## Step 5: Test the Connection (On LOCAL PC)

Open Command Prompt on your LOCAL PC and type:
```
curl http://13.59.157.124:3001
```

**Expected response:**
```
Cannot GET /
```

This is GOOD! It means the server is reachable (WebSocket servers don't respond to HTTP GET).

## Step 6: Update Game Code (Optional - for later)

When ready to connect your game to EC2, edit this file:
- **File**: `HideoutAdsWebsite/game/index.tsx`
- **Line 1583**: Change from `ws://localhost:3001` to `ws://13.59.157.124:3001`

Then deploy to your website (Vercel/Netlify).

## YOU'RE DONE! 🎉

Your matchmaking server is now:
- ✅ Running 24/7 on EC2
- ✅ Auto-restarts if it crashes
- ✅ Auto-starts when EC2 boots
- ✅ Accessible worldwide at 13.59.157.124:3001

Players can now connect to your multiplayer game from anywhere!

## Helpful PM2 Commands (Run on EC2)

View status:
```
pm2 status
```

View logs:
```
pm2 logs matchmaking-server
```

Restart server:
```
pm2 restart matchmaking-server
```

Stop server:
```
pm2 stop matchmaking-server
```

Start server:
```
pm2 start matchmaking-server
