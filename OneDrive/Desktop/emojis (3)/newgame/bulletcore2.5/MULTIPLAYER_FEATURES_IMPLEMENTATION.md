# Multiplayer Features Implementation Guide

## Overview
This document provides a comprehensive implementation plan for the complete multiplayer system including sessions, communication, stats sync, leaderboards, and mobile optimizations.

---

## 🎮 1. Multiplayer Sessions

### 1.1 Session Management (3-Player Co-op)

**Server Updates (`multiplayer-server/server.js`):**

```javascript
// Add to server.js
class GameSession {
    constructor(sessionId, hostId) {
        this.sessionId = sessionId;
        this.hostId = hostId;
        this.players = new Map();
        this.bots = [];
        this.maxPlayers = 3;
        this.status = 'waiting'; // waiting, starting, active, finished
        this.gameState = {
            wave: 1,
            enemies: [],
            score: 0,
            startTime: null
        };
    }

    addPlayer(playerId, playerData) {
        if (this.players.size >= this.maxPlayers) return false;
        
        this.players.set(playerId, {
            id: playerId,
            name: playerData.name,
            health: 100,
            score: 0,
            kills: 0,
            deaths: 0,
            ready: false
        });
        
        // Auto-fill with bots if needed
        this.updateBots();
        return true;
    }

    updateBots() {
        const humanPlayers = this.players.size;
        const botsNeeded = this.maxPlayers - humanPlayers;
        
        this.bots = [];
        for (let i = 0; i < botsNeeded; i++) {
            this.bots.push({
                id: `bot_${i}`,
                name: `AI Pilot ${i + 1}`,
                isBot: true,
                health: 100,
                score: 0
            });
        }
    }

    canStart() {
        return this.players.size > 0 && 
               Array.from(this.players.values()).every(p => p.ready);
    }

    startSession() {
        if (!this.canStart()) return false;
        this.status = 'active';
        this.gameState.startTime = Date.now();
        return true;
    }

    endSession() {
        this.status = 'finished';
        return this.getSessionResults();
    }

    getSessionResults() {
        const results = {
            sessionId: this.sessionId,
            duration: Date.now() - this.gameState.startTime,
            wave: this.gameState.wave,
            players: Array.from(this.players.values()).map(p => ({
                name: p.name,
                score: p.score,
                kills: p.kills,
                deaths: p.deaths
            })),
            bots: this.bots.map(b => ({
                name: b.name,
                score: b.score
            }))
        };
        return results;
    }
}

// Add session management
let activeSessions = new Map();
let matchmakingQueue = [];

// Quick Match Handler
function handleQuickMatch(playerId, playerData) {
    // Try to find available session
    for (let [sessionId, session] of activeSessions) {
        if (session.status === 'waiting' && session.players.size < session.maxPlayers) {
            session.addPlayer(playerId, playerData);
            return { sessionId, session };
        }
    }
    
    // Create new session
    const sessionId = `session_${Date.now()}`;
    const session = new GameSession(sessionId, playerId);
    session.addPlayer(playerId, playerData);
    activeSessions.set(sessionId, session);
    
    return { sessionId, session };
}
```

**Client Integration (`game/index.tsx`):**

Add WebSocket connection manager:

```typescript
// Add to game code
class MultiplayerManager {
    ws: WebSocket | null = null;
    sessionId: string | null = null;
    isHost: boolean = false;
    
    connect(serverUrl: string) {
        this.ws = new WebSocket(serverUrl);
        
        this.ws.onopen = () => {
            console.log('Connected to multiplayer server');
            this.send({ type: 'join', name: gameState.username });
        };
        
        this.ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            this.handleMessage(data);
        };
    }
    
    joinQuickMatch() {
        this.send({ 
            type: 'quick_match',
            playerData: {
                name: gameState.username,
                level: gameState.level,
                ship: gameState.selectedShip
            }
        });
    }
    
    handleMessage(data: any) {
        switch(data.type) {
            case 'session_joined':
                this.sessionId = data.sessionId;
                this.isHost = data.isHost;
                showSessionLobby(data.session);
                break;
            case 'session_started':
                startMultiplayerGame(data.session);
                break;
            case 'player_joined':
                updateLobbyPlayers(data.players);
                break;
            // ... more handlers
        }
    }
    
    send(data: any) {
        if (this.ws && this.ws.readyState === WebSocket.OPEN) {
            this.ws.send(JSON.stringify(data));
        }
    }
}

const multiplayerManager = new MultiplayerManager();
```

---

## 💬 2. Communication System

### 2.1 Enhanced Chat with Channels

**Add to game code:**

