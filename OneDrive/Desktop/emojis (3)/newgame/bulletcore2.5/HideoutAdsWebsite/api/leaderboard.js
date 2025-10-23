/**
 * Vercel Serverless Function - Leaderboard API
 * Endpoint: /api/leaderboard
 * Method: GET
 * Query Parameters:
 *   - limit: number of entries to return (default: 10, max: 100)
 *   - offset: pagination offset (default: 0)
 */

export default async function handler(req, res) {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  // Handle OPTIONS request for CORS
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  // Only allow GET requests
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    // Supabase configuration
    const SUPABASE_URL = 'https://flnbfizlfofqfbrdjttk.supabase.co';
    const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZsbmJmaXpsZm9mcWZicmRqdHRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjk1NTMzNzUsImV4cCI6MjA0NTEyOTM3NX0.kQ9HoYOuVxoQNZAVTy1kpXH3l68kRTBdSbE5_pzI9ik';

    // Parse query parameters
    const limit = Math.min(parseInt(req.query.limit) || 10, 100);
    const offset = parseInt(req.query.offset) || 0;

    // Fetch leaderboard data from Supabase
    const response = await fetch(
      `${SUPABASE_URL}/rest/v1/leaderboard?select=*&order=score.desc&limit=${limit}&offset=${offset}`,
      {
        headers: {
          'apikey': SUPABASE_KEY,
          'Authorization': `Bearer ${SUPABASE_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );

    if (!response.ok) {
      throw new Error(`Supabase error: ${response.statusText}`);
    }

    const data = await response.json();

    // Transform data for frontend
    const leaderboard = data.map((entry, index) => ({
      rank: offset + index + 1,
      name: entry.player_name,
      score: entry.score,
      kills: entry.kills,
      games: entry.wave,
      timestamp: entry.created_at
    }));

    return res.status(200).json({
      success: true,
      count: leaderboard.length,
      data: leaderboard
    });

  } catch (error) {
    console.error('Leaderboard API Error:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to fetch leaderboard data',
      message: error.message
    });
  }
}
