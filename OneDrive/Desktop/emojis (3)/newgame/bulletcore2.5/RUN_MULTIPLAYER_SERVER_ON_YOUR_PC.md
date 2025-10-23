# How to Run Multiplayer Server on Your Local PC

## Quick Start (2 minutes)

### Step 1: Open Terminal in multiplayer-server folder

```bash
cd multiplayer-server
```

### Step 2: Install Dependencies (first time only)

```bash
npm install
```

### Step 3: Start the Server

```bash
npm start
```

You should see:
```
🚀 Multiplayer server running on port 3001
✅ Server ready for connections!
```

### Step 4: Keep Terminal Open

The server must stay running in the terminal. Don't close it!

### Step 5: Test on Your Website

Now go to: https://hideoutads.online/multiplayer-lobby

The servers should show as ONLINE! 🟢

---

## What Just Happened?

- Server is now running on `localhost:3001`
- Your multiplayer lobby connects to `ws://localhost:3001`
- Chat and player tracking work in real-time
- Keep the terminal open to keep server running

---

## To Stop the Server

Press `Ctrl+C` in the terminal

---

## Run Server 24/7 (Even When PC is Off)

If you want the server to run even when your PC is off, deploy to Render.com (FREE):

See: `multiplayer-server/README.md` for full deployment guide

---

## Troubleshooting

### "npm: command not found"
- Install Node.js from https://nodejs.org

### "Cannot find module"
- Run `npm install` first

### "Port 3001 in use"
- Another program is using port 3001
- Change port in `multiplayer-server/server.js` line 7:
  ```javascript
  const PORT = process.env.PORT || 3002; // Changed to 3002
  ```
- Also update `HideoutAdsWebsite/multiplayer-lobby.html` to use port 3002

### "Server offline" on website
- Make sure server is running (`npm start`)
- Check firewall allows port 3001
- Run the Windows firewall command from `add-firewall-rule-port-3001.bat`

---

## Windows Firewall Rule (if needed)

Run this command as Administrator:

```powershell
netsh advfirewall firewall add rule name="WebSocket Port 3001" dir=in action=allow protocol=TCP localport=3001
```

Or double-click: `add-firewall-rule-port-3001.bat`

---

## Multiple Regional Servers

To run multiple servers for different regions:

1. **US East Server** - Port 3001 (your PC)
2. **EU West Server** - Deploy to Render.com (Region: Frankfurt)
3. **Asia Pacific Server** - Deploy to Render.com (Region: Singapore)

Each server runs independently!

See: `multiplayer-server/README.md` for multi-region setup

---

## Quick Commands

### Start Server:
```bash
cd multiplayer-server
npm start
```

### Check if Running:
Open browser: http://localhost:3001

Should show: "Space Shooter Multiplayer Server"

### View Logs:
Server logs appear in the terminal as players connect

---

## Pro Tip: Run Server in Background

### Windows (PowerShell):
```powershell
Start-Process -NoNewWindow -FilePath "node" -ArgumentList "server.js" -WorkingDirectory "multiplayer-server"
```

### Or use PM2 (Process Manager):
```bash
npm install -g pm2
cd multiplayer-server
pm2 start server.js --name space-shooter-server
pm2 save
```

Now server runs in background even if you close terminal!

---

## That's It!

Your multiplayer server is now running on your local PC! 🎮

Go to https://hideoutads.online/multiplayer-lobby and enjoy! 🚀
