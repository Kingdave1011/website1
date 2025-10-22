const WebSocket = require('ws');
const http = require('http');

// Create HTTP server
const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Matchmaking Server Running\n');
});

// Create WebSocket server
const wss = new WebSocket.Server({ server });

// Store players waiting for match
const waitingPlayers = new Map();
const activeMatches = new Map();

console.log('Matchmaking Server Starting...');

wss.on('connection', (ws) => {
  console.log('New client connected');
  
  ws.on('message', (message) => {
    try {
      const data = JSON.parse(message);
      
      switch (data.type) {
        case 'JOIN_QUEUE':
          handleJoinQueue(ws, data);
          break;
        case 'LEAVE_QUEUE':
          handleLeaveQueue(ws, data);
          break;
        case 'MATCH_READY':
          handleMatchReady(ws, data);
          break;
        default:
          ws.send(JSON.stringify({ type: 'ERROR', message: 'Unknown message type' }));
      }
    } catch (error) {
      console.error('Error processing message:', error);
      ws.send(JSON.stringify({ type: 'ERROR', message: 'Invalid message format' }));
    }
  });

  ws.on('close', () => {
    console.log('Client disconnected');
    // Remove player from waiting queue if they disconnect
    for (const [playerId, playerData] of waitingPlayers.entries()) {
      if (playerData.ws === ws) {
        waitingPlayers.delete(playerId);
        console.log(`Removed player ${playerId} from queue`);
        break;
      }
    }
  });

  // Send welcome message
  ws.send(JSON.stringify({
    type: 'CONNECTED',
    message: 'Connected to matchmaking server'
  }));
});

function handleJoinQueue(ws, data) {
  const playerId = data.playerId || generatePlayerId();
  const playerRating = data.rating || 1000;
  
  console.log(`Player ${playerId} joining queue with rating ${playerRating}`);
  
  // Add player to waiting queue
  waitingPlayers.set(playerId, {
    ws,
    playerId,
    rating: playerRating,
    joinTime: Date.now()
  });

  // Notify player they're in queue
  ws.send(JSON.stringify({
    type: 'QUEUE_JOINED',
    playerId,
    position: waitingPlayers.size
  }));

  // Try to find a match
  findMatch(playerId);
}

function handleLeaveQueue(ws, data) {
  const playerId = data.playerId;
  
  if (waitingPlayers.has(playerId)) {
    waitingPlayers.delete(playerId);
    console.log(`Player ${playerId} left queue`);
    
    ws.send(JSON.stringify({
      type: 'QUEUE_LEFT',
      playerId
    }));
  }
}

function handleMatchReady(ws, data) {
  const matchId = data.matchId;
  const playerId = data.playerId;
  
  if (activeMatches.has(matchId)) {
    const match = activeMatches.get(matchId);
    
    if (match.player1.playerId === playerId) {
      match.player1.ready = true;
    } else if (match.player2.playerId === playerId) {
      match.player2.ready = true;
    }
    
    // Check if both players are ready
    if (match.player1.ready && match.player2.ready) {
      // Start match
      const matchData = {
        type: 'MATCH_START',
        matchId,
        players: [
          { playerId: match.player1.playerId, rating: match.player1.rating },
          { playerId: match.player2.playerId, rating: match.player2.rating }
        ]
      };
      
      match.player1.ws.send(JSON.stringify(matchData));
      match.player2.ws.send(JSON.stringify(matchData));
      
      console.log(`Match ${matchId} starting`);
    }
  }
}

function findMatch(playerId) {
  const player = waitingPlayers.get(playerId);
  
  if (!player) return;
  
  // Find best opponent (closest rating)
  let bestOpponent = null;
  let bestRatingDiff = Infinity;
  
  for (const [opponentId, opponent] of waitingPlayers.entries()) {
    if (opponentId === playerId) continue;
    
    const ratingDiff = Math.abs(player.rating - opponent.rating);
    
    if (ratingDiff < bestRatingDiff) {
      bestRatingDiff = ratingDiff;
      bestOpponent = opponent;
    }
  }
  
  // Create match if opponent found
  if (bestOpponent) {
    const matchId = generateMatchId();
    
    // Remove both players from queue
    waitingPlayers.delete(playerId);
    waitingPlayers.delete(bestOpponent.playerId);
    
    // Create match
    const match = {
      matchId,
      player1: { ...player, ready: false },
      player2: { ...bestOpponent, ready: false },
      createdAt: Date.now()
    };
    
    activeMatches.set(matchId, match);
    
    // Notify both players
    const matchFoundData = {
      type: 'MATCH_FOUND',
      matchId,
      opponent: {
        playerId: bestOpponent.playerId,
        rating: bestOpponent.rating
      }
    };
    
    player.ws.send(JSON.stringify({
      ...matchFoundData,
      yourPlayerId: playerId
    }));
    
    bestOpponent.ws.send(JSON.stringify({
      ...matchFoundData,
      opponent: {
        playerId: player.playerId,
        rating: player.rating
      },
      yourPlayerId: bestOpponent.playerId
    }));
    
    console.log(`Match ${matchId} created: ${playerId} vs ${bestOpponent.playerId}`);
  }
}

function generatePlayerId() {
  return 'player_' + Math.random().toString(36).substr(2, 9);
}

function generateMatchId() {
  return 'match_' + Math.random().toString(36).substr(2, 9);
}

// Start server
const PORT = process.env.PORT || 3001;
server.listen(PORT, () => {
  console.log(`Matchmaking server listening on port ${PORT}`);
});

// Clean up old matches every minute
setInterval(() => {
  const now = Date.now();
  for (const [matchId, match] of activeMatches.entries()) {
    // Remove matches older than 10 minutes
    if (now - match.createdAt > 10 * 60 * 1000) {
      activeMatches.delete(matchId);
      console.log(`Removed expired match ${matchId}`);
    }
  }
}, 60000);
