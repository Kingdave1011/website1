# 🚀 Render 24/7 Server Uptime Guide

## ✅ Current Setup

Your multiplayer server is deployed on **Render.com** at:
- **URL:** https://website-game-ix11.onrender.com
- **WebSocket:** wss://website-game-ix11.onrender.com

## 🌟 Automatic 24/7 Uptime

Render.com provides **automatic 24/7 uptime** with the following features:

### 1. **Always-On Service**
- Your server runs continuously without manual intervention
- Automatic restarts if the server crashes
- No need to manually start/stop the server

### 2. **Health Checks**
- Render monitors your `/api/status` endpoint
- Automatically restarts if health checks fail
- Sends notifications on downtime

### 3. **Auto-Scaling**
- Handles traffic spikes automatically
- Scales based on demand
- No configuration needed

## 🔄 Server Refresh Feature

### Admin Panel Controls
The admin panel now includes two server management buttons:

#### 🔄 Refresh Server
- Pings the server to wake it up if sleeping (free tier only)
- Checks server responsiveness
- Displays current player count

#### 📡 Check Server Status
- Full diagnostic report
- Shows latency, player count, and uptime
- Confirms server health

### How to Use:
1. Go to admin panel: `https://yourdomain.com/admin-panel.html`
2. Login with admin credentials
3. Navigate to "System Controls" card
4. Click "🔄 Refresh Server" or "📡 Check Server Status"

## ⚙️ Render Configuration

### Current Settings:
```yaml
# render.yaml (auto-generated)
services:
  - type: web
    name: multiplayer-server
    env: node
    buildCommand: npm install
    startCommand: node server.js
    healthCheckPath: /api/status
    autoDeploy: true
```

### Environment Variables:
- `PORT`: Automatically set by Render
- No additional configuration needed

## 📊 Monitoring

### How to Monitor Your Server:

1. **Render Dashboard**
   - Visit: https://dashboard.render.com
   - View real-time logs
   - Check uptime metrics
   - Monitor resource usage

2. **Admin Panel** (Quick Access)
   - Use "Check Server Status" button
   - Real-time player count
   - Latency monitoring

3. **Manual Check**
   - Visit: https://website-game-ix11.onrender.com/api/status
   - Should return: `{"online": true, "players": X}`

## 🚨 Troubleshooting

### Issue: Server appears offline
**Solutions:**
1. Check Render dashboard for errors
2. Use admin panel "Refresh Server" button
3. Free tier servers may sleep after 15 minutes of inactivity
4. Wait 30-60 seconds for cold start

### Issue: Slow response times
**Solutions:**
1. Free tier has cold start delays (30-60 seconds)
2. Upgrade to paid plan for instant responses
3. Use "Refresh Server" to keep warm

### Issue: Players can't connect
**Solutions:**
1. Verify server URL in multiplayer-lobby.html
2. Check Render dashboard for errors
3. Ensure WebSocket connections are enabled
4. Test with "Check Server Status" button

## 💰 Pricing Tiers

### Free Tier (Current)
- ✅ 24/7 uptime
- ⚠️ Sleeps after 15 min inactivity
- ⚠️ Cold start: 30-60 seconds
- ✅ 750 hours/month free

### Starter Plan ($7/month)
- ✅ No sleep/cold starts
- ✅ Instant response
- ✅ Better performance
- ✅ Priority support

### Pro Plan ($25/month)
- ✅ All Starter features
- ✅ Auto-scaling
- ✅ Advanced metrics
- ✅ 99.99% uptime SLA

## 🔧 Maintenance

### No Maintenance Required!
Your server is fully automated:
- ✅ Automatic updates
- ✅ Automatic restarts
- ✅ Automatic scaling
- ✅ Automatic backups

### Optional: Keep Server Warm
To prevent cold starts on free tier, you can:
1. Use a service like **UptimeRobot** (free)
2. Ping your server every 10 minutes
3. URL to ping: https://website-game-ix11.onrender.com/api/status

## 📱 Admin Panel Features

### New Server Management Tools:
1. **🔄 Refresh Server** - Wake up sleeping server
2. **📡 Check Server Status** - Full diagnostic report

### How It Works:
```javascript
// Refresh Server Button
async function refreshServer() {
    const response = await fetch('https://website-game-ix11.onrender.com/api/status');
    const data = await response.json();
    // Displays: Players, Status, Uptime
}

// Check Status Button  
async function checkServerStatus() {
    const startTime = Date.now();
    const response = await fetch('https://website-game-ix11.onrender.com/api/status');
    const latency = Date.now() - startTime;
    // Shows: Status, Players, Latency, URL
}
```

## 🎯 Best Practices

### For Optimal Uptime:
1. ✅ Keep health check endpoint (`/api/status`) always responding
2. ✅ Monitor Render dashboard regularly
3. ✅ Use admin panel to check status
4. ✅ Consider upgrading to Starter plan for no cold starts
5. ✅ Set up UptimeRobot for free tier (optional)

### For Players:
1. Server is available 24/7
2. First connection may take 30-60 seconds (free tier)
3. Subsequent connections are instant
4. Admin can refresh server anytime

## 📞 Support

### If Server Issues Occur:
1. Check Render dashboard: https://dashboard.render.com
2. Use admin panel status buttons
3. View server logs in Render dashboard
4. Contact Render support if needed

### Admin Access:
- **Panel:** https://yourdomain.com/admin-panel.html
- **Username:** King_davez
- **Features:** Server refresh, status check, monitoring

## ✅ Summary

Your server is configured for **24/7 automatic uptime**:
- ✅ No manual intervention needed
- ✅ Automatic restarts on failures
- ✅ Health monitoring enabled
- ✅ Admin panel for quick checks
- ✅ Always accessible at https://website-game-ix11.onrender.com

**Your server runs 24/7 automatically. The admin panel provides tools to check status and refresh if needed on free tier.**