```typescript
class ChatManager {
    channels = {
        lobby: [] as ChatMessage[],
        party: [] as ChatMessage[],
        match: [] as ChatMessage[]
    };
    
    currentChannel: 'lobby' | 'party' | 'match' = 'lobby';
    mutedPlayers = new Set<string>();
    blockedPlayers = new Set<string>();
    lastMessageTime = 0;
    messageCount = 0;
    
    sendMessage(message: string) {
        // Anti-spam protection
        const now = Date.now();
        if (now - this.lastMessageTime < 1000) {
            this.messageCount++;
            if (this.messageCount > 3) {
                showNotification('⚠️ Please wait before sending more messages');
                return false;
            }
        } else {
            this.messageCount = 0;
        }
        this.lastMessageTime = now;
        
        // Filter profanity
        const filtered = this.filterProfanity(message);
        
        multiplayerManager.send({
            type: 'chat',
            channel: this.currentChannel,
            message: filtered
        });
        
        return true;
    }
    
    receiveMessage(from: string, message: string, channel: string) {
        if (this.mutedPlayers.has(from) || this.blockedPlayers.has(from)) {
            return;
        }
        
        this.channels[channel as keyof typeof this.channels].push({
            from,
            message,
            timestamp: Date.now()
        });
        
        this.displayMessage(from, message, channel);
    }
    
    mutePlayer(playerName: string) {
        this.mutedPlayers.add(playerName);
        showNotification(`🔇 Muted ${playerName}`);
    }
    
    blockPlayer(playerName: string) {
        this.blockedPlayers.add(playerName);
        showNotification(`🚫 Blocked ${playerName}`);
    }
    
    switchChannel(channel: 'lobby' | 'party' | 'match') {
        this.currentChannel = channel;
        this.refreshChatDisplay();
    }
    
    filterProfanity(text: string): string {
        const profanityList = ['badword1', 'badword2']; // Expand this list
        let filtered = text;
        profanityList.forEach(word => {
            const regex = new RegExp(`\\b${word}\\b`, 'gi');
            filtered = filtered.replace(regex, '****');
        });
        return filtered;
    }
    
    displayMessage(from: string, message: string, channel: string) {
        const chatMessages = document.getElementById('chat-messages')!;
        const msgEl = document.createElement('div');
        msgEl.className = `chat-message channel-${channel}`;
        msgEl.innerHTML = `
            <span class="chat-time">${new Date().toLocaleTimeString()}</span>
            <span class="chat-channel">[${channel.toUpperCase()}]</span>
            <span class="chat-user">${from}:</span>
            <span class="chat-text">${message}</span>
            <button class="chat-mute" onclick="chatManager.mutePlayer('${from}')">🔇</button>
        `;
        chatMessages.appendChild(msgEl);
        chatMessages.scrollTop = chatMessages.scrollHeight;
        
        // Keep only last 100 messages
        while (chatMessages.children.length > 100) {
            chatMessages.removeChild(chatMessages.firstChild!);
        }
    }
    
    refreshChatDisplay() {
        const chatMessages = document.getElementById('chat-messages')!;
        chatMessages.innerHTML = '';
        
        const messages = this.channels[this.currentChannel];
        messages.slice(-50).forEach(msg => {
            this.displayMessage(msg.from, msg.message, this.currentChannel);
        });
    }
}

const chatManager = new ChatManager();
```

**Add Chat UI HTML:**

```html
<!-- Add to game HTML -->
<div id="chat-panel" class="chat-panel">
    <div class="chat-channels">
        <button onclick="chatManager.switchChannel('lobby')" class="channel-btn active" data-channel="lobby">
            Lobby
        </button>
        <button onclick="chatManager.switchChannel('party')" class="channel-btn" data-channel="party">
            Party
        </button>
        <button onclick="chatManager.switchChannel('match')" class="channel-btn" data-channel="match">
            Match
        </button>
    </div>
    <div id="chat-messages" class="chat-messages"></div>
    <div class="chat-input-container">
        <input type="text" id="chat-input-new" placeholder="Type a message..." maxlength="200">
        <button onclick="sendChatMessage()">Send</button>
    </div>
</div>

<style>
.chat-panel {
    position: fixed;
    bottom: 20px;
    right: 20px;
    width: 350px;
    height: 400px;
    background: rgba(0, 0, 0, 0.9);
    border: 2px solid cyan;
    border-radius: 10px;
    display: flex;
    flex-direction: column;
}

.chat-channels {
    display: flex;
    background: rgba(0, 255, 255, 0.1);
    border-bottom: 1px solid cyan;
}

.channel-btn {
    flex: 1;
    padding: 10px;
    background: transparent;
    color: cyan;
    border: none;
    cursor: pointer;
    transition: all 0.3s;
}

.channel-btn.active {
    background: rgba(0, 255, 255, 0.3);
    border-bottom: 3px solid cyan;
}

.chat-messages {
    flex: 1;
    overflow-y: auto;
    padding: 10px;
}

.chat-message {
    margin-bottom: 8px;
    padding: 5px;
    border-radius: 5px;
    background: rgba(255, 255, 255, 0.05);
}

.chat-time {
    color: #666;
    font-size: 0.8em;
    margin-right: 5px;
}

.chat-channel {
    color: #ff00ff;
    font-weight: bold;
    margin-right: 5px;
}

.chat-user {
    color: #00ffff;
    font-weight: bold;
}

.chat-text {
    color: white;
}

.chat-mute {
    float: right;
    background: transparent;
    border: none;
    cursor: pointer;
    opacity: 0.5;
}

.chat-mute:hover {
    opacity: 1;
}
</style>
```

---

## 📊 3. Stats and Progression Sync

### 3.1 Server-Authoritative Stats System

**Add stats API endpoint (`api/stats.js`):**

