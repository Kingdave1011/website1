# Vercel Serverless API Documentation

## Overview

Your Space Shooter game now has three Vercel serverless API endpoints that act as a gateway for:
- **Leaderboard**: Fetch top player scores
- **Matchmaking**: Find and join multiplayer matches
- **Player Stats**: View and update individual player statistics

These APIs are deployed on Vercel and integrate with your Supabase database.

---

## 🎯 API Endpoints

### Base URL
When deployed to Vercel:
```
https://your-domain.vercel.app/api/
```

For local testing:
```
http://localhost:3000/api/
```

---

## 📊 1. Leaderboard API

### GET `/api/leaderboard`

Fetch the global leaderboard with top players.

**Query Parameters:**
- `limit` (optional): Number of entries to return (default: 10, max: 100)
- `offset` (optional): Pagination offset (default: 0)

**Example Request:**
```javascript
fetch('https://your-domain.vercel.app/api/leaderboard?limit=10')
  .then(response => response.json())
  .then(data => console.log(data));
```

**Example Response:**
```json
{
  "success": true,
  "count": 10,
  "data": [
    {
      "rank": 1,
      "name": "ProGamer123",
      "score": 15000,
      "kills": 250,
      "games": 45,
      "timestamp": "2025-10-23T05:00:00Z"
    }
  ]
}
```

---

## 🎮 2. Matchmaking API

### GET `/api/matchmaking`

Find an available match or check queue status.

**Query Parameters:**
- `playerId` (required): Unique player identifier

**Example Request:**
```javascript
const playerId = crypto.randomUUID();
fetch(`https://your-domain.vercel.app/api/matchmaking?playerId=${playerId}`)
  .then(response => response.json())
  .then(data => console.log(data));
```

**Example Response (Match Found):**
```json
{
  "success": true,
  "status": "match_found",
  "server": {
    "id": "railway-main",
    "url": "wss://jw6v6rkm.up.railway.app",
    "region": "us-east",
    "players": 0,
    "maxPlayers": 10,
    "status": "active"
  }
}
```

**Example Response (In Queue):**
```json
{
  "success": true,
  "status": "in_queue",
  "position": 3,
  "queueSize": 8,
  "estimatedWait": 30
}
```

---

### POST `/api/matchmaking`

Join the matchmaking queue.

**Request Body:**
```json
{
  "playerId": "unique-player-id",
  "playerName": "ProGamer123",
  "gameMode": "default"
}
```

**Example Request:**
```javascript
fetch('https://your-domain.vercel.app/api/matchmaking', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    playerId: 'unique-player-id',
    playerName: 'ProGamer123',
    gameMode: 'default'
  })
})
  .then(response => response.json())
  .then(data => console.log(data));
```

**Example Response:**
```json
{
  "success": true,
  "status": "joined_queue",
  "position": 5,
  "queueSize": 5,
  "estimatedWait": 40
}
```

---

### DELETE `/api/matchmaking`

Leave the matchmaking queue.

**Query Parameters:**
- `playerId` (required): Unique player identifier

**Example Request:**
```javascript
fetch(`https://your-domain.vercel.app/api/matchmaking?playerId=${playerId}`, {
  method: 'DELETE'
})
  .then(response => response.json())
  .then(data => console.log(data));
```

**Example Response:**
```json
{
  "success": true,
  "status": "left_queue",
  "message": "Successfully removed from matchmaking queue"
}
```

---

## 📈 3. Player Stats API

### GET `/api/stats`

Fetch detailed statistics for a specific player.

**Query Parameters:**
- `playerId` (optional): Player's unique ID
- `playerName` (optional): Player's display name

**Note:** You must provide either `playerId` or `playerName`.

**Example Request:**
```javascript
fetch('https://your-domain.vercel.app/api/stats?playerName=ProGamer123')
  .then(response => response.json())
  .then(data => console.log(data));
```

**Example Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "playerName": "ProGamer123",
    "score": 15000,
    "kills": 250,
    "gamesPlayed": 45,
    "rank": 1,
    "totalPlayers": 150,
    "avgScorePerGame": 333,
    "avgKillsPerGame": "5.6",
    "lastPlayed": "2025-10-23T05:00:00Z",
    "stats": {
      "highScore": 15000,
      "totalKills": 250,
      "gamesPlayed": 45
    }
  }
}
```

---

### POST `/api/stats`

Update player statistics (used after completing a game).

**Request Body:**
```json
{
  "playerName": "ProGamer123",
  "score": 16000,
  "kills": 275,
  "wave": 48
}
```

**Example Request:**
```javascript
fetch('https://your-domain.vercel.app/api/stats', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    playerName: 'ProGamer123',
    score: 16000,
    kills: 275,
    wave: 48
  })
})
  .then(response => response.json())
  .then(data => console.log(data));
```

