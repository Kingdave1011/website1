# Session Management & Game Server Configuration
## For hideoutads.online Space Shooter

This guide ensures proper session management (3-hour login) and game server functionality.

## 🔐 Session Management - 3 Hour Auto-Login

### Current Issue:
Game asks for password every time it reloads. Need to keep users logged in for 3 hours.

### Solution: Add Session Expiry with Timestamp

Update `checkWebsiteAuth()` function in `index.tsx`:

```typescript
function checkWebsiteAuth() {
    // Check if user is already authenticated from website
    const websiteAuth = sessionStorage.getItem('space_shooter_auth');
    const websiteUser = sessionStorage.getItem('space_shooter_username');
    const loginTimestamp = sessionStorage.getItem('space_shooter_login_time');
    
    // Check if session has expired (3 hours = 10800000 milliseconds)
    const SESSION_DURATION = 3 * 60 * 60 * 1000;  // 3 hours in milliseconds
    const now = Date.now();
    
    if (websiteAuth === 'true' && websiteUser && loginTimestamp) {
        const timeElapsed = now - parseInt(loginTimestamp);
        
        if (timeElapsed < SESSION_DURATION) {
            // Session still valid, auto-login
            console.log('Auto-login detected from website:', websiteUser);
            console.log(`Session time remaining: ${Math.floor((SESSION_DURATION - timeElapsed) / 60000)} minutes`);
            
            initAudio();
            loadGameState(websiteUser);
            gameState.username = websiteUser;
            showScreen('start-screen');
            startMenuAnimation();
            document.getElementById('admin-panel-button')!.style.display = (websiteUser === 'King_davez') ? 'inline-block' : 'none';
            chatContainer.style.display = 'flex';
            
            // Show welcome notification with time remaining
            const minutesLeft = Math.floor((SESSION_DURATION - timeElapsed) / 60000);
            showWaveNotification(`Welcome back, ${websiteUser}! (Session: ${minutesLeft}min left)`);
        } else {
            // Session expired, clear and show login
            console.log('Session expired. Please log in again.');
            sessionStorage.removeItem('space_shooter_auth');
            sessionStorage.removeItem('space_shooter_username');
            sessionStorage.removeItem('space_shooter_login_time');
            loadGameState('guest_default');
            showScreen('login-screen');
        }
    } else {
        // No website auth, show login screen
        loadGameState('guest_default');
        showScreen('login-screen');
    }
}
```

### Update `loginSuccess()` function:

```typescript
function loginSuccess(username: string, isGuest = false) {
    playSound('uiClick');
    initAudio();
    loadGameState(isGuest ? `guest_${username}` : username);
    gameState.username = username;
    
    // Set session timestamp for 3-hour expiry
    sessionStorage.setItem('space_shooter_auth', 'true');
    sessionStorage.setItem('space_shooter_username', username);
    sessionStorage.setItem('space_shooter_login_time', Date.now().toString());
    
    showScreen('start-screen');
    startMenuAnimation();
    document.getElementById('admin-panel-button')!.style.display = (username === 'admin') ? 'inline-block' : 'none';
    chatContainer.style.display = 'flex';
    
    // Show session duration notification
    showWaveNotification(`Logged in successfully! Session valid for 3 hours.`);
}
```

### Add Session Timer Display (Optional):

Add to game UI HTML:
```html
<div id="session-timer" style="position: fixed; bottom: 10px; right: 10px; color: cyan; font-size: 12px; opacity: 0.7;">
    Session: --:--
</div>
```

Add update function:
```typescript
function updateSessionTimer() {
    const loginTimestamp = sessionStorage.getItem('space_shooter_login_time');
    if (!loginTimestamp) return;
    
    const SESSION_DURATION = 3 * 60 * 60 * 1000;
    const now = Date.now();
    const timeElapsed = now - parseInt(loginTimestamp);
    const timeRemaining = SESSION_DURATION - timeElapsed;
    
    if (timeRemaining > 0) {
        const hours = Math.floor(timeRemaining / (60 * 60 * 1000));
        const minutes = Math.floor((timeRemaining % (60 * 60 * 1000)) / (60 * 1000));
        const sessionTimerEl = document.getElementById('session-timer');
        if (sessionTimerEl) {
            sessionTimerEl.innerText = `Session: ${hours}:${minutes.toString().padStart(2, '0')}`;
        }
    } else {
        // Session expired during gameplay
        sessionStorage.clear();
        showScreen('login-screen');
        alert('Your session has expired. Please log in again.');
    }
}

// Call this in your game loop or setInterval
setInterval(updateSessionTimer, 60000); // Update every minute
```

---

## 🎮 Game Server Configuration

### Current Server Setup:

Your game uses `matchmaking-server.cjs` for multiplayer functionality.

### Verify Server is Running:

1. **Check if server is active:**
```bash
cd c:/Users/kinlo/OneDrive/Desktop/emojis (3)/newgame/bulletcore2.5
node matchmaking-server.cjs
```

2. **Server should output:**
```
Matchmaking server running on port 3000
```

### Make Server Always Available:

**Option 1: Use PM2 (Process Manager)**
```bash
npm install -g pm2
pm2 start matchmaking-server.cjs --name "space-shooter-server"
pm2 save
pm2 startup
```

