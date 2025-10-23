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
let activePvPMatches = new Map();

// PvP Match Class
class PvPMatch {
    constructor(matchId) {
        this.matchId = matchId;
        this.players = new Map();
        this.bullets = [];
        this.scores = new Map();
        this.startTime = Date.now();
        this.gameMode = 'FFA'; // FFA, TDM, 3v3
    }

    addPlayer(playerId, playerData) {
        this.players.set(playerId, {
            id: playerId,
            name: playerData.name,
            x: Math.random() * 800,
            y: Math.random() * 600,
            health: 100,
            kills: 0,
            deaths: 0,
            ...playerData
        });
        this.scores.set(playerId, { kills: 0, deaths: 0 });
    }

    removePlayer(playerId) {
        this.players.delete(playerId);
        this.scores.delete(playerId);
    }

    updatePlayerPosition(playerId, x, y, rotation) {
        const player = this.players.get(playerId);
        if (player) {
            player.x = x;
            player.y = y;
            player.rotation = rotation;
        }
    }

    addBullet(playerId, bulletData) {
        this.bullets.push({
            id: `${playerId}_${Date.now()}`,
            ownerId: playerId,
            x: bulletData.x,
            y: bulletData.y,
            velocityX: bulletData.velocityX,
            velocityY: bulletData.velocityY,
            damage: bulletData.damage || 20,
            timestamp: Date.now()
        });
    }

    checkHits() {
        const hits = [];
        this.bullets.forEach((bullet, bulletIndex) => {
            this.players.forEach((player, playerId) => {
                if (playerId === bullet.ownerId) return;
                
                const distance = Math.sqrt(
                    Math.pow(bullet.x - player.x, 2) + 
                    Math.pow(bullet.y - player.y, 2)
                );
                
                if (distance < 30) {
                    player.health -= bullet.damage;
                    hits.push({
                        bulletId: bullet.id,
                        hitPlayerId: playerId,
                        shooterId: bullet.ownerId,
                        damage: bullet.damage,
                        remainingHealth: player.health
                    });
                    
                    if (player.health <= 0) {
                        player.health = 100;
                        player.x = Math.random() * 800;
                        player.y = Math.random() * 600;
                        player.deaths++;
                        
                        const shooter = this.players.get(bullet.ownerId);
                        if (shooter) {
                            shooter.kills++;
                        }
                        
                        const shooterScore = this.scores.get(bullet.ownerId);
                        if (shooterScore) {
                            shooterScore.kills++;
                        }
                        
                        const victimScore = this.scores.get(playerId);
                        if (victimScore) {
                            victimScore.deaths++;
                        }
                    }
                    
                    this.bullets.splice(bulletIndex, 1);
                }
            });
        });
        
        this.bullets = this.bullets.filter(b => Date.now() - b.timestamp < 5000);
        return hits;
    }

    getGameState() {
        return {
            matchId: this.matchId,
            players: Array.from(this.players.values()),
            bullets: this.bullets,
            scores: Array.from(this.scores.entries()).map(([id, score]) => ({
                playerId: id,
                ...score
            }))
        };
    }
}

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
            
            // Handle player list request
            if (data.type === 'get_players') {
                const playerNames = Array.from(players.values()).map(p => p.name);
                ws.send(JSON.stringify({
                    type: 'playerList',
                    players: playerNames
                }));
            }
            
            // Handle matchmaking requests
            if (data.type === 'find_match') {
                const matchId = `match_${Date.now()}`;
                const match = new PvPMatch(matchId);
                match.addPlayer(playerId, { name: playerName, ws });
                activePvPMatches.set(matchId, match);
                
                ws.send(JSON.stringify({
                    type: 'match_found',
                    matchId: matchId,
                    message: 'Match found! Starting game...'
                }));
            }
            
            // Handle PvP position updates
            if (data.type === 'position_update') {
                const match = activePvPMatches.get(data.matchId);
                if (match) {
                    match.updatePlayerPosition(playerId, data.x, data.y, data.rotation);
                    
                    // Broadcast position to all players in match
                    match.players.forEach((player, pid) => {
                        if (pid !== playerId && player.ws && player.ws.readyState === WebSocket.OPEN) {
                            player.ws.send(JSON.stringify({
                                type: 'player_moved',
                                playerId: playerId,
                                x: data.x,
                                y: data.y,
                                rotation: data.rotation
                            }));
                        }
                    });
                }
            }
            
            // Handle bullet firing
            if (data.type === 'fire_bullet') {
                const match = activePvPMatches.get(data.matchId);
                if (match) {
                    match.addBullet(playerId, data);
                    
                    // Broadcast bullet to all players
                    match.players.forEach((player, pid) => {
                        if (player.ws && player.ws.readyState === WebSocket.OPEN) {
                            player.ws.send(JSON.stringify({
                                type: 'bullet_fired',
                                bulletId: `${playerId}_${Date.now()}`,
                                ownerId: playerId,
                                x: data.x,
                                y: data.y,
                                velocityX: data.velocityX,
                                velocityY: data.velocityY
                            }));
                        }
                    });
                }
            }
            
            // Handle game state requests
            if (data.type === 'get_game_state') {
                const match = activePvPMatches.get(data.matchId);
                if (match) {
                    ws.send(JSON.stringify({
                        type: 'game_state',
                        state: match.getGameState()
                    }));
                }
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
