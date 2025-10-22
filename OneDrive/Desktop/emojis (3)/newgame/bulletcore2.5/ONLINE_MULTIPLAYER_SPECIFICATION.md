# Space Shooter - Online Multiplayer System Specification

## Executive Summary

This document outlines the comprehensive online multiplayer architecture for Space Shooter, transforming it from a local/peer-to-peer game into a fully online, server-authoritative competitive experience with matchmaking, lobbies, and ranked play.

---

## 🎮 System Architecture Overview

### Core Principle: Server-Authoritative
**All gameplay logic runs on dedicated servers.** Clients send inputs; servers validate, process, and broadcast state updates.

**Benefits:**
- Eliminates client-side cheating
- Consistent game state across all players
- Fair competitive environment
- Centralized anti-cheat and monitoring

---

## 🔐 Online-Only Play with Secure Sessions

### Session Management

**Authentication Flow:**
1. Player logs in via website (already implemented)
2. Receives secure session token (JWT with 24h expiration)
3. Token includes: user_id, username, permissions, MMR, region
4. Game client validates token with auth server before joining matches

**Server-Authoritative Control:**
- **Movement:** Server validates speed, bounds, collision
- **Combat:** Hit detection, damage calculation, death on server
- **Scoring:** Wave completion, kills, bonuses calculated server-side
- **Progression:** XP, unlocks, currency changes server-validated

### Session Types

1. **Public Matchmaking**
   - Quick Play: Fast matches, broad MMR tolerance
   - Ranked: Competitive matches, strict MMR bands

2. **Private Lobbies**
   - Invite-only with unique codes
   - Custom rules (wave difficulty, power-up frequency, etc.)
   - Friends and party support

3. **Custom Matches**
   - Host-controlled settings
   - Practice mode with bots
   - Tournament support

### Verification Gates

**Pre-Match Checks:**
- ✅ Human verification (CAPTCHA for suspicious accounts)
- ✅ Anti-cheat client integrity check
- ✅ Rate limiting on match joins (prevent spam)
- ✅ Content version match (all players on same patch)
- ✅ Least-privilege tokens (can only join authorized sessions)

---

## 🎯 Match Lifecycle

### Phase 1: Pre-Match (30-60 seconds)

**Player Actions:**
1. Join queue or lobby
2. Select ship/loadout (locked at match start)
3. Map loading and asset validation
4. Ready-up confirmation

**Server Actions:**
1. Validate all players connected
2. Confirm content versions match
3. Allocate game server instance
4. Initialize match state
5. Send map and settings to clients

### Phase 2: In-Match (10-20 minutes typical)

**Wave-Based Progression:**
- 3-minute timer per wave
- Synchronized enemy spawns (server-controlled)
- Progressive difficulty scaling
- Booster currency earned in real-time

**Server Responsibilities:**
- Enemy AI control and pathfinding
- Power-up spawn timing and effects
- Boss mechanics and phases
- Score tracking and validation
- Player elimination and respawn logic

**Client Responsibilities:**
- Input capture and transmission
- State interpolation for smooth rendering
- Visual effects and audio
- HUD updates from server data

### Phase 3: Post-Match (15-30 seconds)

**Score Submission:**
1. Server finalizes match statistics
2. Anti-cheat anomaly detection runs
3. Scores signed and submitted to leaderboard service
4. Rewards calculated and distributed
5. MMR updated for ranked matches

**Player Options:**
- Return to lobby (rematch with same players)
- Back to main menu
- View match summary and stats
- Report players if needed

---

## 🎲 Matchmaking System

### Queue Types

#### Quick Play
**Goal:** Fast matches with acceptable quality

**Parameters:**
- MMR tolerance: ±300 initially, expands ±100 every 20 seconds
- Max wait time: 2 minutes before bot-fill
- Region: Primary + adjacent regions
- Party size: Solo to 4-player parties
- Target latency: <100ms preferred, <150ms maximum

#### Ranked
**Goal:** Competitive integrity and fair matches

**Parameters:**
- MMR tolerance: ±150 initially, expands ±50 every 30 seconds
- Max wait time: 5 minutes
- Region: Locked to player's region
- Party size: Solo or full team only
- Target latency: <80ms preferred, <120ms maximum
- Placement matches: 10 games to calibrate new players

### Matchmaking Constraints

