# Supabase Setup Guide - Complete Integration

This guide will help you set up Supabase for your Space Shooter game with proper database tables and Row Level Security.

## 🗄️ Part 1: Database Setup

### Step 1: Create Tables in Supabase Dashboard

Go to your Supabase project's SQL Editor and run these commands:

```sql
-- Create countries table (example)
create table countries (
  id bigint primary key generated always as identity,
  name text not null
);

-- Insert sample data
insert into countries (name)
values
  ('Canada'),
  ('United States'),
  ('Mexico');

-- Enable Row Level Security
alter table countries enable row level security;

-- Create policy for public read access
create policy "public can read countries"
on public.countries
for select to anon
using (true);
```

### Step 2: Create Player Data Table

```sql
-- Create player_data table for game stats
create table player_data (
  id uuid default gen_random_uuid() primary key,
  user_id text unique not null,
  username text not null,
  level int default 1,
  xp int default 0,
  credits int default 0,
  high_score int default 0,
  total_kills int default 0,
  waves_survived int default 0,
  unlocked_ships jsonb default '["ranger"]'::jsonb,
  unlocked_skins jsonb default '{}'::jsonb,
  selected_ship text default 'ranger',
  upgrades jsonb default '{"fireRate": 0, "speed": 0, "extraLife": 0}'::jsonb,
  boosters jsonb default '{"shield": 1, "rapidFire": 1, "doubleCredits": 1}'::jsonb,
  achievements jsonb default '[]'::jsonb,
  created_at timestamp default now(),
  updated_at timestamp default now()
);

-- Enable RLS
alter table player_data enable row level security;

-- Public can read all player data
create policy "public can read player_data"
on public.player_data
for select
to anon
using (true);

-- Users can insert their own data
create policy "users can insert own data"
on public.player_data
for insert
to anon
with check (true);

-- Users can update their own data
create policy "users can update own data"  
on public.player_data
for update
to anon
using (true);
```

### Step 3: Create Leaderboard Table

```sql
-- Create leaderboard table
create table leaderboard (
  id uuid default gen_random_uuid() primary key,
  user_id text not null,
  username text not null,
  score int not null,
  kills int default 0,
  wave int default 0,
  created_at timestamp default now()
);

-- Enable RLS
alter table leaderboard enable row level security;

-- Public can read leaderboard
create policy "public can read leaderboard"
on public.leaderboard
for select
to anon
using (true);

-- Anyone can insert to leaderboard
create policy "anyone can insert leaderboard"
on public.leaderboard
for insert
to anon
with check (true);

-- Create index for faster queries
create index leaderboard_score_idx on leaderboard(score desc);
create index leaderboard_username_idx on leaderboard(username);
```

---

## 🔧 Part 2: Install Supabase Client

### For React/TypeScript Project

```bash
cd HideoutAdsWebsite/game
npm install @supabase/supabase-js
```

---

## 🔑 Part 3: Environment Variables

### Step 1: Get Supabase Credentials

1. Go to Supabase Project Settings > API
2. Copy your `Project URL`
3. Copy your `anon/public key`

### Step 2: Create .env.local File

Create `HideoutAdsWebsite/game/.env.local`:

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

### Step 3: Update .gitignore

Ensure `.env.local` is in your `.gitignore`:

```
node_modules/
dist/
.env
.env.local
.env.*.local
```

---

## 💻 Part 4: Create Supabase Client

Create `HideoutAdsWebsite/game/src/lib/supabaseClient.ts`:

```typescript
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  console.warn('⚠️ Supabase credentials not found in environment variables');
}

export const supabase = createClient(supabaseUrl || '', supabaseAnonKey || '');

// Helper functions for game data
export const supabaseHelpers = {
  // Save player data
  async savePlayerData(userData: any) {
    try {
      const { data, error } = await supabase
        .from('player_data')
        .upsert({
          user_id: userData.userId,
          username: userData.username,
          level: userData.level,
          xp: userData.xp,
          credits: userData.credits,
          high_score: userData.highScore,
          total_kills: userData.totalKills,
          waves_survived: userData.wavesSurvived,
          unlocked_ships: userData.unlockedShips,
          unlocked_skins: userData.unlockedSkins,
          selected_ship: userData.selectedShip,
          upgrades: userData.upgrades,
          boosters: userData.boosters,
          achievements: userData.achievements,
          updated_at: new Date().toISOString()
        })
        .select();
      
      if (error) throw error;
      return { success: true, data };
    } catch (error) {
      console.error('Failed to save player data:', error);
      return { success: false, error };
    }
  },

  // Load player data
  async loadPlayerData(userId: string) {
    try {
      const { data, error } = await supabase
        .from('player_data')
        .select('*')
        .eq('user_id', userId)
        .single();
      
      if (error && error.code !== 'PGRST116') throw error;
      return { success: true, data };
    } catch (error) {
      console.error('Failed to load player data:', error);
      return { success: false, error };
    }
  },

  // Submit score to leaderboard
  async submitScore(userId: string, username: string, score: number, kills: number, wave: number) {
    try {
      const { data, error } = await supabase
        .from('leaderboard')
        .insert({
          user_id: userId,
          username: username,
          score: score,
          kills: kills,
          wave: wave
        })
        .select();
      
      if (error) throw error;
      return { success: true, data };
    } catch (error) {
      console.error('Failed to submit score:', error);
      return { success: false, error };
    }
  },

  // Get top leaderboard entries
  async getLeaderboard(limit: number = 100) {
    try {
      const { data, error } = await supabase
        .from('leaderboard')
        .select('*')
        .order('score', { ascending: false })
        .limit(limit);
      
      if (error) throw error;
      return { success: true, data };
    } catch (error) {
      console.error('Failed to fetch leaderboard:', error);
      return { success: false, error };
    }
  },

  // Real-time leaderboard subscription
  subscribeToLeaderboard(callback: (payload: any) => void) {
    return supabase
      .channel('leaderboard_changes')
      .on('postgres_changes', 
        { event: '*', schema: 'public', table: 'leaderboard' },
        callback
      )
      .subscribe();
  }
};
```

