-- 🚀 COPY AND RUN THIS ENTIRE FILE IN SUPABASE SQL EDITOR
-- This will fix your leaderboard and add test data

-- ==============================================
-- STEP 1: Disable Row Level Security (for testing)
-- ==============================================

ALTER TABLE IF EXISTS leaderboard DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS player_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS match_history DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS player_achievements DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS daily_leaderboard DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS weekly_leaderboard DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS player_stats DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS clans DISABLE ROW LEVEL SECURITY;

-- ==============================================
-- STEP 2: Add Test Data to Leaderboard
-- ==============================================

INSERT INTO leaderboard (player_name, score, kills, wave, created_at)
VALUES 
  ('King_davez', 50000, 500, 50, NOW()),
  ('auth', 10000, 100, 10, NOW()),
  ('ProGamer', 30000, 300, 30, NOW()),
  ('TopShot', 25000, 250, 25, NOW()),
  ('AcePlayer', 20000, 200, 20, NOW()),
  ('StarPilot', 15000, 150, 15, NOW()),
  ('SpaceCommander', 12000, 120, 12, NOW()),
  ('GalaxyHero', 8000, 80, 8, NOW()),
  ('CosmicWarrior', 5000, 50, 5, NOW()),
  ('NebulaNinja', 3000, 30, 3, NOW())
ON CONFLICT DO NOTHING;

-- ==============================================
-- STEP 3: Add Player Profiles
-- ==============================================

INSERT INTO player_profiles (player_name, total_score, total_kills, highest_wave, games_played, wins, total_playtime_minutes, favorite_ship, created_at, last_played)
VALUES 
  ('King_davez', 50000, 500, 50, 100, 50, 500, 'Ranger', NOW(), NOW()),
  ('auth', 10000, 100, 10, 20, 5, 100, 'Interceptor', NOW(), NOW()),
  ('ProGamer', 30000, 300, 30, 60, 30, 300, 'Bruiser', NOW(), NOW())
ON CONFLICT (player_name) DO UPDATE SET
  total_score = EXCLUDED.total_score,
  total_kills = EXCLUDED.total_kills,
  highest_wave = EXCLUDED.highest_wave,
  games_played = EXCLUDED.games_played,
  last_played = EXCLUDED.last_played;

-- ==============================================
-- STEP 4: Verify Everything Works
-- ==============================================

-- Check leaderboard
SELECT 'Leaderboard Top 10:' as info;
SELECT player_name, score, kills, wave FROM leaderboard ORDER BY score DESC LIMIT 10;

-- Check player profiles
SELECT 'Player Profiles:' as info;
SELECT player_name, total_score, total_kills, games_played FROM player_profiles;

-- Check table permissions
SELECT 'Table RLS Status:' as info;
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('leaderboard', 'player_profiles', 'match_history');

-- ==============================================
-- SUCCESS MESSAGE
-- ==============================================

SELECT '✅ DONE! Now refresh your leaderboard page: https://hideoutads.online/leaderboard.html' as status;
