# 🎃 Halloween Event: The Haunted Nebula

Complete implementation guide for the seasonal Halloween event level.

## 🗺️ Event Configuration

```typescript
// Add to your game configuration
interface HalloweenEventConfig {
    enabled: boolean;
    startDate: Date;
    endDate: Date;
    mapId: number;
    specialRewards: string[];
}

const HALLOWEEN_EVENT: HalloweenEventConfig = {
    enabled: true,
    startDate: new Date('2025-10-01'),
    endDate: new Date('2025-11-01'),
    mapId: 99, // Special event map ID
    specialRewards: ['pumpkin_skin', 'witch_skin', 'ghost_skin']
};

// Check if event is active
function isHalloweenEventActive(): boolean {
    const now = new Date();
    return HALLOWEEN_EVENT.enabled && 
           now >= HALLOWEEN_EVENT.startDate && 
           now <= HALLOWEEN_EVENT.endDate;
}
```

## 🎨 Visual Environment

### Haunted Nebula Background

```typescript
function drawHalloweenBackground() {
    // Dark purple/black gradient
    const gradient = ctx.createLinearGradient(0, 0, 0, canvas.height);
    gradient.addColorStop(0, '#1a0033');
    gradient.addColorStop(0.5, '#330066');
    gradient.addColorStop(1, '#0d001a');
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    // Add orange gas clouds
    drawGasClouds();
    
    // Add flickering lanterns
    drawLanterns();
    
    // Add ghostly silhouettes
    drawGhostlyShips();
}

function drawGasClouds() {
    const time = Date.now() * 0.0005;
    
    for (let i = 0; i < 5; i++) {
        const x = (Math.sin(time + i) * 200) + canvas.width / 2;
        const y = (Math.cos(time * 0.7 + i) * 150) + canvas.height / 2;
        const size = 150 + Math.sin(time + i) * 50;
        
        const cloudGradient = ctx.createRadialGradient(x, y, 0, x, y, size);
        cloudGradient.addColorStop(0, 'rgba(255, 140, 0, 0.3)');
        cloudGradient.addColorStop(0.5, 'rgba(255, 69, 0, 0.15)');
        cloudGradient.addColorStop(1, 'rgba(255, 140, 0, 0)');
        
        ctx.fillStyle = cloudGradient;
        ctx.beginPath();
        ctx.arc(x, y, size, 0, Math.PI * 2);
        ctx.fill();
    }
}

function drawLanterns() {
    const time = Date.now() * 0.003;
    const lanternPositions = [
        { x: 100, y: 150 },
        { x: canvas.width - 100, y: 200 },
        { x: canvas.width / 2, y: 100 }
    ];
    
    lanternPositions.forEach((pos, i) => {
        const flicker = 0.7 + Math.sin(time * 3 + i) * 0.3;
        const glow = ctx.createRadialGradient(pos.x, pos.y, 0, pos.x, pos.y, 30);
        glow.addColorStop(0, `rgba(255, 165, 0, ${flicker})`);
        glow.addColorStop(1, 'rgba(255, 165, 0, 0)');
        
        ctx.fillStyle = glow;
        ctx.beginPath();
        ctx.arc(pos.x, pos.y, 30, 0, Math.PI * 2);
        ctx.fill();
    });
}

function drawGhostlyShips() {
    const time = Date.now() * 0.0002;
    
    ctx.save();
    ctx.globalAlpha = 0.1 + Math.sin(time) * 0.05;
    ctx.fillStyle = '#8888ff';
    
    // Draw simple derelict ship silhouettes
    ctx.fillRect(50, 300, 80, 20);
    ctx.fillRect(canvas.width - 130, 400, 60, 15);
    
    ctx.restore();
}
```

## 👾 Halloween Enemies

### Pumpkin Drone