**Primary Factors:**
1. **MMR (Matchmaking Rating):** Elo-like system with decay
2. **Region:** NA-East, NA-West, EU, Asia-Pacific, SA, etc.
3. **Input device:** Controller, keyboard/mouse (optional separation)
4. **Platform:** Windows, Linux, Web (cross-play enabled by default)
5. **Party size:** Solo, Duo, Squad (2-4 players)
6. **Latency threshold:** Player-to-server ping limits

### Queue Rules

**Timeout Behavior:**
- **0-30s:** Strict matching within target parameters
- **30s-1m:** MMR band expands by 25%
- **1m-2m:** MMR band expands by 50%, adjacent regions added
- **2m+:** Bot-fill offer presented; accept or continue waiting

**Backfill System:**
- Players can backfill matches with leavers
- Only during first wave (first 3 minutes)
- MMR-appropriate replacements
- Bonus rewards for backfill players

**Party Support:**
- Parties up to 4 players
- Party MMR: Weighted average with +5% penalty per member
- Prevents smurf-stacking (high-skill player + low-skill accounts)
- All party members must meet latency requirements

---

## 🏠 Lobby System

### Lobby Features

#### Roster Panel
**Displays:**
- Player list (up to 32 players)
- Ready/Not Ready status (green check/red X)
- Ping to server (color-coded: <50ms green, <100ms yellow, >100ms red)
- Platform icon (Windows, Linux, Web, Mobile)
- MMR preview (if public profile)
- Party indicator (brackets showing grouped players)

#### Lobby Chat
**Features:**
- Text chat with profanity filter
- Emoji and quick phrases support
- Mute individual players
- Report system (harassment, spam, inappropriate content)
- Admin moderation tools (kick, ban, warn)

**Rate Limiting:**
- 1 message per 2 seconds per player
- 10 messages per minute cap
- Auto-mute for spam (5 messages in 10 seconds)

#### Host Controls

**Map Selection:**
- Dropdown of all unlocked maps
- Preview image and description
- Vote system option (all players vote, highest wins)

**Game Rules:**
- Wave difficulty: Easy, Normal, Hard, Extreme
- Power-up frequency: Rare, Normal, Frequent
- Friendly fire: On/Off
- Respawn rules: Immediate, Wave-based, Limited lives

**Player Management:**
- Set player cap (4, 8, 16, 32)
- Enable/disable bot fill
- Kick players (with confirmation)
- Transfer host (promote player)

**Privacy Settings:**
- Public: Anyone can join
- Friends Only: Steam/platform friends
- Invite Only: Code required
- Password protected: Optional passphrase

**Start Controls:**
- Force start (requires 75% ready or host override)
- Cancel match preparation
- Return to matchmaking

#### Invite System

**Invite Codes:**
- 6-character alphanumeric codes
- One-time use or unlimited (host choice)
- Expiration: 5 minutes to 24 hours
- Share via clipboard, Discord, in-game friends list

**Friend List Invites:**
- One-click invite from friends list
- Real-time delivery notification
- Accept/Decline with countdown timer

---

## 🎮 In-Game: Pause and Menu

### Pause Menu Behavior

**Online Matches:**
- **Client-side overlay only:** Gameplay continues for other players
- **Input blocked locally:** Player's ship becomes idle/auto-pilot
- **No game pause:** Cannot freeze online match state
- **Timeout protection:** 60 seconds max pause; auto-resume after

**Single-Player/Training:**
- **True pause:** Freezes entire simulation
- **Save state:** Can resume later
- **No time limits:** Pause as long as needed

### Pause Menu Options

**Main Options:**
1. **Resume:** Return to gameplay immediately
2. **Settings:** 
   - Audio (master, music, SFX, voice chat)
   - Graphics (resolution, quality, effects, HUD scale)
   - Controls (rebind keys, sensitivity, invert axes)
   - HUD Layout (drag/resize elements, save presets)
3. **Report Player:**
   - Select player from list
   - Choose reason (cheating, toxic, AFK, etc.)
   - Add optional description
   - Submit report (server-logged)
4. **Leave Match:**
   - **Quick Play:** Leave instantly, soft penalty
   - **Ranked:** Confirmation required, 5-minute cooldown penalty
   - **Lobby:** Return to lobby waiting room
5. **Back to Lobby:**
   - Available only in post-match or if host ends match
   - Clean session teardown
