const express = require('express');
const http = require('http');
const WebSocket = require('ws');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

const PORT = process.env.PORT || 3001;
const MAX_PLAYERS = 100;

let players = new Map();
let matches = [];

console.log('🚀 Starting Space Shooter Multiplayer Server...');

// Enable CORS for all routes
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    res.header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    next();
});

// Health check endpoint
app.get('/', (req, res) => {
    res.json({
        status: 'online',
        message: 'Space Shooter Multiplayer Server',
        players: players.size,
        maxPlayers: MAX_PLAYERS,
        uptime: process.uptime()
    });
});

// Status API
app.get('/api/status', (req, res) => {
    res.json({
        online: true,
        players: players.size,
        maxPlayers: MAX_PLAYERS,
        matches: matches.length,
        uptime: process.uptime()
    });
});

// Players list API
app.get('/api/players', (req, res) => {
    const playerList = Array.from(players.values()).map(p => ({
        name: p.name,
        joinedAt: p.joinedAt
    }));
    res.json({ players: playerList, count: players.size });
});

// WebSocket connection handler
wss.on('connection', (ws, req) => {
    const clientIp = req.headers['x-forwarded-for'] || req.socket.remoteAddress;
    console.log(`✅ New connection from ${clientIp}`);
    
    let playerId = null;
    let playerName = 'Anonymous';
    
    // Send welcome message
    ws.send(JSON.stringify({
        type: 'system',
        message: 'Connected to multiplayer server!'
    }));
    
    ws.on('message', (message) => {
        try {
            const data = JSON.parse(message);
            
            // Handle player join
            if (data.type === 'join') {
                playerId = data.playerId || `player_${Date.now()}`;
                playerName = data.name || 'Anonymous';
                
                players.set(playerId, {
                    ws,
                    name: playerName,
                    joinedAt: new Date().toISOString()
                });
                
                console.log(`👤 ${playerName} joined (${players.size}/${MAX_PLAYERS})`);
                
                // Send player count update
                broadcastPlayerCount();
                
                // Welcome message
                ws.send(JSON.stringify({
                    type: 'system',
                    message: `Welcome ${playerName}!`,
                    playerId: playerId
                }));
                
                // Notify others
                broadcast({
                    type: 'system',
                    message: `${playerName} joined the lobby`
                }, ws);
            }
            
            // Handle chat messages
            if (data.type === 'chat') {
                const chatMessage = {
                    type: 'chat',
                    from: data.from || playerName,
                    message: data.message,
                    timestamp: Date.now()
                };
                
                console.log(`💬 ${chatMessage.from}: ${chatMessage.message}`);
                broadcast(chatMessage);
            }
            
            // Handle ping/pong for connection health
            if (data.type === 'ping') {
                ws.send(JSON.stringify({
                    type: 'pong',
                    timestamp: Date.now(),
                    serverTime: new Date().toISOString()
                }));
            }
            
            // Handle matchmaking requests
            if (data.type === 'find_match') {
                ws.send(JSON.stringify({
                    type: 'match_found',
                    matchId: `match_${Date.now()}`,
                    message: 'Match found! Starting game...'
                }));
            }
            
        } catch (error) {
            console.error('❌ Error processing message:', error);
            ws.send(JSON.stringify({
                type: 'error',
                message: 'Invalid message format'
            }));
        }
    });
    
    ws.on('close', () => {
        if (playerId && players.has(playerId)) {
            const player = players.get(playerId);
            console.log(`👋 ${player.name} disconnected`);
            
            broadcast({
                type: 'system',
                message: `${player.name} left the lobby`
            });
            
            players.delete(playerId);
            broadcastPlayerCount();
        }
    });
    
    ws.on('error', (error) => {
        console.error('❌ WebSocket error:', error);
    });
});

// Broadcast message to all connected clients
function broadcast(data, excludeWs = null) {
    const message = JSON.stringify(data);
    let sent = 0;
    
    wss.clients.forEach(client => {
        if (client !== excludeWs && client.readyState === WebSocket.OPEN) {
            client.send(message);
            sent++;
        }
    });
    
    return sent;
}

// Broadcast player count update
function broadcastPlayerCount() {
    broadcast({
        type: 'playerCount',
        count: players.size,
        max: MAX_PLAYERS
    });
}

// Start server
server.listen(PORT, '0.0.0.0', () => {
    console.log('');
    console.log('═══════════════════════════════════════════');
    console.log('  🎮 SPACE SHOOTER MULTIPLAYER SERVER');
    console.log('═══════════════════════════════════════════');
    console.log(`  ✅ Status: ONLINE`);
    console.log(`  🌐 Port: ${PORT}`);
    console.log(`  👥 Max Players: ${MAX_PLAYERS}`);
    console.log(`  📡 WebSocket: ws://0.0.0.0:${PORT}`);
    console.log('═══════════════════════════════════════════');
    console.log('');
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('🛑 SIGTERM received, shutting down gracefully...');
    server.close(() => {
        console.log('✅ Server closed');
        process.exit(0);
    });
});

process.on('SIGINT', () => {
    console.log('🛑 SIGINT received, shutting down gracefully...');
    server.close(() => {
        console.log('✅ Server closed');
        process.exit(0);
    });
});

// Error handling
process.on('uncaughtException', (error) => {
    console.error('❌ Uncaught Exception:', error);
});

process.on('unhandledRejection', (error) => {
    console.error('❌ Unhandled Rejection:', error);
});

// Keep-alive ping every 30 seconds
setInterval(() => {
    wss.clients.forEach(client => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(JSON.stringify({
                type: 'ping',
                timestamp: Date.now()
            }));
        }
    });
}, 30000);

console.log('✅ Server initialized successfully');
