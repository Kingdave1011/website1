-- =================================================================
-- Database Schema for hideoutads.online Space Shooter Game
-- Supabase/PostgreSQL Compatible
-- =================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =================================================================
-- USERS TABLE
-- =================================================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP DEFAULT NOW(),
    referral_code VARCHAR(20) UNIQUE NOT NULL,
    referred_by VARCHAR(20),
    level INTEGER DEFAULT 1,
    xp INTEGER DEFAULT 0,
    credits INTEGER DEFAULT 0,
    total_playtime INTEGER DEFAULT 0,
    games_played INTEGER DEFAULT 0,
    is_banned BOOLEAN DEFAULT FALSE,
    ban_reason TEXT,
    role VARCHAR(20) DEFAULT 'player'
);

-- Enable RLS for users
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Users can read their own data
CREATE POLICY "Users can read own data"
    ON users FOR SELECT
    USING (auth.uid() = id);

-- Users can update their own data
CREATE POLICY "Users can update own data"
    ON users FOR UPDATE
    USING (auth.uid() = id);

-- =================================================================
-- LEADERBOARD TABLE
-- =================================================================
CREATE TABLE IF NOT EXISTS leaderboard (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    username VARCHAR(50) NOT NULL,
    score INTEGER NOT NULL,
    wave INTEGER NOT NULL,
    kills INTEGER DEFAULT 0,
    credits_earned INTEGER DEFAULT 0,
    timestamp TIMESTAMP DEFAULT NOW(),
    week_number INTEGER DEFAULT EXTRACT(WEEK FROM NOW()),
    year INTEGER DEFAULT EXTRACT(YEAR FROM NOW())
);

-- Enable RLS
ALTER TABLE leaderboard ENABLE ROW LEVEL SECURITY;

-- Public can read leaderboard
CREATE POLICY "Public can read leaderboard"
    ON leaderboard FOR SELECT
    TO anon, authenticated
    USING (true);

-- Authenticated users can insert their own scores
CREATE POLICY "Users can insert own scores"
    ON leaderboard FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Create indexes for performance
CREATE INDEX idx_leaderboard_score ON leaderboard(score DESC);
CREATE INDEX idx_leaderboard_week ON leaderboard(week_number, year, score DESC);
CREATE INDEX idx_leaderboard_username ON leaderboard(username);