```typescript
class PumpkinDrone extends Enemy {
    glowPhase: number;
    
    constructor(x: number, y: number) {
        super(x, y, 'scout');
        this.glowPhase = Math.random() * Math.PI * 2;
        this.speed = 2.5;
        this.health = 1;
        this.config.points = 15;
    }
    
    draw() {
        const glow = 0.5 + Math.sin(this.glowPhase + Date.now() * 0.005) * 0.5;
        
        // Pumpkin body
        ctx.save();
        ctx.shadowBlur = 20;
        ctx.shadowColor = `rgba(255, 140, 0, ${glow})`;
        ctx.fillStyle = '#ff8c00';
        ctx.beginPath();
        ctx.ellipse(this.x, this.y, 20, 18, 0, 0, Math.PI * 2);
        ctx.fill();
        
        // Jack-o-lantern face
        ctx.fillStyle = '#000';
        // Eyes
        ctx.beginPath();
        ctx.arc(this.x - 8, this.y - 5, 3, 0, Math.PI * 2);
        ctx.arc(this.x + 8, this.y - 5, 3, 0, Math.PI * 2);
        ctx.fill();
        // Mouth
        ctx.beginPath();
        ctx.moveTo(this.x - 10, this.y + 5);
        ctx.quadraticCurveTo(this.x, this.y + 10, this.x + 10, this.y + 5);
        ctx.stroke();
        
        ctx.restore();
    }
    
    explode() {
        // Candy-colored particle explosion
        const colors = ['#ff6b6b', '#4ecdc4', '#ffe66d', '#a8e6cf', '#ffd3b6'];
        for (let i = 0; i < 20; i++) {
            const color = colors[Math.floor(Math.random() * colors.length)];
            particles.push(new Particle(this.x, this.y, color, 4));
        }
    }
}
```

### Ghost Ship

```typescript
class GhostShip extends Enemy {
    phaseTimer: number;
    isVisible: boolean;
    opacity: number;
    
    constructor(x: number, y: number) {
        super(x, y, 'brute');
        this.phaseTimer = 0;
        this.isVisible = true;
        this.opacity = 1;
        this.speed = 1.5;
        this.health = 3;
        this.config.points = 30;
    }
    
    update() {
        super.update();
        
        this.phaseTimer += 1000 / 60;
        
        // Phase in/out every 3 seconds
        if (this.phaseTimer > 3000) {
            this.isVisible = !this.isVisible;
            this.phaseTimer = 0;
        }
        
        // Smooth opacity transition
        const targetOpacity = this.isVisible ? 1 : 0.2;
        this.opacity += (targetOpacity - this.opacity) * 0.1;
    }
    
    draw() {
        ctx.save();
        ctx.globalAlpha = this.opacity;
        ctx.shadowBlur = 15;
        ctx.shadowColor = '#8888ff';
        
        // Ghost ship body
        ctx.fillStyle = 'rgba(136, 136, 255, 0.6)';
        ctx.beginPath();
        ctx.moveTo(this.x, this.y - 20);
        ctx.lineTo(this.x + 15, this.y + 20);
        ctx.lineTo(this.x - 15, this.y + 20);
        ctx.closePath();
        ctx.fill();
        
        // Ethereal glow
        const glow = ctx.createRadialGradient(this.x, this.y, 0, this.x, this.y, 40);
        glow.addColorStop(0, 'rgba(136, 136, 255, 0.3)');
        glow.addColorStop(1, 'rgba(136, 136, 255, 0)');
        ctx.fillStyle = glow;
        ctx.beginPath();
        ctx.arc(this.x, this.y, 40, 0, Math.PI * 2);
        ctx.fill();
        
        ctx.restore();
    }
}
```

### Witch Boss

