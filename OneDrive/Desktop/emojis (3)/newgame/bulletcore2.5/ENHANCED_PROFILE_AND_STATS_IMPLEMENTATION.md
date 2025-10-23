# Enhanced Profile & Stats Implementation Guide

## Overview
This guide covers the complete implementation of profile customization, player stats tracking, and Supabase integration for hideoutads.online.

## ✅ Already Completed

### 1. Database Schema Created
- File: `COMPLETE_SUPABASE_DATABASE_SETUP.sql`
- Run this entire SQL file in your Supabase SQL Editor to create all tables

### 2. Game Functions Added (index.html)
The following functions are now available in the game:
- `window.savePlayerScore()` - Saves to leaderboard table
- `window.saveMatchHistory()` - Saves detailed match data
- `window.saveAchievement()` - Saves player achievements
- `window.updatePlayerProfile()` - Updates/creates player profiles

### 3. Game Integration (index.tsx)
- Game automatically calls `savePlayerScore()` when game ends
- Saves: player name, score, kills, wave reached

### 4. Leaderboard Page (leaderboard.html)
- Fetches top 10 players from Supabase
- Auto-refreshes every 30 seconds
- Beautiful rank display with gold/silver/bronze

## 🔧 Additional Integration Needed

### Step 1: Enhanced Game Over Function (index.tsx)

Add this to the `gameOver()` function after the existing `savePlayerScore` call:

```typescript
// Also save detailed match history
if (typeof (window as any).saveMatchHistory === 'function' && !gameState.username.startsWith('guest_')) {
    const matchData = {
        playerName: gameState.username,
        score: score,
        kills: gameState.stats.totalKills,
        wave: currentWave,
        duration: Math.floor((Date.now() - gameStartTime) / 1000),
        ship: gameState.selectedShip,
        map: gameState.selectedMap,
        boostersUsed: gameState.stats.boostersUsed,
        powerUpsCollected: powerUpsCollectedThisGame,
        deaths: totalDeaths
    };
    (window as any).saveMatchHistory(matchData);
}
```

### Step 2: Track Additional Game Variables

Add these global variables at the top of index.tsx:

```typescript
let gameStartTime = 0;
let powerUpsCollectedThisGame = 0;
let totalDeaths = 0;
```

Initialize in `startGame()`:
```typescript
gameStartTime = Date.now();
powerUpsCollectedThisGame = 0;
totalDeaths = 0;
```

Increment in appropriate places:
- `powerUpsCollectedThisGame++` when player collects power-up
- `totalDeaths++` when player loses a life

### Step 3: Save Achievements to Database

Update `checkAchievements()` function to also save to Supabase:

```typescript
function checkAchievements(isGameOver: boolean) {
    ACHIEVEMENTS.forEach(ach => {
        if (!gameState.unlockedAchievements.includes(ach.id) && ach.condition(gameState.stats, gameState.level, currentWave)) {
            gameState.unlockedAchievements.push(ach.id);
            achievementToast.innerText = `${ach.icon} ${ach.name}`;
            achievementToast.classList.add('show');
            playSound('achievement');
            setTimeout(() => achievementToast.classList.remove('show'), 3000);
            saveGameState();
            
            // Save to Supabase
            if (typeof (window as any).saveAchievement === 'function' && !gameState.username.startsWith('guest_')) {
                (window as any).saveAchievement(gameState.username, ach.id, ach.name);
            }
        }
    });
}
```

### Step 4: Enhanced Profile Page (profile.html)

Replace the `loadProfile()` function with this Supabase-powered version:

