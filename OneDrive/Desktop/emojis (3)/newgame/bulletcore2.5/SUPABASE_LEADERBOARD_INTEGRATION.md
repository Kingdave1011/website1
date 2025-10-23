# Supabase Leaderboard Integration Guide

This guide shows how to integrate Supabase into your Space Shooter game to sync player data and leaderboards.

## Step 1: Get Your Supabase Credentials

1. Go to your Supabase project: https://app.supabase.com
2. Click on your project
3. Go to **Settings** → **API**
4. Copy these values:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon public key** (starts with `eyJ...`)

## Step 2: Add Supabase to Your Game

The game loads Supabase from CDN, so no installation needed!

## Step 3: Update Game to Save Scores

Add this code to `HideoutAdsWebsite/game/index.html` in the `<head>` section:

```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
```

Add this JavaScript before the game starts:

```javascript
// Supabase Configuration
const SUPABASE_URL = 'YOUR_PROJECT_URL_HERE';
const SUPABASE_KEY = 'YOUR_ANON_KEY_HERE';
const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

// Function to save player score
async function savePlayerScore(playerName, score, kills, wave) {
    try {
        const { data, error } = await supabase
            .from('leaderboard')
            .insert([
                {
                    player_name: playerName,
                    score: score,
                    kills: kills,
                    wave_reached: wave,
                    played_at: new Date().toISOString()
                }
            ]);
        
        if (error) console.error('Error saving score:', error);
        else console.log('Score saved!', data);
    } catch (err) {
        console.error('Failed to save score:', err);
    }
}

// Call this when game ends
// Example: savePlayerScore('King_davez', 15000, 50, 10);
```

## Step 4: Create Leaderboard Table in Supabase

Go to Supabase SQL Editor and run:

```sql
-- Create leaderboard table
CREATE TABLE leaderboard (
    id BIGSERIAL PRIMARY KEY,
    player_name TEXT NOT NULL,
    score INTEGER NOT NULL,
    kills INTEGER DEFAULT 0,
    wave_reached INTEGER DEFAULT 1,
    played_at TIMESTAMP DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX idx_score ON leaderboard(score DESC);

-- Enable Row Level Security
ALTER TABLE leaderboard ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read leaderboard
CREATE POLICY "Anyone can view leaderboard"
    ON leaderboard FOR SELECT
    USING (true);

-- Allow anyone to insert scores
CREATE POLICY "Anyone can insert scores"
    ON leaderboard FOR INSERT
    WITH CHECK (true);
```

## Step 5: Update Leaderboard Page

In `HideoutAdsWebsite/leaderboard.html`, replace the `loadLeaderboard()` function:

```javascript
// Add Supabase to leaderboard.html
const SUPABASE_URL = 'YOUR_PROJECT_URL_HERE';
const SUPABASE_KEY = 'YOUR_ANON_KEY_HERE';

// Load Supabase library
const script = document.createElement('script');
script.src = 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2';
script.onload = () => {
    window.supabase = supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
    loadLeaderboard();
};
document.head.appendChild(script);

async function loadLeaderboard() {
    const content = document.getElementById('leaderboard-content');
    content.innerHTML = '<div class="loading">Loading...</div>';
    
    try {
        const { data, error } = await window.supabase
            .from('leaderboard')
            .select('*')
            .order('score', { ascending: false })
            .limit(10);
        
        if (error) throw error;
        
        const formattedData = data.map(item => ({
            name: item.player_name,
            score: item.score,
            kills: item.kills,
            games: item.wave_reached
        }));
        
        displayLeaderboard(formattedData);
    } catch (error) {
        console.error('Error:', error);
        content.innerHTML = '<div class="loading">⚠️ Unable to load leaderboard</div>';
    }
}
```

## Step 6: Test It

1. Play your game
2. When game ends, score should save to Supabase
3. Visit leaderboard page - scores should display
4. Check Supabase dashboard to see data

## Troubleshooting

**Scores not saving?**
- Check browser console for errors
- Verify Supabase URL and key are correct
- Check Supabase dashboard → Authentication → Policies

**Leaderboard empty?**
- Make sure table exists in Supabase
- Check RLS policies allow SELECT
- Verify data exists in Supabase table editor

## Security Notes

- The anon key is safe to use in browser
- Row Level Security protects your data
- Consider adding rate limiting for production

That's it! Your game now syncs scores to Supabase and displays on leaderboard!