```javascript
// Enhanced stats API
export default async function handler(req, res) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    
    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }
    
    const { createClient } = require('@supabase/supabase-js');
    const supabase = createClient(
        process.env.SUPABASE_URL,
        process.env.SUPABASE_KEY
    );
    
    if (req.method === 'POST') {
        const { username, matchData } = req.body;
        
        // Validate match data
        if (!username || !matchData) {
            return res.status(400).json({ error: 'Missing required fields' });
        }
        
        try {
            // Get current stats
            const { data: currentStats } = await supabase
                .from('player_stats')
                .select('*')
                .eq('username', username)
                .single();
            
            // Calculate new stats (server-authoritative)
            const newStats = {
                total_kills: (currentStats?.total_kills || 0) + matchData.kills,
                total_deaths: (currentStats?.total_deaths || 0) + matchData.deaths,
                total_score: (currentStats?.total_score || 0) + matchData.score,
                matches_played: (currentStats?.matches_played || 0) + 1,
                waves_survived: Math.max(currentStats?.waves_survived || 0, matchData.wave),
                win_count: (currentStats?.win_count || 0) + (matchData.won ? 1 : 0),
                last_played: new Date().toISOString()
            };
            
            // Update or insert
            const { data, error } = await supabase
                .from('player_stats')
                .upsert({
                    username,
                    ...newStats
                }, { onConflict: 'username' });
            
            if (error) throw error;
            
            // Update leaderboard
            await updateLeaderboard(supabase, username, newStats.total_score);
            
            return res.status(200).json({ 
                success: true,
                stats: newStats
            });
            
        } catch (error) {
            console.error('Stats sync error:', error);
            return res.status(500).json({ error: 'Failed to sync stats' });
        }
    }
    
    if (req.method === 'GET') {
        const { username } = req.query;
        
        try {
            const { data, error } = await supabase
                .from('player_stats')
                .select('*')
                .eq('username', username)
                .single();
            
            if (error && error.code !== 'PGRST116') throw error;
            
            return res.status(200).json({ stats: data || {} });
            
        } catch (error) {
            console.error('Get stats error:', error);
            return res.status(500).json({ error: 'Failed to get stats' });
        }
    }
}

async function updateLeaderboard(supabase, username, score) {
    const { error } = await supabase
        .from('leaderboard')
        .upsert({
            username,
            score,
            updated_at: new Date().toISOString()
        }, { onConflict: 'username' });
    
    if (error) console.error('Leaderboard update error:', error);
}
```

**Client-side sync (`game/index.tsx`):**

```typescript
class StatsManager {
    pendingSync: any[] = [];
    syncInterval: number | null = null;
    
    startAutoSync() {
        // Sync every 30 seconds
        this.syncInterval = window.setInterval(() => {
            this.syncPendingStats();
        }, 30000);
    }
    
    async recordMatchEnd(matchData: MatchData) {
        const statsUpdate = {
            username: gameState.username,
            matchData: {
                kills: matchData.kills,
                deaths: matchData.deaths,
                score: matchData.score,
                wave: matchData.wave,
                won: matchData.won,
                timestamp: Date.now()
            }
        };
        
        // Add to pending queue
        this.pendingSync.push(statsUpdate);
        
        // Try immediate sync
        await this.syncToServer(statsUpdate);
    }
    
    async syncToServer(statsUpdate: any) {
        try {
            const response = await fetch('/api/stats', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(statsUpdate)
            });
            
            if (response.ok) {
                const result = await response.json();
                
                // Update local state with server-authoritative stats
                this.updateLocalStats(result.stats);
                
                // Remove from pending
                this.pendingSync = this.pendingSync.filter(
                    p => p.matchData.timestamp !== statsUpdate.matchData.timestamp
                );
                
                return true;
            }
        } catch (error) {
            console.error('Stats sync failed:', error);
            // Will retry on next sync interval
        }
        return false;
    }
    
    async syncPendingStats() {
        if (this.pendingSync.length === 0) return;
        
        console.log(`Syncing ${this.pendingSync.length} pending stats...`);
        
        for (const pending of this.pendingSync) {
            await this.syncToServer(pending);
        }
    }
    
    updateLocalStats(serverStats: any) {
        gameState.stats.totalKills = serverStats.total_kills;
        gameState.stats.wavesSurvived = serverStats.waves_survived;
        // Update other stats...
        saveGameState();
    }
    
    async loadStatsFromServer() {
        try {
            const response = await fetch(`/api/stats?username=${gameState.username}`);
            if (response.ok) {
                const { stats } = await response.json();
                if (stats) {
                    this.updateLocalStats(stats);
                }
            }
        } catch (error) {
            console.error('Failed to load stats:', error);
        }
    }
}

const statsManager = new StatsManager();
```

---

## 🏆 4. Enhanced Leaderboards

### 4.1 Real-time Leaderboard System

**Database Schema (add to Supabase):**