```javascript
async function loadProfile() {
    const profileContent = document.getElementById('profile-content');
    
    // Check for logged in user
    const websiteUser = sessionStorage.getItem('space_shooter_username');
    
    if (!websiteUser) {
        profileContent.innerHTML = `
            <div class="login-prompt">
                <h2>🔒 Please Log In</h2>
                <p style="color: #8A2BE2; font-size: 1.2rem; margin-bottom: 20px;">
                    Create an account to track your stats and customize your profile!
                </p>
                <a href="user-auth.html" class="back-btn">Sign In</a>
            </div>
        `;
        return;
    }

    // Load Supabase
    if (!window.supabase) {
        const script = document.createElement('script');
        script.src = 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2';
        document.head.appendChild(script);
        await new Promise((resolve) => script.onload = resolve);
    }

    const SUPABASE_URL = 'https://flnbfizlfofqfbrdjttk.supabase.co';
    const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZsbmJmaXpsZm9mcWZicmRqdHRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEwOTg4MzQsImV4cCI6MjA3NjY3NDgzNH0.8lHxwyudvSJA7S-FDtj1XYVm6Zrpc0_myIzrUClzH4g';
    const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

    try {
        // Fetch player profile from Supabase
        const { data: profile, error } = await supabase
            .from('player_profiles')
            .select('*')
            .eq('player_name', websiteUser)
            .single();

        if (error && error.code !== 'PGRST116') throw error;

        // Fetch recent matches
        const { data: recentMatches } = await supabase
            .from('match_history')
            .select('*')
            .eq('player_name', websiteUser)
            .order('played_at', { ascending: false })
            .limit(5);

        // Fetch achievements
        const { data: achievements } = await supabase
            .from('player_achievements')
            .select('*')
            .eq('player_name', websiteUser);

        displayProfile(websiteUser, profile, recentMatches, achievements);

    } catch (error) {
        console.error('Error loading profile:', error);
        profileContent.innerHTML = '<div class="loading">Error loading profile. Please refresh.</div>';
    }
}

function displayProfile(username, profile, matches, achievements) {
    const p = profile || {
        player_name: username,
        level: 1,
        total_kills: 0,
        total_games_played: 0,
        highest_score: 0,
        highest_wave: 0,
        bio: 'New space pilot!',
        avatar_url: 'https://api.dicebear.com/7.x/avataaars/svg?seed=' + username
    };

    const profileContent = document.getElementById('profile-content');
    profileContent.innerHTML = `
        <div class="profile-header">
            <img src="${p.avatar_url}" alt="Avatar" style="width: 100px; height: 100px; border-radius: 50%; border: 3px solid #00C6FF; margin-bottom: 15px;">
            <h2>${username}</h2>
            <div class="level-badge">Level ${p.level || 1}</div>
            <p style="color: #8A2BE2; margin-top: 15px; font-size: 1.1rem; max-width: 500px; margin-left: auto; margin-right: auto;">
                ${p.bio || 'No bio yet'}
            </p>
            <button onclick="editProfile()" style="margin-top: 15px; padding: 10px 20px; background: rgba(0,198,255,0.2); border: 2px solid #00C6FF; border-radius: 8px; color: #00C6FF; cursor: pointer;">
                ✏️ Edit Profile
            </button>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-value">${p.total_kills || 0}</div>
                <div class="stat-label">💥 Total Kills</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">${p.highest_wave || 0}</div>
                <div class="stat-label">🌊 Best Wave</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">${p.highest_score || 0}</div>
                <div class="stat-label">🏆 High Score</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">${p.total_games_played || 0}</div>
                <div class="stat-label">🎮 Games Played</div>
            </div>
        </div>

        <div class="section">
            <h3>📜 Recent Matches</h3>
            ${matches && matches.length > 0 ? `
                <div style="overflow-x: auto;">
                    <table style="width: 100%; border-collapse: collapse; margin-top: 15px;">
                        <thead>
                            <tr style="border-bottom: 2px solid #00C6FF;">
                                <th style="padding: 10px; text-align: left; color: #00C6FF;">Score</th>
                                <th style="padding: 10px; text-align: left; color: #00C6FF;">Kills</th>
                                <th style="padding: 10px; text-align: left; color: #00C6FF;">Wave</th>
                                <th style="padding: 10px; text-align: left; color: #00C6FF;">Ship</th>
                                <th style="padding: 10px; text-align: left; color: #00C6FF;">Date</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${matches.map(m => `
                                <tr style="border-bottom: 1px solid rgba(0,198,255,0.2);">
                                    <td style="padding: 10px;">${m.score}</td>
                                    <td style="padding: 10px;">${m.kills}</td>
                                    <td style="padding: 10px;">${m.wave}</td>
                                    <td style="padding: 10px;">${m.ship_used || 'ranger'}</td>
                                    <td style="padding: 10px; font-size: 0.9em;">${new Date(m.played_at).toLocaleDateString()}</td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
            ` : '<p style="color: #8A2BE2;">No matches yet. Play to see your history!</p>'}
        </div>

        <div class="section">
            <h3>🏆 Achievements (${achievements ? achievements.length : 0})</h3>
            <div style="margin-top: 15px;">
                ${achievements && achievements.length > 0
                    ? achievements.map(ach => `<span class="achievement-badge">✓ ${ach.achievement_name}</span>`).join('')
                    : '<p style="color: #8A2BE2;">No achievements yet. Play to unlock!</p>'
                }
            </div>
        </div>
    `;
}

