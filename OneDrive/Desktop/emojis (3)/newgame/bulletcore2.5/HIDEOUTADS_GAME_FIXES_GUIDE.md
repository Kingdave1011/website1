# HideoutAds.online Game Fixes & Enhancements Guide

## Overview
This guide covers fixes for maps, music, visuals, and the Wave 3 mobile bug in your space shooter game.

---

## 🗺️ Issue 1: Fix Broken Maps

### Current Problem:
All 20 maps are defined in MAP_CONFIG but they all look the same - only basic background color changes.

### Solution - Enhanced Map Visuals:

The code currently only changes background colors. Here's what needs to be enhanced in the `drawBackground()` function:

**Current Code (line ~2920):**
```typescript
function drawBackground() {
    const map = MAP_CONFIG[gameState.selectedMap];
    if (map && map.type === 'nebula') {
        const gradient = ctx.createLinearGradient(0, 0, 0, canvas.height);
        gradient.addColorStop(0, '#1a0d33');
        gradient.addColorStop(1, '#3c1a66');
        ctx.fillStyle = gradient;
    } else if (map && map.type === 'asteroids') {
         ctx.fillStyle = '#111118';
    }
    else {
        ctx.fillStyle = 'black';
    }
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    updateAndDraw(stars);
}
```

**Enhanced Solution - Add to index.tsx after the drawBackground function:**

```typescript
// Add visual variety to each map
function drawEnhancedBackground() {
    const map = MAP_CONFIG[gameState.selectedMap];
    const mapNum = gameState.selectedMap;
    
    // Different visual themes for different map ranges
    if (mapNum <= 7) {
        // Space theme - dark with stars
        ctx.fillStyle = 'black';
    } else if (mapNum <= 14) {
        // Nebula theme - colorful gradients
        const colors = [
            ['#1a0d33', '#3c1a66'], // Purple
            ['#0d1a33', '#1a3c66'], // Blue
            ['#330d1a', '#661a3c'], // Red
            ['#1a330d', '#3c661a'], // Green
            ['#33221a', '#66441a'], // Orange
            ['#1a2233', '#1a4466'], // Cyan
            ['#331a2d', '#661a5a']  // Magenta
        ];
        const colorIndex = (mapNum - 8) % colors.length;
        const gradient = ctx.createLinearGradient(0, 0, 0, canvas.height);
        gradient.addColorStop(0, colors[colorIndex][0]);
        gradient.addColorStop(1, colors[colorIndex][1]);
        ctx.fillStyle = gradient;
    } else {
        // Asteroid theme - darker tones
        const darkColors = ['#0a0a0a', '#111118', '#181820', '#1a1a22', '#14141c', '#1c1c28'];
        const colorIndex = (mapNum - 15) % darkColors.length;
        ctx.fillStyle = darkColors[colorIndex];
    }
    
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    // Add animated nebula effects for nebula maps
    if (mapNum > 7 && mapNum <= 14 && effectsEnabled) {
        ctx.save();
        ctx.globalAlpha = 0.1;
        const nebulaX = Math.sin(Date.now() / 5000) * 100;
        const nebulaY = Math.cos(Date.now() / 5000) * 100;
        const nebulaGradient = ctx.createRadialGradient(
            canvas.width/2 + nebulaX, canvas.height/2 + nebulaY, 0,
            canvas.width/2 + nebulaX, canvas.height/2 + nebulaY, canvas.width/2
        );
        nebulaGradient.addColorStop(0, '#ff00ff');
        nebulaGradient.addColorStop(1, 'transparent');
        ctx.fillStyle = nebulaGradient;
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctx.restore();
    }
    
    updateAndDraw(stars);
}
```

**Then replace the drawBackground() call in gameLoop() with drawEnhancedBackground()**

---

## 🎵 Issue 2: Add Background Music

### Current Problem:
Only placeholder audio assets exist. No actual music playing.

### Solution - Add Music System:

**Step 1: Create Simple Music Using Web Audio API**

Add this function after the `stopMusic()` function (around line 3150):

