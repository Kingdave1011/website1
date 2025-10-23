# Railway.app Deployment Guide - EASIEST Cloud Hosting!

## 🚀 Railway.app is EASIER than Render.com!

Railway automatically detects your project structure - no configuration needed!

---

## Step-by-Step Guide (3 minutes):

### 1. Go to Railway.app

Visit: **https://railway.app**

### 2. Sign Up

Click **"Start a New Project"** or **"Login with GitHub"**

### 3. Create New Project

Click **"New Project"** button

### 4. Deploy from GitHub

Click **"Deploy from GitHub repo"**

### 5. Select Repository

Choose: **`Kingdave1011/website1`**

### 6. Select Service

Railway will scan your repo and find:
- `multiplayer-server` folder
- `backend` folder  
- `HideoutAdsWebsite` folder

Click on **`multiplayer-server`**

### 7. Wait for Auto-Deploy

Railway automatically:
- ✅ Detects it's a Node.js project
- ✅ Runs `npm install`
- ✅ Runs `npm start`
- ✅ Assigns a public URL
- ✅ Enables HTTPS/WSS

No configuration needed! 🎉

### 8. Get Your URL

After deployment (2-3 minutes), click on your service:
- Go to **"Settings"** → **"Networking"**
- Copy your **Public Domain** (e.g., `space-shooter.up.railway.app`)

### 9. Update Your Website

Edit `HideoutAdsWebsite/multiplayer-lobby.html`:

```javascript
// Find this line:
const serverUrl = 'ws://localhost:3001';

// Change to:
const serverUrl = 'wss://space-shooter.up.railway.app';
```

### 10. Push to GitHub

```bash
git add HideoutAdsWebsite/multiplayer-lobby.html
git commit -m "Connect to Railway 24/7 server"
git push origin master
```

### 11. DONE! 🎉

Your server now runs 24/7 on Railway, even when your PC is off!

---

## 🎯 Why Railway is Better:

| Feature | Railway | Render.com | Your PC |
|---------|---------|------------|---------|
| **Auto-detects project** | ✅ Yes | ❌ Manual setup | ❌ Manual |
| **Runs when PC off** | ✅ Yes | ✅ Yes | ❌ No |
| **Free tier** | ✅ $5/month credit | ✅ Yes | ✅ Free |
| **Setup time** | 🟢 3 minutes | 🟡 10 minutes | 🟢 2 minutes |
| **Configuration needed** | ✅ None | ❌ Lots | ❌ Some |
| **WebSocket support** | ✅ Built-in | ✅ Yes | ✅ Yes |
| **100+ players** | ✅ Yes | ✅ Yes | ✅ Yes |

---

## 💰 Railway Pricing:

- **Free**: $5 credit/month (enough for 24/7 server!)
- **Hobby**: $5/month (if you exceed free tier)
- **Pro**: $20/month (for heavy usage)

Your multiplayer server uses ~$3-4/month, so **FREE tier covers it**!

---

## 🌍 Custom Domain Setup:

### Add Your Domain to Railway:

1. **In Railway Dashboard**:
   - Click your service
   - Settings → Networking
   - Click **"Add Custom Domain"**
   - Enter: `mp.hideoutads.online`

2. **In Your Domain DNS Settings**:
   - Add CNAME record:
     - **Name**: `mp`
     - **Value**: `your-app.up.railway.app`
     - **TTL**: 3600

3. **Railway Auto-Configures SSL**

4. **Use in your code**: `wss://mp.hideoutads.online`

---

## 📊 Monitor Your Server:

### In Railway Dashboard:

- **Metrics**: See CPU, RAM, Network usage
- **Logs**: View real-time server logs  
- **Deployments**: See all past deploys
- **Environment Variables**: Add config if needed

---

## 🔄 Auto-Deploy on Git Push:

Railway automatically redeploys when you push to GitHub!

```bash
git add .
git commit -m "Update server"
git push origin master
```

Railway detects the change and redeploys in 2 minutes. Zero downtime!

---

## 🛠️ Troubleshooting:

### Build Failed?

Railway should auto-detect everything. If it fails:

1. **Add `nixpacks.toml`** to multiplayer-server folder:
```toml
[phases.setup]
nixPkgs = ["nodejs"]

[phases.install]
cmds = ["npm install"]

[start]
cmd = "npm start"
```

2. **Or add `railway.json`** to multiplayer-server folder:
```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "npm start",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

But **usually you don't need these** - Railway is smart!

---

## 🎮 Multiple Regional Servers on Railway:

Deploy the same repo multiple times:

1. **US Server**: Deploy once, use US region
2. **EU Server**: Deploy again, use EU region
3. **Asia Server**: Deploy again, use Asia region

Each gets its own URL and runs independently!

---

## ✅ Summary:

Railway.app is the EASIEST way to deploy your multiplayer server:
- ✅ No configuration needed
- ✅ Auto-detects Node.js
- ✅ Free $5/month credit
- ✅ 24/7 uptime
- ✅ Runs when PC is off
- ✅ Custom domain support
- ✅ Auto-SSL for wss://
- ✅ Auto-redeploy on git push

**Just 3 clicks and you're done!** 🚀