**Example Response (New High Score):**
```json
{
  "success": true,
  "message": "New high score! Stats updated",
  "data": {
    "id": 1,
    "player_name": "ProGamer123",
    "score": 16000,
    "kills": 275,
    "wave": 48
  },
  "newHighScore": true
}
```

**Example Response (Not a New High Score):**
```json
{
  "success": true,
  "message": "Score recorded but not a new high score",
  "currentHighScore": 16000,
  "newHighScore": false
}
```

---

## 🔧 Integration Examples

### Using in Your Game

**Example: Fetch Leaderboard on Page Load**
```javascript
async function loadLeaderboard() {
  try {
    const response = await fetch('https://your-domain.vercel.app/api/leaderboard?limit=10');
    const data = await response.json();
    
    if (data.success) {
      displayLeaderboard(data.data);
    }
  } catch (error) {
    console.error('Failed to load leaderboard:', error);
  }
}
```

**Example: Update Player Stats After Game**
```javascript
async function submitGameScore(playerName, score, kills, wave) {
  try {
    const response = await fetch('https://your-domain.vercel.app/api/stats', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ playerName, score, kills, wave })
    });
    
    const data = await response.json();
    
    if (data.success && data.newHighScore) {
      alert('New high score! 🎉');
    }
  } catch (error) {
    console.error('Failed to submit score:', error);
  }
}
```

**Example: Find Multiplayer Match**
```javascript
async function findMatch(playerId, playerName) {
  try {
    // First, join the queue
    await fetch('https://your-domain.vercel.app/api/matchmaking', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ playerId, playerName })
    });
    
    // Then check for available matches
    const response = await fetch(
      `https://your-domain.vercel.app/api/matchmaking?playerId=${playerId}`
    );
    const data = await response.json();
    
    if (data.status === 'match_found') {
      connectToServer(data.server.url);
    } else if (data.status === 'in_queue') {
      console.log(`Queue position: ${data.position}, Wait: ${data.estimatedWait}s`);
    }
  } catch (error) {
    console.error('Matchmaking error:', error);
  }
}
```

---

## 🚀 Deployment

### Step 1: Push to GitHub
```bash
cd HideoutAdsWebsite
git add api/
git commit -m "Add Vercel serverless API endpoints"
git push origin main
```

### Step 2: Deploy to Vercel
1. Go to [vercel.com](https://vercel.com)
2. Import your GitHub repository
3. Set Root Directory to `HideoutAdsWebsite`
4. Deploy

### Step 3: Test Your APIs
After deployment, test each endpoint:
```bash
# Test Leaderboard
curl https://your-domain.vercel.app/api/leaderboard

# Test Matchmaking
curl https://your-domain.vercel.app/api/matchmaking?playerId=test123

# Test Stats
curl https://your-domain.vercel.app/api/stats?playerName=TestPlayer
```

---

## 🔒 Security Notes

1. **CORS**: All APIs have CORS enabled (`Access-Control-Allow-Origin: *`)
2. **Rate Limiting**: Consider adding rate limiting in production
3. **API Keys**: Supabase keys are included in the code (use environment variables for production)
4. **Validation**: All endpoints validate required parameters

---

## 📝 Environment Variables (Production)

For production, move sensitive data to environment variables:

In Vercel Dashboard → Settings → Environment Variables:
```
SUPABASE_URL=https://flnbfizlfofqfbrdjttk.supabase.co
SUPABASE_KEY=your-supabase-key
```

Then update your API files:
```javascript
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY;
```

---

## 🎯 Next Steps

1. **Deploy to Vercel** - Push code and deploy
2. **Update multiplayer-lobby.html** - Use the matchmaking API
3. **Update leaderboard.html** - Use the leaderboard API  
4. **Update game code** - Submit scores using the stats API
5. **Test Everything** - Verify all endpoints work correctly

---

## 🐛 Troubleshooting

**Issue: CORS Errors**
- Verify `vercel.json` has correct CORS headers
- Check browser console for specific errors

**Issue: 500 Internal Server Error**
- Check Vercel function logs
- Verify Supabase credentials are correct
- Ensure database table exists

**Issue: 404 Not Found**
- Verify API files are in `HideoutAdsWebsite/api/` directory
- Check file names match exactly: `leaderboard.js`, `matchmaking.js`, `stats.js`
- Redeploy to Vercel

---

## 📚 Additional Resources

- [Vercel Serverless Functions](https://vercel.com/docs/functions)
- [Supabase REST API](https://supabase.com/docs/guides/api)
- [CORS Documentation](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)

---

**Created**: October 23, 2025
**Version**: 1.0
**Author**: Cline AI Assistant
