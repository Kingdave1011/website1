# 🎮 Space Shooter Multiplayer Server

24/7 WebSocket server for Space Shooter online multiplayer.

## 🚀 Quick Deploy (FREE - 5 Minutes)

### Option 1: Render.com (Recommended)

**Easiest FREE deployment:**

1. **Sign up:** https://render.com (free account)
2. **Click:** "New +" → "Web Service"
3. **Connect:** Your GitHub repository
4. **Settings:**
   - Name: `space-shooter-server`
   - Root Directory: `multiplayer-server`
   - Environment: `Node`
   - Build Command: `npm install`
   - Start Command: `npm start`
   - Plan: **Free**
5. **Click:** "Create Web Service"

**You'll get a URL like:** `https://space-shooter-server.onrender.com`

---

### Option 2: Railway.app

1. **Go to:** https://railway.app
2. **Sign up** (free $5 credit monthly)
3. **Click:** "New Project" → "Deploy from GitHub"
4. **Select:** Your repo → `multiplayer-server` folder
5. **Add variable:** `PORT` = `3001` (optional)
6. **Deploy!**

**You'll get:** `https://your-app.up.railway.app`

---

### Option 3: Fly.io

```bash
# Install flyctl
npm install -g flyctl

# Login
flyctl auth login

# Deploy
flyctl launch

# Follow prompts:
# - Name: space-shooter-server
# - Region: Choose closest to you
# - Deploy: Yes
```

---

## 📝 After Deployment:

### Update Your Website

**Edit:** `HideoutAdsWebsite/multiplayer-lobby.html`

**Find line ~150:**
```javascript
const ws = new WebSocket('ws://18.116.64.173:3001');
```

**Change to:**
```javascript
const ws = new WebSocket('wss://YOUR-RENDER-URL.onrender.com');
```

**Note:** Use `wss://` (secure) not `ws://` for cloud hosting!

### Push Changes:

```bash
git add HideoutAdsWebsite/multiplayer-lobby.html
git commit -m "Update multiplayer server URL"
git push origin master
```

---

## ✅ Features:

- ✅ Real-time WebSocket chat
- ✅ Player join/leave notifications
- ✅ Player count tracking (0/100)
- ✅ Health check endpoint: `/api/status`
- ✅ Auto-reconnect support
- ✅ Keep-alive pings every 30s
- ✅ CORS enabled for all domains
- ✅ Graceful shutdown handling

---

## 🧪 Testing:

### Local Test:

```bash
cd multiplayer-server
npm install
npm start
```

**Visit:** http://localhost:3001

**Should show:** `{"status":"online",...}`

### Test WebSocket:

```javascript
// Open browser console
const ws = new WebSocket('ws://localhost:3001');
ws.onopen = () => console.log('Connected!');
ws.send(JSON.stringify({ type: 'join', name: 'TestPlayer' }));
```

---

## 🔧 Environment Variables:

| Variable | Default | Description |
|----------|---------|-------------|
| PORT | 3001 | Server port (auto-set by host) |
| MAX_PLAYERS | 100 | Maximum concurrent players |

---

## 📊 API Endpoints:

### GET /
Health check - returns server status

### GET /api/status
```json
{
  "online": true,
  "players": 5,
  "maxPlayers": 100,
  "matches": 0,
  "uptime": 3600
}
```

### GET /api/players
```json
{
  "players": [
    {"name": "Player1", "joinedAt": "2025-10-23T03:00:00Z"}
  ],
  "count": 1
}
```

---

## 🎯 WebSocket Messages:

### Client → Server:

```javascript
// Join lobby
{ type: 'join', name: 'PlayerName', playerId: 'optional' }

// Send chat
{ type: 'chat', from: 'PlayerName', message: 'Hello!' }

// Ping
{ type: 'ping' }

// Find match
{ type: 'find_match' }
```

### Server → Client:

```javascript
// System message
{ type: 'system', message: 'Player joined' }

// Chat message
{ type: 'chat', from: 'PlayerName', message: 'Hi!', timestamp: 123 }

// Player count
{ type: 'playerCount', count: 5, max: 100 }

// Pong response
{ type: 'pong', timestamp: 123, serverTime: '2025...' }
```

---

## 🎮 Why This Works Better Than AWS:

| Feature | AWS EC2 | Render.com |
|---------|---------|------------|
| Cost | $10-20/month | **FREE** |
| Setup Time | 2 hours | **5 minutes** |
| SSL/HTTPS | Manual | **Automatic** |
| Auto-restart | Manual (PM2) | **Automatic** |
| Logs | Manual | **Built-in** |
| Scaling | Manual | **Automatic** |

---

## 🔒 Security:

- ✅ CORS enabled (accepts all origins)
- ✅ Input validation on all messages
- ✅ Error handling for invalid JSON
- ✅ Rate limiting (can be added)
- ✅ Connection timeout handling

---

## 🐛 Troubleshooting:

### Server won't start locally?
```bash
# Check if port 3001 is in use
netstat -ano | findstr :3001

# Use different port
PORT=3002 npm start
```

### Can't connect from browser?
- Check WebSocket URL uses `wss://` for HTTPS sites
- Verify server is running (check logs)
- Test health endpoint first: `https://your-url.com/api/status`

---

## 📚 Documentation:

**Full guides in parent directory:**
- `COMPLETE_V7_SETUP_MASTER_GUIDE.md` - Complete setup
- `EC2_COMPLETE_SETUP_NOW.md` - AWS setup (complex)
- `YOU_ARE_IN_WRONG_PLACE.md` - Common mistakes

---

## 💡 Quick Start Summary:

1. **Deploy to Render.com** (5 min, free)
2. **Get your server URL**
3. **Update multiplayer-lobby.html** with new URL
4. **Push to GitHub**
5. **Test:** https://hideoutads.online/multiplayer-lobby.html

**That's it! 24/7 multiplayer is live!** 🎉

---

*Created by King_davez for Space Shooter v7.0*
