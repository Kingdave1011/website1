# 🗄️ How to Run SQL in Supabase - Step-by-Step Guide

## Complete Database Setup for Space Shooter

### ✅ What You Already Have
- SQL file: `COMPLETE_SUPABASE_DATABASE_SETUP.sql`
- Supabase project at: `https://flnbfizlfofqfbrdjttk.supabase.co`
- Connection configured in `HideoutAdsWebsite/game/index.html`

---

## 🚀 Quick Setup (5 Minutes)

### Step 1: Open Supabase Dashboard
1. Go to: https://supabase.com/dashboard
2. Sign in to your account
3. Select your project: **flnbfizlfofqfbrdjttk**

### Step 2: Open SQL Editor
1. Click **"SQL Editor"** in the left sidebar
2. Click **"New query"** button (or press Ctrl+Enter)

### Step 3: Copy SQL Code
1. Open `COMPLETE_SUPABASE_DATABASE_SETUP.sql` file
2. Select ALL content (Ctrl+A)
3. Copy it (Ctrl+C)

### Step 4: Paste and Run
1. Paste into Supabase SQL Editor (Ctrl+V)
2. Click **"Run"** button (or press Ctrl+Enter)
3. Wait for "Success" message

### Step 5: Verify Tables Created
1. Click **"Table Editor"** in left sidebar
2. You should see these tables:
   - ✅ leaderboard
   - ✅ player_profiles
   - ✅ match_history
   - ✅ player_achievements
   - ✅ daily_leaderboard
   - ✅ weekly_leaderboard
   - ✅ player_stats
   - ✅ clans

---

## 📋 What Gets Created

### 🏆 Tables

**1. leaderboard** - Top player scores
```sql
- player_name (text)
- score (integer)
- kills (integer)
- wave (integer)
- created_at (timestamp)
```

**2. player_profiles** - User profiles
```sql
- player_name (text, unique)
- total_score (integer)
- total_kills (integer)
- highest_wave (integer)
- games_played (integer)
- win_rate (decimal)
- favorite_ship (text)
- total_playtime_minutes (integer)
- last_played (timestamp)
```

**3. match_history** - Detailed match records
```sql
- player_name (text)
- score, kills, wave (integers)
- duration_seconds (integer)
- ship_used (text)
- map_played (integer)
- boosters_used (integer)
- power_ups_collected (integer)
- deaths (integer)
- match_date (timestamp)
```

**4. player_achievements** - Achievement tracking
```sql
- player_name (text)
- achievement_id (text)
- achievement_name (text)
- unlocked_at (timestamp)
```

**5. daily_leaderboard** - Daily top scores
**6. weekly_leaderboard** - Weekly top scores
**7. player_stats** - Aggregate statistics
**8. clans** - Clan/Team system

### 🔧 Database Functions

**Auto-update triggers:**
- Updates player profiles automatically when matches complete
- Maintains daily/weekly leaderboards
- Calculates aggregate statistics

---

## 🔍 Testing the Database

### Test 1: Check if Tables Exist
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';
```

### Test 2: Insert Test Data
```sql
INSERT INTO leaderboard (player_name, score, kills, wave)
VALUES ('TestPlayer', 1000, 50, 5);
```

### Test 3: Query Data
```sql
SELECT * FROM leaderboard 
ORDER BY score DESC 
LIMIT 10;
```

### Test 4: Check Player Profile Auto-Creation
```sql
SELECT * FROM player_profiles 
WHERE player_name = 'TestPlayer';
```

---

## 🎮 How Your Game Uses the Database

### When Player Finishes Game:
```javascript
// Automatically called from index.html
window.savePlayerScore(playerName, score, kills, wave)
```

This saves to:
- ✅ `leaderboard` table
- ✅ `player_profiles` (auto-updated via trigger)
- ✅ `daily_leaderboard` (auto-updated via trigger)

### Advanced Tracking (Optional):
```javascript
// Save detailed match info
window.saveMatchHistory({
  playerName: "Player123",
  score: 5000,
  kills: 250,
  wave: 15,
  duration: 600,
  ship: "interceptor",
  map: 3
})

// Save achievements
window.saveAchievement("Player123", "wave10", "Wave 10 Warrior")

// Update profile
window.updatePlayerProfile("Player123", {
  favorite_ship: "bruiser",
  total_playtime_minutes: 120
})
```

---

## 🔒 Security Configuration

### Enable Row Level Security (RLS) - Optional but Recommended

**Step 1: Enable RLS**
```sql
ALTER TABLE leaderboard ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_history ENABLE ROW LEVEL SECURITY;
```

**Step 2: Create Policies**
```sql
-- Allow anyone to read leaderboard
CREATE POLICY "Public read access" ON leaderboard
FOR SELECT USING (true);

-- Allow authenticated users to insert scores
CREATE POLICY "Authenticated insert" ON leaderboard
FOR INSERT WITH CHECK (auth.role() = 'anon');
```

---

## 📊 View Your Data

### Method 1: Supabase Dashboard
1. Go to **Table Editor**
2. Click any table name
3. View/edit data in spreadsheet-like interface

### Method 2: SQL Query
```sql
-- Top 10 players
SELECT player_name, score, kills, wave 
FROM leaderboard 
ORDER BY score DESC 
LIMIT 10;