**Option 2: Windows Service**
- Use NSSM (Non-Sucking Service Manager)
- Download from nssm.cc
- Install as Windows service

**Option 3: Cloud Hosting (Recommended for hideoutads.online)**

Deploy to AWS/Heroku/DigitalOcean:
```bash
# Example for Heroku
heroku create space-shooter-server
git add matchmaking-server.cjs
git commit -m "Add matchmaking server"
git push heroku master
```

### Update Client to Connect to Server:

In `index.tsx`, ensure WebSocket/HTTP connection points to correct server:

```typescript
// Add at top of file
const SERVER_URL = process.env.NODE_ENV === 'production' 
    ? 'https://your-server.herokuapp.com'  // Production server
    : 'http://localhost:3000';  // Local development

// Use SERVER_URL when connecting to matchmaking server
function connectToMatchmaking() {
    fetch(`${SERVER_URL}/api/matchmaking`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username: gameState.username })
    })
    .then(response => response.json())
    .then(data => {
        console.log('Connected to server:', data);
    })
    .catch(error => {
        console.error('Server connection failed:', error);
        alert('Unable to connect to game servers. Playing in offline mode.');
    });
}
```

---

## 🔧 Server Health Check

### Add Server Status Indicator:

```typescript
async function checkServerStatus() {
    const statusEl = document.getElementById('server-status');
    if (!statusEl) return;
    
    try {
        const response = await fetch(`${SERVER_URL}/health`, { 
            method: 'GET',
            signal: AbortSignal.timeout(5000)  // 5 second timeout
        });
        
        if (response.ok) {
            statusEl.innerText = '🟢 Server Online';
            statusEl.style.color = '#32cd32';
            return true;
        }
    } catch (error) {
        statusEl.innerText = '🔴 Server Offline';
        statusEl.style.color = 'red';
        console.error('Server health check failed:', error);
        return false;
    }
}

// Check server status when game loads
window.onload = () => {
    // ... existing code ...
    checkServerStatus();
    setInterval(checkServerStatus, 30000);  // Check every 30 seconds
};
```

Add to start screen HTML:
```html
<div id="server-status" style="position: fixed; top: 10px; left: 10px; font-size: 14px;">
    🟡 Checking server...
</div>
```

---

## 📊 Backend Server Setup

### Ensure `matchmaking-server.cjs` is properly configured:

```javascript
const express = require('express');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'healthy', timestamp: Date.now() });
});

// Matchmaking endpoint
app.post('/api/matchmaking', (req, res) => {
    const { username } = req.body;
    console.log(`Matchmaking request from: ${username}`);
    
    // Your matchmaking logic here
    res.json({ 
        success: true, 
        message: 'Connected to matchmaking',
        username: username,
        serverTime: Date.now()
    });
});

app.listen(PORT, () => {
    console.log(`✅ Matchmaking server running on port ${PORT}`);
    console.log(`🔗 Health check: http://localhost:${PORT}/health`);
});
```

### Install Required Dependencies:

```bash
cd c:/Users/kinlo/OneDrive/Desktop/emojis (3)/newgame/bulletcore2.5
npm install express cors
```

---

## 🚀 Deployment Checklist

### For hideoutads.online:

- [ ] Session management implemented with 3-hour expiry
- [ ] Login timestamp stored in sessionStorage
- [ ] Session timer display added (optional)
- [ ] Server URL configured for production
- [ ] matchmaking-server.cjs running (locally or cloud)
- [ ] Health check endpoint working
- [ ] CORS enabled for hideoutads.online domain
- [ ] Server status indicator visible
- [ ] WebSocket connections tested
- [ ] Error handling for offline mode

### Testing Steps:

1. **Test Session Management:**
   - Log in to game
   - Reload page (should stay logged in)
   - Wait 3+ hours and reload (should ask for login)

2. **Test Server Connection:**
   - Start matchmaking server
   - Launch game
   - Check server status indicator
   - Try multiplayer matchmaking
   - Verify connection in console

3. **Test Offline Mode:**
   - Stop server
   - Launch game
   - Should show "Playing in offline mode"
   - Single-player should still work

---

## 🐛 Troubleshooting

### Session Not Persisting:
- Check browser console for sessionStorage errors
- Verify sessionStorage is not cleared by browser
- Check if hideoutads.online has HTTPS (required for sessionStorage)

### Server Not Connecting:
- Verify matchmaking-server.cjs is running
- Check firewall allows port 3000
- Test with `curl http://localhost:3000/health`
- Check CORS headers allow hideoutads.online domain

### Game Freezes on Server Connection:
- Add timeout to fetch requests (shown above)
- Implement offline fallback mode
- Add loading indicators during connection

---

## 📝 Quick Implementation

**Priority Order:**
1. Add session timestamp logic (5 minutes)
2. Test session expiry locally (critical for UX)
3. Ensure matchmaking server is running (5 minutes)
4. Add server status indicator (10 minutes)
5. Deploy and test on hideoutads.online (20 minutes)

**Total Time:** ~40 minutes for full implementation

---

## ✅ Summary

This guide provides:
- ✅ 3-hour session management with auto-expiry
- ✅ Session timer display
- ✅ Game server health monitoring
- ✅ Offline mode fallback
- ✅ Production deployment checklist

Implement these changes to ensure smooth player experience on hideoutads.online!
