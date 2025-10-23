/**
 * Vercel Serverless Function - Matchmaking API
 * Endpoint: /api/matchmaking
 * Methods: GET (find match), POST (join queue), DELETE (leave queue)
 * 
 * This API acts as a gateway to assign players to game servers
 */

// In-memory matchmaking queue (Note: In production, use Redis or similar)
let matchmakingQueue = [];

export default async function handler(req, res) {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  // Handle OPTIONS request for CORS
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  try {
    // GET - Find available match or check queue status
    if (req.method === 'GET') {
      const { playerId } = req.query;

      if (!playerId) {
        return res.status(400).json({
          success: false,
          error: 'playerId is required'
        });
      }

      // Check if player is in queue
      const playerInQueue = matchmakingQueue.find(p => p.id === playerId);

      if (playerInQueue) {
        return res.status(200).json({
          success: true,
          status: 'in_queue',
          position: matchmakingQueue.indexOf(playerInQueue) + 1,
          queueSize: matchmakingQueue.length,
          estimatedWait: matchmakingQueue.indexOf(playerInQueue) * 10 // seconds
        });
      }

      // Try to find an available match
      // For now, return available game servers (Railway/Render)
      const availableServers = [
        {
          id: 'railway-main',
          url: 'wss://jw6v6rkm.up.railway.app',
          region: 'us-east',
          players: 0,
          maxPlayers: 10,
          status: 'active'
        },
        {
          id: 'render-backup',
          url: 'wss://your-render-url.onrender.com',
          region: 'us-west',
          players: 0,
          maxPlayers: 10,
          status: 'standby'
        }
      ];

      const bestServer = availableServers[0]; // Simple selection

      return res.status(200).json({
        success: true,
        status: 'match_found',
        server: bestServer
      });
    }

    // POST - Join matchmaking queue
    if (req.method === 'POST') {
      const { playerId, playerName, gameMode = 'default' } = req.body || {};

      if (!playerId) {
        return res.status(400).json({
          success: false,
          error: 'playerId is required'
        });
      }

      // Check if player is already in queue
      const existingPlayer = matchmakingQueue.find(p => p.id === playerId);
      if (existingPlayer) {
        return res.status(200).json({
          success: true,
          status: 'already_in_queue',
          position: matchmakingQueue.indexOf(existingPlayer) + 1,
          queueSize: matchmakingQueue.length
        });
      }

      // Add player to queue
      const newPlayer = {
        id: playerId,
        name: playerName || `Player_${playerId.substr(0, 8)}`,
        gameMode,
        joinedAt: Date.now()
      };

      matchmakingQueue.push(newPlayer);

      // Clean up old queue entries (older than 5 minutes)
      const fiveMinutesAgo = Date.now() - (5 * 60 * 1000);
      matchmakingQueue = matchmakingQueue.filter(p => p.joinedAt > fiveMinutesAgo);

      return res.status(200).json({
        success: true,
        status: 'joined_queue',
        position: matchmakingQueue.length,
        queueSize: matchmakingQueue.length,
        estimatedWait: (matchmakingQueue.length - 1) * 10 // seconds
      });
    }

    // DELETE - Leave matchmaking queue
    if (req.method === 'DELETE') {
      const { playerId } = req.query;

      if (!playerId) {
        return res.status(400).json({
          success: false,
          error: 'playerId is required'
        });
      }

      const initialLength = matchmakingQueue.length;
      matchmakingQueue = matchmakingQueue.filter(p => p.id !== playerId);

      if (matchmakingQueue.length < initialLength) {
        return res.status(200).json({
          success: true,
          status: 'left_queue',
          message: 'Successfully removed from matchmaking queue'
        });
      } else {
        return res.status(404).json({
          success: false,
          error: 'Player not found in queue'
        });
      }
    }

    // Method not allowed
    return res.status(405).json({
      success: false,
      error: 'Method not allowed'
    });

  } catch (error) {
    console.error('Matchmaking API Error:', error);
    return res.status(500).json({
      success: false,
      error: 'Internal server error',
      message: error.message
    });
  }
}
