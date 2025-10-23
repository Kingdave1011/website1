-- ============================================
-- COMPLETE SUPABASE DATABASE SETUP
-- Space Shooter Game Database Schema
-- ============================================

-- 1. LEADERBOARD TABLE (Main high scores)
CREATE TABLE IF NOT EXISTS leaderboard (
  id BIGSERIAL PRIMARY KEY,
  player_name TEXT NOT NULL,
  score INTEGER NOT NULL,
  kills INTEGER NOT NULL,
  wave INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_leaderboard_score ON leaderboard(score DESC);
CREATE INDEX IF NOT EXISTS idx_leaderboard_player ON leaderboard(player_name);
CREATE INDEX IF NOT EXISTS idx_leaderboard_date ON leaderboard(created_at DESC);

-- 2. PLAYER PROFILES TABLE (Detailed player information)
CREATE TABLE IF NOT EXISTS player_profiles (
  id BIGSERIAL PRIMARY KEY,
  player_name TEXT UNIQUE NOT NULL,
  avatar_url TEXT DEFAULT 'https://api.dicebear.com/7.x/avataaars/svg?seed=default',
  bio TEXT DEFAULT 'New space pilot ready to conquer the galaxy!',
  favorite_ship TEXT DEFAULT 'ranger',
  total_playtime INTEGER DEFAULT 0,
  total_games_played INTEGER DEFAULT 0,
  highest_score INTEGER DEFAULT 0,
  highest_wave INTEGER DEFAULT 0,
  total_kills INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,
  xp INTEGER DEFAULT 0,
  credits INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_played TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_player_name ON player_profiles(player_name);
CREATE INDEX IF NOT EXISTS idx_player_score ON player_profiles(highest_score DESC);

-- 3. MATCH HISTORY TABLE (Individual game sessions)
CREATE TABLE IF NOT EXISTS match_history (
  id BIGSERIAL PRIMARY KEY,
  player_name TEXT NOT NULL,
  score INTEGER NOT NULL,
  kills INTEGER NOT NULL,
  wave INTEGER NOT NULL,
  duration_seconds INTEGER DEFAULT 0,
  ship_used TEXT DEFAULT 'ranger',
  map_played INTEGER DEFAULT 1,
  boosters_used INTEGER DEFAULT 0,
  power_ups_collected INTEGER DEFAULT 0,
  accuracy_percentage DECIMAL(5,2) DEFAULT 0,
  deaths INTEGER DEFAULT 0,
  played_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_match_player ON match_history(player_name);
CREATE INDEX IF NOT EXISTS idx_match_date ON match_history(played_at DESC);
CREATE INDEX IF NOT EXISTS idx_match_score ON match_history(score DESC);

-- 4. PLAYER ACHIEVEMENTS TABLE
CREATE TABLE IF NOT EXISTS player_achievements (
  id BIGSERIAL PRIMARY KEY,
  player_name TEXT NOT NULL,
  achievement_id TEXT NOT NULL,
  achievement_name TEXT NOT NULL,
  unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(player_name, achievement_id)
);

CREATE INDEX IF NOT EXISTS idx_achievements_player ON player_achievements(player_name);

-- 5. DAILY LEADERBOARD TABLE
CREATE TABLE IF NOT EXISTS daily_leaderboard (
  id BIGSERIAL PRIMARY KEY,
  player_name TEXT NOT NULL,
  score INTEGER NOT NULL,
  kills INTEGER NOT NULL,
  wave INTEGER NOT NULL,
  date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(player_name, date)
);

CREATE INDEX IF NOT EXISTS idx_daily_leaderboard_date ON daily_leaderboard(date DESC, score DESC);

-- 6. WEEKLY LEADERBOARD TABLE
CREATE TABLE IF NOT EXISTS weekly_leaderboard (
  id BIGSERIAL PRIMARY KEY,
  player_name TEXT NOT NULL,
  score INTEGER NOT NULL,
  kills INTEGER NOT NULL,
  wave INTEGER NOT NULL,
  week_start DATE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(player_name, week_start)
);

CREATE INDEX IF NOT EXISTS idx_weekly_leaderboard_week ON weekly_leaderboard(week_start DESC, score DESC);

-- 7. PLAYER STATS TABLE (Aggregated statistics)
CREATE TABLE IF NOT EXISTS player_stats (
  id BIGSERIAL PRIMARY KEY,
  player_name TEXT UNIQUE NOT NULL,
  total_kills INTEGER DEFAULT 0,
  total_deaths INTEGER DEFAULT 0,
  total_score BIGINT DEFAULT 0,
  total_playtime INTEGER DEFAULT 0,
  favorite_ship TEXT,
  favorite_map INTEGER,
  best_accuracy DECIMAL(5,2) DEFAULT 0,
  longest_wave_survived INTEGER DEFAULT 0,
  power_ups_collected INTEGER DEFAULT 0,
  boosters_used INTEGER DEFAULT 0,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_player_stats_name ON player_stats(player_name);

-- 8. CLAN/TEAM SYSTEM (Optional - for future multiplayer)
CREATE TABLE IF NOT EXISTS clans (
  id BIGSERIAL PRIMARY KEY,
  clan_name TEXT UNIQUE NOT NULL,
  clan_tag TEXT UNIQUE NOT NULL,
  description TEXT,
  leader_name TEXT NOT NULL,
  total_members INTEGER DEFAULT 1,
  clan_score BIGINT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS clan_members (
  id BIGSERIAL PRIMARY KEY,
  clan_id BIGINT REFERENCES clans(id) ON DELETE CASCADE,
  player_name TEXT NOT NULL,
  role TEXT DEFAULT 'member',
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(player_name)
);

CREATE INDEX IF NOT EXISTS idx_clan_members ON clan_members(clan_id);

-- ============================================
-- FUNCTIONS AND TRIGGERS
-- ============================================

-- Function to update player profile on new match
CREATE OR REPLACE FUNCTION update_player_profile()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO player_profiles (
    player_name,
    total_games_played,
    highest_score,
    highest_wave,
    total_kills,
    last_played
  ) VALUES (
    NEW.player_name,
    1,
    NEW.score,
    NEW.wave,
    NEW.kills,
    NEW.played_at
  )
  ON CONFLICT (player_name) 
  DO UPDATE SET
    total_games_played = player_profiles.total_games_played + 1,
    highest_score = GREATEST(player_profiles.highest_score, NEW.score),
    highest_wave = GREATEST(player_profiles.highest_wave, NEW.wave),
    total_kills = player_profiles.total_kills + NEW.kills,
    last_played = NEW.played_at;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update player profile
CREATE TRIGGER trigger_update_player_profile
AFTER INSERT ON match_history
FOR EACH ROW
EXECUTE FUNCTION update_player_profile();

-- Function to update daily leaderboard
CREATE OR REPLACE FUNCTION update_daily_leaderboard()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO daily_leaderboard (
    player_name,
    score,
    kills,
    wave,
    date
  ) VALUES (
    NEW.player_name,
    NEW.score,
    NEW.kills,
    NEW.wave,
    CURRENT_DATE
  )
  ON CONFLICT (player_name, date)
  DO UPDATE SET
    score = GREATEST(daily_leaderboard.score, NEW.score),
    kills = daily_leaderboard.kills + NEW.kills,
    wave = GREATEST(daily_leaderboard.wave, NEW.wave);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for daily leaderboard
CREATE TRIGGER trigger_update_daily_leaderboard
AFTER INSERT ON match_history
FOR EACH ROW
EXECUTE FUNCTION update_daily_leaderboard();

-- ============================================
-- VIEWS FOR EASY QUERYING
-- ============================================

-- Top players view
CREATE OR REPLACE VIEW v_top_players AS
SELECT 
  pp.player_name,
  pp.highest_score,
  pp.highest_wave,
  pp.total_kills,
  pp.total_games_played,
  pp.level,
  pp.favorite_ship,
  pp.created_at
FROM player_profiles pp
ORDER BY pp.highest_score DESC
LIMIT 100;

-- Daily top players view
CREATE OR REPLACE VIEW v_daily_top_players AS
SELECT 
  player_name,
  score,
  kills,
  wave,
  date
FROM daily_leaderboard
WHERE date = CURRENT_DATE
ORDER BY score DESC
LIMIT 100;

-- Weekly top players view  
CREATE OR REPLACE VIEW v_weekly_top_players AS
SELECT 
  player_name,
  score,
  kills,
  wave,
  week_start
FROM weekly_leaderboard
WHERE week_start = DATE_TRUNC('week', CURRENT_DATE)::DATE
ORDER BY score DESC
LIMIT 100;

-- ============================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================

-- Uncomment to insert sample data
/*
INSERT INTO player_profiles (player_name, highest_score, highest_wave, total_kills, favorite_ship)
VALUES 
  ('SpaceAce', 15000, 15, 500, 'interceptor'),
  ('GalaxyWarrior', 12000, 12, 400, 'ranger'),
  ('StarPilot', 10000, 10, 350, 'bruiser')
ON CONFLICT DO NOTHING;
*/

-- ============================================
-- NOTES
-- ============================================
-- After running this script:
-- 1. Your game will automatically save match data
-- 2. Player profiles will auto-update
-- 3. Leaderboards will populate automatically
-- 4. You can query views for easy data access
--
-- Backup: Use Supabase dashboard to backup your database
-- Security: Set up Row Level Security (RLS) policies as needed
