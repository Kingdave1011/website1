# Browser Game Enhancements Guide
## For hideoutads.online Space Shooter Game

This guide documents all the enhancements being added to your browser-based space shooter game.

## 🎵 Feature 1: Music Selection System

### Implementation Notes:
The game currently has a single music track. To add music selection:

1. **Add Multiple Music Tracks** - In `SOUND_ASSETS` object, add more music tracks:
```typescript
const SOUND_ASSETS: { [key: string]: string } = {
    laser: 'data:audio/wav;base64,...',
    explosion: 'data:audio/wav;base64,...',
    waveStart: 'data:audio/wav;base64,...',
    music1: 'data:audio/wav;base64,...',  // Action track
    music2: 'data:audio/wav;base64,...',  // Ambient track
    music3: 'data:audio/wav;base64,...',  // Boss battle track
};
```

2. **Add Music Selection to Settings** - In `GameState` type, add:
```typescript
settings: {
    sfxVolume: number;
    musicVolume: number;
    effectsEnabled: boolean;
    hudScale: number;
    hudPosition: 'top' | 'bottom';
    selectedMusic: number;  // NEW: Track which music is selected
}
```

3. **Music Selector UI** - Add to settings modal HTML:
```html
<div class="setting-group">
    <label>Music Track:</label>
    <select id="music-selector">
        <option value="1">Action Theme</option>
        <option value="2">Ambient Space</option>
        <option value="3">Boss Battle</option>
    </select>
</div>
```

4. **Update `playMusic()` function** to accept track number:
```typescript
function playMusic(trackNumber: number = 1) {
    if (!audioCtx || musicSource) return;
    const trackKey = `music${trackNumber}`;
    if (!decodedAudioBuffers[trackKey]) return;
    
    musicSource = audioCtx.createBufferSource();
    musicSource.buffer = decodedAudioBuffers[trackKey];
    musicSource.loop = true;
    musicSource.connect(musicGainNode);
    musicSource.start(0);
}
```

### Free Music Resources:
- **Incompetech.com** - Royalty-free music by Kevin MacLeod
- **FreePD.com** - Public domain music
- **OpenGameArt.org** - Game music and sound effects
- Convert to data URI using online tools or code

---

## ⚖️ Feature 2: Wave Difficulty Balancing

### Current Issue:
Waves may become too difficult too quickly, making the game frustrating.

### Solution - Progressive Difficulty Curve:

Update `spawnEnemies()` function with balanced difficulty:

```typescript
function spawnEnemies() {
    // Gentler difficulty curve
    const baseCount = 3;
    const waveMultiplier = Math.floor(currentWave / 3);  // Slower increase
    const enemyCount = Math.min(baseCount + waveMultiplier, 15);  // Cap at 15
    
    for (let i = 0; i < enemyCount; i++) {
        const x = Math.random() * (canvas.width - 50) + 25;
        const y = Math.random() * -canvas.height - 200;  // Start further away
        
        let type: keyof typeof ENEMY_CONFIG = 'scout';
        
        // Gradual enemy type introduction
        if (currentWave >= 3 && Math.random() > 0.8) type = 'brute';
        if (currentWave >= 5 && Math.random() > 0.85) type = 'bomber';
        if (currentWave >= 7 && Math.random() > 0.9) type = 'sniper';
        if (currentWave >= 10 && Math.random() > 0.95) type = 'kamikaze';
        
        enemies.push(new Enemy(x, y, type));
    }
}
```

### Wave Spawn Interval Adjustment:

```typescript
function nextWave() {
    currentWave++;
    updateWaveDisplay();
    showWaveNotification(`Wave ${currentWave}`);
    playSound('waveStart');
    
    // Give players breathing room between waves
    const waveDelay = currentWave < 5 ? 3000 : 2000;
    
    setTimeout(() => {
        if (currentWave % BOSS_WAVE === 0) {
            spawnBoss();
        } else {
            spawnEnemies();
        }
    }, waveDelay);
}
```

### Enemy Speed Balancing:

Reduce enemy speeds in `ENEMY_CONFIG`:
```typescript
const ENEMY_CONFIG = {
    scout: { speed: 2,  // Was 3
    brute: { speed: 0.8,  // Was 1
    bomber: { speed: 1.5,  // Was 2
    // etc...
}
```

---

## 🎮 Feature 3: New Upgrade System

### Additional Upgrades to Add:

1. **Shield Capacity** - More shield hits
2. **Bullet Damage** - Stronger projectiles
3. **Critical Hit Chance** - Chance for 2x damage
4. **Magnet Range** - Attract power-ups from further away
5. **Health Regeneration** - Slow HP recovery over time

### Update GameState:
```typescript
upgrades: {
    fireRate: number;
    speed: number;
    extraLife: number;
    shieldCapacity: number;     // NEW
    bulletDamage: number;       // NEW
    criticalChance: number;     // NEW
    magnetRange: number;        // NEW
    healthRegen: number;        // NEW
}
```

### Add to Upgrades Modal:
```html
<div class="upgrade-card">
    <h3>Shield Capacity</h3>
    <p>Increases maximum shield strength</p>
    <p id="shield-level">Lvl 0</p>
    <button id="upgrade-shield-button">Upgrade (100 Cr)</button>
</div>

<div class="upgrade-card">
    <h3>Bullet Damage</h3>
    <p>Increases projectile damage</p>
    <p id="damage-level">Lvl 0</p>
    <button id="upgrade-damage-button">Upgrade (75 Cr)</button>
</div>
```

### Populate Upgrades Function:
```typescript
function populateUpgrades() {
    const upgrades = gameState.upgrades;
    
    // Existing upgrades...
    
    // New upgrades
    const shieldCost = 100 * (upgrades.shieldCapacity + 1);
    const damageCost = 75 * (upgrades.bulletDamage + 1);
    
    updateUpgradeUI('shieldCapacity', upgrades.shieldCapacity, shieldCost);
    updateUpgradeUI('bulletDamage', upgrades.bulletDamage, damageCost);
    
    // Button handlers
    document.getElementById('upgrade-shield-button')!.onclick = () => {
        if(gameState.credits >= shieldCost) {
            gameState.credits -= shieldCost;
            upgrades.shieldCapacity++;
            player.maxShield = 3 + upgrades.shieldCapacity;
            saveGameState();
            populateUpgrades();
            updateUI();
        }
    };
}
```

---

## ⭐ Feature 4: Power-Ups Display on Screen

### Current State:
Power-ups exist in the code but may not be visible enough.

### Enhancement 1: HUD Power-Up Indicator

Add to game UI HTML:
```html
<div id="active-powerups" class="powerup-display">
    <!-- Active power-ups will be shown here -->
</div>
```

Add CSS:
```css
.powerup-display {
    position: fixed;
    top: 120px;
    right: 20px;
    display: flex;
    flex-direction: column;
    gap: 10px;
    z-index: 100;
}

.powerup-icon {
    width: 40px;
    height: 40px;
    background: rgba(0, 0, 0, 0.7);
    border: 2px solid cyan;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
    animation: pulse 1s infinite;
}

@keyframes pulse {
    0%, 100% { transform: scale(1); }
    50% { transform: scale(1.1); }
}

.powerup-timer {
    position: absolute;
    bottom: -15px;
    font-size: 10px;
    color: cyan;
}
```

### Enhancement 2: Track Active Power-Ups

Add to Player class:
```typescript
class Player {
    // ... existing properties
    activePowerUps: Array<{type: string, timeLeft: number}> = [];
    
    applyPowerUp(type: string) {
        // ... existing power-up logic
        
        // Track active power-up
        this.activePowerUps.push({
            type: type,
            timeLeft: 10000  // 10 seconds
        });
        
        updatePowerUpDisplay();
    }
    
    update() {
        // ... existing update logic
        
        // Update power-up timers
        this.activePowerUps = this.activePowerUps.filter(pu => {
            pu.timeLeft -= 1000/60;  // Subtract frame time
            return pu.timeLeft > 0;
        });
        
        updatePowerUpDisplay();
    }
}
```

### Enhancement 3: Display Function

```typescript
function updatePowerUpDisplay() {
    const container = document.getElementById('active-powerups')!;
    container.innerHTML = '';
    
    player.activePowerUps.forEach(powerUp => {
        const div = document.createElement('div');
        div.className = 'powerup-icon';
        
        // Get icon from POWERUP_CONFIG
        const config = Object.values(POWERUP_CONFIG).find(c => c.type === powerUp.type);
        if (config) {
            div.innerHTML = config.svg;
            div.style.borderColor = config.color;
        }
        
        // Add timer
        const timer = document.createElement('div');
        timer.className = 'powerup-timer';
        timer.innerText = Math.ceil(powerUp.timeLeft / 1000) + 's';
        div.appendChild(timer);
        
        container.appendChild(div);
    });
}
```

