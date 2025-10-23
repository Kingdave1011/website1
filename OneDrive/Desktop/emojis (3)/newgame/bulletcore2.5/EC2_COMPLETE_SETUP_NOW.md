# ✅ Good! You're Connected to EC2!

## Problem Identified:

1. ❌ Node.js not installed (npm command not found)
2. ❌ C:\gameservers folder doesn't exist
3. ❌ matchmaking-server.cjs file is missing

---

## Solution (Run These Commands In Order):

### Step 1: Install Node.js on EC2

**In your EC2 PowerShell, run:**

```powershell
# Download Node.js installer
Invoke-WebRequest -Uri "https://nodejs.org/dist/v20.10.0/node-v20.10.0-x64.msi" -OutFile "$env:TEMP\nodejs.msi"

# Install Node.js
Start-Process msiexec.exe -Wait -ArgumentList "/i $env:TEMP\nodejs.msi /quiet /norestart"

# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Verify installation
node --version
npm --version
```

**Expected output:**
```
v20.10.0
10.2.3
```

---

### Step 2: Create gameservers Directory

```powershell
# Create the directory
New-Item -Path "C:\gameservers" -ItemType Directory -Force

# Navigate to it
cd C:\gameservers
```

---

### Step 3: Create matchmaking-server.cjs File

**Copy this entire content:**

```powershell
# Create the server file
@"
const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

const PORT = 3001;
const MAX_PLAYERS = 100;

let players = new Map();
let matches = [];

// Enable CORS
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    next();
});

// WebSocket connection handler
wss.on('connection', (ws) => {
    console.log('New client connected');
    
    ws.on('message', (message) => {
        try {
            const data = JSON.parse(message);
            
            // Handle different message types
            if (data.type === 'join') {
                const playerId = data.playerId || `player_${Date.now()}`;
                players.set(playerId, { ws, name: data.name || 'Anonymous' });
                
                // Broadcast player count
                broadcastPlayerCount();
                
                // Send welcome message
                ws.send(JSON.stringify({
                    type: 'system',
                    message: `Welcome ${data.name || 'Anonymous'}!`
                }));
                
                // Notify others
                broadcast({
                    type: 'system',
                    message: `${data.name || 'Anonymous'} joined the lobby`
                }, ws);
            }
            
            if (data.type === 'chat') {
                // Broadcast chat message
                broadcast({
                    type: 'chat',
                    from: data.from || 'Anonymous',
                    message: data.message,
                    timestamp: Date.now()
                });
            }
            
            if (data.type === 'ping') {
                ws.send(JSON.stringify({ type: 'pong', timestamp: Date.now() }));
            }
        } catch (error) {
            console.error('Error processing message:', error);
        }
    });
    
    ws.on('close', () => {
        // Remove player
        for (const [playerId, player] of players.entries()) {
            if (player.ws === ws) {
                broadcast({
                    type: 'system',
                    message: `${player.name} left the lobby`
                });
                players.delete(playerId);
                break;
            }
        }
        broadcastPlayerCount();
        console.log('Client disconnected');
    });
});

function broadcast(data, excludeWs = null) {
    wss.clients.forEach(client => {
        if (client !== excludeWs && client.readyState === WebSocket.OPEN) {
            client.send(JSON.stringify(data));
        }
    });
}

function broadcastPlayerCount() {
    broadcast({
        type: 'playerCount',
        count: players.size,
        max: MAX_PLAYERS
    });
}

// REST API endpoints
app.get('/api/status', (req, res) => {
    res.json({
        online: true,
        players: players.size,
        maxPlayers: MAX_PLAYERS,
        matches: matches.length
    });
});

app.get('/api/players', (req, res) => {
    const playerList = Array.from(players.values()).map(p => ({ name: p.name }));
    res.json({ players: playerList });
});

// Start server
server.listen(PORT, '0.0.0.0', () => {
    console.log(`✅ Multiplayer server running on port ${PORT}`);
    console.log(`Max players: ${MAX_PLAYERS}`);
    console.log(`WebSocket: ws://0.0.0.0:${PORT}`);
});

// Error handling
process.on('uncaughtException', (error) => {
    console.error('Uncaught Exception:', error);
});

process.on('unhandledRejection', (error) => {
    console.error('Unhandled Rejection:', error);
});
"@ | Out-File -FilePath C:\gameservers\matchmaking-server.cjs -Encoding UTF8
```

---

### Step 4: Install Dependencies

```powershell
# Initialize npm project
npm init -y

# Install required packages
npm install express ws
```

---

### Step 5: Install PM2 and Start Server

```powershell
# Install PM2 globally
npm install -g pm2

# Start the server
pm2 start matchmaking-server.cjs --name "multiplayer-server"

# Save PM2 configuration
pm2 save

# Check status
pm2 status
```

**Expected output:**
```
┌────┬──────────────────────┬─────────┬─────────┐
│ id │ name                 │ status  │ restart │
├────┼──────────────────────┼─────────┼─────────┤
│ 0  │ multiplayer-server   │ online  │ 0       │
└────┴──────────────────────┴─────────┴─────────┘
```

---

### Step 6: Setup Auto-Start

```powershell
# Configure PM2 to start on Windows boot
pm2 startup
# Copy and run the command it shows

pm2 save
```

---

### Step 7: Verify Port is Listening

```powershell
netstat -ano | findstr :3001
```

**Expected:** `TCP    0.0.0.0:3001           0.0.0.0:0              LISTENING`

---

### Step 8: Add Windows Firewall Rule

```powershell
New-NetFirewallRule -DisplayName "WebSocket Port 3001" -Direction Inbound -LocalPort 3001 -Protocol TCP -Action Allow
```

---

## Test Your Server:

**On your PC (not EC2), run:**

```powershell
Test-NetConnection -ComputerName 18.116.64.173 -Port 3001
```

**Should show:** `TcpTestSucceeded: True` ✅

**Then visit:** https://hideoutads.online/multiplayer-lobby.html

Should show: **"Server Status: Online"** 🎉

---

## Complete Command List (Copy All At Once):

```powershell
# Install Node.js
Invoke-WebRequest -Uri "https://nodejs.org/dist/v20.10.0/node-v20.10.0-x64.msi" -OutFile "$env:TEMP\nodejs.msi"
Start-Process msiexec.exe -Wait -ArgumentList "/i $env:TEMP\nodejs.msi /quiet /norestart"
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Create directory
New-Item -Path "C:\gameservers" -ItemType Directory -Force
cd C:\gameservers

# Create server file (copy the @"..."@ block from Step 3 above)

# Install dependencies
npm init -y
npm install express ws

# Install and start PM2
npm install -g pm2
pm2 start matchmaking-server.cjs --name "multiplayer-server"
pm2 save
pm2 startup

# Add firewall rule
New-NetFirewallRule -DisplayName "WebSocket Port 3001" -Direction Inbound -LocalPort 3001 -Protocol TCP -Action Allow

# Check status
pm2 status
netstat -ano | findstr :3001
```

---

*After this, your multiplayer will be fully online!* 🚀