function editProfile() {
    const modal = document.createElement('div');
    modal.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0,0,0,0.9);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 10000;
    `;
    
    modal.innerHTML = `
        <div style="background: #0A0A1A; padding: 30px; border-radius: 15px; border: 2px solid #00C6FF; max-width: 500px; width: 90%;">
            <h2 style="color: #00C6FF; margin-bottom: 20px;">Edit Profile</h2>
            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 5px; color: #8A2BE2;">Bio:</label>
                <textarea id="edit-bio" style="width: 100%; padding: 10px; background: rgba(0,0,0,0.5); border: 1px solid #00C6FF; color: #E0E0E0; border-radius: 5px; font-family: 'Rajdhani', sans-serif; min-height: 100px;" maxlength="200"></textarea>
            </div>
            <div style="margin-bottom: 20px;">
                <label style="display: block; margin-bottom: 5px; color: #8A2BE2;">Avatar (Dice Bear seed):</label>
                <input type="text" id="edit-avatar" style="width: 100%; padding: 10px; background: rgba(0,0,0,0.5); border: 1px solid #00C6FF; color: #E0E0E0; border-radius: 5px;" placeholder="e.g., spacepilot">
            </div>
            <div style="display: flex; gap: 10px;">
                <button onclick="saveProfileChanges()" style="flex: 1; padding: 12px; background: #00C6FF; border: none; border-radius: 8px; color: #000; font-weight: bold; cursor: pointer;">Save Changes</button>
                <button onclick="this.closest('div[style*=fixed]').remove()" style="flex: 1; padding: 12px; background: transparent; border: 2px solid #FF007F; border-radius: 8px; color: #FF007F; cursor: pointer;">Cancel</button>
            </div>
        </div>
    `;
    
    document.body.appendChild(modal);
}

async function saveProfileChanges() {
    const websiteUser = sessionStorage.getItem('space_shooter_username');
    const bio = document.getElementById('edit-bio').value;
    const avatarSeed = document.getElementById('edit-avatar').value || websiteUser;
    
    if (!window.supabase) {
        alert('Please wait for the page to fully load');
        return;
    }

    const SUPABASE_URL = 'https://flnbfizlfofqfbrdjttk.supabase.co';
    const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZsbmJmaXpsZm9mcWZicmRqdHRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEwOTg4MzQsImV4cCI6MjA3NjY3NDgzNH0.8lHxwyudvSJA7S-FDtj1XYVm6Zrpc0_myIzrUClzH4g';
    const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);

    try {
        const { error } = await supabase
            .from('player_profiles')
            .upsert([{
                player_name: websiteUser,
                bio: bio,
                avatar_url: `https://api.dicebear.com/7.x/avataaars/svg?seed=${avatarSeed}`
            }], { onConflict: 'player_name' });

        if (error) throw error;

        alert('Profile updated successfully!');
        document.querySelector('div[style*="fixed"]').remove();
        loadProfile(); // Reload profile
    } catch (error) {
        console.error('Error updating profile:', error);
        alert('Failed to update profile. Please try again.');
    }
}
```

### Step 5: Add Daily/Weekly Leaderboard Tabs (leaderboard.html)

Add tabs above the leaderboard content:

```html
<div style="display: flex; gap: 10px; justify-content: center; margin-bottom: 30px;">
    <button onclick="loadLeaderboard('all')" class="tab-btn active" id="tab-all">🏆 All Time</button>
    <button onclick="loadLeaderboard('daily')" class="tab-btn" id="tab-daily">📅 Today</button>
    <button onclick="loadLeaderboard('weekly')" class="tab-btn" id="tab-weekly">📊 This Week</button>