6. **Back to Main Menu:**
   - Ultimate exit path
   - Confirmation dialog: "Progress will not be saved. Leave match?"
   - Properly disconnects from server

### Navigation Flow

```
In-Match → Pause (ESC) → Options → Back to In-Match
                       ↓
                  Leave Match → Return to Lobby → Back to Main Menu
                       ↓
                  Leave Match → Back to Main Menu (direct exit)
```

**Safety Mechanisms:**
- All exits properly disconnect from server
- No orphaned sessions or stuck lobby states
- Reconnect logic for accidental disconnects (60-second grace period)

---

## 🏆 Leaderboards

### Leaderboard Types

1. **Global Leaderboard**
   - All players worldwide
   - Updated every 5 minutes
   - Top 1000 visible

2. **Regional Leaderboards**
   - NA-East, NA-West, EU, Asia, etc.
   - Top 500 per region
   - Updated every 5 minutes

3. **Friends Leaderboard**
   - Your friends only
   - Real-time updates
   - See friends' progress

4. **Seasonal Leaderboards**
   - 3-month seasons
   - Reset with rewards
   - Archived history viewable
   - Seasonal badges and titles

5. **Mode-Specific**
   - Separate boards for Quick Play and Ranked
   - Daily Challenge leaderboard
   - Boss Rush mode board

### Tracked Metrics

**Primary Rankings:**
- **Total Score:** Cumulative lifetime score
- **Ranked Rating:** MMR/ELO for competitive play
- **Win Rate:** Wins / Total Matches (min 10 matches)

**Secondary Stats:**
- K/D Ratio (Kills / Deaths)
- Highest Wave Reached
- Total Time Survived
- Boosters Earned
- Maps Completed
- Boss Defeats

### Leaderboard Integrity

**Write Path (Server-Side Only):**
1. Match ends on game server
2. Server signs score data with private key
3. Anti-cheat passive checks run (score vs. time played, movement patterns)
4. Score submitted to leaderboard service with signature
5. Leaderboard service validates signature
6. Anomaly detection flags suspicious scores for manual review
7. Accepted scores update rankings

**Anti-Cheat Checks:**
- Score impossible for time played (too high)
- Perfect accuracy (aim-bot detection)
- Movement too fast/precise (speed hack)
- Damage dealt vs. shots fired mismatch
- Server-client state mismatches

### Performance Optimization

**Caching Strategy:**
- Top 100 cached per segment (refreshed every 5 min)
- Player personal rank: On-demand query with 30s cache
- Cursor-based pagination for deeper pages
- Pre-computed aggregates for stats displays

**Database:**
- Write-optimized log table (append-only match results)
- Read-optimized index table (denormalized leaderboards)
- Periodic compaction (hourly rollup, daily archival)
- Redis cache layer for hot data

### Profile Cards

**Click Player to View:**
- Username and title/badge
- Current rank and MMR
- Win rate and K/D
- Favorite ship and loadout
- Recent match history (last 10)
- Achievements earned
- Play time and join date

**Privacy Settings:**
- Public: All stats visible
- Friends Only: Stats visible to friends
- Private: Only username and rank visible

---

## 🎨 UI/UX Details

### Main Menu Updates

**Enhanced Play Button:**
```
PLAY (Primary Button)
├── Quick Play (🎮 Fast match)
├── Ranked (🏆 Competitive)
├── Create Lobby (🏠 Host game)
└── Join Lobby (🔗 Enter code)
```

**Social Panel (New):**
- Friends list with online status
- Pending invites (Accept/Decline)
- Party management (Create, Invite, Leave)
- Recent players list
- Block/Report from social panel

**Leaderboards Access:**
- Main menu: Leaderboards button
- Post-match: View Rankings button
- Profile menu: My Rank option

### In-Match HUD

**Core Elements:**
- Wave timer (center-top): "Wave 3/20 - 2:15 remaining"
- Score counter (top-right): "+250 SCORE"
- Booster currency (top-right below score)
- Team status (left side): Teammate health bars, names, status
- Mini-map (optional, bottom-left corner)

**Persistent Controls:**
- Pause button (top-left): ESC or hamburger icon
- Settings quick-access: Gear icon
- Voice chat indicator: Mic icon with mute toggle

**Mobile-Specific:**
- Virtual joystick (left)
- Fire button (right)
- Special ability buttons (right side)
- Pause button (top-center, large)

