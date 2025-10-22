# 🚀 Implementation Roadmap for hideoutads.online

## Phase 1: Core Enhancements (Week 1-2)

### 1. Expand Achievement System (5 → 50+ achievements)
**File:** `game/index.tsx`
- Add categories: Combat, Exploration, Collection, Social, Special
- Combat: First Blood, Sharpshooter (100 kills), Ace (500 kills), Legend (1000 kills), Perfectionist (no damage wave)
- Exploration: Map Explorer (visit all maps), Speed Runner (complete wave in under 60s)
- Collection: Skin Collector (unlock all skins), Ship Master (unlock all ships)
- Social: Team Player (play with friends), Chat Champion (send 100 messages)
- Special: Lucky Shot (destroy 3 enemies with 1 shot), Boss Slayer (defeat 10 bosses)

### 2. Expand Power-Up System (3 → 15+ power-ups)
**File:** `game/index.tsx` - POWERUP_CONFIG
- Current: health, weaponBoost, speedBoost
- Add:
  - `tripleShot`: Fire 3 bullets at once
  - `spreadShot`: Fire in 5 directions
  - `laserBeam`: Continuous damage beam
  - `homingMissiles`: Auto-targeting missiles
  - `timeSlowdown`: Slow enemies 50%
  - `invincibility`: 10 seconds immune
  - `creditMultiplier`: 2x credits for 30s
  - `megaBomb`: Clear all enemies on screen
  - `magneticField`: Attract power-ups
  - `regeneration`: Heal 1 HP every 3 seconds
  - `reflectShield`: Reflect enemy bullets
  - `ghostMode`: Pass through enemies

### 3. Expand Enemy Types (3 → 10+ types)
**File:** `game/index.tsx` - ENEMY_CONFIG
- Current: scout, brute, bomber
- Add:
  - `sniper`: Long-range, high accuracy
  - `kamikaze`: Rushes player, explodes
  - `splitter`: Splits into 2 smaller enemies
  - `tank`: Very slow, very tanky
  - `healer`: Heals nearby enemies
  - `teleporter`: Blinks around screen
  - `minelayer`: Drops stationary mines

## Phase 2: Website Features (Week 2-3)

### 4. Theme System (10 themes with selector)
**New Files:**
- `HideoutAdsWebsite/themes.css`
- `HideoutAdsWebsite/theme-manager.js`

**Themes to add:**
1. Default Starfield (current)
2. Nebula Dreams (purple/pink gradients)
3. Arctic Freeze (ice blue, falling snow)
4. Cyber Neon (cyberpunk, neon grid)
5. Deep Ocean (underwater blue/green)
6. Desert Storm (orange/yellow sand)
7. Forest Night (dark green, fireflies)
8. Halloween Spooky (orange/black, floating ghosts)
9. Winter Wonderland (white/blue, snowflakes)
10. Sunset Horizon (warm orange/red)

**Implementation:**
- Add dropdown in header: "Theme: [Selector]"
- Save to localStorage: `selectedTheme`
- Apply CSS variables for colors
- Animated backgrounds for some themes (particles.js or CSS animations)

### 5. Referral System
**New File:** `HideoutAdsWebsite/referral.html`

**Features:**
- Generate unique referral code per user
- Track referrals via URL param: `?ref=CODE`
- Rewards:
  - 1 referral: 500 credits + Bronze skin
  - 5 referrals: 2000 credits + Silver skin
  - 10 referrals: 5000 credits + Gold skin
  - 25 referrals: 10000 credits + Diamond skin
- Display: Total referrals, Active friends, Rewards claimed
- One-click copy button for referral link

### 6. Enhanced Leaderboard
**File:** `HideoutAdsWebsite/leaderboard.html`

**Enhancements:**
- Real-time updates (fetch every 30 seconds)
- Top 3 highlighted with special styling (🥇🥈🥉)
- Multiple leaderboards:
  - All-Time High Score
  - Weekly Top Scores (resets Monday)
  - Total Kills
  - Wave Progression
  - Credits Earned