```typescript
class WitchBoss extends Boss {
    cauldronRotation: number;
    minionSpawnPhase: number;
    
    constructor() {
        super();
        this.width = 250;
        this.height = 120;
        this.maxHealth = 300;
        this.health = this.maxHealth;
        this.cauldronRotation = 0;
        this.minionSpawnPhase = 0;
    }
    
    draw() {
        ctx.save();
        
        // Cauldron body
        ctx.fillStyle = '#4a0080';
        ctx.strokeStyle = '#8000ff';
        ctx.lineWidth = 4;
        ctx.beginPath();
        ctx.ellipse(this.x, this.y, 100, 50, 0, 0, Math.PI * 2);
        ctx.fill();
        ctx.stroke();
        
        // Green plasma glow
        const plasmaGlow = ctx.createRadialGradient(this.x, this.y - 20, 0, this.x, this.y - 20, 60);
        plasmaGlow.addColorStop(0, 'rgba(0, 255, 0, 0.6)');
        plasmaGlow.addColorStop(1, 'rgba(0, 255, 0, 0)');
        ctx.fillStyle = plasmaGlow;
        ctx.beginPath();
        ctx.arc(this.x, this.y - 20, 60, 0, Math.PI * 2);
        ctx.fill();
        
        // Bubbling effects
        this.cauldronRotation += 0.05;
        for (let i = 0; i < 5; i++) {
            const bubbleX = this.x + Math.cos(this.cauldronRotation + i) * 40;
            const bubbleY = this.y - 10 + Math.sin(this.cauldronRotation * 2 + i) * 10;
            ctx.fillStyle = 'rgba(0, 255, 0, 0.4)';
            ctx.beginPath();
            ctx.arc(bubbleX, bubbleY, 5, 0, Math.PI * 2);
            ctx.fill();
        }
        
        ctx.restore();
    }
    
    update() {
        super.update();
        
        this.minionSpawnPhase += 1000 / 60;
        
        // Summon pumpkin drones every 4 seconds
        if (this.minionSpawnPhase > 4000) {
            this.summonMinions();
            this.minionSpawnPhase = 0;
        }
    }
    
    summonMinions() {
        for (let i = 0; i < 3; i++) {
            const angle = (i / 3) * Math.PI * 2;
            const x = this.x + Math.cos(angle) * 100;
            const y = this.y + Math.sin(angle) * 100;
            enemies.push(new PumpkinDrone(x, y));
        }
        playSound('witchSummon');
    }
    
    phase2Attack() {
        super.phase2Attack();
        
        // Green plasma spread shot
        if (Date.now() - this.lastFireTime > 800) {
            this.plasmaSpread();
            this.lastFireTime = Date.now();
        }
    }
    
    plasmaSpread() {
        for (let i = 0; i < 7; i++) {
            const angle = (i / 6) * 60 - 30;
            const proj = new EnemyProjectile(this.x, this.y + this.height / 2);
            proj.speedX = Math.sin(angle * Math.PI / 180) * 4;
            proj.speedY = Math.cos(angle * Math.PI / 180) * 4;
            // Green plasma color
            (proj as any).color = '#00ff00';
            enemyProjectiles.push(proj);
        }
        playSound('plasmaShot');
    }
}
```

## 🎁 Halloween Power-Ups

```typescript
// Add to POWERUP_CONFIG
const HALLOWEEN_POWERUPS = {
    candyCornBlaster: {
        type: 'candyCornBlaster' as const,
        svg: `<svg width="30" height="30" viewBox="0 0 24 24"><path fill="#ff8c00" d="M12 2 L8 12 L12 22 L16 12 Z"/><path fill="#ffff00" d="M12 8 L10 12 L12 16 L14 12 Z"/></svg>`,
        color: '#ff8c00'
    },
    pumpkinShield: {
        type: 'pumpkinShield' as const,
        svg: `<svg width="30" height="30" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10" fill="none" stroke="#ff8c00" stroke-width="3"/><path d="M8 10 L10 10 M14 10 L16 10 M8 15 Q12 18 16 15" stroke="#000" stroke-width="2"/></svg>`,
        color: '#ff8c00'
    }
};

