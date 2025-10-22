// Game Constants
const PLAYER_SIZE = 40;
const PROJECTILE_SPEED = 7;
const PARTICLE_LIFESPAN = 50;
const STAR_COUNT = 300;
const PLAYER_INVINCIBILITY_FRAMES = 120; // 2 seconds at 60fps
const BASE_FIRE_rate = 20; // Lower is faster
const BASE_PLAYER_SPEED = 5;

// --- TYPE DEFINITIONS ---
interface ShipConfig {
    name: string;
    unlockLevel: number;
    speed: number;
    svg: string;
    skin?: {
        name: string;
        svg: string;
    };
}

interface PlayerState {
    level: number;
    xp: number;
    credits: number;
    upgrades: {
        fireRate: number;
        shipSpeed: number;
        extraLife: number;
    };
    lastClaimedDay: number | null;
    claimedRewards: number[];
    boosters: {
        shield: number;
        rapidFire: number;
        doubleCredits: number;
    };
    selectedShip: string;
    unlockedShips: string[];
    stats: {
        totalKills: number;
        totalBoostersUsed: number;
    };
    achievements: string[];
    selectedMap: number;
    unlockedMaps: number[];
    unlockedSkins: Record<string, string[]>;
    battlePassTier: number;
    claimedBattlePassTiers: number[];
    battlePassSeason: number;
    battlePassLastReset: string;
    password?: string;
}


// --- ASSET CONFIGURATIONS ---

const SHIP_CONFIG: Record<string, ShipConfig> = {
    ranger: {
        name: "Ranger",
        unlockLevel: 1,
        speed: 0,
        svg: `<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><g transform="rotate(90 50 50)"><path d="M50 10 L60 25 L90 35 L70 50 L90 65 L60 75 L50 90 L40 75 L10 65 L30 50 L10 35 L40 25 Z" fill="#2d3748" stroke="#718096" stroke-width="2"/><path d="M50 20 L58 30 L75 38 L65 50 L75 62 L58 70 L50 80 L42 70 L25 62 L35 50 L25 38 L42 30 Z" fill="#4a5568"/><path d="M50 45 L55 50 L50 55 L45 50 Z" fill="#63b3ed" stroke="#e2e8f0" stroke-width="1.5"/><path d="M45 25 L55 25 L52 35 L48 35 Z" fill="#e53e3e"/><path d="M45 65 L55 65 L52 75 L48 75 Z" fill="#e53e3e"/></g></svg>`,
        skin: {
            name: "Ranger Elite",
            svg: `<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><g transform="rotate(90 50 50)"><path d="M50 10 L60 25 L90 35 L70 50 L90 65 L60 75 L50 90 L40 75 L10 65 L30 50 L10 35 L40 25 Z" fill="#E5B80B" stroke="#FFD700" stroke-width="2"/><path d="M50 20 L58 30 L75 38 L65 50 L75 62 L58 70 L50 80 L42 70 L25 62 L35 50 L25 38 L42 30 Z" fill="#FFC300"/><path d="M50 45 L55 50 L50 55 L45 50 Z" fill="#FF5733" stroke="#e2e8f0" stroke-width="1.5"/><path d="M45 25 L55 25 L52 35 L48 35 Z" fill="#C70039"/><path d="M45 65 L55 65 L52 75 L48 75 Z" fill="#C70039"/></g></svg>`,
        }
    },
    interceptor: {
        name: "Interceptor",
        unlockLevel: 5,
        speed: 1,
        svg: `<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><g transform="rotate(90 50 50)"><path d="M50 5 L95 50 L50 95 L5 50 Z" fill="#2d3748" stroke="#718096" stroke-width="2"/><path d="M50 15 L85 50 L50 85 L15 50 Z" fill="#4a5568"/><path d="M50 30 L70 50 L50 70 L30 50 Z" fill="#4299e1"/><path d="M50 40 L60 50 L50 60 L40 50 Z" fill="#63b3ed" stroke="#e2e8f0" stroke-width="1.5"/></g></svg>`
    },
    bruiser: {
        name: "Bruiser",
        unlockLevel: 10,
        speed: -1,
        svg: `<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><g transform="rotate(90 50 50)"><path d="M50 20 L80 35 L90 60 L70 80 L30 80 L10 60 L20 35 Z" fill="#2d3748" stroke="#718096" stroke-width="2"/><path d="M50 30 L70 40 L80 60 L65 70 L35 70 L20 60 L30 40 Z" fill="#4a5568"/><path d="M40 45 L60 45 L65 55 L35 55 Z" fill="#e53e3e"/><rect x="45" y="55" width="10" height="10" fill="#f6e05e"/></g></svg>`
    }
};

const BATTLE_PASS_REWARDS = [
    { level: 2, type: 'credits', amount: 250, description: "250 Credits" },
    { level: 4, type: 'booster', booster: 'shield', amount: 2, description: "2x Shield Boosters" },
    { level: 6, type: 'credits', amount: 500, description: "500 Credits" },
    { level: 8, type: 'booster', booster: 'rapidFire', amount: 2, description: "2x Rapid Fire Boosters" },
    { level: 10, type: 'credits', amount: 1000, description: "1000 Credits" },
    { level: 12, type: 'booster', booster: 'doubleCredits', amount: 2, description: "2x Double Credits Boosters" },
    { level: 15, type: 'skin', ship: 'ranger', skinName: 'Ranger Elite', description: "Elite Skin for Ranger" },
];


const ENEMY_CONFIG = {
    scout: {
        type: 'scout' as const,
        svg: `<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><g transform="rotate(-90 50 50)"><path d="M50 10 L80 80 L50 60 L20 80 Z" fill="#4a1d1d" stroke="#e53e3e" stroke-width="2"/><path d="M50 20 L70 70 L50 55 L30 70 Z" fill="#9b2c2c"/><path d="M50 45 L55 55 L45 55 Z" fill="#fed7d7" /></g></svg>`,
        health: 1,
        speed: 2.5,
        score: 10,
    },
    brute: {
        type: 'brute' as const,
        svg: `<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><g transform="rotate(-90 50 50)"><path d="M50 15 L90 40 L90 85 L10 85 L10 40 Z" fill="#4a1d1d" stroke="#e53e3e" stroke-width="2"/><path d="M50 30 L80 50 L80 75 L20 75 L20 50 Z" fill="#9b2c2c"/><rect x="30" y="20" width="40" height="10" fill="#fed7d7"/><rect x="45" y="55" width="10" height="15" fill="#fed7d7"/></g></svg>`,
        health: 5,
        speed: 1,
        score: 50,
    },
    bomber: {
        type: 'bomber' as const,
        svg: `<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg"><g transform="rotate(-90 50 50)"><path d="M50 10 L70 20 L90 40 L90 60 L70 80 L50 90 L30 80 L10 60 L10 40 L30 20 Z" fill="#4a1d1d" stroke="#e53e3e" stroke-width="2"/><path d="M50 20 L65 28 L80 45 L80 55 L65 72 L50 80 L35 72 L20 55 L20 45 L35 28 Z" fill="#9b2c2c"/><circle cx="50" cy="50" r="10" fill="#fed7d7"/></g></svg>`,
        health: 3,
        speed: 1.5,
        score: 30,
        fireRate: 100, // Fires every 100 frames
    },
};