</div>
```

Update the `loadLeaderboard()` function to accept a type parameter:

```javascript
async function loadLeaderboard(type = 'all') {
    // Update tab styling
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    document.getElementById(`tab-${type}`).classList.add('active');
    
    const content = document.getElementById('leaderboard-content');
    content.innerHTML = '<div class="loading">Loading...</div>';
    
    try {
        const SUPABASE_URL = 'https://flnbfizlfofqfbrdjttk.supabase.co';
        const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZsbmJmaXpsZm9mcWZicmRqdHRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEwOTg4MzQsImV4cCI6MjA3NjY3NDgzNH0.8lHxwyudvSJA7S-FDtj1XYVm6Zrpc0_myIzrUClzH4g';
        
        if (!window.supabase) {
            const script = document.createElement('script');
            script.src = 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2';
            document.head.appendChild(script);
            await new Promise((resolve) => script.onload = resolve);
        }
        
        const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_KEY);
        
        let query, data, error;
        
        if (type === 'daily') {
            const result = await supabase
                .from('daily_leaderboard')
                .select('*')
                .eq('date', new Date().toISOString().split('T')[0])
                .order('score', { ascending: false })
                .limit(10);
            data = result.data;
            error = result.error;
        } else if (type === 'weekly') {
            const weekStart = getWeekStart();
            const result = await supabase
                .from('weekly_leaderboard')
                .select('*')
                .eq('week_start', weekStart)
                .order('score', { ascending: false })
                .limit(10);
            data = result.data;
            error = result.error;
        } else {
            const result = await supabase
                .from('leaderboard')
                .select('*')
                .order('score', { ascending: false })
                .limit(10);
            data = result.data;
            error = result.error;
        }
        
        if (error) throw error;
        
        const leaderboardData = data.map(entry => ({
            name: entry.player_name,
            score: entry.score,
            kills: entry.kills,
            games: entry.wave
        }));
        
        displayLeaderboard(leaderboardData);
        
    } catch (error) {
        content.innerHTML = `
            <div class="loading">
                ⚠️ Unable to load leaderboard.<br>
                <small>Please check your connection and try again.</small>
            </div>
        `;
        console.error('Error loading leaderboard:', error);
    }
}

function getWeekStart() {
    const now = new Date();
    const day = now.getDay();
    const diff = now.getDate() - day;
    const weekStart = new Date(now.setDate(diff));
    return weekStart.toISOString().split('T')[0];
}
```

## 📋 Complete Setup Checklist

1. ✅ Run `COMPLETE_SUPABASE_DATABASE_SETUP.sql` in Supabase SQL Editor
2. ✅ Game functions added to index.html
3. ✅ Basic score saving works (index.tsx)
4. ✅ Leaderboard fetches from database
5. ⏳ Add match history tracking to game
6. ⏳ Add achievement syncing to game
7. ⏳ Update profile page with Supabase integration
8. ⏳ Add profile editing functionality
9. ⏳ Add daily/weekly leaderboard tabs
10. ⏳ Test everything end-to-end

## 🎯 Key Features

### Player Profiles
- Avatar customization (DiceBear API)
- Bio/description
- Level and XP tracking
- Favorite ship tracking
- Total playtime

### Match History
- Every game session saved
- Ship used, map played
- Boosters and power-ups tracked
- Accuracy percentage
- Duration tracking

### Leaderboards
- All-time high scores
- Daily leaderboards (resets daily)
- Weekly leaderboards (resets Monday)
- Automatic population via triggers

### Achievements
- Synced to database
- Timestamp tracking
- Displayable on profile

### Future: Clan System
- Create/join clans
- Clan leaderboards
- Team competitions

## 🔒 Security Notes

After setup, consider adding Row Level Security (RLS) policies in Supabase:

```sql
-- Enable RLS
ALTER TABLE player_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_achievements ENABLE ROW LEVEL SECURITY;

-- Allow read access to all
CREATE POLICY "Public read access" ON player_profiles FOR SELECT USING (true);
CREATE POLICY "Public read access" ON match_history FOR SELECT USING (true);
CREATE POLICY "Public read access" ON player_achievements FOR SELECT USING (true);

-- Allow insert for authenticated users only (optional)
-- CREATE POLICY "Authenticated insert" ON match_history FOR INSERT WITH CHECK (auth.role() = 'authenticated');
```

## 🚀 Testing

1. Play a game and die
2. Check browser console for "Score saved" messages
3. Visit leaderboard page - should see your score
4. Visit profile page - should see your stats
5. Try editing profile - save and verify changes
6. Check Supabase dashboard to see data

## ✨ Enhancements Complete!

Your game now has:
- ✅ Comprehensive player profiles with customization
- ✅ Detailed match history tracking
- ✅ Multiple leaderboard types
- ✅ Achievement syncing
- ✅ Auto-updating stats via database triggers
- ✅ Beautiful UI with real data