### Enhancement 4: Increase Power-Up Visibility

Update PowerUp class draw method:
```typescript
draw() {
    // Add pulsing glow effect
    ctx.save();
    ctx.shadowBlur = 20 + Math.sin(Date.now() / 200) * 10;
    ctx.shadowColor = this.config.color;
    
    // Draw rotating outer ring
    const rotation = (Date.now() / 1000) % (Math.PI * 2);
    ctx.translate(this.x, this.y);
    ctx.rotate(rotation);
    ctx.strokeStyle = this.config.color;
    ctx.lineWidth = 2;
    ctx.strokeRect(-this.size/2 - 5, -this.size/2 - 5, this.size + 10, this.size + 10);
    ctx.rotate(-rotation);
    ctx.translate(-this.x, -this.y);
    
    // Draw icon
    ctx.drawImage(this.img, this.x - this.size / 2, this.y - this.size / 2, this.size, this.size);
    ctx.restore();
}
```

---

## 🌐 Deployment to hideoutads.online

### Build Steps:

1. **Compile TypeScript:**
```bash
cd HideoutAdsWebsite/game
npm run build
```

2. **Test Locally:**
```bash
npm run dev
# Open browser to http://localhost:5173
```

3. **Deploy to Production:**
```bash
# If using Vercel (as indicated by vercel.json)
cd ../..
vercel deploy --prod

# Or manually copy dist/ contents to your web server
```

4. **Verify Deployment:**
- Visit https://hideoutads.online
- Check that game loads
- Test all new features
- Verify music plays
- Check power-up visibility
- Test wave difficulty balance

---

## 📝 Testing Checklist

- [ ] Music selector works and changes tracks
- [ ] Multiple music tracks play correctly
- [ ] Wave difficulty feels balanced (not too hard)
- [ ] New upgrades appear in upgrade menu
- [ ] New upgrades can be purchased
- [ ] New upgrade effects work correctly
- [ ] Power-ups are highly visible on screen
- [ ] Active power-ups show in HUD
- [ ] Power-up timers count down correctly
- [ ] Game loads on hideoutads.online
- [ ] All features work in production
- [ ] Performance is smooth (60 FPS)
- [ ] Mobile controls still work
- [ ] No console errors

---

## 🎨 Additional Polish Suggestions

1. **Particle Effects for Power-Ups:**
   - Add trail particles as power-ups fall
   - Add burst effect when collected

2. **Sound Feedback:**
   - Unique sound for each power-up type
   - Audio cue when power-up is about to expire

3. **Visual Feedback:**
   - Screen flash when collecting power-up
   - Player glow color matches active power-up

4. **Balance Tweaks:**
   - Test with real players
   - Adjust spawn rates based on feedback
   - Monitor wave completion times

---

## 📚 Resources for Assets

### Music:
- **Incompetech** (incompetech.com) - Kevin MacLeod's royalty-free music
- **FreePD** (freepd.com) - Public domain recordings
- **OpenGameArt** (opengameart.org) - Community contributions

### Sound Effects:
- **Freesound.org** - Community sound library
- **Zapsplat.com** - Free sound effects
- **Kenney.nl** - Game asset packs

### Converting to Data URI:
```javascript
// Example: Convert audio file to data URI
function audioToDataURI(audioFile) {
    return new Promise((resolve) => {
        const reader = new FileReader();
        reader.onload = (e) => resolve(e.target.result);
        reader.readAsDataURL(audioFile);
    });
}
```

---

## 🔧 Quick Implementation Priority

1. **HIGHEST**: Balance wave difficulty (immediate player experience improvement)
2. **HIGH**: Make power-ups more visible (improves gameplay clarity)  
3. **MEDIUM**: Add power-up HUD display (nice-to-have feature)
4. **MEDIUM**: Add new upgrades (extends gameplay depth)
5. **LOW**: Add music selection (polish feature)

---

## ✅ Summary

This guide provides complete instructions for:
- Adding music selection system
- Balancing wave difficulty
- Implementing new upgrades
- Making power-ups highly visible on screen
- Deploying to hideoutads.online

All changes maintain the existing code structure and are backwards compatible with saved game data.

**Next Steps:**
1. Implement wave balancing first (easiest, biggest impact)
2. Enhance power-up visibility second
3. Add new upgrades third
4. Add music selection last

Good luck with your game development! 🚀