const MAP_CONFIG = [
    { name: "Orion's Belt", unlockLevel: 1, type: 'deep-space' },
    { name: "Eagle Nebula", unlockLevel: 2, type: 'nebula', color1: '#ff00ff', color2: '#00ffff' },
    { name: "Hale-Bopp", unlockLevel: 3, type: 'asteroid-field' },
    { name: "Andromeda", unlockLevel: 4, type: 'deep-space' },
    { name: "Pleiades Cluster", unlockLevel: 5, type: 'nebula', color1: '#00ff00', color2: '#0000ff' },
    { name: "Kuiper Belt", unlockLevel: 6, type: 'asteroid-field' },
    { name: "Whirlpool Galaxy", unlockLevel: 7, type: 'deep-space' },
    { name: "Tarantula Nebula", unlockLevel: 8, type: 'nebula', color1: '#ff4500', color2: '#ffd700' },
    { name: "Ceres Debris", unlockLevel: 9, type: 'asteroid-field' },
    { name: "Triangulum", unlockLevel: 10, type: 'deep-space' },
    { name: "Crab Nebula", unlockLevel: 11, type: 'nebula', color1: '#da70d6', color2: '#f0e68c' },
    { name: "Vesta Fragments", unlockLevel: 12, type: 'asteroid-field' },
    { name: "Centaurus A", unlockLevel: 13, type: 'deep-space' },
    { name: "Rosette Nebula", unlockLevel: 14, type: 'nebula', color1: '#ff1493', color2: '#1e90ff' },
    { name: "Pallas Remnants", unlockLevel: 15, type: 'asteroid-field' },
    { name: "Sombrero Galaxy", unlockLevel: 16, type: 'deep-space' },
    { name: "Veil Nebula", unlockLevel: 17, type: 'nebula', color1: '#8a2be2', color2: '#7fffd4' },
    { name: "Hygeia Field", unlockLevel: 18, type: 'asteroid-field' },
    { name: "Pinwheel Galaxy", unlockLevel: 19, type: 'deep-space' },
    { name: "Ghost Nebula", unlockLevel: 20, type: 'nebula', color1: '#f8f8ff', color2: '#4682b4' },
];

const DAILY_REWARDS = [
    { type: 'credits', amount: 100, icon: '💰' }, { type: 'credits', amount: 150, icon: '💰' }, { type: 'booster', booster: 'shield', amount: 1, icon: '🛡️' }, { type: 'credits', amount: 200, icon: '💰' }, { type: 'credits', amount: 250, icon: '💰' }, { type: 'booster', booster: 'rapidFire', amount: 1, icon: '⚡' }, { type: 'mystery', icon: '🎁' },
    { type: 'credits', amount: 300, icon: '💰' }, { type: 'credits', amount: 350, icon: '💰' }, { type: 'booster', booster: 'shield', amount: 2, icon: '🛡️' }, { type: 'credits', amount: 400, icon: '💰' }, { type: 'credits', amount: 450, icon: '💰' }, { type: 'booster', booster: 'doubleCredits', amount: 1, icon: '💰💰' }, { type: 'mystery', icon: '🎁' },
    { type: 'credits', amount: 500, icon: '💰' }, { type: 'credits', amount: 550, icon: '💰' }, { type: 'booster', booster: 'rapidFire', amount: 2, icon: '⚡' }, { type: 'credits', amount: 600, icon: '💰' }, { type: 'credits', amount: 650, icon: '💰' }, { type: 'booster', booster: 'shield', amount: 3, icon: '🛡️' }, { type: 'mystery', icon: '🎁' },
    { type: 'credits', amount: 700, icon: '💰' }, { type: 'credits', amount: 750, icon: '💰' }, { type: 'booster', booster: 'doubleCredits', amount: 2, icon: '💰💰' }, { type: 'credits', amount: 800, icon: '💰' }, { type: 'credits', amount: 900, icon: '💰' }, { type: 'booster', booster: 'rapidFire', amount: 3, icon: '⚡' }, { type: 'mystery', icon: '🎁' }
];

const ACHIEVEMENT_CONFIG: Record<string, { name: string, description: string, condition: (state: PlayerState, gameStats: any) => boolean }> = {
    firstKill: { name: "First Kill", description: "Destroy your first enemy.", condition: (state, gameStats) => gameStats.killsInRun >= 1 },
    wave5: { name: "Wave 5 Survivor", description: "Clear wave 5 in a single run.", condition: (state, gameStats) => gameStats.wave > 5 },
    centurion: { name: "Centurion", description: "Destroy 100 total enemies.", condition: (state) => state.stats.totalKills >= 100 },
    level10: { name: "Level 10", description: "Reach player level 10.", condition: (state) => state.level >= 10 },
    booster10: { name: "Booster Enthusiast", description: "Use 10 total boosters.", condition: (state) => state.stats.totalBoostersUsed >= 10 },
};

const SOUND_ASSETS: Record<string, string> = {
    laser: 'data:audio/wav;base64,UklGRl9vT19XQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YU9vT19BAIAAQAB//v8//f/5/9v/ev+z/4D/T/7//P/8//n/7//e/4D/f/5//P/8//f/5/+v/5//f/8//f/5/9v/5/8A',
    explosion: 'data:audio/wav;base64,UklGRigBAABXQVZFZm10IBAAAAABAAEARKwAAESsAAABAAgAZGF0YQQBAADp/9H/0v/S/9T/2f/e/+L/6v/w//b/8v/s/+b/4P/a/9T/z//H/8P/wf/A/7z/t/+y/6//qP+j/6H/oP+d/5v/mf+V/5P/k/+N/4v/iP+F/4L/f/98/3v/cv9y/3H/bv9s/2r/aP9o/2f/Zf9k/2L/Yv9h/2D/YP9f/17/Xf9b/1r/Wf9Y/1f/V/9U/1P/Uv9R/0//T/9O/03/S/9K/0n/R/9G/0T/Q/9C/0H/P/8+/z3/Pf88/zv/Ov85/zn/N/82/zX/M/8x/zD/L/8u/y3/K/8q/yn/J/8k/yP/Iv8h/yD/H/8d/x3/HP8a/xr/GP8W/xX/FP8T/xL/Ef8Q/w==',
    hit: 'data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEAwDMAAMAzAAABAAgAZGF0YQAAAAA=',
    uiClick: 'data:audio/wav;base64,UklGRl5vT19XQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YVtvT18AQABA//3/9f/p/9n/0v/B/7v/pP+R/4f/cv9l/1j/T/9F/z7/Mf8f/xf/D/8H/wX/Af8A/wD//P/5/+v/4//f/9X/0P/I/8D/uv+w/6X/mv+P/4v/g/9//3L/af9d/1b/Tf9J/0H/Pf80/yv/IP8Z/xL/C/8G/wH/AP/9//r/8//q/+H/3f/Y/9H/yP/D/7//tf+r/6T/m/+U/4v/iP+B/33/bv9n/1v/Vv9R/0r/Rf8/L/8v/yX/Gv8S/w3/B/8C/wH/AP8A',
    levelUp: 'data:audio/wav;base64,UklGRmYBAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YVIAAgD9/v4MAhEDFwAbACcANwA/AEcAUgBbAGIAawBzAHgAfQCIAJMAnACiAKgArACxALgAvQDGAMwA0wDYAN4A4gDoAO4A9AD8AQYBGgEdASQBKAEuATkBPgFBAUYBSwFOAVIBWAFbAV8BYwFqAXEBdQF6AYEBigGOAZMBnAGgAaYBrQGzAbkBwAHIAcsB0QHXAd8B5AHqAfIB+gIIAhUCGgIfAiYCLgI5Aj8CSAJQAlgCXgJmAmsCdQJ/AocCkQKeAqICqwK5AsIC0QLhAvEC+AMDAxsDIQMoAzADOQNBA0sDUQNXA2UDeAOMA5oDpwOxA8AD0APhBA8EGgQjBCsEMgQ/BFMERwRRBFoEYARvBH0EiQSTAJoAnwCpALEAuADBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
    achievement: 'data:audio/wav;base64,UklGRkIBAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YSwBAACH/3wAi/9yAIz/bgCM/24Ai/9yAIv/dACN/3MAjP9tAIv/cwCL/3MAi/9yAIv/cwCK/3MAiv9zAIr/dACK/3QAh/94AIX/fAB//4MAf/+DAH//gwB//4MAf/+DAH//gwB+/4QAgP+DAID/gwCA/4MAgP+DAID/gwCA/4MAgP+DAID/gwB//4MAfv+EAH3/hQB4/4kAd/+MAHD/lgBu/5wAbf+jAGv/qgBq/7MAaf+7AGj/wQBo/8gAaP/PAGj/1wBo/9sAaP/fAGj/5gBo/+oAaP/yAGj/9ABp/+wAaf/mAGn/5gBp/+YAZ//qAGX/8gBj//sAYf8CAWH/BgFg/woBXv8QAVv/FgFa/xoBWf8fAVj/JQFZ/ysBV/8zAVX/OgFR/0IBRv9KAUb/UgFG/1gBRv9hAUb/aQFG/3EBRv91AUb/fgFG/4cBRv+QAUb/nwFG/6sBRv+4AUb/xQFG/9MBRv+FAUb/kAFG/58BRv+rAUb/uAFG/8UBRv/TAUb/gwFG/5ABRv+fAUb/qwFG/7gBRv/FAUb/0wE=',
    music: ''
};

