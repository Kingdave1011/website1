# AWS EC2 Multiplayer Server Setup Guide
## Space Shooter Dedicated Server Configuration

## Your Server Information

**Instance Details:**
- **Instance ID:** i-0b45bbd8105d85e19
- **Public IP:** 18.116.64.173
- **Private IP:** 172.31.16.27
- **DNS:** ec2-18-116-64-173.us-east-2.compute.amazonaws.com
- **Region:** us-east-2 (Ohio)
- **Instance Type:** t3.micro (1 vCPU, 1 GB RAM)
- **OS:** Windows Server 2025
- **Account ID:** 217558553462

---

## Quick Start - Connect to Your Server

### Option 1: Remote Desktop (Windows)
```
1. Open Remote Desktop Connection (mstsc.exe)
2. Enter: 18.116.64.173
3. Click Connect
4. Use your AWS EC2 key pair credentials
```

### Option 2: AWS Console
```
1. Go to AWS Console → EC2 → Instances
2. Select instance i-0b45bbd8105d85e19
3. Click "Connect" → RDP client
4. Download Remote Desktop file
5. Get password using your key pair
```

---

## Step-by-Step Server Setup

### Phase 1: Install Prerequisites (On EC2 Server)

#### 1. Install Node.js
```powershell
# Download Node.js installer
Invoke-WebRequest -Uri "https://nodejs.org/dist/v20.10.0/node-v20.10.0-x64.msi" -OutFile "node-installer.msi"

# Install Node.js
Start-Process msiexec.exe -ArgumentList '/i', 'node-installer.msi', '/quiet', '/norestart' -Wait

# Verify installation
node --version
npm --version
```

#### 2. Install PM2 (Process Manager)
```powershell
npm install -g pm2
pm2 startup
```

#### 3. Configure Windows Firewall
```powershell
# Open game server ports
New-NetFirewallRule -DisplayName "Space Shooter Game Server" -Direction Inbound -Protocol TCP -LocalPort 7777 -Action Allow
New-NetFirewallRule -DisplayName "Space Shooter Game Server UDP" -Direction Inbound -Protocol UDP -LocalPort 7777 -Action Allow
New-NetFirewallRule -DisplayName "Space Shooter Matchmaking" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow
```

#### 4. Install Git (Optional, for updates)
```powershell
winget install --id Git.Git -e --source winget
```

---

### Phase 2: Deploy Game Server

#### 1. Create Server Directory
```powershell
mkdir C:\SpaceShooterServer
cd C:\SpaceShooterServer
```

#### 2. Create Simple Matchmaking Server (server.js)
```javascript
const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

// Store active game sessions
const gameSessions = new Map();
const players = new Map();

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'online', players: players.size, sessions: gameSessions.size });
});

// Join game session
app.post('/join', (req, res) => {
    const { username, sessionId } = req.body;
    
    if (!sessionId) {
        // Create new session
        const newSessionId = Date.now().toString();
        gameSessions.set(newSessionId, {
            players: [username],
            created: Date.now()
        });
        
        players.set(username, {
            sessionId: newSessionId,
            health: 100,
            score: 0,
            joinedAt: Date.now()
        });
        
        return res.json({ sessionId: newSessionId, message: 'Session created' });
    }
    
    // Join existing session
    const session = gameSessions.get(sessionId);
    if (session && session.players.length < 32) {
        session.players.push(username);
        players.set(username, {
            sessionId,
            health: 100,
            score: 0,
            joinedAt: Date.now()
        });
        
        return res.json({ sessionId, message: 'Joined session', playerCount: session.players.length });
    }
    
    res.status(400).json({ error: 'Session full or not found' });
});

// Get session info
app.get('/session/:id', (req, res) => {
    const session = gameSessions.get(req.params.id);
    if (session) {
        const playerDetails = session.players.map(p => players.get(p));
        res.json({ ...session, playerDetails });
    } else {
        res.status(404).json({ error: 'Session not found' });
    }
});

// Update player health
app.post('/update-health', (req, res) => {
    const { username, health } = req.body;
    const player = players.get(username);
    
    if (player) {
        player.health = health;
        res.json({ success: true, health });
    } else {
        res.status(404).json({ error: 'Player not found' });
    }
});

// Leave session
app.post('/leave', (req, res) => {
    const { username } = req.body;
    const player = players.get(username);
    
    if (player) {
        const session = gameSessions.get(player.sessionId);
        if (session) {
            session.players = session.players.filter(p => p !== username);
            if (session.players.length === 0) {
                gameSessions.delete(player.sessionId);
            }
        }
        players.delete(username);
    }
    
    res.json({ success: true });
});

// List active sessions
app.get('/sessions', (req, res) => {
    const sessionList = Array.from(gameSessions.entries()).map(([id, session]) => ({
        id,
        playerCount: session.players.length,
        maxPlayers: 32,
        created: session.created
    }));
    res.json(sessionList);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Space Shooter Server running on port ${PORT}`);
    console.log(`Server IP: 18.116.64.173`);
});
```

#### 3. Install Dependencies
```powershell
npm init -y
npm install express cors
```

#### 4. Start Server with PM2
```powershell
pm2 start server.js --name "space-shooter-server"
pm2 save
pm2 startup
```

---

### Phase 3: Configure AWS Security Group

#### In AWS Console:

1. **Go to EC2 → Security Groups**
2. **Find your instance's security group**
3. **Add Inbound Rules:**

```
Type: Custom TCP
Port: 3000
Source: 0.0.0.0/0 (Anywhere)
Description: Matchmaking Server