**HUD Customization:**
- Drag-resize any HUD element
- Save presets per device
- Reset to defaults option
- Opacity sliders for overlays

---

## 🛠️ Technical Implementation

### Networking Architecture

#### Transport Layer

**Protocols:**
- **TCP for:** Lobby chat, match invites, player status, leaderboards
- **UDP for:** Game state, player inputs, position updates

**Channels:**
- **Reliable ordered:** Chat messages, match events, score updates
- **Unreliable sequenced:** Player positions, enemy positions, projectiles

**Message Types:**
```
Client → Server:
- PlayerInput (move, shoot, ability)
- ChatMessage
- ReadyStatus
- LoadoutChange

Server → Client:
- GameStateSnapshot (full state every 100ms)
- EntityUpdate (delta updates every 33ms)
- EventNotification (kills, wave complete, power-up)
- ChatBroadcast
```

#### Tick Rate and Reconciliation

**Server Tick Rate:** 30 ticks/second
- Full snapshots: 10Hz (every 100ms)
- Delta updates: 30Hz (every 33ms)

**Client Prediction:**
- Client predicts own movement immediately
- Server reconciles and corrects as needed
- Smooth interpolation between server states

**Lag Compensation:**
- Server rewinds time for hitscan validation
- Maximum 200ms compensation window
- Favors shooter within reason

#### Snapshot Compression

**Delta Encoding:**
- Only send changed values
- Reference previous snapshot
- Typical reduction: 70-90% bandwidth

**Priority Updates:**
- Nearby entities: Full precision, frequent updates
- Distant entities: Lower precision, less frequent
- Occluded entities: Minimal updates

---

## 🔒 Security and Anti-Cheat

### Authentication

**Session Tokens:**
- Short-lived (15 minutes active session)
- Refresh token (24 hours, secure cookie)
- Issued by auth gateway (separate from game servers)
- Revocable (admin can force logout)

**Audit Logs:**
- All admin actions logged
- Player reports tracked
- Suspicious activity flagged
- Review dashboard for moderators

### Anti-Cheat Systems

**Client Integrity:**
- Hash verification of game files
- Memory scanning for known cheats
- Process list monitoring (suspicious apps)
- Fail-closed: Kick if integrity check fails

**Server-Side Validation:**
- **Movement sanity:** Speed caps, collision validation, teleport detection
- **Combat sanity:** Damage per second caps, accuracy thresholds, impossible shots
- **Score anomalies:** Flag outliers (3+ standard deviations from mean)
- **Behavioral patterns:** Bot-like inputs, frame-perfect actions

**Rate Limiting:**
- Per-IP: 100 requests/minute
- Per-account: 50 actions/minute
- Match joins: 10/hour per account
- Chat messages: 1 per 2 seconds

### Ban System

**Violation Tiers:**
1. **Warning:** Notification, tracked in system
2. **Cooldown:** 5-minute to 24-hour queue ban
3. **Suspension:** 1-7 day account suspension
4. **Permanent Ban:** Hardware ID + account ban

---

## 📊 Data Architecture

### MMR System

**Elo-Based Rating:**
- Starting MMR: 1500
- K-factor: 32 for <30 matches, 24 for <100, 16 thereafter
- Win/Loss adjustment: ±15-40 MMR per match
- Placement matches: 10 games with double K-factor

**MMR Decay:**
- No decay for first 7 days inactive
- 10 MMR/day after 7 days (max 300 loss)
- Stops at original placement MMR

**Uncertainty:**
- New players: High uncertainty (±200 MMR confidence)
- Consistent players: Low uncertainty (±50 MMR)
- Uncertainty decreases with matches played

### Leaderboard Storage

**Database Schema:**

```sql
-- Match Results Log (Write-Optimized)
CREATE TABLE match_results (
    match_id UUID PRIMARY KEY,
    player_id UUID,
    username VARCHAR(50),
    score INT,
    wave_reached INT,
    kills INT,
    deaths INT,
    playtime_seconds INT,
    mmr_change INT,
    match_timestamp TIMESTAMP,
    signature TEXT,
    INDEX idx_player_timestamp (player_id, match_timestamp),
    INDEX idx_score (score DESC)
);

-- Leaderboard Index (Read-Optimized)
CREATE TABLE leaderboard (
    player_id UUID PRIMARY KEY,
    username VARCHAR(50),
    total_score BIGINT,
    ranked_mmr INT,
    wins INT,
    losses INT,
    win_rate DECIMAL(5,2),
    kd_ratio DECIMAL(5,2),
    highest_wave INT,
    global_rank INT,
    regional_rank INT,
    last_updated TIMESTAMP,
    INDEX idx_global (total_score DESC),
    INDEX idx_ranked (ranked_mmr DESC),
    INDEX idx_region_score (region, total_score DESC)
);
```