// FIX: Corrected syntax error in variable declaration. This was causing multiple parsing errors.
const gameContainer = document.getElementById('game-container')! as HTMLDivElement;
const canvas = document.getElementById('game-canvas')! as HTMLCanvasElement;
const ctx = canvas.getContext('2d')!;
const startScreen = document.getElementById('start-screen')!;
const gameOverScreen = document.getElementById('game-over-screen')!;
const hud = document.getElementById('hud')!;
const scoreEl = document.getElementById('score')!;
const finalScoreEl = document.getElementById('final-score')!;
const livesEl = document.getElementById('lives')!;
const levelEl = document.getElementById('level')!;
const xpBar = document.getElementById('xp-bar')! as HTMLDivElement;
const creditsEl = document.getElementById('credits')!;
const waveEl = document.getElementById('wave')!;
const levelUpNotification = document.getElementById('level-up-notification')!;
const waveNotification = document.getElementById('wave-notification')!;

// --- GAME STATE ---
let player: Player;
let projectiles: Projectile[] = [];
let enemies: Enemy[] = [];
let particles: Particle[] = [];
let stars: Star[] = [];
// FIX: 'EnemyProjectile' is a value, not a type. Use the 'Projectile' type directly.
let enemyProjectiles: Projectile[] = [];
let shockwaves: Shockwave[] = [];

let score = 0;
let animationId: number;
let keys: { [key: string]: boolean } = {};
let isGameOver = false;
let effectsEnabled = true;
let sfxVolume = 0.5;
let musicVolume = 0.2;
let gameHasStarted = false;
let wave = 1;
let waveCooldown = 180; // 3 seconds
let currentWaveEnemies = 0;
let totalWaveEnemies = 0;

let gameState: PlayerState;
let allPlayerStates: Record<string, PlayerState> = {};
let currentUsername: string | null = null;
let loggedInRole: 'guest' | 'player' | 'admin' = 'guest';

let activeBooster: 'shield' | 'rapidFire' | 'doubleCredits' | null = null;
let isShieldActive = false;

let mouse = { x: 0, y: 0 };
let currentMapIndex = 0;
let menuAnimationId: number;
let fakePlayerCount = 127;
let chatInterval: number;
let audioContext: AudioContext;
let musicSource: AudioBufferSourceNode | null = null;

// --- GAME CLASSES ---

class Player {
    x: number;
    y: number;
    size: number;
    speed: number;
    fireRate: number;
    fireCooldown: number;
    lives: number;
    invincibilityFrames: number;
    shipSvg: string;
    thrusterParticles: Particle[];

    constructor() {
        this.x = canvas.width / 2;
        this.y = canvas.height - 60;
        this.size = PLAYER_SIZE;
        this.fireCooldown = 0;
        this.invincibilityFrames = 0;
        this.thrusterParticles = [];

        this.resetStats();
        this.shipSvg = SHIP_CONFIG[gameState.selectedShip]?.svg || SHIP_CONFIG.ranger.svg;
    }

    resetStats() {
        const ship = SHIP_CONFIG[gameState.selectedShip];
        this.speed = BASE_PLAYER_SPEED + ship.speed + gameState.upgrades.shipSpeed;
        this.fireRate = BASE_FIRE_rate - (gameState.upgrades.fireRate * 2);
        this.lives = 3 + gameState.upgrades.extraLife;
        this.x = canvas.width / 2;
        this.y = canvas.height - 60;

        if (activeBooster === 'rapidFire') {
            this.fireRate = 5;
        }
        isShieldActive = activeBooster === 'shield';
    }
    
    updateShipSVG() {
        const shipConf = SHIP_CONFIG[gameState.selectedShip];
        if (!shipConf) return;

        const selectedSkinName = gameState.unlockedSkins[gameState.selectedShip]?.find(skinName => skinName === shipConf.skin?.name);

        if (selectedSkinName && shipConf.skin) {
            this.shipSvg = shipConf.skin.svg;
        } else {
            this.shipSvg = shipConf.svg;
        }
    }


    draw() {
        // Thruster
        if (keys['w'] || keys['ArrowUp'] || keys['s'] || keys['ArrowDown'] || keys['a'] || keys['ArrowLeft'] || keys['d'] || keys['ArrowRight']) {
            this.thrusterParticles.push(new Particle(this.x, this.y + this.size / 2, 3, `hsl(${Math.random() * 60 + 200}, 100%, 50%)`, { x: 0, y: 3 }, 20));
        }
        this.thrusterParticles.forEach((p, i) => {
            p.update();
            p.draw();
            if (p.lifespan <= 0) this.thrusterParticles.splice(i, 1);
        });

        if (this.invincibilityFrames > 0 && Math.floor(this.invincibilityFrames / 10) % 2 === 0) {
            // Blink when invincible
        } else {
            const image = new Image();
            image.src = "data:image/svg+xml;base64," + btoa(this.shipSvg);
            ctx.drawImage(image, this.x - this.size / 2, this.y - this.size / 2, this.size, this.size);
        }

        // Shield
        if (isShieldActive) {
            ctx.beginPath();
            ctx.arc(this.x, this.y, this.size / 2 + 10, 0, Math.PI * 2);
            ctx.strokeStyle = `rgba(0, 255, 255, ${0.5 + Math.random() * 0.3})`;
            ctx.lineWidth = 3;
            ctx.stroke();
        }
    }

    update() {
        if (this.fireCooldown > 0) this.fireCooldown--;
        if (this.invincibilityFrames > 0) this.invincibilityFrames--;
        this.draw();
    }

    shoot() {
        if (this.fireCooldown === 0) {
            projectiles.push(new Projectile(this.x, this.y - this.size / 2, 'player'));
            this.fireCooldown = this.fireRate;
            playSound('laser');
        }
    }
}

class Projectile {
    x: number;
    y: number;
    size: number;
    speed: number;
    type: 'player' | 'enemy';
    trail: { x: number, y: number }[];

    constructor(x: number, y: number, type: 'player' | 'enemy') {
        this.x = x;
        this.y = y;
        this.size = 5;
        this.speed = PROJECTILE_SPEED;
        this.type = type;
        this.trail = [];
    }

    draw() {
        // Draw trail
        if (effectsEnabled) {
            ctx.beginPath();
            if(this.trail.length > 0) ctx.moveTo(this.trail[0].x, this.trail[0].y);
            for(let i=1; i < this.trail.length; i++){
                ctx.lineTo(this.trail[i].x, this.trail[i].y);
            }
            ctx.strokeStyle = this.type === 'player' ? 'rgba(0, 255, 255, 0.5)' : 'rgba(255, 0, 0, 0.5)';
            ctx.lineWidth = 3;
            ctx.stroke();
        }

        // Draw projectile head
        ctx.fillStyle = this.type === 'player' ? '#00ffff' : '#ff0000';
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
        ctx.fill();
    }