```sql
-- Leaderboards table with filters
CREATE TABLE leaderboards (
    id SERIAL PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    total_score BIGINT DEFAULT 0,
    season_score BIGINT DEFAULT 0,
    region TEXT DEFAULT 'global',
    game_mode TEXT DEFAULT 'survival',
    rank INT,
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_leaderboard_score ON leaderboards(total_score DESC);
CREATE INDEX idx_leaderboard_season ON leaderboards(season_score DESC);
CREATE INDEX idx_leaderboard_region ON leaderboards(region, total_score DESC);
CREATE INDEX idx_leaderboard_mode ON leaderboards(game_mode, total_score DESC);

-- Auto-update ranks
CREATE OR REPLACE FUNCTION update_leaderboard_ranks()
RETURNS TRIGGER AS $$
BEGIN
    WITH ranked AS (
        SELECT username, ROW_NUMBER() OVER (ORDER BY total_score DESC) as new_rank
        FROM leaderboards
    )
    UPDATE leaderboards l
    SET rank = r.new_rank
    FROM ranked r
    WHERE l.username = r.username;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER leaderboard_rank_update
AFTER INSERT OR UPDATE ON leaderboards
FOR EACH STATEMENT
EXECUTE FUNCTION update_leaderboard_ranks();
```

**Enhanced Leaderboard API (`api/leaderboard.js`):**

```javascript
export default async function handler(req, res) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    
    const { createClient } = require('@supabase/supabase-js');
    const supabase = createClient(
        process.env.SUPABASE_URL,
        process.env.SUPABASE_KEY
    );
    
    const { 
        filter = 'global', 
        season = 'current',
        gameMode = 'survival',
        limit = 100,
        username = null
    } = req.query;
    
    try {
        let query = supabase
            .from('leaderboards')
            .select('*');
        
        // Apply filters
        if (filter === 'friends' && username) {
            // Get friends list and filter
            const { data: friends } = await supabase
                .from('friends')
                .select('friend_username')
                .eq('username', username);
            
            const friendsList = friends?.map(f => f.friend_username) || [];
            friendsList.push(username);
            
            query = query.in('username', friendsList);
        } else if (filter !== 'global') {
            query = query.eq('region', filter);
        }
        
        if (gameMode !== 'all') {
            query = query.eq('game_mode', gameMode);
        }
        
        // Order and limit
        const scoreColumn = season === 'current' ? 'season_score' : 'total_score';
        query = query.order(scoreColumn, { ascending: false }).limit(parseInt(limit));
        
        const { data, error } = await query;
        
        if (error) throw error;
        
        res.status(200).json({ 
            leaderboard: data,
            filter,
            season,
            gameMode,
            lastUpdated: new Date().toISOString()
        });
        
    } catch (error) {
        console.error('Leaderboard error:', error);
        res.status(500).json({ error: 'Failed to fetch leaderboard' });
    }
}
```

**Client-side Leaderboard UI:**

```typescript
class LeaderboardManager {
    currentFilter = 'global';
    currentSeason = 'current';
    currentMode = 'survival';
    autoRefreshInterval: number | null = null;
    
    async loadLeaderboard() {
        try {
            const params = new URLSearchParams({
                filter: this.currentFilter,
                season: this.currentSeason,
                gameMode: this.currentMode,
                username: gameState.username
            });
            
            const response = await fetch(`/api/leaderboard?${params}`);
            if (response.ok) {
                const data = await response.json();
                this.displayLeaderboard(data.leaderboard);
            }
        } catch (error) {
            console.error('Failed to load leaderboard:', error);
        }
    }
    
    displayLeaderboard(entries: any[]) {
        const container = document.getElementById('leaderboard-entries')!;
        container.innerHTML = '';
        
        entries.forEach((entry, index) => {
            const row = document.createElement('div');
            row.className = 'leaderboard-row';
            if (entry.username === gameState.username) {
                row.classList.add('player-row');
            }
            
            const medal = index < 3 ? ['🥇', '🥈', '🥉'][index] : '';
            
            row.innerHTML = `
                <span class="rank">${medal || entry.rank}</span>
                <span class="username">${entry.username}</span>
                <span class="score">${entry.total_score.toLocaleString()}</span>
                <span class="region">${entry.region}</span>
            `;
            
            container.appendChild(row);
        });
    }
    
    startAutoRefresh() {
        // Refresh every 60 seconds
        this.autoRefreshInterval = window.setInterval(() => {
            this.loadLeaderboard();
        }, 60000);
    }
    
    setFilter(filter: string) {
        this.currentFilter = filter;
        this.loadLeaderboard();
    }
}

const leaderboardManager = new LeaderboardManager();
```

---

## 📱 5. Mobile Optimizations

### 5.1 Landscape Mode Enforcement

```typescript
// Add to game initialization
function enforceLandscapeMode() {
    const checkOrientation = () => {
        const isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);
        
        if (isMobile) {
            const isLandscape = window.innerWidth > window.innerHeight;
            const rotateWarning = document.getElementById('rotate-warning');
            
            if (!rotateWarning) {
                const warning = document.createElement('div');
                warning.id = 'rotate-warning';
                warning.innerHTML = `
                    <div class="rotate-warning-content">
                        <div class="rotate-icon">📱➡️</div>
                        <h2>Please Rotate Your Device</h2>
                        <p>This game is best played in landscape mode</p>
                    </div>
                `;
                document.body.appendChild(warning);
            }
            
            const warning = document.getElementById('rotate-warning')!;
            warning.style.display = isLandscape ? 'none' : 'flex';
            
            // Lock orientation if supported
            if (screen.orientation && screen.orientation.lock) {
                screen.orientation.lock('landscape').catch(() => {
                    console.log('Orientation lock not supported');
                });
            }
        }
    };
    
    window.addEventListener('resize', checkOrientation);
    window.addEventListener('orientationchange', checkOrientation);
    checkOrientation();
}

// Add CSS
const style = document.createElement('style');
style.textContent = `
#rotate-warning {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.95);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 10000;
}