Type: Custom TCP
Port: 7777
Source: 0.0.0.0/0 (Anywhere)
Description: Game Server

Type: Custom UDP
Port: 7777
Source: 0.0.0.0/0 (Anywhere)
Description: Game Server UDP
```

---

### Phase 4: Update Game to Connect to Server

#### Add Server URL to Game

In your game's NetworkManager or connection script:

```gdscript
const SERVER_URL = "http://18.116.64.173:3000"

func connect_to_server():
    var http = HTTPRequest.new()
    add_child(http)
    
    var body = JSON.stringify({
        "username": player_name,
        "sessionId": null  # null to create new session
    })
    
    http.request(SERVER_URL + "/join", ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)
    http.request_completed.connect(_on_join_response)

func _on_join_response(result, response_code, headers, body):
    var json = JSON.parse_string(body.get_string_from_utf8())
    if json and json.has("sessionId"):
        current_session_id = json["sessionId"]
        print("Connected to session: ", current_session_id)
```

---

### Phase 5: Website Integration

#### Update index.html Play Button

```html
<div class="button-group">
    <a href="javascript:void(0)" onclick="selectGameMode()" class="button">🎮 Play Game</a>
    <a href="https://github.com/Kingdave1011/website1/releases/download/v2.5-updated/SpaceShooter-Windows-v2.5.zip" class="button secondary" download>💻 Download</a>
</div>

<script>
function selectGameMode() {
    const mode = confirm('Play Online Multiplayer?\n\nClick OK for Online Mode\nClick Cancel for Single Player');
    
    if (mode) {
        // Online mode
        window.location.href = 'https://space-shooter-634206651593.us-west1.run.app?mode=online&server=18.116.64.173:3000';
    } else {
        // Single player
        window.location.href = 'https://space-shooter-634206651593.us-west1.run.app?mode=singleplayer';
    }
}
</script>
```

---

## Server Management Commands

### Start Server
```powershell
pm2 start space-shooter-server
```

### Stop Server
```powershell
pm2 stop space-shooter-server
```

### Restart Server
```powershell
pm2 restart space-shooter-server
```

### View Logs
```powershell
pm2 logs space-shooter-server
```

### Server Status
```powershell
pm2 status
```

### Monitor Server
```powershell
pm2 monit
```

---

## Testing the Server

### From Your Computer:

```bash
# Test health endpoint
curl http://18.116.64.173:3000/health

# Test joining a session
curl -X POST http://18.116.64.173:3000/join \
  -H "Content-Type: application/json" \
  -d '{"username":"TestPlayer","sessionId":null}'