    update() {
        if (effectsEnabled) {
            this.trail.push({ x: this.x, y: this.y });
            if (this.trail.length > 10) this.trail.shift();
        }
        
        if (this.type === 'player') {
            this.y -= this.speed;
        } else {
            this.y += this.speed;
        }
        this.draw();
    }
}

class Enemy {
    x: number;
    y: number;
    size: number;
    speed: number;
    health: number;
    maxHealth: number;
    config: (typeof ENEMY_CONFIG)[keyof typeof ENEMY_CONFIG];
    fireCooldown: number;
    svg: string;

    constructor(x: number, y: number, type: keyof typeof ENEMY_CONFIG) {
        this.x = x;
        this.y = y;
        this.size = 50;
        this.config = ENEMY_CONFIG[type];
        this.speed = this.config.speed;
        this.maxHealth = this.config.health;
        this.health = this.config.health;
        this.svg = this.config.svg;
        this.fireCooldown = Math.random() * (('fireRate' in this.config && this.config.fireRate) || 200);
    }
    
    takeDamage(amount: number) {
        this.health -= amount;
        if (effectsEnabled) {
            for (let i = 0; i < 3; i++) {
                particles.push(new Particle(this.x, this.y, Math.random() * 2 + 1, 'white', { x: (Math.random() - 0.5) * 2, y: (Math.random() - 0.5) * 2 }, 10));
            }
        }
    }


    draw() {
        const image = new Image();
        image.src = "data:image/svg+xml;base64," + btoa(this.svg);
        
        ctx.save();
        if (this.health < this.maxHealth) {
             ctx.filter = `brightness(${1 + (this.maxHealth - this.health) * 0.5})`;
        }
        ctx.drawImage(image, this.x - this.size / 2, this.y - this.size / 2, this.size, this.size);
        ctx.restore();
    }

    update() {
        this.y += this.speed;
        if (this.config.type === 'bomber') {
            if (this.fireCooldown <= 0) {
                this.shoot();
                this.fireCooldown = this.config.fireRate + Math.random() * 50;
            } else {
                this.fireCooldown--;
            }
        }
        this.draw();
    }

    shoot() {
        enemyProjectiles.push(new Projectile(this.x, this.y + this.size / 2, 'enemy'));
        // playSound('enemyLaser'); // A different sound for enemy fire
    }
}


class Particle {
    x: number;
    y: number;
    size: number;
    color: string;
    velocity: { x: number, y: number };
    lifespan: number;
    opacity: number;

    constructor(x: number, y: number, size: number, color: string, velocity: { x: number, y: number }, lifespan: number = PARTICLE_LIFESPAN) {
        this.x = x;
        this.y = y;
        this.size = size;
        this.color = color;
        this.velocity = velocity;
        this.lifespan = lifespan;
        this.opacity = 1;
    }

    draw() {
        ctx.save();
        ctx.globalAlpha = this.opacity;
        ctx.fillStyle = this.color;
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();
    }

    update() {
        this.x += this.velocity.x;
        this.y += this.velocity.y;
        this.lifespan--;
        this.opacity = this.lifespan / PARTICLE_LIFESPAN;
        this.draw();
    }
}

class Star {
    x: number;
    y: number;
    size: number;
    speed: number;

    constructor() {
        this.x = Math.random() * canvas.width;
        this.y = Math.random() * canvas.height;
        this.size = Math.random() * 2 + 0.5;
        this.speed = this.size * 0.5; // Slower stars for parallax
    }

    draw() {
        ctx.fillStyle = `rgba(255, 255, 255, ${this.size / 2.5})`;
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
        ctx.fill();
    }

    update() {
        this.y += this.speed;
        if (this.y > canvas.height) {
            this.y = 0;
            this.x = Math.random() * canvas.width;
        }
        this.draw();
    }
}

class Shockwave {
    x: number;
    y: number;
    radius: number;
    maxRadius: number;
    speed: number;
    opacity: number;

    constructor(x: number, y: number) {
        this.x = x;
        this.y = y;
        this.radius = 0;
        this.maxRadius = 60;
        this.speed = 2;
        this.opacity = 1;
    }

    draw() {
        ctx.save();
        ctx.globalAlpha = this.opacity;
        ctx.strokeStyle = `rgba(0, 255, 255, ${this.opacity})`;
        ctx.lineWidth = 3;
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
        ctx.stroke();
        ctx.restore();
    }

    update() {
        this.radius += this.speed;
        this.opacity = 1 - this.radius / this.maxRadius;
        this.draw();
    }
}

// Alias Projectile for EnemyProjectile for clarity, they are the same
const EnemyProjectile = Projectile;

// --- INITIALIZATION ---

function init() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;

    loadAllPlayerStates();
    showLoginScreen();
    initStars();
    setupEventListeners();
    setupModals();
}

function initGame() {
    isGameOver = false;
    gameHasStarted = true;
    score = 0;
    wave = 1;
    player = new Player();
    projectiles = [];
    enemies = [];
    particles = [];
    enemyProjectiles = [];
    shockwaves = [];
    
    if(activeBooster) {
        gameState.stats.totalBoostersUsed++;
        checkAchievement('booster10', {});
    }
    
    hud.classList.remove('hidden');
    gameOverScreen.classList.add('hidden');
    startScreen.classList.add('hidden');
    
    updateHUD();
    updateXPBar();
    spawnEnemiesForWave();
    
    if (!musicSource) playMusic();
    
    if (animationId) cancelAnimationFrame(animationId);
    animate();
}

function initStars() {
    stars = [];
    for (let i = 0; i < STAR_COUNT; i++) {
        stars.push(new Star());
    }
}

// --- GAME LOOP ---
function animate() {
    animationId = requestAnimationFrame(animate);
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    drawBackground();

    // Update and draw stars
    stars.forEach(star => star.update());

    // Update and draw particles, shockwaves etc.
    particles.forEach((p, i) => p.lifespan > 0 ? p.update() : particles.splice(i, 1));
    shockwaves.forEach((s, i) => s.radius < s.maxRadius ? s.update() : shockwaves.splice(i, 1));

    player.update();
    handleInput();
    
    projectiles.forEach((p, i) => p.y > 0 ? p.update() : projectiles.splice(i, 1));
    enemyProjectiles.forEach((p, i) => p.y < canvas.height ? p.update() : enemyProjectiles.splice(i, 1));
    
    enemies.forEach((enemy, i) => {
        if (enemy.y > canvas.height) {
            enemies.splice(i, 1);
            currentWaveEnemies--;
        } else {
            enemy.update();
        }
    });

    handleCollisions();
    
    if (currentWaveEnemies <= 0 && enemies.length === 0) {
        if (waveCooldown > 0) {
            waveCooldown--;
             if (waveCooldown === 120) { // Show message
                waveNotification.textContent = `WAVE ${wave + 1}`;
                waveNotification.style.opacity = '1';
            }
        } else {
            wave++;
            spawnEnemiesForWave();
            waveCooldown = 180;
            waveNotification.style.opacity = '0';
        }
    }
}

// --- COLLISION DETECTION ---