.rotate-warning-content {
    text-align: center;
    color: white;
}

.rotate-icon {
    font-size: 80px;
    animation: rotate-pulse 2s infinite;
}

@keyframes rotate-pulse {
    0%, 100% { transform: scale(1); }
    50% { transform: scale(1.2) rotate(90deg); }
}
`;
document.head.appendChild(style);
```

### 5.2 Enhanced Mobile Controls

```typescript
// Improved mobile joystick
class MobileJoystick {
    joystickArea: HTMLElement;
    joystickThumb: HTMLElement;
    active = false;
    startX = 0;
    startY = 0;
    
    constructor() {
        this.joystickArea = document.getElementById('joystick-area')!;
        this.joystickThumb = document.getElementById('joystick-thumb')!;
        this.setupEvents();
    }
    
    setupEvents() {
        this.joystickArea.addEventListener('touchstart', this.onTouchStart.bind(this), { passive: false });
        this.joystickArea.addEventListener('touchmove', this.onTouchMove.bind(this), { passive: false });
        this.joystickArea.addEventListener('touchend', this.onTouchEnd.bind(this), { passive: false });
    }
    
    onTouchStart(e: TouchEvent) {
        e.preventDefault();
        this.active = true;
        const rect = this.joystickArea.getBoundingClientRect();
        this.startX = rect.left + rect.width / 2;
        this.startY = rect.top + rect.height / 2;
        this.updatePosition(e.touches[0]);
    }
    
    onTouchMove(e: TouchEvent) {
        e.preventDefault();
        if (!this.active) return;
        this.updatePosition(e.touches[0]);
    }
    
    onTouchEnd(e: TouchEvent) {
        e.preventDefault();
        this.active = false;
        this.joystickThumb.style.transform = 'translate(0, 0)';
        keys['w'] = keys['s'] = keys['a'] = keys['d'] = false;
    }
    
    updatePosition(touch: Touch) {
        const deltaX = touch.clientX - this.startX;
        const deltaY = touch.clientY - this.startY;
        const angle = Math.atan2(deltaY, deltaX);
        const maxDistance = this.joystickArea.clientWidth / 2 - this.joystickThumb.clientWidth / 2;
        const distance = Math.min(maxDistance, Math.hypot(deltaX, deltaY));
        
        const x = Math.cos(angle) * distance;
        const y = Math.sin(angle) * distance;
        
        this.joystickThumb.style.transform = `translate(${x}px, ${y}px)`;
        
        // Update movement keys based on angle and distance
        const threshold = maxDistance * 0.3;
        keys['w'] = deltaY < -threshold;
        keys['s'] = deltaY > threshold;
        keys['a'] = deltaX < -threshold;
        keys['d'] = deltaX > threshold;
    }
}

// Initialize on mobile
if ('ontouchstart' in window) {
    new MobileJoystick();
}
```

---

---

## 🏅 6. Post-Game Score Screen

### 6.1 Multi-Player Results Display

```typescript
class GameResultsManager {
    showPostGameResults(sessionResults: any) {
        const modal = document.getElementById('post-game-results-modal')!;
        const resultsContainer = document.getElementById('results-container')!;
        
        resultsContainer.innerHTML = '';
        
        // Add header
        const header = document.createElement('div');
        header.className = 'results-header';
        header.innerHTML = `
            <h2>🎮 Match Complete!</h2>
            <p>Wave ${sessionResults.wave} - Duration: ${this.formatDuration(sessionResults.duration)}</p>
        `;
        resultsContainer.appendChild(header);
        
        // Sort players by score
        const allPlayers = [
            ...sessionResults.players,
            ...sessionResults.bots
        ].sort((a, b) => b.score - a.score);
        
        // Display player cards
        allPlayers.forEach((player, index) => {
            const card = document.createElement('div');
            card.className = 'player-result-card';
            if (player.name === gameState.username) {
                card.classList.add('current-player');
            }
            if (player.isBot) {
                card.classList.add('bot-player');
            }
            
            const medal = index === 0 ? '🥇' : index === 1 ? '🥈' : index === 2 ? '🥉' : '';
            
            card.innerHTML = `
                <div class="result-rank">${medal || `#${index + 1}`}</div>
                <div class="result-player-info">
                    <h3>${player.name} ${player.isBot ? '🤖' : ''}</h3>
                    <div class="result-stats">
                        <span>⚔️ ${player.kills || 0} Kills</span>
                        <span>💀 ${player.deaths || 0} Deaths</span>
                        <span>🎯 ${player.score.toLocaleString()} Score</span>
                    </div>
                </div>
                ${!player.isBot && player.name !== gameState.username ? `
                    <button class="add-friend-btn" onclick="friendManager.sendFriendRequest('${player.name}')">
                        ➕ Add Friend
                    </button>
                ` : ''}
            `;
            
            resultsContainer.appendChild(card);
        });
        
        // Add action buttons
        const actions = document.createElement('div');
        actions.className = 'result-actions';
        actions.innerHTML = `
            <button class="btn-primary" onclick="gameResultsManager.playAgain()">
                🔄 Play Again
            </button>
            <button class="btn-secondary" onclick="gameResultsManager.returnToLobby()">
                🏠 Return to Lobby
            </button>
            <button class="btn-tertiary" onclick="gameResultsManager.shareResults()">
                📤 Share Results
            </button>
        `;
        resultsContainer.appendChild(actions);
        
        modal.classList.add('active');
        playSound('matchComplete');
    }
    
    formatDuration(ms: number): string {
        const minutes = Math.floor(ms / 60000);
        const seconds = Math.floor((ms % 60000) / 1000);
        return `${minutes}m ${seconds}s`;
    }
    
    playAgain() {
        document.getElementById('post-game-results-modal')!.classList.remove('active');
        multiplayerManager.joinQuickMatch();
    }
    
    returnToLobby() {
        document.getElementById('post-game-results-modal')!.classList.remove('active');
        quitGame();
    }
    
    shareResults() {
        // Share functionality
        const shareText = `I just scored ${score} points in Space Shooter! Can you beat that?`;
        if (navigator.share) {
            navigator.share({
                title: 'Space Shooter Results',
                text: shareText,
                url: window.location.href
            });
        } else {
            navigator.clipboard.writeText(shareText);
            showNotification('📋 Results copied to clipboard!');
        }
    }
}

const gameResultsManager = new GameResultsManager();
```

