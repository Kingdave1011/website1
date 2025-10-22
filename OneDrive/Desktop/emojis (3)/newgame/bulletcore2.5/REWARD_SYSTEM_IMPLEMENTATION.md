# Reward System Implementation Guide

## Overview
Complete reward system with sign-up bonuses, playtime tracking, and daily/weekly rewards.

## 1. Sign-Up Rewards

### Implementation in `user-auth.html`:
Already implemented! When users sign up, they receive:
- **1000 Credits**
- **3x Shield Boosters**
- **3x Rapid Fire Boosters**  
- **2x Double Credits Boosters**
- **Ranger ship unlocked**
- **2 starter skins** (default + gold)

### Code Location:
```javascript
// In user-auth.html, line ~150
const starterBundle = {
    credits: 1000,
    boosters: {
        shield: 3,
        rapidFire: 3,
        doubleCredits: 2
    },
    ships: ['ranger'],
    skins: ['default', 'gold'],
    message: '🎁 Starter Bundle Received! 1000 Credits + Boosters!'
};
```

## 2. Playtime Rewards System

### localStorage Keys:
- `playtime_${username}` - Total minutes played
- `playtime_rewards_${username}` - Claimed reward tiers

### Reward Tiers:
```javascript
const playtimeRewards = {
    30: { credits: 500, boosters: { shield: 2 } },      // 30 minutes
    60: { credits: 1000, boosters: { rapidFire: 3 } },  // 1 hour
    120: { credits: 2000, ship: 'interceptor' },        // 2 hours
    300: { credits: 5000, skins: ['neon', 'violet'] },  // 5 hours
    600: { credits: 10000, ship: 'bruiser' },           // 10 hours
    1200: { credits: 25000, skins: ['all'] }            // 20 hours
};
```

### Implementation:
Add to game's main loop (HideoutAdsWebsite/game/index.tsx):
```typescript
// Track playtime
let sessionStart = Date.now();
setInterval(() => {
    const username = localStorage.getItem('space_shooter_auth');
    if (username) {
        const playtime = parseInt(localStorage.getItem(`playtime_${username}`) || '0');
        const newPlaytime = playtime + 1; // Add 1 minute
        localStorage.setItem(`playtime_${username}`, newPlaytime.toString());
        checkPlaytimeRewards(username, newPlaytime);
    }
}, 60000); // Every minute
```

## 3. Daily Rewards (Weekly Reset)

### System Design:
- 7 days of rewards
- Resets every Monday at midnight
- Streak bonus for consecutive logins

### Reward Schedule:
```javascript
const dailyRewards = {
    day1: { credits: 100, message: 'Day 1: 100 Credits!' },
    day2: { credits: 200, boosters: { shield: 1 } },
    day3: { credits: 300, boosters: { rapidFire: 1 } },
    day4: { credits: 500, boosters: { doubleCredits: 1 } },
    day5: { credits: 750, skin: 'special' },
    day6: { credits: 1000, boosters: { shield: 2, rapidFire: 2 } },
    day7: { credits: 2000, ship: 'elite', message: '🎉 Week Complete! Elite Ship Unlocked!' }
};
```

### localStorage Keys:
- `daily_reward_week_${username}` - Current week number
- `daily_reward_day_${username}` - Last claim day
- `daily_reward_streak_${username}` - Consecutive weeks

### Implementation:
```javascript
function checkDailyReward(username) {
    const now = new Date();
    const weekNumber = getWeekNumber(now);
    const dayOfWeek = now.getDay(); // 0 = Sunday, 1 = Monday, etc.
    
    const lastWeek = localStorage.getItem(`daily_reward_week_${username}`);
    const lastDay = localStorage.getItem(`daily_reward_day_${username}`);
    
    // Reset on new week (Monday)
    if (lastWeek != weekNumber && dayOfWeek === 1) {
        localStorage.setItem(`daily_reward_week_${username}`, weekNumber);
        localStorage.setItem(`daily_reward_day_${username}`, '0');
    }
    
    // Check if user can claim today's reward
    if (lastDay != dayOfWeek) {
        const reward = dailyRewards[`day${dayOfWeek}`];
        grantReward(username, reward);
        localStorage.setItem(`daily_reward_day_${username}`, dayOfWeek);
    }
}

function getWeekNumber(date) {
    const firstDayOfYear = new Date(date.getFullYear(), 0, 1);
    const pastDaysOfYear = (date - firstDayOfYear) / 86400000;
    return Math.ceil((pastDaysOfYear + firstDayOfYear.getDay() + 1) / 7);
}
```

## 4. Server Capacity Upgrade (32 → 400 players)