```typescript
function createBackgroundMusic() {
    if (!audioCtx) return;
    
    // Create a simple ambient space music using oscillators
    const oscillator1 = audioCtx.createOscillator();
    const oscillator2 = audioCtx.createOscillator();
    const oscillator3 = audioCtx.createOscillator();
    
    const gainNode1 = audioCtx.createGain();
    const gainNode2 = audioCtx.createGain();
    const gainNode3 = audioCtx.createGain();
    
    // Bass layer
    oscillator1.type = 'sine';
    oscillator1.frequency.value = 55; // A1
    gainNode1.gain.value = 0.3;
    
    // Mid layer
    oscillator2.type = 'triangle';
    oscillator2.frequency.value = 110; // A2
    gainNode2.gain.value = 0.2;
    
    // High layer with slow vibrato
    oscillator3.type = 'sine';
    oscillator3.frequency.value = 220; // A3
    gainNode3.gain.value = 0.15;
    
    // Add LFO for vibrato effect
    const lfo = audioCtx.createOscillator();
    const lfoGain = audioCtx.createGain();
    lfo.frequency.value = 0.5; // Slow vibrato
    lfoGain.gain.value = 3;
    
    lfo.connect(lfoGain);
    lfoGain.connect(oscillator3.frequency);
    
    // Connect everything
    oscillator1.connect(gainNode1);
    oscillator2.connect(gainNode2);
    oscillator3.connect(gainNode3);
    
    gainNode1.connect(musicGainNode);
    gainNode2.connect(musicGainNode);
    gainNode3.connect(musicGainNode);
    
    // Start all oscillators
    oscillator1.start();
    oscillator2.start();
    oscillator3.start();
    lfo.start();
    
    // Slowly modulate the frequency for variety
    setInterval(() => {
        if (gameRunning) {
            const randomFreq = 55 + Math.random() * 10;
            oscillator1.frequency.exponentialRampToValueAtTime(
                randomFreq, audioCtx.currentTime + 4
            );
        }
    }, 8000);
}
```

**Step 2: Update playMusic function (around line 3140):**

```typescript
function playMusic(sound: string) {
    if (!audioCtx) return;
    if (musicSource) return; // Already playing
    
    // Use generated music instead of audio file
    createBackgroundMusic();
}
```

**Alternative: Use Free Music**

For better music, you can download free space music from:
- OpenGameArt.org
- FreeSoundEffects.com
- YouTube Audio Library

Convert to base64 and add to SOUND_ASSETS.

---

## ✨ Issue 3: Improve Visual Quality

### Enhancements to Add:

**1. Better Particle Effects (replace Particle class ~line 2640):**

```typescript
class Particle {
    x: number;
    y: number;
    size: number;
    speedX: number;
    speedY: number;
    color: string;
    life: number;
    maxLife: number;
    glow: boolean;
    rotation: number;
    rotationSpeed: number;

    constructor(x: number, y: number, color: string, size = 5, speedX = 0, speedY = 0, glow = true) {
        this.x = x;
        this.y = y;
        this.size = Math.random() * size + 2;
        this.speedX = speedX === 0 ? Math.random() * 6 - 3 : speedX;
        this.speedY = speedY === 0 ? Math.random() * 6 - 3 : speedY;
        this.color = color;
        this.maxLife = Math.random() * 60 + 40;
        this.life = this.maxLife;
        this.glow = glow;
        this.rotation = Math.random() * Math.PI * 2;
        this.rotationSpeed = (Math.random() - 0.5) * 0.2;
    }
    
    draw() {
        ctx.save();
        ctx.globalAlpha = this.life / this.maxLife;
        ctx.translate(this.x, this.y);
        ctx.rotate(this.rotation);
        
        if (this.glow) {
            ctx.shadowBlur = 15;
            ctx.shadowColor = this.color;
        }
        
        // Draw as a small square instead of circle for variety
        ctx.fillStyle = this.color;
        ctx.fillRect(-this.size/2, -this.size/2, this.size, this.size);
        
        ctx.restore();
    }
    
    update() {
        this.x += this.speedX;
        this.y += this.speedY;
        this.life -= 2;
        this.rotation += this.rotationSpeed;
        // Add gravity effect
        this.speedY += 0.1;
    }
}
```

**2. Add Trail Effect to Player**

In Player.draw() method, add before drawing the ship:

```typescript
// Draw motion trail
if (effectsEnabled && this.thrusterParticles.length > 0) {
    ctx.save();
    ctx.globalAlpha = 0.3;
    ctx.strokeStyle = 'cyan';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(this.x, this.y);
    for (let i = this.thrusterParticles.length - 1; i >= 0; i--) {
        const p = this.thrusterParticles[i];
        ctx.lineTo(p.x, p.y);
    }
    ctx.stroke();
    ctx.restore();
}
```

**3. Add Screen Edge Glow Effect**

Add to gameLoop() before updateAndDraw calls:

```typescript
// Add edge glow effect
if (effectsEnabled && gameRunning) {
    ctx.save();
    // Top edge
    const topGradient = ctx.createLinearGradient(0, 0, 0, 50);
    topGradient.addColorStop(0, 'rgba(0, 255, 255, 0.1)');
    topGradient.addColorStop(1, 'transparent');
    ctx.fillStyle = topGradient;
    ctx.fillRect(0, 0, canvas.width, 50);
    
    // Bottom edge
    const bottomGradient = ctx.createLinearGradient(0, canvas.height - 50, 0, canvas.height);
    bottomGradient.addColorStop(0, 'transparent');
    bottomGradient.addColorStop(1, 'rgba(0, 255, 255, 0.1)');
    ctx.fillStyle = bottomGradient;
    ctx.fillRect(0, canvas.height - 50, canvas.width, 50);
    ctx.restore();
}
```

---

## 📱 Issue 4: Fix Wave 3 Mobile Bug (No Enemies Spawn)

### Problem:
Enemies not spawning on Wave 3 on mobile devices.

### Solution:

**Check the spawnEnemies() function (around line 3000):**

The current code looks okay, but add mobile-specific checks:

```typescript
function spawnEnemies() {
    // Cap enemy count for better performance
    const isMobile = 'ontouchstart' in window;
    const maxEnemies = isMobile ? 10 : MAX_ENEMIES; // Reduce for mobile
    const enemyCount = Math.min(5 + currentWave * 2, maxEnemies);
    
    console.log(`Spawning ${enemyCount} enemies for wave ${currentWave}`); // Debug log
    
    for (let i = 0; i < enemyCount; i++) {
        const x = Math.random() * (canvas.width - 50) + 25;
        const y = Math.random() * -canvas.height;
        let type: keyof typeof ENEMY_CONFIG = 'scout';
        
        // Ensure wave 3 spawns
        if (currentWave >= 3 && Math.random() > 0.7) type = 'brute';
        if (currentWave >= 4 && Math.random() > 0.6) type = 'bomber';
        
        const enemy = new Enemy(x, y, type);
        enemies.push(enemy);
    }
    
    console.log(`Total enemies spawned: ${enemies.length}`); // Debug log
}
```

**Also add a check in nextWave():**

```typescript
function nextWave() {
    currentWave++;
    updateWaveDisplay();
    showWaveNotification(`Wave ${currentWave}`);
    playSound('waveStart');
    
    console.log(`Starting wave ${currentWave}`); // Debug
    
    if (currentWave % BOSS_WAVE === 0) {
        spawnBoss();
    } else {
        // Clear any remaining enemies first
        enemies = enemies.filter(e => e.health > 0);
        spawnEnemies();
        
        // Fallback check - if no enemies spawned, spawn at least 5
        if (enemies.length === 0) {
            console.warn('No enemies spawned! Adding fallback enemies.');
            for (let i = 0; i < 5; i++) {
                enemies.push(new Enemy(
                    Math.random() * canvas.width,
                    Math.random() * -200,
                    'scout'
                ));
            }
        }
    }
}
```

---

## 🚀 Quick Implementation Steps

1. **Backup your current file**
2. **Open HideoutAdsWebsite/game/index.tsx**
3. **Apply each fix section by section**
4. **Test after each change**
5. **Build and deploy**: Run `npm run build` in the game directory

---

## 🧪 Testing Checklist

- [ ] All 20 maps show different visuals
- [ ] Background music plays during gameplay
- [ ] Enhanced particle effects visible
- [ ] Player ship has trail effect
- [ ] Wave 3 spawns enemies on mobile
- [ ] Wave 3 spawns enemies on desktop
- [ ] Game runs smoothly on mobile
- [ ] No console errors

---

## 📝 Additional Enhancements

**Add More Stars for Different Maps:**
```typescript
function initStars() {
    stars = [];
    const starCount = gameState.selectedMap > 14 ? STAR_COUNT * 2 : STAR_COUNT;
    for (let i = 0; i < starCount; i++) stars.push(new Star());
}
```

Call `initStars()` whenever map changes in populateMapSelector().

---

## 💡 Pro Tips

1. **Performance**: Reduce particle counts on mobile devices
2. **Music**: Consider adding different music for boss battles
3. **Maps**: Add unique hazards to each map type
4. **Mobile**: Test extensively on actual mobile devices, not just browser devtools

---

**Need Help?** Check the browser console (F12) for debug logs to troubleshoot any issues.