# List active sessions
curl http://18.116.64.173:3000/sessions
```

---

## Maintenance & Monitoring

### Auto-Restart on Crash
PM2 automatically restarts crashed processes

### Log Rotation
```powershell
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
```

### Update Game Server
```powershell
# Stop server
pm2 stop space-shooter-server

# Update files (git pull or manual)
# Update server.js if needed

# Restart
pm2 restart space-shooter-server
```

---

## Scaling & Performance

### Current Capacity (t3.micro):
- **Simultaneous Players:** ~50-100
- **Active Sessions:** ~10-20
- **Memory Usage:** ~200-400 MB

### Upgrade Path:
If you need more capacity:
1. t3.small: ~200 players
2. t3.medium: ~500 players  
3. t3.large: ~1000+ players

---

## Security Best Practices

### 1. Enable HTTPS (Recommended)
```powershell
# Install Certbot for SSL
# Use Let's Encrypt for free SSL certificates
```

### 2. Rate Limiting
Add to server.js:
```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100 // limit each IP to 100 requests per windowMs
});

app.use(limiter);
```

### 3. Authentication
Add JWT tokens:
```javascript
const jwt = require('jsonwebtoken');
const SECRET_KEY = 'your-secret-key-here';

// Middleware to verify tokens
function verifyToken(req, res, next) {
    const token = req.headers['authorization'];
    if (!token) return res.status(403).json({ error: 'No token provided' });
    
    jwt.verify(token, SECRET_KEY, (err, decoded) => {
        if (err) return res.status(401).json({ error: 'Invalid token' });
        req.userId = decoded.id;
        next();
    });
}
```

---

## Troubleshooting

### Server Won't Start
```powershell
# Check if port is in use
netstat -ano | findstr :3000

# Kill process if needed
taskkill /PID <PID> /F

# Restart
pm2 restart space-shooter-server
```

### Can't Connect from Game
1. Check firewall rules (ports 3000, 7777)
2. Verify security group in AWS Console
3. Test with curl command
4. Check server logs: `pm2 logs`

### High Memory Usage
```powershell
# Check memory
pm2 monit

# Restart if needed
pm2 restart space-shooter-server
```

---

## Cost Optimization

### Current Cost (t3.micro):
- **On-Demand:** ~$0.0104/hour (~$7.50/month)
- **Reserved (1 year):** ~$4/month
- **Spot Instance:** ~$0.003/hour (~$2/month)

### Save Money:
- Use Reserved Instances for 40% savings
- Stop instance when not in use
- Use auto-scaling for peak times only

---

## Monitoring Setup

### CloudWatch Metrics:
```
- CPU Utilization
- Network In/Out
- Disk Usage
- Memory Usage (needs CloudWatch agent)
```

### Set Up Alerts:
```
1. AWS Console → CloudWatch → Alarms
2. Create alarm for CPU > 80%
3. Send notification to your email
```

---

## Backup Strategy

### Automated Backups:
```powershell
# Schedule daily backups of server.js and game files
schtasks /create /tn "ServerBackup" /tr "powershell C:\backup-script.ps1" /sc daily /st 02:00
```

### Manual Backup:
```powershell
# Backup server files
Compress-Archive -Path C:\SpaceShooterServer -DestinationPath C:\Backups\server-$(Get-Date -Format 'yyyyMMdd').zip
```

---

## Next Steps

1. **Connect to your EC2 instance** via Remote Desktop
2. **Run the PowerShell commands** above to install Node.js
3. **Create server.js** with the provided code
4. **Start the server** with PM2
5. **Test the connection** from your local machine
6. **Update your game** to connect to 18.116.64.173:3000
7. **Push changes** to GitHub

---

## Support Commands

### Check Server Status from Anywhere:
```bash
curl http://18.116.64.173:3000/health
```

### Expected Response:
```json
{
  "status": "online",
  "players": 0,
  "sessions": 0
}
```

---

**Version:** 1.0  
**Author:** King_davezz / NEXO GAMES  
**Last Updated:** October 2025  
**Server IP:** 18.116.64.173