// Power-up application
function applyHalloweenPowerUp(type: string) {
    if (type === 'candyCornBlaster') {
        player.candyCornBlasterActive = true;
        player.candyCornBlasterTimer = 15000;
        showNotification('🌽 Candy Corn Blaster Activated!');
    } else if (type === 'pumpkinShield') {
        player.pumpkinShieldActive = true;
        player.pumpkinShieldHits = 3;
        showNotification('🎃 Pumpkin Shield Activated!');
    }
}

// Updated Player shoot method for Candy Corn Blaster
class Player {
    candyCornBlasterActive: boolean = false;
    candyCornBlasterTimer: number = 0;
    pumpkinShieldActive: boolean = false;
    pumpkinShieldHits: number = 0;
    
    shoot() {
        if (this.candyCornBlasterActive) {
            // Spread shot in candy corn pattern
            for (let i = -2; i <= 2; i++) {
                const proj = new Projectile(this.x + i * 15, this.y);
                proj.speedY = PROJECTILE_SPEED + Math.abs(i) * 0.5;
                // Candy corn colors
                (proj as any).color = i % 2 === 0 ? '#ff8c00' : '#ffff00';
                projectiles.push(proj);
            }
        } else {
            super.shoot();
        }
    }
    
    takeDamage() {
        if (this.pumpkinShieldActive) {
            this.pumpkinShieldHits--;
            createShieldImpact();
            if (this.pumpkinShieldHits <= 0) {
                this.pumpkinShieldActive = false;
                showNotification('Pumpkin Shield Broken!');
            }
            return;
        }
        super.takeDamage();
    }
}
```

## 🏆 Halloween Achievements

```typescript
const HALLOWEEN_ACHIEVEMENTS: Achievement[] = [
    {
        id: 'pumpkinSmasher',
        name: 'Pumpkin Smasher',
        description: 'Destroy 100 pumpkin drones',
        icon: '🎃',
        condition: (stats) => stats.pumpkinDronesDestroyed >= 100
    },
    {
        id: 'ghostbuster',
        name: 'Ghostbuster',
        description: 'Defeat 50 ghost ships',
        icon: '👻',
        condition: (stats) => stats.ghostShipsDestroyed >= 50
    },
    {
        id: 'witchHunter',
        name: 'Witch Hunter',
        description: 'Defeat the Halloween boss',
        icon: '🧙',
        condition: (stats) => stats.witchBossDefeated >= 1
    },
    {
        id: 'halloweenMaster',
        name: 'Halloween Master',
        description: 'Complete The Haunted Nebula on Nightmare difficulty',
        icon: '🏆',
        condition: (stats, level, wave, difficulty) => 
            stats.hauntedNebulaCompleted && difficulty === 'nightmare'
    }
];

// Add to GameState.stats
interface GameStats {
    // ... existing stats
    pumpkinDronesDestroyed: number;
    ghostShipsDestroyed: number;
    witchBossDefeated: number;
    hauntedNebulaCompleted: boolean;
}
```

## 🌫️ Fog of Fear Mechanic

```typescript
interface LanternBeacon {
    x: number;
    y: number;
    active: boolean;
    radius: number;
}

let lanternBeacons: LanternBeacon[] = [];
let fogOverlay: CanvasGradient;

function initFogOfFear() {
    // Create lantern beacons
    lanternBeacons = [
        { x: 200, y: 200, active: true, radius: 150 },
        { x: 600, y: 400, active: true, radius: 150 },
        { x: 400, y: 600, active: true, radius: 150 }
    ];
}