-- Player statistics
SELECT * FROM player_profiles 
ORDER BY total_score DESC;

-- Recent matches
SELECT * FROM match_history 
ORDER BY match_date DESC 
LIMIT 20;
```

### Method 3: Your Website
Visit: https://hideoutads.online/leaderboard.html

---

## 🧹 Maintenance Queries

### Clear Test Data
```sql
DELETE FROM leaderboard WHERE player_name = 'TestPlayer';
```

### Reset Leaderboard (Careful!)
```sql
TRUNCATE TABLE leaderboard RESTART IDENTITY CASCADE;
```

### Backup Data
```sql
-- In Supabase Dashboard:
-- Settings → Database → Backups → Create backup
```

### View Table Size
```sql
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

---

## 🔧 Troubleshooting

### Issue: "Permission denied" error
**Solution:**
1. Check you're logged into correct Supabase project
2. Verify project isn't paused (free tier)
3. Check RLS policies aren't blocking inserts

### Issue: Tables already exist
**Solution:**
```sql
-- Drop existing tables (WARNING: Deletes all data!)
DROP TABLE IF EXISTS leaderboard CASCADE;
DROP TABLE IF EXISTS player_profiles CASCADE;
-- ... repeat for all tables

-- Then run setup SQL again
```

### Issue: Triggers not working
**Solution:**
```sql
-- Check if triggers exist
SELECT trigger_name, event_object_table 
FROM information_schema.triggers 
WHERE trigger_schema = 'public';

-- Recreate triggers by running SQL setup again
```

### Issue: Can't connect from game
**Solution:**
1. Check SUPABASE_URL and SUPABASE_KEY in index.html
2. Verify they match your Supabase project settings
3. Check browser console for errors (F12)

---

## 🎯 Performance Optimization

### Add Indexes for Better Performance
```sql
-- Speed up leaderboard queries
CREATE INDEX idx_leaderboard_score ON leaderboard(score DESC);
CREATE INDEX idx_leaderboard_player ON leaderboard(player_name);

-- Speed up profile lookups
CREATE INDEX idx_profiles_player ON player_profiles(player_name);
CREATE INDEX idx_profiles_score ON player_profiles(total_score DESC);
```

### Automatic Cleanup (Old Records)
```sql
-- Delete match history older than 90 days
DELETE FROM match_history 
WHERE match_date < NOW() - INTERVAL '90 days';

-- Archive old leaderboard entries
CREATE TABLE leaderboard_archive AS 
SELECT * FROM leaderboard 
WHERE created_at < NOW() - INTERVAL '30 days';

DELETE FROM leaderboard 
WHERE created_at < NOW() - INTERVAL '30 days';
```

---

## 📈 Advanced Features

### Create Views for Easy Queries
```sql
-- Top players this month
CREATE VIEW monthly_top_players AS
SELECT 
  player_name,
  COUNT(*) as games_played,
  MAX(score) as best_score,
  AVG(score) as avg_score
FROM leaderboard
WHERE created_at >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY player_name
ORDER BY best_score DESC;
```

### Real-time Subscriptions
```javascript
// In your game code
const subscription = supabase
  .channel('leaderboard_changes')
  .on('postgres_changes', 
    { event: 'INSERT', schema: 'public', table: 'leaderboard' },
    payload => {
      console.log('New score!', payload.new)
      // Update UI in real-time
    }
  )
  .subscribe()
```

---

## ✅ Success Checklist

After running the SQL:

- ✅ All 8 tables created
- ✅ Triggers and functions active
- ✅ Test insert successful
- ✅ Test query returns data
- ✅ Game can save scores
- ✅ Leaderboard page works

---

## 🆘 Need Help?

1. **Check Supabase Logs:**
   - Dashboard → Logs → Database logs

2. **Test Connection:**
   - Open your game
   - Open browser console (F12)
   - Look for "✅ Supabase initialized" message

3. **Verify SQL Ran:**
   ```sql
   SELECT COUNT(*) FROM information_schema.tables 
   WHERE table_schema = 'public';
   -- Should return 8 or more
   ```

---

## 🎉 You're Done!

Your database is now set up and ready to:
- ✅ Track player scores
- ✅ Save match history
- ✅ Record achievements
- ✅ Display leaderboards
- ✅ Maintain player profiles
- ✅ Support clan features

Players' data will now persist across sessions! 🚀

---

## 📞 Quick Reference

**Supabase Dashboard:** https://supabase.com/dashboard
**Your Project:** https://supabase.com/dashboard/project/flnbfizlfofqfbrdjttk
**SQL Editor:** Dashboard → SQL Editor
**Table Editor:** Dashboard → Table Editor
**API Docs:** Dashboard → Settings → API

**Important:** Keep your SUPABASE_KEY secret! Never commit it to public GitHub repos.