-- =================================================================
-- REFERRALS TABLE
-- =================================================================
CREATE TABLE IF NOT EXISTS referrals (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    referrer_id UUID REFERENCES users(id) ON DELETE CASCADE,
    referrer_username VARCHAR(50) NOT NULL,
    referred_id UUID REFERENCES users(id) ON DELETE CASCADE,
    referred_username VARCHAR(50) NOT NULL,
    reward_claimed BOOLEAN DEFAULT FALSE,
    reward_type VARCHAR(50),
    reward_amount INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;

-- Users can read their own referrals
CREATE POLICY "Users can read own referrals"
    ON referrals FOR SELECT
    USING (auth.uid() = referrer_id OR auth.uid() = referred_id);

-- Users can insert referrals
CREATE POLICY "Users can insert referrals"
    ON referrals FOR INSERT
    WITH CHECK (auth.uid() = referred_id);

-- =================================================================
-- PLAYER STATS TABLE
-- =================================================================
CREATE TABLE IF NOT EXISTS player_stats (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    total_kills INTEGER DEFAULT 0,
    total_deaths INTEGER DEFAULT 0,
    waves_survived INTEGER DEFAULT 0,
    bosses_defeated INTEGER DEFAULT 0,
    power_ups_collected INTEGER DEFAULT 0,
    boosters_used INTEGER DEFAULT 0,
    perfect_waves INTEGER DEFAULT 0,
    highest_wave INTEGER DEFAULT 0,
    highest_score INTEGER DEFAULT 0,
    favorite_ship VARCHAR(50),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE player_stats ENABLE ROW LEVEL SECURITY;

-- Users can read their own stats
CREATE POLICY "Users can read own stats"
    ON player_stats FOR SELECT
    USING (auth.uid() = user_id);

-- Users can update their own stats
CREATE POLICY "Users can update own stats"
    ON player_stats FOR UPDATE
    USING (auth.uid() = user_id);

-- Users can insert their own stats
CREATE POLICY "Users can insert own stats"
    ON player_stats FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- =================================================================
-- ACHIEVEMENTS TABLE
-- =================================================================
CREATE TABLE IF NOT EXISTS user_achievements (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    achievement_id VARCHAR(50) NOT NULL,
    unlocked_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

-- Enable RLS
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;

-- Users can read their own achievements
CREATE POLICY "Users can read own achievements"
    ON user_achievements FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own achievements
CREATE POLICY "Users can insert own achievements"
    ON user_achievements FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- =================================================================
-- GAME SESSIONS TABLE
-- =================================================================
CREATE TABLE IF NOT EXISTS game_sessions (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    username VARCHAR(50) NOT NULL,
    start_time TIMESTAMP DEFAULT NOW(),
    end_time TIMESTAMP,
    final_score INTEGER,
    final_wave INTEGER,
    ship_used VARCHAR(50),
    map_played INTEGER,
    duration_seconds INTEGER,
    kills INTEGER DEFAULT 0
);

-- Enable RLS
ALTER TABLE game_sessions ENABLE ROW LEVEL SECURITY;

-- Users can read their own sessions
CREATE POLICY "Users can read own sessions"
    ON game_sessions FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own sessions
CREATE POLICY "Users can insert own sessions"
    ON game_sessions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own sessions
CREATE POLICY "Users can update own sessions"
    ON game_sessions FOR UPDATE
    USING (auth.uid() = user_id);

-- =================================================================
-- UNLOCKED CONTENT TABLE
-- =================================================================
CREATE TABLE IF NOT EXISTS unlocked_content (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content_type VARCHAR(50) NOT NULL, -- 'ship', 'skin', 'map', 'booster'
    content_id VARCHAR(100) NOT NULL,
    unlocked_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, content_type, content_id)
);

-- Enable RLS
ALTER TABLE unlocked_content ENABLE ROW LEVEL SECURITY;

-- Users can read their own unlocked content
CREATE POLICY "Users can read own content"
    ON unlocked_content FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own unlocked content
CREATE POLICY "Users can insert own content"
    ON unlocked_content FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- =================================================================
-- DAILY REWARDS TABLE
-- =================================================================
CREATE TABLE IF NOT EXISTS daily_rewards_claimed (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    day_number INTEGER NOT NULL,
    claimed_at TIMESTAMP DEFAULT NOW(),
    reward_type VARCHAR(50),
    reward_amount INTEGER,
    UNIQUE(user_id, day_number)
);

-- Enable RLS
ALTER TABLE daily_rewards_claimed ENABLE ROW LEVEL SECURITY;

-- Users can read their own daily rewards
CREATE POLICY "Users can read own rewards"
    ON daily_rewards_claimed FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own rewards
CREATE POLICY "Users can insert own rewards"
    ON daily_rewards_claimed FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- =================================================================
-- BATTLE PASS TABLE
-- =================================================================
CREATE TABLE IF NOT EXISTS battle_pass_progress (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    current_tier INTEGER DEFAULT 0,
    xp INTEGER DEFAULT 0,
    season_id INTEGER DEFAULT 1,
    claimed_rewards TEXT[], -- Array of reward IDs
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE battle_pass_progress ENABLE ROW LEVEL SECURITY;

-- Users can read their own battle pass
CREATE POLICY "Users can read own battle pass"
    ON battle_pass_progress FOR SELECT
    USING (auth.uid() = user_id);

-- Users can update their own battle pass
CREATE POLICY "Users can update own battle pass"
    ON battle_pass_progress FOR UPDATE
    USING (auth.uid() = user_id);

-- Users can insert their own battle pass
CREATE POLICY "Users can insert own battle pass"
    ON battle_pass_progress FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- =================================================================
-- CHAT MESSAGES TABLE
-- =================================================================
CREATE TABLE IF NOT EXISTS chat_messages (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    username VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT NOW(),
    is_system BOOLEAN DEFAULT FALSE,
    is_moderated BOOLEAN DEFAULT FALSE
);

-- Enable RLS
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Public can read recent chat messages
CREATE POLICY "Public can read recent chat"
    ON chat_messages FOR SELECT
    TO anon, authenticated
    USING (timestamp > NOW() - INTERVAL '1 hour');

-- Authenticated users can insert messages
CREATE POLICY "Users can insert messages"
    ON chat_messages FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Create index for performance
CREATE INDEX idx_chat_timestamp ON chat_messages(timestamp DESC);

-- =================================================================
-- ADMIN LOGS TABLE
-- =================================================================
CREATE TABLE IF NOT EXISTS admin_logs (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    admin_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    target_user_id UUID REFERENCES users(id),
    details TEXT,
    timestamp TIMESTAMP DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE admin_logs ENABLE ROW LEVEL SECURITY;

-- Only admins can read logs
CREATE POLICY "Admins can read logs"
    ON admin_logs FOR SELECT
    USING ((SELECT role FROM users WHERE id = auth.uid()) = 'admin');

-- =================================================================
-- VIEWS FOR COMMON QUERIES
-- =================================================================

-- Top players view
CREATE OR REPLACE VIEW top_players AS
SELECT 
    u.username,
    u.level,
    ps.highest_score,
    ps.highest_wave,
    ps.total_kills,
    ps.bosses_defeated
FROM users u
LEFT JOIN player_stats ps ON u.id = ps.user_id
WHERE u.is_banned = FALSE
ORDER BY ps.highest_score DESC
LIMIT 100;

-- Weekly leaderboard view
CREATE OR REPLACE VIEW weekly_leaderboard AS
SELECT 
    username,
    MAX(score) as best_score,
    MAX(wave) as best_wave,
    COUNT(*) as games_played,
    week_number,
    year
FROM leaderboard
WHERE week_number = EXTRACT(WEEK FROM NOW())
  AND year = EXTRACT(YEAR FROM NOW())
GROUP BY username, week_number, year
ORDER BY best_score DESC
LIMIT 100;

-- =================================================================
-- FUNCTIONS
-- =================================================================

-- Function to update user stats
CREATE OR REPLACE FUNCTION update_user_stats(
    p_user_id UUID,
    p_kills INTEGER,
    p_wave INTEGER,
    p_score INTEGER
) RETURNS VOID AS $$
BEGIN
    INSERT INTO player_stats (user_id, total_kills, waves_survived, highest_wave, highest_score)
    VALUES (p_user_id, p_kills, 1, p_wave, p_score)
    ON CONFLICT (user_id) DO UPDATE SET
        total_kills = player_stats.total_kills + p_kills,
        waves_survived = player_stats.waves_survived + 1,
        highest_wave = GREATEST(player_stats.highest_wave, p_wave),
        highest_score = GREATEST(player_stats.highest_score, p_score),
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to generate unique referral code
CREATE OR REPLACE FUNCTION generate_referral_code()
RETURNS TEXT AS $$
DECLARE
    code TEXT;
    exists BOOLEAN;
BEGIN
    LOOP
        code := UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 8));
        SELECT EXISTS(SELECT 1 FROM users WHERE referral_code = code) INTO exists;
        EXIT WHEN NOT exists;
    END LOOP;
    RETURN code;
END;
$$ LANGUAGE plpgsql;

-- =================================================================
-- SAMPLE DATA (for testing)
-- =================================================================

-- Example: Insert sample countries table (from user request)
CREATE TABLE IF NOT EXISTS countries (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name TEXT NOT NULL
);

INSERT INTO countries (name)
VALUES
    ('Canada'),
    ('United States'),
    ('Mexico')
ON CONFLICT DO NOTHING;

ALTER TABLE countries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public can read countries"
    ON public.countries
    FOR SELECT TO anon
    USING (true);

-- =================================================================
-- INDEXES FOR PERFORMANCE
-- =================================================================

CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_referral_code ON users(referral_code);
CREATE INDEX IF NOT EXISTS idx_referrals_referrer ON referrals(referrer_id);
CREATE INDEX IF NOT EXISTS idx_achievements_user ON user_achievements(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_user ON game_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_timestamp ON game_sessions(start_time DESC);

-- =================================================================
-- TRIGGERS
-- =================================================================

-- Trigger to update last_login
CREATE OR REPLACE FUNCTION update_last_login()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_login := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_last_login
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_last_login();

-- =================================================================
-- NOTES
-- =================================================================

-- To use this schema:
-- 1. Run this SQL in your Supabase SQL Editor
-- 2. Update backend/.env with your Supabase credentials:
--    SUPABASE_URL=your_project_url
--    SUPABASE_ANON_KEY=your_anon_key
--    SUPABASE_SERVICE_KEY=your_service_role_key
-- 3. Install Supabase client in backend: npm install @supabase/supabase-js
-- 4. Update backend/index.js to use Supabase instead of localStorage

-- For local development, you can also use Supabase CLI:
-- npx supabase init
-- npx supabase start
-- npx supabase db reset