**Add HTML for Post-Game Screen:**

```html
<div id="post-game-results-modal" class="modal">
    <div class="modal-content results-modal-content">
        <div id="results-container"></div>
    </div>
</div>

<style>
.results-modal-content {
    max-width: 700px;
    max-height: 80vh;
    overflow-y: auto;
}

.results-header {
    text-align: center;
    padding: 20px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 10px 10px 0 0;
    margin: -20px -20px 20px -20px;
}

.results-header h2 {
    margin: 0 0 10px 0;
    color: white;
}

.player-result-card {
    display: flex;
    align-items: center;
    padding: 15px;
    margin-bottom: 10px;
    background: rgba(255, 255, 255, 0.05);
    border: 2px solid rgba(255, 255, 255, 0.1);
    border-radius: 10px;
    transition: all 0.3s;
}

.player-result-card:hover {
    background: rgba(255, 255, 255, 0.1);
    transform: translateX(5px);
}

.player-result-card.current-player {
    border-color: #00ffff;
    background: rgba(0, 255, 255, 0.1);
}

.player-result-card.bot-player {
    opacity: 0.7;
}

.result-rank {
    font-size: 32px;
    margin-right: 15px;
    min-width: 60px;
    text-align: center;
}

.result-player-info {
    flex: 1;
}

.result-player-info h3 {
    margin: 0 0 8px 0;
    color: cyan;
}

.result-stats {
    display: flex;
    gap: 15px;
    font-size: 14px;
    color: #aaa;
}

.add-friend-btn {
    padding: 8px 15px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    transition: all 0.3s;
}

.add-friend-btn:hover {
    transform: scale(1.05);
    box-shadow: 0 0 15px rgba(102, 126, 234, 0.5);
}

.result-actions {
    display: flex;
    gap: 10px;
    margin-top: 20px;
    justify-content: center;
}

.result-actions button {
    padding: 12px 24px;
    border: none;
    border-radius: 8px;
    font-size: 16px;
    cursor: pointer;
    transition: all 0.3s;
}

.btn-primary {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
}

.btn-secondary {
    background: rgba(255, 255, 255, 0.1);
    color: white;
}

.btn-tertiary {
    background: rgba(0, 255, 0, 0.2);
    color: #00ff00;
}
</style>
```

---

## 👥 7. Friend System

### 7.1 Friend Request Manager

```typescript
class FriendManager {
    friends: Set<string> = new Set();
    pendingRequests: Set<string> = new Set();
    
    async loadFriends() {
        try {
            const response = await fetch(`/api/friends?username=${gameState.username}`);
            if (response.ok) {
                const data = await response.json();
                this.friends = new Set(data.friends);
                this.pendingRequests = new Set(data.pending);
            }
        } catch (error) {
            console.error('Failed to load friends:', error);
        }
    }
    
    async sendFriendRequest(targetUsername: string) {
        if (this.friends.has(targetUsername)) {
            showNotification('✅ Already friends!');
            return;
        }
        
        try {
            const response = await fetch('/api/friends/request', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    from: gameState.username,
                    to: targetUsername
                })
            });
            
            if (response.ok) {
                this.pendingRequests.add(targetUsername);
                showNotification(`✉️ Friend request sent to ${targetUsername}`);
                playSound('uiClick');
            }
        } catch (error) {
            console.error('Failed to send friend request:', error);
            showNotification('❌ Failed to send friend request');
        }
    }
    
    async acceptFriendRequest(username: string) {
        try {
            const response = await fetch('/api/friends/accept', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    username: gameState.username,
                    friendUsername: username
                })
            });
            
            if (response.ok) {
                this.friends.add(username);
                showNotification(`✅ You are now friends with ${username}`);
                this.loadFriends();
            }
        } catch (error) {
            console.error('Failed to accept friend request:', error);
        }
    }
    
    displayFriendsList() {
        const container = document.getElementById('friends-list')!;
        container.innerHTML = '';
        
        if (this.friends.size === 0) {
            container.innerHTML = '<p class="no-friends">No friends yet. Add players from the lobby!</p>';
            return;
        }
        
        this.friends.forEach(friend => {
            const friendCard = document.createElement('div');
            friendCard.className = 'friend-card';
            friendCard.innerHTML = `
                <span class="friend-name">👤 ${friend}</span>
                <button onclick="multiplayerManager.inviteToGame('${friend}')">
                    📧 Invite
                </button>
                <button onclick="friendManager.removeFriend('${friend}')">
                    ❌
                </button>
            `;
            container.appendChild(friendCard);
        });
    }
    
    async removeFriend(username: string) {
        if (!confirm(`Remove ${username} from friends?`)) return;
        
        try {
            const response = await fetch('/api/friends/remove', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    username: gameState.username,
                    friendUsername: username
                })
            });
            
            if (response.ok) {
                this.friends.delete(username);
                showNotification(`Removed ${username} from friends`);
                this.displayFriendsList();
            }
        } catch (error) {
            console.error('Failed to remove friend:', error);
        }
    }
}

const friendManager = new FriendManager();
```