### Update `matchmaking-server.cjs`:
```javascript
// Change MAX_PLAYERS constant
const MAX_PLAYERS_PER_MATCH = 400; // Increased from 32
const MAX_QUEUE_SIZE = 1000; // Increase queue

// Add performance optimizations
const config = {
    maxPlayers: 400,
    tickRate: 60, // Server updates per second
    regionServers: {
        'us-east': {
            maxPlayers: 400,
            instances: 1 // Can scale to multiple instances
        }
    }
};
```

### Optimization for 400 Players:
```javascript
// Use efficient data structures
const players = new Map(); // Instead of array
const rooms = new Map(); // Separate rooms if needed

// Batch updates every 100ms instead of per-message
let updateQueue = [];
setInterval(() => {
    if (updateQueue.length > 0) {
        broadcastBatch(updateQueue);
        updateQueue = [];
    }
}, 100);
```

## 5. Remove "Server Offline" Spam

### Update `multiplayer-lobby.html`:
```javascript
let lastOfflineMessage = 0;
const OFFLINE_MESSAGE_COOLDOWN = 10000; // 10 seconds

ws.onerror = () => {
    isOnline = false;
    const now = Date.now();
    if (now - lastOfflineMessage > OFFLINE_MESSAGE_COOLDOWN) {
        addSystemMessage('Connection lost. Reconnecting...');
        lastOfflineMessage = now;
    }
};

ws.onclose = () => {
    isOnline = false;
    // Only show message once, not repeatedly
    if (isOnline !== false) {
        setTimeout(connectWebSocket, 3000);
    }
};
```

## 6. Real-Time Player Count Updates

### Server-Side (matchmaking-server.cjs):
```javascript
let playerCount = 0;

wss.on('connection', (ws) => {
    playerCount++;
    broadcastPlayerCount();
    
    ws.on('close', () => {
        playerCount--;
        broadcastPlayerCount();
    });
});

function broadcastPlayerCount() {
    const message = JSON.stringify({
        type: 'playerCount',
        count: playerCount,
        region: 'us-east'
    });
    
    wss.clients.forEach(client => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(message);
        }
    });
}
```

### Client-Side (multiplayer-lobby.html):
Already implemented! The WebSocket listener handles `playerCount` messages and updates display in real-time.

## 7. Ensure Server Stays Online

### PM2 Configuration:
```bash
# Set aggressive restart policy
pm2 start matchmaking-server.cjs --name matchmaking-server --max-restarts 999 --min-uptime 1000

# Enable startup script
pm2 startup
pm2 save

# Monitor and auto-restart
pm2 set pm2:autodump true
pm2 set pm2:watch true
```

### Health Check Endpoint:
```javascript
// Add to matchmaking-server.cjs
app.get('/health', (req, res) => {
    res.json({
        status: 'online',
        players: playerCount,
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        maxPlayers: 400
    });
});
```

## 8. Update Multiplayer Lobby Display

### Change in `multiplayer-lobby.html`:
```javascript
// Update player limit display
document.getElementById('us-east-players').textContent = count + '/400';
```

## Implementation Checklist

- [x] Sign-up rewards (already working)
- [ ] Add playtime tracking to game
- [ ] Implement playtime reward system
- [ ] Create daily reward calendar
- [ ] Add weekly reset logic
- [ ] Update server capacity to 400 players
- [ ] Optimize server for high player count
- [ ] Reduce offline message spam
- [ ] Add real-time player count broadcasting
- [ ] Update UI to show /400 instead of /32
- [ ] Add health monitoring
- [ ] Ensure PM2 keeps server online 24/7

## Testing

1. **Sign-up Rewards**: Create new account → check localStorage
2. **Playtime**: Play for 30+ minutes → check rewards granted
3. **Daily Rewards**: Log in each day → verify reset on Monday
4. **Player Count**: Open multiple browser tabs → verify count updates
5. **Capacity**: Stress test with 100+ concurrent connections
6. **Uptime**: Monitor with `pm2 monit` for 24 hours

## Performance Considerations

For 400 players:
- Use WebSocket message batching
- Implement regional sharding if needed
- Cache frequently accessed data
- Use efficient data structures (Map over Array)
- Limit broadcast frequency (10 updates/sec max)
- Add player instance distribution across multiple servers if lag occurs

## Next Steps

1. Implement playtime tracking first
2. Add daily reward calendar UI
3. Update server capacity settings
4. Optimize WebSocket message handling
5. Remove offline message spam
6. Test with increasing player counts (50, 100, 200, 400)
7. Monitor server performance and optimize as needed