**Update Schedule:**
- Match results: Immediate write
- Leaderboard rollup: Every 5 minutes
- Personal rank refresh: On-demand with cache

---

## 🚀 Scalability

### Auto-Scaling Game Servers

**Instance Management:**
- Spin up: When queues >5 minutes or >80% capacity
- Spin down: When utilization <30% for 10 minutes
- Regions: Independent scaling per region
- Limits: Max 100 instances per region (cost caps)

**Load Balancing:**
- Route to lowest-latency available server
- Distribute matchmaking load evenly
- Health checks every 30 seconds
- Remove unhealthy instances immediately

### Database Scaling

**Read Replicas:**
- Leaderboard reads: 3 replicas per region
- Match history: 2 replicas globally
- Profile data: Cached aggressively

**Write Sharding:**
- Match results: Shard by timestamp (append-only)
- Player data: Shard by user_id prefix
- Leaderboards: Centralized master + cached copies

---

## 📱 Platform Considerations

### Cross-Platform Play

**Supported Platforms:**
- Windows (primary)
- Linux
- Web browser
- Mobile (iOS/Android) - limited

**Input Fairness:**
- Optional input-based matchmaking
- Controller aim-assist in mixed lobbies
- Mobile players in separate queue by default (opt-in to cross-play)

### Content Delivery

**Asset Streaming:**
- Map assets pre-loaded during matchmaking
- On-demand texture streaming for lower-end devices
- Progressive quality (load low-res, upgrade to high-res)

---

## 🎁 Rewards and Progression

### Match Rewards

**Base Rewards:**
- Booster currency: 100-500 per match (based on performance)
- XP: 50-200 (wave depth + score bonus)
- Credits: 25-100 (for cosmetics shop)

**Bonuses:**
- First win of day: 2x rewards
- Ranked wins: 1.5x rewards
- Perfect wave (no damage): +50 currency
- Team victory: +25% bonus
- Backfill completion: +100 currency

**Season Rewards:**
- Top 100 global: Exclusive title + badge
- Top 1000: Seasonal badge
- Diamond tier (top 5%): Premium cosmetics
- All ranked players: Participation rewards

---

## 🏗️ Development Roadmap

### Phase 1: Foundation (Weeks 1-4)
- [ ] Set up dedicated server infrastructure (AWS/GCP)
- [ ] Implement basic networking (UDP + TCP)
- [ ] Server-authoritative movement and combat
- [ ] Simple matchmaking (Quick Play only)
- [ ] Basic lobby system

### Phase 2: Core Features (Weeks 5-8)
- [ ] Ranked matchmaking with MMR
- [ ] Leaderboards (global and regional)
- [ ] Lobby chat and moderation
- [ ] Pause menu with all options
- [ ] Anti-cheat foundation

### Phase 3: Polish (Weeks 9-12)
- [ ] Advanced matchmaking (parties, filters)
- [ ] Seasonal systems
- [ ] Enhanced anti-cheat
- [ ] Performance optimizations
- [ ] Cross-platform support

### Phase 4: Launch (Week 13+)
- [ ] Beta testing with limited players
- [ ] Stress testing and load balancing
- [ ] Security audit
- [ ] Public launch
- [ ] Ongoing maintenance and seasons

---

## 💰 Cost Estimates

### Infrastructure (Monthly)

**Game Servers:**
- 10 dedicated servers @ $50/server = $500/month
- Auto-scaling: +$200/month peak capacity
- **Total: $700/month**

**Database & Storage:**
- PostgreSQL managed instance: $150/month
- Redis cache: $75/month
- S3 asset storage: $25/month
- **Total: $250/month**

**Networking:**
- CDN for assets: $50/month
- Data transfer: $100/month
- **Total: $150/month**

**Monitoring & Tools:**
- Application monitoring: $25/month
- Log aggregation: $50/month
- **Total: $75/month**