- Show player's rank even if not in top 100
- Filter by time period: Today, Week, Month, All-Time
- Backend endpoint: `/api/leaderboard`

## Phase 3: Enhanced Profile & Backend (Week 3-4)

### 7. Enhanced Profile Page
**File:** `HideoutAdsWebsite/profile.html`

**Add:**
- Player stats dashboard:
  - Total playtime
  - Games played
  - Win/loss ratio
  - Favorite ship
  - Best wave
  - Total credits earned
- Achievement showcase (display unlocked achievements)
- XP progress bar with next level
- Recent matches history
- Friends list (if multiplayer)
- Ship collection showcase

### 8. Backend Enhancements
**File:** `backend/index.js`

**Add endpoints:**
- `POST /api/referral/generate` - Generate referral code
- `GET /api/referral/:code` - Track referral
- `GET /api/leaderboard/:type` - Get leaderboard data
- `POST /api/profile/:username` - Get profile data
- `POST /api/stats/update` - Update player stats
- `GET /api/achievements/:username` - Get achievements

**Database tables needed (if using DB):**
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE,
  email VARCHAR(100),
  created_at TIMESTAMP,
  referral_code VARCHAR(20) UNIQUE,
  referred_by VARCHAR(20)
);

CREATE TABLE leaderboard (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50),
  score INTEGER,
  wave INTEGER,
  timestamp TIMESTAMP
);

CREATE TABLE referrals (
  id SERIAL PRIMARY KEY,
  referrer VARCHAR(50),
  referred VARCHAR(50),
  reward_claimed BOOLEAN,
  created_at TIMESTAMP
);
```

## Phase 4: Seasonal Content (Week 4-5)

### 9. Seasonal Events
**Halloween Event (Oct 1-31):**
- Haunted Nebula map (fog effects)
- Ghost enemies (semi-transparent, phase through)
- Pumpkin drones (explode into candy power-ups)
- Witch boss (summons ghost minions)
- Halloween skins: Ghost Ship, Pumpkin Cruiser, Witch Broom
- Limited-time achievements

**Winter Event (Dec 1-31):**
- Frozen Sector map (ice crystals)
- Ice enemies (freeze player temporarily)
- Snowman sentries (stationary turrets)
- Santa boss (ho-ho-ho voice lines)
- Winter skins: Snowflake, Ice Crystal, Candy Cane
- Limited-time achievements

**Implementation:**
- Check current date in code
- Load event-specific configs
- Display event banner on main screen
- Event shop with exclusive items

## Phase 5: Polish & Testing (Week 5-6)

### 10. Additional Polish
- Add sound effects for all actions
- Improve particle effects
- Add screen transitions
- Optimize performance
- Mobile responsiveness
- Cross-browser testing
- Backend load testing

## Quick Wins (Do First!)

1. **Add 45 more achievements** - Just expand ACHIEVEMENTS array
2. **Add 12 more power-ups** - Just expand POWERUP_CONFIG
3. **Add 7 more enemies** - Just expand ENEMY_CONFIG
4. **Create themes.css** - Pure CSS, no backend needed
5. **Add theme selector to header** - Simple dropdown + localStorage

## Implementation Priority

**HIGH PRIORITY:**
- ✅ Achievements expansion
- ✅ Power-ups expansion
- ✅ Enemy types expansion
- ✅ Theme system

**MEDIUM PRIORITY:**
- Referral system
- Enhanced leaderboard
- Profile enhancements

**LOW PRIORITY:**
- Seasonal events (implement closer to holidays)
- Backend database migration (can use localStorage initially)

## Testing Checklist

- [ ] All achievements unlock correctly
- [ ] All power-ups work as intended
- [ ] All enemy types spawn and behave correctly
- [ ] Theme selector works on all pages
- [ ] Referral codes generate and track
- [ ] Leaderboard updates in real-time
- [ ] Profile displays all stats correctly
- [ ] Mobile controls work with new features
- [ ] No console errors
- [ ] Performance is smooth (60 FPS)