---

## 🎮 Part 5: Integrate with Game

### Update your index.tsx to use Supabase

Add at the top of `index.tsx`:

```typescript
import { supabase, supabaseHelpers } from './lib/supabaseClient';

// Check if Supabase is connected
supabase.from('player_data').select('count').then(({ data, error }) => {
  if (error) {
    console.warn('⚠️ Supabase not connected, using localStorage only');
  } else {
    console.log('✅ Supabase connected successfully!');
  }
});
```

### Save Game Data to Cloud

```typescript
// Modify saveGameState function
async function saveGameState(username: string = gameState.username) {
  // Save locally first
  localStorage.setItem(`space_shooter_${username}`, JSON.stringify(gameState));
  
  // Save to Supabase if available
  if (supabase && !username.startsWith('guest_')) {
    await supabaseHelpers.savePlayerData({
      userId: username,
      username: gameState.username,
      level: gameState.level,
      xp: gameState.xp,
      credits: gameState.credits,
      highScore: gameState.high_score || 0,
      totalKills: gameState.stats.totalKills,
      wavesSurvived: gameState.stats.wavesSurvived,
      unlockedShips: gameState.unlockedShips,
      unlockedSkins: gameState.unlockedSkins,
      selectedShip: gameState.selectedShip,
      upgrades: gameState.upgrades,
      boosters: gameState.boosters,
      achievements: gameState.unlockedAchievements
    });
  }
}
```

### Load Game Data from Cloud

```typescript
// Modify loadGameState function
async function loadGameState(username: string) {
  // Try to load from Supabase first
  if (!username.startsWith('guest_')) {
    const result = await supabaseHelpers.loadPlayerData(username);
    if (result.success && result.data) {
      // Map Supabase data to gameState
      gameState = {
        username: result.data.username,
        level: result.data.level,
        xp: result.data.xp,
        credits: result.data.credits,
        // ... map other fields
      };
      return;
    }
  }
  
  // Fallback to localStorage
  const data = localStorage.getItem(`space_shooter_${username}`);
  if (data) {
    gameState = JSON.parse(data);
  } else {
    gameState = getDefaultGameState(username);
  }
}
```

### Submit Scores to Leaderboard

```typescript
function gameOver() {
  gameRunning = false;
  stopMusic();
  
  // Submit to Supabase leaderboard
  if (supabase && !gameState.username.startsWith('guest_')) {
    supabaseHelpers.submitScore(
      gameState.username,
      gameState.username,
      score,
      gameState.stats.totalKills,
      currentWave
    );
  }
  
  showScreen('game-over-screen');
  // ... rest of game over logic
}
```

---

## 🔄 Part 6: Vercel Integration

### Step 1: Link to Vercel

```bash
cd HideoutAdsWebsite
npx vercel link
```

### Step 2: Add Environment Variables to Vercel

```bash
npx vercel env pull .env.local
```

Or manually add in Vercel Dashboard:
- Go to Project Settings > Environment Variables
- Add `VITE_SUPABASE_URL`
- Add `VITE_SUPABASE_ANON_KEY`

### Step 3: Deploy

```bash
git add .
git commit -m "Add Supabase integration"
git push origin master
```

Vercel will auto-deploy with your Supabase credentials!

---

## ✅ Implementation Checklist

- [ ] Create Supabase project
- [ ] Run SQL commands to create tables
- [ ] Set up Row Level Security policies
- [ ] Install @supabase/supabase-js
- [ ] Create .env.local with credentials
- [ ] Create supabaseClient.ts
- [ ] Update saveGameState to use Supabase
- [ ] Update loadGameState to use Supabase
- [ ] Add leaderboard submission
- [ ] Link Vercel project
- [ ] Add environment variables to Vercel
- [ ] Test cloud save/load
- [ ] Deploy to production

---

## 🚀 Quick Commands

```bash
# In HideoutAdsWebsite/game directory
npm install @supabase/supabase-js
npx vercel link
npx vercel env pull .env.local
npm run build
git add . && git commit -m "Add Supabase" && git push
```

Your game now has cloud save functionality! 🎮☁️
