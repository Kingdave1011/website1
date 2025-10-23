/**
 * Vercel Serverless Function - Player Stats API
 * Endpoint: /api/stats
 * Methods: GET (fetch player stats), POST (update player stats)
 */

export default async function handler(req, res) {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  // Handle OPTIONS request for CORS
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  try {
    // Supabase configuration
    const SUPABASE_URL = 'https://flnbfizlfofqfbrdjttk.supabase.co';
    const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZsbmJmaXpsZm9mcWZicmRqdHRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjk1NTMzNzUsImV4cCI6MjA0NTEyOTM3NX0.kQ9HoYOuVxoQNZAVTy1kpXH3l68kRTBdSbE5_pzI9ik';

    // GET - Fetch player statistics
    if (req.method === 'GET') {
      const { playerId, playerName } = req.query;

      if (!playerId && !playerName) {
        return res.status(400).json({
          success: false,
          error: 'playerId or playerName is required'
        });
      }

      // Build query based on available parameters
      let query = `${SUPABASE_URL}/rest/v1/leaderboard?select=*`;
      
      if (playerId) {
        query += `&id=eq.${playerId}`;
      } else if (playerName) {
        query += `&player_name=eq.${encodeURIComponent(playerName)}`;
      }

      const response = await fetch(query, {
        headers: {
          'apikey': SUPABASE_KEY,
          'Authorization': `Bearer ${SUPABASE_KEY}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error(`Supabase error: ${response.statusText}`);
      }

      const data = await response.json();

      if (data.length === 0) {
        return res.status(404).json({
          success: false,
          error: 'Player not found'
        });
      }

      const playerData = data[0];

      // Calculate additional stats
      const avgScorePerGame = playerData.wave > 0 ? Math.round(playerData.score / playerData.wave) : 0;
      const avgKillsPerGame = playerData.wave > 0 ? (playerData.kills / playerData.wave).toFixed(1) : 0;

      // Get player rank
      const rankResponse = await fetch(
        `${SUPABASE_URL}/rest/v1/leaderboard?select=score&order=score.desc`,
        {
          headers: {
            'apikey': SUPABASE_KEY,
            'Authorization': `Bearer ${SUPABASE_KEY}`,
            'Content-Type': 'application/json'
          }
        }
      );

      if (rankResponse.ok) {
        const allScores = await rankResponse.json();
        const rank = allScores.findIndex(entry => entry.score <= playerData.score) + 1;
        playerData.rank = rank || allScores.length + 1;
        playerData.totalPlayers = allScores.length;
      }

      return res.status(200).json({
        success: true,
        data: {
          id: playerData.id,
          playerName: playerData.player_name,
          score: playerData.score,
          kills: playerData.kills,
          gamesPlayed: playerData.wave,
          rank: playerData.rank,
          totalPlayers: playerData.totalPlayers,
          avgScorePerGame,
          avgKillsPerGame,
          lastPlayed: playerData.created_at,
          stats: {
            highScore: playerData.score,
            totalKills: playerData.kills,
            gamesPlayed: playerData.wave
          }
        }
      });
    }

    // POST - Update player statistics
    if (req.method === 'POST') {
      const { playerName, score, kills, wave } = req.body || {};

      if (!playerName || score === undefined) {
        return res.status(400).json({
          success: false,
          error: 'playerName and score are required'
        });
      }

      // Check if player exists
      const checkResponse = await fetch(
        `${SUPABASE_URL}/rest/v1/leaderboard?player_name=eq.${encodeURIComponent(playerName)}`,
        {
          headers: {
            'apikey': SUPABASE_KEY,
            'Authorization': `Bearer ${SUPABASE_KEY}`,
            'Content-Type': 'application/json'
          }
        }
      );

      const existingData = await checkResponse.json();

      if (existingData.length > 0) {
        // Update existing player - only if new score is higher
        const currentHighScore = existingData[0].score;
        
        if (score > currentHighScore) {
          const updateResponse = await fetch(
            `${SUPABASE_URL}/rest/v1/leaderboard?player_name=eq.${encodeURIComponent(playerName)}`,
            {
              method: 'PATCH',
              headers: {
                'apikey': SUPABASE_KEY,
                'Authorization': `Bearer ${SUPABASE_KEY}`,
                'Content-Type': 'application/json',
                'Prefer': 'return=representation'
              },
              body: JSON.stringify({
                score,
                kills: kills || existingData[0].kills,
                wave: wave || existingData[0].wave
              })
            }
          );

          if (!updateResponse.ok) {
            throw new Error(`Failed to update stats: ${updateResponse.statusText}`);
          }

          const updatedData = await updateResponse.json();

          return res.status(200).json({
            success: true,
            message: 'New high score! Stats updated',
            data: updatedData[0],
            newHighScore: true
          });
        } else {
          return res.status(200).json({
            success: true,
            message: 'Score recorded but not a new high score',
            currentHighScore,
            newHighScore: false
          });
        }
      } else {
        // Create new player entry
        const insertResponse = await fetch(
          `${SUPABASE_URL}/rest/v1/leaderboard`,
          {
            method: 'POST',
            headers: {
              'apikey': SUPABASE_KEY,
              'Authorization': `Bearer ${SUPABASE_KEY}`,
              'Content-Type': 'application/json',
              'Prefer': 'return=representation'
            },
            body: JSON.stringify({
              player_name: playerName,
              score,
              kills: kills || 0,
              wave: wave || 1
            })
          }
        );

        if (!insertResponse.ok) {
          throw new Error(`Failed to create player: ${insertResponse.statusText}`);
        }

        const newData = await insertResponse.json();

        return res.status(201).json({
          success: true,
          message: 'Player stats created',
          data: newData[0],
          newHighScore: true
        });
      }
    }

    // Method not allowed
    return res.status(405).json({
      success: false,
      error: 'Method not allowed'
    });

  } catch (error) {
    console.error('Stats API Error:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to process player stats',
      message: error.message
    });
  }
}