---

## 🌍 8. Multi-Language Support

### 8.1 Language Manager with Auto-Translation

```typescript
class LanguageManager {
    currentLanguage = 'en';
    supportedLanguages = {
        en: 'English',
        es: 'Español',
        fr: 'Français',
        de: 'Deutsch',
        pt: 'Português',
        ru: 'Русский',
        zh: '中文',
        ja: '日本語',
        ko: '한국어',
        ar: 'العربية'
    };
    
    translations: { [key: string]: { [key: string]: string } } = {
        en: {
            welcome: 'Welcome',
            play: 'Play',
            quit: 'Quit',
            score: 'Score',
            level: 'Level',
            kills: 'Kills',
            deaths: 'Deaths',
            wave: 'Wave',
            gameOver: 'Game Over',
            playAgain: 'Play Again',
            mainMenu: 'Main Menu',
            settings: 'Settings',
            language: 'Language',
            friends: 'Friends',
            addFriend: 'Add Friend',
            chat: 'Chat',
            lobby: 'Lobby',
            party: 'Party',
            match: 'Match',
            quickMatch: 'Quick Match',
            inviteFriend: 'Invite Friend',
            matchComplete: 'Match Complete'
        },
        es: {
            welcome: 'Bienvenido',
            play: 'Jugar',
            quit: 'Salir',
            score: 'Puntuación',
            level: 'Nivel',
            kills: 'Eliminaciones',
            deaths: 'Muertes',
            wave: 'Oleada',
            gameOver: 'Juego Terminado',
            playAgain: 'Jugar de Nuevo',
            mainMenu: 'Menú Principal',
            settings: 'Ajustes',
            language: 'Idioma',
            friends: 'Amigos',
            addFriend: 'Agregar Amigo',
            chat: 'Chat',
            lobby: 'Vestíbulo',
            party: 'Grupo',
            match: 'Partida',
            quickMatch: 'Partida Rápida',
            inviteFriend: 'Invitar Amigo',
            matchComplete: 'Partida Completa'
        },
        fr: {
            welcome: 'Bienvenue',
            play: 'Jouer',
            quit: 'Quitter',
            score: 'Score',
            level: 'Niveau',
            kills: 'Éliminations',
            deaths: 'Morts',
            wave: 'Vague',
            gameOver: 'Partie Terminée',
            playAgain: 'Rejouer',
            mainMenu: 'Menu Principal',
            settings: 'Paramètres',
            language: 'Langue',
            friends: 'Amis',
            addFriend: 'Ajouter un Ami',
            chat: 'Chat',
            lobby: 'Hall',
            party: 'Groupe',
            match: 'Match',
            quickMatch: 'Match Rapide',
            inviteFriend: 'Inviter un Ami',
            matchComplete: 'Match Terminé'
        }
        // Add more languages...
    };
    
    constructor() {
        this.loadLanguagePreference();
    }
    
    loadLanguagePreference() {
        const saved = localStorage.getItem('preferred_language');
        if (saved && this.supportedLanguages[saved]) {
            this.currentLanguage = saved;
        } else {
            // Auto-detect from browser
            const browserLang = navigator.language.split('-')[0];
            if (this.supportedLanguages[browserLang]) {
                this.currentLanguage = browserLang;
            }
        }
        this.applyLanguage();
    }
    
    setLanguage(lang: string) {
        if (!this.supportedLanguages[lang]) return;
        
        this.currentLanguage = lang;
        localStorage.setItem('preferred_language', lang);
        this.applyLanguage();
        showNotification(`Language changed to ${this.supportedLanguages[lang]}`);
    }
    
    applyLanguage() {
        // Update all elements with data-translate attribute
        document.querySelectorAll('[data-translate]').forEach(element => {
            const key = element.getAttribute('data-translate')!;
            const translation = this.translate(key);
            if (element.tagName === 'INPUT' || element.tagName === 'TEXTAREA') {
                (element as HTMLInputElement).placeholder = translation;
            } else {
                element.textContent = translation;
            }
        });
    }
    
    translate(key: string): string {
        return this.translations[this.currentLanguage]?.[key] || 
               this.translations['en'][key] || 
               key;
    }
    
    async translateChatMessage(message: string, targetLang: string): Promise<string> {
        // Use Google Translate API or similar
        try {
            const response = await fetch('/api/translate', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    text: message,
                    targetLang: targetLang
                })
            });
            
            if (response.ok) {
                const data = await response.json();
                return data.translatedText;
            }
        } catch (error) {
            console.error('Translation failed:', error);
        }
        
        return message; // Return original if translation fails
    }
    
    async detectLanguage(text: string): Promise<string> {
        try {
            const response = await fetch('/api/detect-language', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ text })
            });
            
            if (response.ok) {
                const data = await response.json();
                return data.language;
            }
        } catch (error) {
            console.error('Language detection failed:', error);
        }
        
        return 'en';
    }
}

const languageManager = new LanguageManager();
```