function handleCollisions() {
    // Projectiles with enemies
    projectiles.forEach((proj, projIndex) => {
        enemies.forEach((enemy, enemyIndex) => {
            if (!projectiles[projIndex] || !enemies[enemyIndex]) return;
            const dist = Math.hypot(proj.x - enemy.x, proj.y - enemy.y);
            if (dist - enemy.size / 2 - proj.size < 1) {
                projectiles.splice(projIndex, 1);
                enemy.takeDamage(1);

                if (enemy.health <= 0) {
                    createExplosion(enemy.x, enemy.y);
                    enemies.splice(enemyIndex, 1);
                    currentWaveEnemies--;
                    
                    const scoreGained = enemy.config.score;
                    score += scoreGained;
                    const creditsGained = Math.ceil(scoreGained / 10) * (activeBooster === 'doubleCredits' ? 2 : 1);
                    gameState.credits += creditsGained;
                    gameState.stats.totalKills++;
                    
                    if(!gameState.achievements.includes('firstKill')) {
                         checkAchievement('firstKill', {killsInRun: (gameState.stats.totalKills === 1 ? 1: 0)});
                    }
                     checkAchievement('centurion', {});
                    
                    updateHUD();
                }
            }
        });
    });

    // Player with enemies or enemy projectiles
    if (player.invincibilityFrames === 0) {
        let playerHit = false;
        enemies.forEach((enemy, i) => {
            const dist = Math.hypot(player.x - enemy.x, player.y - enemy.y);
            if (dist - enemy.size / 2 - player.size / 2 < 1) {
                enemies.splice(i, 1);
                currentWaveEnemies--;
                createExplosion(enemy.x, enemy.y);
                playerHit = true;
            }
        });
        
        enemyProjectiles.forEach((proj, i) => {
             const dist = Math.hypot(player.x - proj.x, player.y - proj.y);
             if (dist - player.size / 2 - proj.size < 1) {
                 enemyProjectiles.splice(i, 1);
                 playerHit = true;
             }
        });

        if (playerHit) {
            if (isShieldActive) {
                isShieldActive = false;
                player.invincibilityFrames = PLAYER_INVINCIBILITY_FRAMES;
                createExplosion(player.x, player.y, '#00ffff');
            } else {
                player.lives--;
                playSound('hit');
                updateHUD();
                if (player.lives <= 0) {
                    endGame();
                } else {
                    player.invincibilityFrames = PLAYER_INVINCIBILITY_FRAMES;
                    createExplosion(player.x, player.y, '#ff4d4d');
                }
            }
        }
    }
}


// --- UTILITY FUNCTIONS ---

function createExplosion(x: number, y: number, color?: string) {
    if (effectsEnabled) {
        for (let i = 0; i < 30; i++) {
            const size = Math.random() * 3 + 1;
            const particleColor = color || `hsl(${Math.random() * 60 + 0}, 100%, 50%)`;
            const velocity = {
                x: (Math.random() - 0.5) * (Math.random() * 8),
                y: (Math.random() - 0.5) * (Math.random() * 8)
            };
            particles.push(new Particle(x, y, size, particleColor, velocity, Math.random() * 40 + 20));
        }
        shockwaves.push(new Shockwave(x, y));
    }
    playSound('explosion');
}

function spawnEnemiesForWave() {
    waveNotification.style.opacity = '0';
    totalWaveEnemies = 5 + Math.floor(wave * 1.5);
    currentWaveEnemies = totalWaveEnemies;

    for (let i = 0; i < totalWaveEnemies; i++) {
        const x = Math.random() * (canvas.width - 50) + 25;
        const y = -Math.random() * 500 - 50;
        let enemyType: keyof typeof ENEMY_CONFIG = 'scout';

        if (wave > 2 && Math.random() > 0.6) {
             enemyType = 'brute';
        }
        if (wave > 4 && Math.random() > 0.5) {
             enemyType = 'bomber';
        }
        
        enemies.push(new Enemy(x, y, enemyType));
    }
    
    checkAchievement('wave5', {wave});
}

function endGame() {
    isGameOver = true;
    gameHasStarted = false;
    cancelAnimationFrame(animationId);
    
    addXP(score);
    
    hud.classList.add('hidden');
    gameOverScreen.classList.remove('hidden');
    finalScoreEl.textContent = score.toString();
    
    // Save state after a game
    savePlayerState();
}


function handleInput() {
    // Player Movement
    if (keys['w'] || keys['ArrowUp']) player.y = Math.max(player.y - player.speed, 0 + player.size/2);
    if (keys['s'] || keys['ArrowDown']) player.y = Math.min(player.y + player.speed, canvas.height - player.size / 2);
    if (keys['a'] || keys['ArrowLeft']) player.x = Math.max(player.x - player.speed, 0 + player.size / 2);
    if (keys['d'] || keys['ArrowRight']) player.x = Math.min(player.x + player.speed, canvas.width - player.size / 2);

    // Player Shooting
    if (keys[' '] || keys['Mouse0']) {
        player.shoot();
    }
    
    // Gamepad input
    const gamepads = navigator.getGamepads();
    if (gamepads[0]) {
        const gamepad = gamepads[0];
        const horizontal = gamepad.axes[0];
        const vertical = gamepad.axes[1];

        if (Math.abs(horizontal) > 0.1) player.x += player.speed * horizontal;
        if (Math.abs(vertical) > 0.1) player.y += player.speed * vertical;

        // Clamp position
        player.x = Math.max(0 + player.size / 2, Math.min(canvas.width - player.size / 2, player.x));
        player.y = Math.max(0 + player.size / 2, Math.min(canvas.height - player.size / 2, player.y));

        if (gamepad.buttons[0].pressed || gamepad.buttons[7].pressed) { // A button or Right Trigger
            player.shoot();
        }
    }
}


// --- UI & STATE MANAGEMENT ---

function updateHUD() {
    scoreEl.textContent = score.toString();
    livesEl.textContent = player?.lives.toString() || (3 + gameState.upgrades.extraLife).toString();
    creditsEl.textContent = gameState.credits.toString();
    waveEl.textContent = wave.toString();
}

function updateXPBar() {
    const xpForNextLevel = 100 * Math.pow(1.2, gameState.level);
    const progress = (gameState.xp / xpForNextLevel) * 100;
    xpBar.style.width = `${progress}%`;
    levelEl.textContent = gameState.level.toString();
}

function addXP(amount: number) {
    gameState.xp += amount;
    let xpForNextLevel = 100 * Math.pow(1.2, gameState.level);

    while (gameState.xp >= xpForNextLevel) {
        gameState.level++;
        gameState.xp -= xpForNextLevel;
        levelUpNotification.style.opacity = '1';
        playSound('levelUp');
        setTimeout(() => levelUpNotification.style.opacity = '0', 2000);
        checkAchievement('level10', {});
        updateBattlePass();
        xpForNextLevel = 100 * Math.pow(1.2, gameState.level);
    }
    updateXPBar();
}

function showStartScreen() {
    gameContainer.classList.remove('hidden');
    loginScreen.classList.add('hidden');
    startScreen.classList.remove('hidden');
    gameOverScreen.classList.add('hidden');
    hud.classList.add('hidden');
    
    document.getElementById('welcome-message')!.textContent = `Welcome, ${currentUsername}!`;
    document.getElementById('admin-panel-button')!.classList.toggle('hidden', loggedInRole !== 'admin');
    
    updateBoosterCounts();
    updateUpgradesUI();
    updateXPBar();
    updateBattlePass();
    
    if(menuAnimationId) cancelAnimationFrame(menuAnimationId);
    startMenuAnimation();
    
    startChatSimulation();
}

function startMenuAnimation() {
    if(menuAnimationId) cancelAnimationFrame(menuAnimationId);
    
    let localStars: Star[] = [];
    for (let i = 0; i < STAR_COUNT; i++) {
        localStars.push(new Star());
    }

    const animateMenu = () => {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        drawBackground(localStars);
        localStars.forEach(star => star.update());
        menuAnimationId = requestAnimationFrame(animateMenu);
    };
    animateMenu();
}


