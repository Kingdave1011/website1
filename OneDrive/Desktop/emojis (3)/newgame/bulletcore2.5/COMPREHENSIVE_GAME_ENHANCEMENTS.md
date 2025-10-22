# Comprehensive Game Enhancements Plan

## Current Status
✅ Matchmaking server created and running on PM2 (port 3001)
✅ Stuck spacebar bug fixed (window blur event)
✅ Changes pushed to GitHub

## Priority Enhancements to Implement

### 1. Better "Pew" Laser Sound (Web Audio API)
```typescript
function generatePewSound() {
    if (!audioCtx) return;
    
    const oscillator = audioCtx.createOscillator();
    const gainNode = audioCtx.createGain();
    
    oscillator.connect(gainNode);
    gainNode.connect(sfxGainNode);
    
    // Create "pew" effect with frequency sweep
    oscillator.frequency.setValueAtTime(800, audioCtx.currentTime);
    oscillator.frequency.exponentialRampToValueAtTime(200, audioCtx.currentTime + 0.1);
    
    // Volume envelope
    gainNode.gain.setValueAtTime(0.3, audioCtx.currentTime);
    gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.1);
    
    oscillator.start(audioCtx.currentTime);
    oscillator.stop(audioCtx.currentTime + 0.1);
}

// Replace playSound('laser') calls with:
playSound('laser'); // Will use generated sound instead of base64
```

### 2. Additional Ships (5 New Ships)
```typescript
const NEW_SHIPS = {
    viper: {
        name: 'Viper',
        svg: `<svg viewBox="0 0 60 60"><path d="M30 5 L50 55 L30 45 L10 55 Z M15 25 L5 35 M45 25 L55 35" stroke="lime" stroke-width="2" fill="none"/></svg>`,
        speed: 6,
        unlockLevel: 3,
        specialAbility: 'Dodge Roll'
    },
    titan: {
        name: 'Titan',
        svg: `<svg viewBox="0 0 70 60"><rect x="10" y="15" width="50" height="35" stroke="orange" stroke-width="3" fill="none"/><path d="M25 10 L35 10 L35 0 M25 50 L35 50 L35 60" stroke="orange" stroke-width="2"/></svg>`,
        speed: 3,
        unlockLevel: 7,
        specialAbility: 'Heavy Armor'
    },
    phantom: {
        name: 'Phantom',
        svg: `<svg viewBox="0 0 55 55"><path d="M27.5 0 L50 30 L27.5 25 L5 30 Z" stroke="purple" stroke-width="2" fill="none" stroke-dasharray="5,5"/></svg>`,
        speed: 8,
        unlockLevel: 12,
        specialAbility: 'Stealth Mode'
    },
    sentinel: {
        name: 'Sentinel',
        svg: `<svg viewBox="0 0 65 60"><circle cx="32.5" cy="30" r="25" stroke="blue" stroke-width="2" fill="none"/><path d="M32.5 5 V25 M32.5 35 V55 M7.5 30 H27.5 M37.5 30 H57.5" stroke="blue" stroke-width="2"/></svg>`,
        speed: 5,
        unlockLevel: 15,
        specialAbility: 'Auto-Turret'
    },
    nova: {
        name: 'Nova',
        svg: `<svg viewBox="0 0 60 60"><path d="M30 0 L45 20 L60 30 L45 40 L30 60 L15 40 L0 30 L15 20 Z" stroke="gold" stroke-width="2" fill="none"/></svg>`,
        speed: 6.5,
        unlockLevel: 20,
        specialAbility: 'Energy Burst'
    }
};
```