### 8.2 Enhanced Chat with Auto-Translation

```typescript
// Extend ChatManager with translation
class TranslatedChatManager extends ChatManager {
    autoTranslate = true;
    
    async displayMessage(from: string, message: string, channel: string) {
        const chatMessages = document.getElementById('chat-messages')!;
        
        // Detect message language
        const detectedLang = await languageManager.detectLanguage(message);
        let displayMessage = message;
        let translatedMessage = '';
        
        // Auto-translate if needed
        if (this.autoTranslate && detectedLang !== languageManager.currentLanguage) {
            translatedMessage = await languageManager.translateChatMessage(
                message,
                languageManager.currentLanguage
            );
        }
        
        const msgEl = document.createElement('div');
        msgEl.className = `chat-message channel-${channel}`;
        msgEl.innerHTML = `
            <span class="chat-time">${new Date().toLocaleTimeString()}</span>
            <span class="chat-channel">[${channel.toUpperCase()}]</span>
            <span class="chat-user">${from}:</span>
            <span class="chat-text">${translatedMessage || message}</span>
            ${translatedMessage ? `
                <button class="show-original-btn" onclick="this.nextElementSibling.style.display='block'; this.style.display='none'">
                    🌐 Original
                </button>
                <div class="original-text" style="display:none; font-size:0.9em; color:#888; margin-top:5px;">
                    Original (${detectedLang}): ${message}
                </div>
            ` : ''}
            <button class="chat-mute" onclick="chatManager.mutePlayer('${from}')">🔇</button>
        `;
        chatMessages.appendChild(msgEl);
        chatMessages.scrollTop = chatMessages.scrollHeight;
        
        // Keep only last 100 messages
        while (chatMessages.children.length > 100) {
            chatMessages.removeChild(chatMessages.firstChild!);
        }
    }
    
    toggleAutoTranslate() {
        this.autoTranslate = !this.autoTranslate;
        const btn = document.getElementById('auto-translate-toggle')!;
        btn.textContent = this.autoTranslate ? '🌐 Auto-Translate: ON' : '🌐 Auto-Translate: OFF';
        showNotification(this.autoTranslate ? 'Auto-translate enabled' : 'Auto-translate disabled');
    }
}

// Replace the chatManager instance
const chatManager = new TranslatedChatManager();
```

**Add Translation API Endpoint (`api/translate.js`):**

```javascript
export default async function handler(req, res) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    
    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }
    
    if (req.method === 'POST') {
        const { text, targetLang } = req.body;
        
        try {
            // Use Google Cloud Translation API
            const translateAPIKey = process.env.GOOGLE_TRANSLATE_API_KEY;
            
            const response = await fetch(
                `https://translation.googleapis.com/language/translate/v2?key=${translateAPIKey}`,
                {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        q: text,
                        target: targetLang,
                        format: 'text'
                    })
                }
            );
            
            const data = await response.json();
            
            return res.status(200).json({
                translatedText: data.data.translations[0].translatedText,
                detectedSourceLanguage: data.data.translations[0].detectedSourceLanguage
            });
            
        } catch (error) {
            console.error('Translation error:', error);
            return res.status(500).json({ error: 'Translation failed' });
        }
    }
}
```

---

## 🚀 Implementation Checklist

- [ ] **Session Management**
  - [ ] Update server with GameSession class
  - [ ] Add quick match handler
  - [ ] Implement bot auto-fill system
  - [ ] Add session lobby UI
  - [ ] Test 3-player co-op

- [ ] **Communication**
  - [ ] Implement ChatManager class
  - [ ] Add channel switching
  - [ ] Implement mute/block features
  - [ ] Add anti-spam protection
  - [ ] Test all chat channels

- [ ] **Post-Game Results**
  - [ ] Create GameResultsManager class
  - [ ] Design post-game UI
  - [ ] Add friend request buttons
  - [ ] Implement share functionality
  - [ ] Test with multiple players

- [ ] **Friend System**
  - [ ] Create FriendManager class
  - [ ] Add friend request API
  - [ ] Implement friend list UI
  - [ ] Add invite functionality
  - [ ] Test friend requests

- [ ] **Multi-Language Support**
  - [ ] Create LanguageManager class
  - [ ] Add translation API
  - [ ] Implement auto-detection
  - [ ] Add language selector UI
  - [ ] Test all supported languages

- [ ] **Chat Translation**
  - [ ] Extend ChatManager with translation
  - [ ] Add Google Translate API integration
  - [ ] Implement language detection
  - [ ] Add auto-translate toggle
  - [ ] Test cross-language communication