function drawBackground(starArray: Star[] = stars) {
     const map = MAP_CONFIG[currentMapIndex];
    if (map.type === 'nebula') {
        const gradient = ctx.createLinearGradient(0, 0, canvas.width, canvas.height);
        gradient.addColorStop(0, map.color1!);
        gradient.addColorStop(1, map.color2!);
        ctx.fillStyle = gradient;
    } else if (map.type === 'asteroid-field') {
        ctx.fillStyle = '#1a202c';
    } else { // deep-space
        ctx.fillStyle = '#000010';
    }
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    starArray.forEach(star => star.draw());
    
    if (map.type === 'asteroid-field') {
        for(let i=0; i < 10; i++){
            ctx.fillStyle = `rgba(100,100,100,${0.2 + (i/20)})`;
            ctx.beginPath();
            ctx.arc((i*150 + 50) % canvas.width, (i*200 + 100) % canvas.height, i*5+10, 0, Math.PI * 2);
            ctx.fill();
        }
    }
}


// --- Audio ---
function initAudio() {
    if (!audioContext) {
        audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();
    }
}

async function playSound(sound: keyof typeof SOUND_ASSETS) {
    if (!audioContext) initAudio();
    if (audioContext.state === 'suspended') {
        await audioContext.resume();
    }
    if (sfxVolume === 0) return;
    try {
        const response = await fetch(SOUND_ASSETS[sound]);
        const arrayBuffer = await response.arrayBuffer();
        const audioBuffer = await audioContext.decodeAudioData(arrayBuffer);
        const source = audioContext.createBufferSource();
        source.buffer = audioBuffer;
        const gainNode = audioContext.createGain();
        gainNode.gain.value = sfxVolume;
        source.connect(gainNode).connect(audioContext.destination);
        source.start(0);
    } catch (error) {
        console.error(`Error playing sound ${sound}:`, error);
    }
}

async function playMusic() {
    if (!audioContext) initAudio();
     if (audioContext.state === 'suspended') {
        await audioContext.resume();
    }
    if (musicSource) {
        musicSource.stop();
        musicSource = null;
    }
    if(musicVolume === 0) return;

    try {
        const response = await fetch(SOUND_ASSETS.music);
        const arrayBuffer = await response.arrayBuffer();
        const audioBuffer = await audioContext.decodeAudioData(arrayBuffer);
        musicSource = audioContext.createBufferSource();
        musicSource.buffer = audioBuffer;
        musicSource.loop = true;
        const gainNode = audioContext.createGain();
        gainNode.gain.value = musicVolume;
        musicSource.connect(gainNode).connect(audioContext.destination);
        musicSource.start(0);
    } catch (error) {
        console.error("Error playing music:", error);
    }
}

function updateMusicVolume(volume: number) {
    musicVolume = volume;
    if (musicSource) {
         playMusic(); 
    }
}

// --- Local Storage & Player State ---

function getDefaultPlayerState(): PlayerState {
    const now = new Date();
    const currentMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
    
    return {
        level: 1, xp: 0, credits: 0,
        upgrades: { fireRate: 0, shipSpeed: 0, extraLife: 0 },
        lastClaimedDay: null, claimedRewards: [],
        boosters: { shield: 1, rapidFire: 1, doubleCredits: 1 },
        selectedShip: 'ranger', unlockedShips: ['ranger'],
        stats: { totalKills: 0, totalBoostersUsed: 0 },
        achievements: [],
        selectedMap: 0,
        unlockedMaps: [0],
        unlockedSkins: {},
        battlePassTier: 0,
        claimedBattlePassTiers: [],
        battlePassSeason: 1,
        battlePassLastReset: currentMonth,
    };
}

function savePlayerState() {
    if (loggedInRole === 'guest') {
        localStorage.setItem('spaceShooterGuest', JSON.stringify(gameState));
    }
    else if (currentUsername) {
        allPlayerStates[currentUsername] = gameState;
        localStorage.setItem('spaceShooterAllPlayers', JSON.stringify(allPlayerStates));
    }
}

function loadAllPlayerStates() {
    const savedStates = localStorage.getItem('spaceShooterAllPlayers');
    if (savedStates) {
        allPlayerStates = JSON.parse(savedStates);
    } else {
        allPlayerStates = {};
    }
}

// --- Login/Signup ---

const loginScreen = document.getElementById('login-screen')!;
const usernameInput = document.getElementById('username-input')! as HTMLInputElement;
const passwordInput = document.getElementById('password-input')! as HTMLInputElement;
const loginErrorEl = document.getElementById('login-error')!;

function showLoginScreen() {
    gameContainer.classList.add('hidden');
    loginScreen.style.display = 'flex';
}

function handleSignIn() {
    initAudio(); 
    if (audioContext.state === 'suspended') audioContext.resume();
    playSound('uiClick');
    
    const user = usernameInput.value.trim();
    const pass = passwordInput.value.trim();
    loginErrorEl.textContent = '';

    if (!user || !pass) {
        loginErrorEl.textContent = 'Please enter username and password.';
        return;
    }
    
    if (user === 'admin' && pass === 'password') {
        currentUsername = 'admin';
        loggedInRole = 'admin';
        gameState = allPlayerStates['admin'] || getDefaultPlayerState();
        showStartScreen();
        return;
    }
    
    if (allPlayerStates[user] && allPlayerStates[user].password === pass) {
        currentUsername = user;
        loggedInRole = 'player';
        gameState = allPlayerStates[user];
        showStartScreen();
    } else {
        loginErrorEl.textContent = 'Invalid username or password.';
    }
}

function handleSignUp() {
    initAudio();
    if (audioContext.state === 'suspended') audioContext.resume();
    playSound('uiClick');

    const user = usernameInput.value.trim();
    const pass = passwordInput.value.trim();
    loginErrorEl.textContent = '';

    if (!user || !pass) {
        loginErrorEl.textContent = 'Please enter username and password.';
        return;
    }
    
    if (allPlayerStates[user]) {
        loginErrorEl.textContent = 'Username already exists.';
        return;
    }
    
    currentUsername = user;
    loggedInRole = 'player';
    gameState = getDefaultPlayerState();
    gameState.password = pass; 
    
    savePlayerState();
    showStartScreen();
}

function handleGuestLogin() {
    initAudio();
     if (audioContext.state === 'suspended') audioContext.resume();
    playSound('uiClick');

    currentUsername = 'Guest';
    loggedInRole = 'guest';
    const guestState = localStorage.getItem('spaceShooterGuest');
    gameState = guestState ? JSON.parse(guestState) : getDefaultPlayerState();
    showStartScreen();
}


// --- MODAL UI FUNCTIONS ---

function setupModals() {
    const modals = document.querySelectorAll('.modal');
    modals.forEach(modal => {
        const closeButton = modal.querySelector('.close-button');
        closeButton?.addEventListener('click', () => {
            playSound('uiClick');
            modal.classList.add('hidden');
            if (!gameHasStarted) {
                if (menuAnimationId) cancelAnimationFrame(menuAnimationId);
                startMenuAnimation();
            }
        });
    });
}

function openModal(modalId: string) {
    playSound('uiClick');
    if(menuAnimationId) cancelAnimationFrame(menuAnimationId);
    document.getElementById(modalId)?.classList.remove('hidden');
}


// --- Daily Rewards ---
function populateDailyRewards() {
    const calendar = document.getElementById('reward-calendar')!;
    calendar.innerHTML = '';
    const today = new Date().getDate();

    DAILY_REWARDS.forEach((reward, index) => {
        const day = index + 1;
        const dayEl = document.createElement('div');
        dayEl.classList.add('calendar-day');
        dayEl.innerHTML = `<div>Day ${day}</div><div class="reward-icon">${reward.icon}</div>`;
        
        if (gameState.claimedRewards.includes(day)) {
            dayEl.classList.add('claimed');
        } else {
            dayEl.classList.add('unclaimed');
        }

        if (day === today) {
            dayEl.classList.add('today');
        }
        calendar.appendChild(dayEl);
    });

    const claimButton = document.getElementById('claim-reward-button')! as HTMLButtonElement;
    const canClaim = !gameState.claimedRewards.includes(today) && (gameState.lastClaimedDay === null || gameState.lastClaimedDay < today);
    claimButton.disabled = !canClaim;
}