**Grand Total: ~$1,175/month** (scales with player count)

### Development Time

**Solo Developer:**
- ~12-16 weeks for complete implementation
- Full-time equivalent: 500-700 hours

**Small Team (3 developers):**
- ~6-8 weeks for complete implementation
- Network engineer, backend developer, game programmer

---

## 📋 Acceptance Criteria

### Functional Requirements

✅ **Online-Only:**
- Players must authenticate via website
- Game launches with session token
- Cannot play without server connection
- Training mode optional (offline)

✅ **Matchmaking:**
- Quick Play matches within 2 minutes (90% success rate)
- Ranked matches within 5 minutes (90% success rate)
- MMR and latency constraints respected
- Parties of 2-4 supported

✅ **Lobby System:**
- Create/join lobbies with codes
- Roster shows all player information
- Chat works with moderation
- Host controls functional
- Ready-up and start match seamless

✅ **Pause and Navigation:**
- Pause overlay functional in online matches
- Settings accessible and persistent
- Leave match with proper cleanup
- Back to lobby/menu paths clear
- No stuck states or orphaned sessions

✅ **Leaderboards:**
- Load within 2 seconds
- Update post-match (within 5 minutes)
- Anti-cheat validation active
- Profile cards viewable
- Pagination smooth

### Non-Functional Requirements

✅ **Performance:**
- Server tick rate: 30 TPS
- Client FPS: 60+ on target hardware
- Network latency: <100ms for 90% of matches
- Leaderboard queries: <500ms p95

✅ **Security:**
- No client-side score modification
- Rate limits prevent abuse
- Authentication required for all actions
- Audit logs for admin actions

✅ **Stability:**
- 99.5% server uptime
- Graceful handling of disconnects
- Reconnect logic for network hiccups
- No data loss on server failures (replicated DBs)

---

## 🔧 Required Technologies

### Backend Stack

**Game Server:**
- Godot Headless (for server authority)
- Or: Node.js + custom physics (lighter weight)

**Matchmaking Service:**
- Node.js + Express
- Redis for queue management
- WebSocket for real-time updates

**Database:**
- PostgreSQL (leaderboards, user data)
- Redis (caching, sessions)
- S3 (replays, logs)

**Infrastructure:**
- AWS EC2 or Google Cloud Compute
- Docker + Kubernetes for orchestration
- Load balancers (ALB/NLB)
- CloudWatch/Grafana monitoring

### Frontend Changes

**Game Client Updates:**
- Networking library (ENet or WebRTC)
- Client prediction and reconciliation
- State interpolation
- Input buffering

**Website Integration:**
- Session token issuance after login
- Game launch with token injection
- Status dashboard (online friends, queue times)

---

## 📚 Documentation Deliverables

1. **API Documentation** - All server endpoints and payloads
2. **Network Protocol Spec** - Message formats and sequences
3. **Deployment Guide** - How to set up infrastructure
4. **Admin Manual** - Moderation tools and processes
5. **Player Guide** - How to use matchmaking, lobbies, etc.

---

## ⚠️ Current Limitations

**What's Already Done:**
- ✅ Website authentication system
- ✅ User profiles and session management
- ✅ Basic lobby UI (needs backend connection)

**What Needs Building:**
- ❌ Dedicated game servers
- ❌ Matchmaking service
- ❌ Server-authoritative game logic
- ❌ Real-time networking protocol
- ❌ Leaderboard backend
- ❌ Anti-cheat systems
- ❌ MMR calculation and tracking
- ❌ Party and friends system
- ❌ Admin moderation tools

---

## 🎯 Next Steps

### Immediate Actions:

1. **Decide on infrastructure provider** (AWS, GCP, Azure, or specialized gaming hosting)
2. **Set up development server** for testing
3. **Implement basic networking** in game client
4. **Create matchmaking backend** (start with Quick Play only)
5. **Test with small group** before expanding

### Long-Term Goals:

1. Beta launch with 100-500 players
2. Gather feedback and iterate
3. Scale infrastructure based on growth
4. Add features incrementally (ranked, seasons, etc.)
5. Maintain competitive integrity

---

**Author:** King_davezz / NEXO GAMES  
**Version:** 1.0  
**Last Updated:** October 2025  
**Status:** Specification Complete - Implementation Pending