### 3. Map Background Images
```typescript
const MAP_BACKGROUNDS = {
    asteroidField: {
        drawBackground: () => {
            // Dark space
            ctx.fillStyle = '#0a0a0f';
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            
            // Draw asteroids
            drawAsteroids();
            
            // Dust particles
            drawSpaceDust('#8b7355');
        }
    },
    nebula: {
        drawBackground: () => {
            // Purple nebula gradient
            const gradient = ctx.createRadialGradient(
                canvas.width/2, canvas.height/2, 0,
                canvas.width/2, canvas.height/2, canvas.width
            );
            gradient.addColorStop(0, '#4a0080');
            gradient.addColorStop(0.5, '#1a0033');
            gradient.addColorStop(1, '#000000');
            ctx.fillStyle = gradient;
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            
            // Nebula clouds
            drawNebulaClouds();
        }
    },
    spaceStation: {
        drawBackground: () => {
            // Draw distant space station
            ctx.fillStyle = '#000008';
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            
            // Station silhouette
            drawSpaceStation();
            
            // Distant planet
            drawPlanet(canvas.width * 0.8, canvas.height * 0.3, 100, '#4080ff');
        }
    }
};

function drawAsteroids() {
    // Static asteroids
    const asteroidCount = 15;
    for (let i = 0; i < asteroidCount; i++) {
        const x = (i * 123) % canvas.width;
        const y = (i * 456) % canvas.height;
        const size = 20 + (i * 7) % 40;
        
        ctx.fillStyle = '#5a5a5a';
        ctx.beginPath();
        // Irregular asteroid shape
        for (let j = 0; j < 8; j++) {
            const angle = (j / 8) * Math.PI * 2;
            const variance = 0.7 + Math.sin(i + j) * 0.3;
            const px = x + Math.cos(angle) * size * variance;
            const py = y + Math.sin(angle) * size * variance;
            if (j === 0) ctx.moveTo(px, py);
            else ctx.lineTo(px, py);
        }
        ctx.closePath();
        ctx.fill();
    }
}

function drawNebulaClouds() {
    for (let i = 0; i < 8; i++) {
        const x = (i * 234) % canvas.width;
        const y = (i * 567) % canvas.height;
        const size = 200 + (i * 50);
        
        const cloudGradient = ctx.createRadialGradient(x, y, 0, x, y, size);
        cloudGradient.addColorStop(0, `rgba(147, 51, 234, ${0.3 - i * 0.03})`);
        cloudGradient.addColorStop(0.5, `rgba(79, 70, 229, ${0.2 - i * 0.02})`);
        cloudGradient.addColorStop(1, 'rgba(79, 70, 229, 0)');
        
        ctx.fillStyle = cloudGradient;
        ctx.beginPath();
        ctx.arc(x, y, size, 0, Math.PI * 2);
        ctx.fill();
    }
}

function drawSpaceStation() {
    const stationX = canvas.width * 0.2;
    const stationY = canvas.height * 0.2;
    
    ctx.save();
    ctx.globalAlpha = 0.6;
    
    // Main structure
    ctx.fillStyle = '#4a4a5a';
    ctx.fillRect(stationX - 50, stationY, 100, 20);
    ctx.fillRect(stationX - 20, stationY - 30, 40, 30);
    
    // Lights
    ctx.fillStyle = '#ffff00';
    for (let i = 0; i < 5; i++) {
        ctx.fillRect(stationX - 40 + i * 20, stationY + 5, 3, 3);
    }
    
    ctx.restore();
}

function drawPlanet(x: number, y: number, radius: number, color: string) {
    const planetGradient = ctx.createRadialGradient(
        x - radius * 0.3, y - radius * 0.3, 0,
        x, y, radius
    );
    planetGradient.addColorStop(0, color);
    planetGradient.addColorStop(1, '#000000');
    
    ctx.fillStyle = planetGradient;
    ctx.beginPath();
    ctx.arc(x, y, radius, 0, Math.PI * 2);
    ctx.fill();
}

function drawSpaceDust(color: string) {
    ctx.fillStyle = color;
    for (let i = 0; i < 50; i++) {
        const x = (i * 789) % canvas.width;
        const y = (i * 234) % canvas.height;
        ctx.globalAlpha = 0.1 + (i % 10) * 0.05;
        ctx.fillRect(x, y, 1, 1);
    }
    ctx.globalAlpha = 1;
}
```

### 4. Halloween Event Integration
- Pumpkin Drone enemy (orange glowing enemy)
- Ghost Ship enemy (phases in/out)
- Witch Boss (cauldron-based, summons minions)
- Halloween power-ups (Candy Corn Blaster, Pumpkin Shield)
- Event active: October 1-31

### 5. Game Enjoyability Features
- **Wave Completion Bonuses**: 100 * waveNumber points
- **Combo System**: Consecutive kills = score multiplier
- **Perfect Wave Bonus**: No damage taken = 500 bonus
- **Speed Clear Bonus**: Complete wave quickly = extra credits

### 6. Leaderboard System
```typescript
// Backend API endpoint
app.post('/api/scores', async (req, res) => {
    const { username, score, wave } = req.body;
    // Save to leaderboard
    const leaderboard = JSON.parse(fs.readFileSync('leaderboard.json', 'utf8'));
    leaderboard.push({ username, score, wave, timestamp: Date.now() });
    leaderboard.sort((a, b) => b.score - a.score);
    leaderboard.splice(100); // Keep top 100
    fs.writeFileSync('leaderboard.json', JSON.stringify(leaderboard));
    res.json({ success: true });
});

// Game-over screen leaderboard display
async function showGameOverLeaderboard() {
    const response = await fetch('/api/scores');
    const leaderboard = await response.json();
    
    // Display top 10 with player ranking
    const leaderboardHTML = leaderboard.slice(0, 10).map((entry, i) => 
        `<div class="leaderboard-entry">
            <span>${i + 1}.</span>
            <span>${entry.username}</span>
            <span>Wave ${entry.wave}</span>
            <span>${entry.score} pts</span>
        </div>`
    ).join('');
    
    document.getElementById('game-over-leaderboard').innerHTML = leaderboardHTML;
}
```

### 7. UI/UX Polish
- Move anti-cheat indicator to bottom-right corner (smaller, 50% opacity)
- Add wave completion notification with score bonus
- Smoother particle effects
- Better color schemes for different map types

## Implementation Order
1. Generate "pew" sound (15 min)
2. Add 5 new ships (30 min)
3. Enhance map backgrounds (45 min)
4. Implement wave bonuses (15 min)
5. Add leaderboard API + display (30 min)
6. Halloween event (60 min)
7. UI polish (20 min)
8. Testing (30 min)
9. Push all to GitHub

**Total Estimated Time**: 4 hours

## Quick Wins (Can be done now)
- Better laser sound
- Wave completion bonuses
- Anti-cheat repositioning
- Additional ships

## Complex Features (Require more time)
- Full Halloween event
- Leaderboard backend integration
- Map background images
- Comprehensive visual overhaul