function claimDailyReward() {
    const today = new Date().getDate();
    if (gameState.claimedRewards.includes(today)) return;

    const reward = DAILY_REWARDS[today - 1];
    if (reward) {
        if (reward.type === 'credits') {
            gameState.credits += reward.amount;
        } else if (reward.type === 'booster') {
            gameState.boosters[reward.booster as keyof typeof gameState.boosters] += reward.amount;
        } else if (reward.type === 'mystery') {
            gameState.credits += 500 + Math.floor(Math.random() * 500);
        }
        gameState.claimedRewards.push(today);
        gameState.lastClaimedDay = today;
        savePlayerState();
        populateDailyRewards();
        updateHUD();
        playSound('levelUp');
    }
}

// --- Upgrades ---
function updateUpgradesUI() {
    const fireRateCost = 100 * Math.pow(1.5, gameState.upgrades.fireRate);
    const shipSpeedCost = 100 * Math.pow(1.5, gameState.upgrades.shipSpeed);
    const extraLifeCost = 250 * Math.pow(2, gameState.upgrades.extraLife);

    (document.getElementById('upgrades-credits') as HTMLElement).textContent = gameState.credits.toString();
    (document.getElementById('fire-rate-level') as HTMLElement).textContent = `Lv ${gameState.upgrades.fireRate + 1}`;
    (document.getElementById('ship-speed-level') as HTMLElement).textContent = `Lv ${gameState.upgrades.shipSpeed + 1}`;
    (document.getElementById('extra-life-level') as HTMLElement).textContent = `Lv ${gameState.upgrades.extraLife + 1}`;
    (document.getElementById('fire-rate-cost') as HTMLElement).textContent = Math.floor(fireRateCost).toString();
    (document.getElementById('ship-speed-cost') as HTMLElement).textContent = Math.floor(shipSpeedCost).toString();
    (document.getElementById('extra-life-cost') as HTMLElement).textContent = Math.floor(extraLifeCost).toString();
    
    (document.getElementById('buy-fire-rate') as HTMLButtonElement).disabled = gameState.credits < fireRateCost;
    (document.getElementById('buy-ship-speed') as HTMLButtonElement).disabled = gameState.credits < shipSpeedCost;
    (document.getElementById('buy-extra-life') as HTMLButtonElement).disabled = gameState.credits < extraLifeCost;
}

function buyUpgrade(type: 'fireRate' | 'shipSpeed' | 'extraLife') {
    playSound('uiClick');
    const costs = {
        fireRate: 100 * Math.pow(1.5, gameState.upgrades.fireRate),
        shipSpeed: 100 * Math.pow(1.5, gameState.upgrades.shipSpeed),
        extraLife: 250 * Math.pow(2, gameState.upgrades.extraLife)
    };
    
    const cost = Math.floor(costs[type]);
    if (gameState.credits >= cost) {
        gameState.credits -= cost;
        gameState.upgrades[type]++;
        savePlayerState();
        updateUpgradesUI();
    }
}

// --- Hangar & Ships ---
function populateHangar() {
    const hangarGrid = document.getElementById('hangar-grid')!;
    hangarGrid.innerHTML = '';
    Object.values(SHIP_CONFIG).forEach(ship => {
        const isUnlocked = gameState.level >= ship.unlockLevel;
        if (isUnlocked && !gameState.unlockedShips.includes(ship.name)) {
            gameState.unlockedShips.push(ship.name);
        }

        const shipEl = document.createElement('div');
        shipEl.classList.add('hangar-item');
        if (!isUnlocked) shipEl.classList.add('locked');
        if (gameState.selectedShip === ship.name.toLowerCase()) shipEl.classList.add('selected');

        shipEl.innerHTML = `
            ${ship.svg}
            <div>${ship.name}</div>
            ${isUnlocked ? '' : `<div class="lock-icon">🔒 Lv ${ship.unlockLevel}</div>`}
        `;

        if (isUnlocked) {
            shipEl.addEventListener('click', () => {
                playSound('uiClick');
                gameState.selectedShip = ship.name.toLowerCase();
                player?.updateShipSVG();
                savePlayerState();
                populateHangar(); // Re-render to show selection
            });
        }
        hangarGrid.appendChild(shipEl);
    });
}

// --- Achievements ---
function populateAchievements() {
    const list = document.getElementById('achievements-list')!;
    list.innerHTML = '';
    Object.keys(ACHIEVEMENT_CONFIG).forEach(key => {
        const config = ACHIEVEMENT_CONFIG[key];
        const isUnlocked = gameState.achievements.includes(key);

        const item = document.createElement('div');
        item.classList.add('achievement-item');
        if (isUnlocked) item.classList.add('unlocked');

        item.innerHTML = `
            <div>
                <div>${isUnlocked ? '🏆' : '🔒'} ${config.name}</div>
                <div class="description">${config.description}</div>
            </div>
        `;
        list.appendChild(item);
    });
}

function checkAchievement(key: string, gameStats: any) {
    if (gameState.achievements.includes(key)) return;

    const config = ACHIEVEMENT_CONFIG[key];
    if (config.condition(gameState, gameStats)) {
        gameState.achievements.push(key);
        savePlayerState();
        showAchievementToast(config.name);
        playSound('achievement');
    }
}

function showAchievementToast(name: string) {
    const toast = document.getElementById('achievement-toast')!;
    const nameEl = document.getElementById('achievement-name')!;
    nameEl.textContent = name;
    toast.classList.add('show');
    toast.classList.remove('hidden');
    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => toast.classList.add('hidden'), 500);
    }, 3000);
}

// --- Boosters ---
function updateBoosterCounts() {
    (document.getElementById('shield-booster-count') as HTMLElement).textContent = gameState.boosters.shield.toString();
    (document.getElementById('rapid-fire-booster-count') as HTMLElement).textContent = gameState.boosters.rapidFire.toString();
    (document.getElementById('double-credits-booster-count') as HTMLElement).textContent = gameState.boosters.doubleCredits.toString();

    document.querySelectorAll('.booster-item').forEach(item => {
        const booster = item.getAttribute('data-booster') as keyof typeof gameState.boosters;
        if (gameState.boosters[booster] > 0) {
            item.classList.remove('disabled');
        } else {
            item.classList.add('disabled');
        }
    });
}

function handleBoosterSelection(e: Event) {
    const target = e.currentTarget as HTMLDivElement;
    const boosterType = target.dataset.booster as keyof typeof gameState.boosters;
    const checkbox = target.querySelector('.booster-checkbox') as HTMLInputElement;

    if (gameState.boosters[boosterType] <= 0) {
        checkbox.checked = false;
        return;
    }
    
    // Uncheck other boosters
    document.querySelectorAll('.booster-checkbox').forEach(cb => {
        if (cb !== checkbox) (cb as HTMLInputElement).checked = false;
    });

    if (checkbox.checked) {
        activeBooster = boosterType;
    } else {
        activeBooster = null;
    }
}