function drawFogOfFear() {
    ctx.save();
    
    // Dark fog base layer
    ctx.fillStyle = 'rgba(10, 0, 20, 0.8)';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    // Clear fog around active beacons
    ctx.globalCompositeOperation = 'destination-out';
    
    lanternBeacons.forEach(beacon => {
        if (beacon.active) {
            const beaconGlow = ctx.createRadialGradient(
                beacon.x, beacon.y, 0,
                beacon.x, beacon.y, beacon.radius
            );
            beaconGlow.addColorStop(0, 'rgba(255, 255, 255, 1)');
            beaconGlow.addColorStop(0.7, 'rgba(255, 255, 255, 0.5)');
            beaconGlow.addColorStop(1, 'rgba(255, 255, 255, 0)');
            
            ctx.fillStyle = beaconGlow;
            ctx.beginPath();
            ctx.arc(beacon.x, beacon.y, beacon.radius, 0, Math.PI * 2);
            ctx.fill();
        }
    });
    
    ctx.globalCompositeOperation = 'source-over';
    ctx.restore();
}

function checkBeaconCollisions() {
    projectiles.forEach(proj => {
        lanternBeacons.forEach(beacon => {
            if (beacon.active) {
                const dist = Math.hypot(proj.x - beacon.x, proj.y - beacon.y);
                if (dist < 20) {
                    beacon.active = false;
                    createExplosion(beacon.x, beacon.y, '#ffa500');
                    playSound('beaconDestroyed');
                }
            }
        });
    });
}
```

## 🎨 Halloween Skins

```typescript
const HALLOWEEN_SKINS = {
    ranger: [
        {
            id: 'jack_o_lantern',
            name: "Jack O'Lantern",
            color: '#ff8c00',
            glowColor: '#ff4500',
            unlockRequirement: 'Complete Halloween event'
        },
        {
            id: 'witch',
            name: 'Witch',
            color: '#8000ff',
            glowColor: '#00ff00',
            unlockRequirement: 'Defeat Witch Boss'
        },
        {
            id: 'ghost',
            name: 'Ghost',
            color: '#ffffff',
            glowColor: '#8888ff',
            unlockRequirement: 'Destroy 50 Ghost Ships'
        }
    ]
};
```

## 🎵 Halloween Audio

```typescript
// Add Halloween-specific sound effects
const HALLOWEEN_SOUNDS = {
    witchLaugh: 'data:audio/wav;base64,... (witch cackle)',
    ghostMoan: 'data:audio/wav;base64,... (ghostly moan)',
    pumpkinExplode: 'data:audio/wav;base64,... (pumpkin smash)',
    eerieAmbience: 'data:audio/wav;base64,... (spooky background)',
    beaconDestroyed: 'data:audio/wav;base64,... (lantern break)'
};
```

## 🚀 Integration Checklist

### Phase 1: Event Setup
- [ ] Add Halloween event configuration
- [ ] Implement event date checking
- [ ] Create event notification banner

### Phase 2: Environment
- [ ] Implement Haunted Nebula background
- [ ] Add orange gas cloud effects
- [ ] Create flickering lantern animations
- [ ] Add ghostly ship silhouettes

### Phase 3: Enemies
- [ ] Create Pumpkin Drone class
- [ ] Create Ghost Ship class
- [ ] Create Witch Boss class
- [ ] Add candy particle explosions

### Phase 4: Mechanics
- [ ] Implement Fog of Fear system
- [ ] Create lantern beacons
- [ ] Add Candy Corn Blaster power-up
- [ ] Add Pumpkin Shield power-up

### Phase 5: Rewards
- [ ] Add Halloween skins
- [ ] Implement Halloween achievements
- [ ] Track event-specific stats
- [ ] Create event leaderboard

### Phase 6: Polish
- [ ] Add Halloween music
- [ ] Add spooky sound effects
- [ ] Create event UI elements
- [ ] Add event completion rewards

---

## 🎃 Quick Start

1. **Enable the event** in your configuration
2. **Add Halloween enemies** to spawn pool
3. **Implement Fog of Fear** mechanic
4. **Add Halloween power-ups** to drop table
5. **Test and balance** difficulty

Your game will have an amazing seasonal event! 🎃👻🧙