// Map Selector
function populateMapSelector() {
    const grid = document.getElementById('map-grid')!;
    grid.innerHTML = '';
    MAP_CONFIG.forEach((map, index) => {
        const isUnlocked = gameState.level >= map.unlockLevel;
        if (isUnlocked && !gameState.unlockedMaps.includes(index)) {
            gameState.unlockedMaps.push(index);
        }

        const item = document.createElement('div');
        item.classList.add('map-item');
        if (!isUnlocked) item.classList.add('locked');
        if (currentMapIndex === index) item.classList.add('selected');

        const preview = document.createElement('div');
        preview.classList.add('map-background-preview');
        if (map.type === 'nebula') {
            preview.style.background = `linear-gradient(45deg, ${map.color1}, ${map.color2})`;
        } else if (map.type === 'asteroid-field') {
            preview.style.background = '#1a202c'; // Simplified representation
        } else {
            preview.style.background = '#000010';
        }

        item.appendChild(preview);
        item.innerHTML += `
            <div>${map.name}</div>
            ${isUnlocked ? '' : `<div class="lock-icon">🔒 Lv ${map.unlockLevel}</div>`}
        `;

        if (isUnlocked) {
            item.addEventListener('click', () => {
                playSound('uiClick');
                currentMapIndex = index;
                gameState.selectedMap = index;
                savePlayerState();
                populateMapSelector();
                if(menuAnimationId) cancelAnimationFrame(menuAnimationId);
                startMenuAnimation();
            });
        }
        grid.appendChild(item);
    });
}

// Chat Simulation
function startChatSimulation() {
    if (chatInterval) clearInterval(chatInterval);
    const messagesEl = document.getElementById('chat-messages')!;
    
    const fakeUsers = ["StarPilot_7", "GalaxyGazer", "NovaHunter", "CometRider"];
    const fakeMessages = ["wow, new high score!", "anyone wanna team up?", "this map is awesome", "lol almost died there", "gg", "nice shot!"];

    // FIX: Use window.setInterval to ensure the return type is 'number', matching 'chatInterval' type.
    chatInterval = window.setInterval(() => {
        const user = fakeUsers[Math.floor(Math.random() * fakeUsers.length)];
        const msg = fakeMessages[Math.floor(Math.random() * fakeMessages.length)];
        addChatMessage(user, msg, 'player');
    }, 5000 + Math.random() * 5000);
}

// FIX: Expanded the 'role' type to include 'guest' to match the 'loggedInRole' type.
function addChatMessage(username: string, message: string, role: 'player' | 'admin' | 'system' | 'guest') {
    const messagesEl = document.getElementById('chat-messages')!;
    const p = document.createElement('p');
    const userSpan = document.createElement('span');
    userSpan.className = 'username';
    userSpan.textContent = `${username}: `;
    userSpan.dataset.role = role;
    
    p.appendChild(userSpan);
    p.append(message);
    messagesEl.appendChild(p);
    messagesEl.scrollTop = messagesEl.scrollHeight;
}

const PROFANITY_LIST = ['badword1', 'badword2', 'example']; // Replace with a real list
function filterMessage(message: string): string {
    let filtered = message;
    PROFANITY_LIST.forEach(word => {
        const regex = new RegExp(`\\b${word}\\b`, 'gi');
        filtered = filtered.replace(regex, '*'.repeat(word.length));
    });
    return filtered;
}

// Admin Panel
function showAdminPanel() {
    const infoEl = document.getElementById('admin-info')!;
    infoEl.textContent = JSON.stringify({
        currentPlayer: gameState,
        allPlayers: allPlayerStates
    }, null, 2);
    openModal('admin-panel-modal');
}


// --- Battle Pass ---

function updateBattlePass() {
    // Check for newly unlocked tiers
    BATTLE_PASS_REWARDS.forEach((reward, index) => {
        if (gameState.level >= reward.level && !gameState.claimedBattlePassTiers.includes(index)) {
            // Give reward
            if (reward.type === 'credits') {
                gameState.credits += reward.amount;
            } else if (reward.type === 'booster') {
                gameState.boosters[reward.booster as keyof typeof gameState.boosters] += reward.amount;
            } else if (reward.type === 'skin') {
                if (!gameState.unlockedSkins[reward.ship]) {
                    gameState.unlockedSkins[reward.ship] = [];
                }
                gameState.unlockedSkins[reward.ship].push(reward.skinName);
            }
            gameState.claimedBattlePassTiers.push(index);
        }
    });
    savePlayerState();
}


// --- EVENT LISTENERS ---
function setupEventListeners() {
    window.addEventListener('keydown', (e) => {
        keys[e.key] = true;
        if (e.key === ' ' || e.key.includes('Arrow')) e.preventDefault();
        
        if (e.key === 'Escape' && gameHasStarted) {
            endGame();
        }
    });
    window.addEventListener('keyup', (e) => { keys[e.key] = false; });
    window.addEventListener('mousedown', (e) => { keys[`Mouse${e.button}`] = true; });
    window.addEventListener('mouseup', (e) => { keys[`Mouse${e.button}`] = false; });
    window.addEventListener('resize', () => {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
        initStars();
    });

    // Login screen buttons
    document.getElementById('signin-button')!.addEventListener('click', handleSignIn);
    document.getElementById('signup-button')!.addEventListener('click', handleSignUp);
    document.getElementById('guest-button')!.addEventListener('click', handleGuestLogin);
    
    // Start Screen Buttons
    document.getElementById('start-button')!.addEventListener('click', () => { playSound('uiClick'); initGame(); });
    document.getElementById('restart-button')!.addEventListener('click', () => { playSound('uiClick'); showStartScreen(); });
    document.getElementById('settings-button')!.addEventListener('click', () => openModal('settings-modal'));
    document.getElementById('daily-reward-button')!.addEventListener('click', () => { populateDailyRewards(); openModal('daily-reward-modal'); });
    document.getElementById('claim-reward-button')!.addEventListener('click', claimDailyReward);
    document.getElementById('upgrades-button')!.addEventListener('click', () => { updateUpgradesUI(); openModal('upgrades-modal'); });
    document.getElementById('buy-fire-rate')!.addEventListener('click', () => buyUpgrade('fireRate'));
    document.getElementById('buy-ship-speed')!.addEventListener('click', () => buyUpgrade('shipSpeed'));
    document.getElementById('buy-extra-life')!.addEventListener('click', () => buyUpgrade('extraLife'));
    document.getElementById('hangar-button')!.addEventListener('click', () => { populateHangar(); openModal('hangar-modal'); });
    document.getElementById('achievements-button')!.addEventListener('click', () => { populateAchievements(); openModal('achievements-modal'); });
    document.getElementById('map-selector-button')!.addEventListener('click', () => { populateMapSelector(); openModal('map-selector-modal'); });
    document.getElementById('admin-panel-button')!.addEventListener('click', showAdminPanel);

    // Settings
    (document.getElementById('effects-toggle') as HTMLInputElement).addEventListener('change', (e) => { effectsEnabled = (e.target as HTMLInputElement).checked; });
    (document.getElementById('sfx-volume') as HTMLInputElement).addEventListener('input', (e) => { sfxVolume = parseFloat((e.target as HTMLInputElement).value); });
    (document.getElementById('music-volume') as HTMLInputElement).addEventListener('input', (e) => { updateMusicVolume(parseFloat((e.target as HTMLInputElement).value)); });

    // Boosters
    document.querySelectorAll('.booster-item').forEach(item => {
        item.addEventListener('click', handleBoosterSelection);
    });
    
    // Chat
    document.getElementById('chat-input')!.addEventListener('keydown', (e) => {
        if(e.key === 'Enter') {
            const input = e.target as HTMLInputElement;
            let message = input.value.trim();
            if(message) {
                message = filterMessage(message);
                addChatMessage(currentUsername || 'Guest', message, loggedInRole);
                input.value = '';
                savePlayerState(); // Save chat? Maybe not needed.
            }
        }
    });

    // Player counter simulation
    setInterval(() => {
        fakePlayerCount += Math.floor(Math.random() * 7) - 3;
        if (fakePlayerCount < 80) fakePlayerCount = 80;
        if (fakePlayerCount > 150) fakePlayerCount = 150;
        document.querySelector('#player-counter span')!.textContent = fakePlayerCount.toString();
    }, 3000);
}


// --- START ---
init();
