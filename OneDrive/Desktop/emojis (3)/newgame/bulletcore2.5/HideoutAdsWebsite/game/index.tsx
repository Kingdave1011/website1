// Type definitions
type ShipSkin = {
    id: string;
    name: string;
    color: string;
};

type GameState = {
    username: string;
    level: number;
    xp: number;
    credits: number;
    upgrades: {
        fireRate: number;
        speed: number;
        extraLife: number;
    };
    unlockedShips: string[];
    selectedShip: string;
    unlockedSkins: { [shipId: string]: string[] };
    selectedSkins: { [shipId: string]: string };
    unlockedMaps: number[];
    selectedMap: number;
    dailyRewardLastClaimed: string | null;
    claimedDays: number[];
    boosters: {
        shield: number;
        rapidFire: number;
        doubleCredits: number;
    };
    stats: {
        totalKills: number;
        wavesSurvived: number;
        boostersUsed: number;
    };
    unlockedAchievements: string[];
    settings: {
        sfxVolume: number;
        musicVolume: number;
        effectsEnabled: boolean;
        hudScale: number;
        hudPosition: 'top' | 'bottom';
    };
    health: number;
    maxHealth: number;
};

type ShipConfig = {
    name: string;
    svg: string;
    speed: number;
    unlockLevel: number;
    skins: ShipSkin[];
};

type EnemyConfig = {
    name: string;
    svg: string;
    speed: number;
    health: number;
    points: number;
    fireRate?: number;
};

type PowerUpConfig = {
    type: 'health' | 'weaponBoost' | 'speedBoost';
    svg: string;
    color: string;
};

type Achievement = {
    id: string;
    name: string;
    description: string;
    icon: string;
    condition: (stats: GameState['stats'], level: number, wave: number) => boolean;
};

// =================================================================================
// Global Variables & DOM Elements
// =================================================================================

let canvas: HTMLCanvasElement;
let ctx: CanvasRenderingContext2D;

let player: Player;
let projectiles: Projectile[] = [];
let enemies: Enemy[] = [];
let particles: Particle[] = [];
let stars: Star[] = [];
let enemyProjectiles: EnemyProjectile[] = [];
let powerUps: PowerUp[] = [];
let boss: Boss | null = null;
let lasers: Laser[] = [];

let score = 0;
let lives = 3;
let currentWave = 1;
let gameRunning = false;
let animationFrameId: number;
let keys: { [key: string]: boolean } = {};
let gameState: GameState;
let sfxVolume = 0.5;
let musicVolume = 0.2;
let effectsEnabled = true;

// DOM Elements (to be assigned in window.onload)
let gameContainer: HTMLElement,
    loginScreen: HTMLElement,
    startScreen: HTMLElement,
    gameOverScreen: HTMLElement,
    gameUi: HTMLElement,
    scoreEl: HTMLElement,
    livesEl: HTMLElement,
    levelEl: HTMLElement,
    creditsEl: HTMLElement,
    xpBar: HTMLElement,
    healthBar: HTMLElement,
    finalScoreEl: HTMLElement,
    creditsEarnedEl: HTMLElement,
    levelUpNotification: HTMLElement,
    achievementToast: HTMLElement,
    waveCounterEl: HTMLElement,
    waveNotificationEl: HTMLElement,
    welcomeMessageEl: HTMLElement,
    playerCounterEl: HTMLElement,
    shieldBoosterCountEl: HTMLElement,
    rapidFireBoosterCountEl: HTMLElement,
    doubleCreditsBoosterCountEl: HTMLElement,
    usernameInput: HTMLInputElement,
    emailInput: HTMLInputElement,
    passwordInput: HTMLInputElement,
    loginErrorEl: HTMLElement,
    chatContainer: HTMLElement,
    chatMessages: HTMLElement,
    chatInput: HTMLInputElement,
    sfxVolumeSlider: HTMLInputElement,
    musicVolumeSlider: HTMLInputElement,
    effectsToggle: HTMLInputElement,
    hudScaleSlider: HTMLInputElement,
    hudPosTopRadio: HTMLInputElement,
    hudPosBottomRadio: HTMLInputElement,
    mobileControls: HTMLElement,
    joystickArea: HTMLElement,
    joystickThumb: HTMLElement,
    bossHealthContainer: HTMLElement,
    bossHealthBar: HTMLElement,
    fullscreenToggleButton: HTMLButtonElement;


const PLAYER_SIZE = 50;
const PROJECTILE_SPEED = 7;
const PARTICLE_COUNT = 30;
const STAR_COUNT = 200;
const XP_PER_LEVEL = 1000;
const BOSS_WAVE = 10;

// =================================================================================
// Configurations
// =================================================================================

const SHIP_CONFIG: { [key: string]: ShipConfig } = {
    ranger: {
        name: 'Ranger',
        svg: `<svg viewBox="0 0 60 60"><path d="M30 0 L50 60 L30 50 L10 60 Z" fill="none" stroke="cyan" stroke-width="2"/></svg>`,
        speed: 5,
        unlockLevel: 1,
        skins: [
            { id: 'default', name: 'Default', color: 'cyan' },
            { id: 'gold', name: 'Gold', color: 'gold' },
            { id: 'crimson', name: 'Crimson', color: '#DC143C' },
            { id: 'neon', name: 'Neon Green', color: '#39FF14' },
            { id: 'violet', name: 'Violet Storm', color: '#8A2BE2' },
            { id: 'arctic', name: 'Arctic Blue', color: '#00FFFF' }
        ]
    },
    interceptor: {
        name: 'Interceptor',
        svg: `<svg viewBox="0 0 60 60"><path d="M30 0 L60 40 L30 30 L0 40 Z" fill="none" stroke="cyan" stroke-width="2"/></svg>`,
        speed: 7,
        unlockLevel: 5,
        skins: [
            { id: 'default', name: 'Default', color: 'cyan' },
            { id: 'emerald', name: 'Emerald', color: '#50C878' },
            { id: 'sapphire', name: 'Sapphire', color: '#0F52BA' },
            { id: 'ruby', name: 'Ruby Red', color: '#E0115F' },
            { id: 'amethyst', name: 'Amethyst', color: '#9966CC' },
            { id: 'topaz', name: 'Topaz', color: '#FFC87C' }
        ]
    },
    bruiser: {
        name: 'Bruiser',
        svg: `<svg viewBox="0 0 60 60"><path d="M10 0 L50 0 L60 30 L30 60 L0 30 Z" fill="none" stroke="cyan" stroke-width="2"/></svg>`,
        speed: 4,
        unlockLevel: 10,
        skins: [
            { id: 'default', name: 'Default', color: 'cyan' },
            { id: 'onyx', name: 'Onyx', color: '#353839' },
            { id: 'platinum', name: 'Platinum', color: '#E5E4E2' },
            { id: 'titanium', name: 'Titanium', color: '#878681' },
            { id: 'chrome', name: 'Chrome', color: '#C0C0C0' },
            { id: 'obsidian', name: 'Obsidian', color: '#1C1C1C' }
        ]
    }
};

const ENEMY_CONFIG = {
    scout: { name: 'Scout', svg: `<svg viewBox="0 0 40 40"><path d="M20 0 L40 40 L0 40 Z" fill="none" stroke="red" stroke-width="2"/></svg>`, speed: 3, health: 1, points: 10 },
    brute: { name: 'Brute', svg: `<svg viewBox="0 0 60 60"><path d="M0 10 L60 10 L60 50 L0 50 Z M10 0 L20 10 M40 10 L50 0" fill="none" stroke="orange" stroke-width="2"/></svg>`, speed: 1, health: 5, points: 50 },
    bomber: { name: 'Bomber', svg: `<svg viewBox="0 0 50 50"><circle cx="25" cy="25" r="20" fill="none" stroke="magenta" stroke-width="2"/><path d="M25 0 V50 M0 25 H50" stroke="magenta" stroke-width="1"/></svg>`, speed: 2, health: 3, points: 30, fireRate: 120 }
} as const;

const POWERUP_CONFIG: { [key: string]: PowerUpConfig } = {
    health: { type: 'health', svg: `<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#32cd32" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14M5 12h14"/></svg>`, color: '#32cd32' },
    weaponBoost: { type: 'weaponBoost', svg: `<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#00BFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>`, color: '#00BFFF' },
    speedBoost: { type: 'speedBoost', svg: `<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#FFD700" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M13 17l5-5-5-5M6 17l5-5-5-5"/></svg>`, color: '#FFD700' },
};

const BOOSTER_ICONS = {
    shield: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>`,
    rapidFire: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"></polygon></svg>`,
    doubleCredits: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 1v22M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>`
};

const MAP_CONFIG: { [key: number]: { name: string, type: 'space' | 'nebula' | 'asteroids', unlockLevel: number } } = {};
for (let i = 1; i <= 20; i++) {
    const type = i <= 7 ? 'space' : (i <= 14 ? 'nebula' : 'asteroids');
    MAP_CONFIG[i] = { name: `Sector ${i}`, type, unlockLevel: i };
}

const DAILY_REWARDS = Array.from({ length: 28 }, (_, i) => {
    if ((i + 1) % 7 === 0) return { type: 'mystery', amount: 1 };
    const dayType = i % 3;
    if (dayType === 0) return { type: 'credits', amount: 100 + i * 10 };
    if (dayType === 1) return { type: 'booster', booster: 'shield', amount: 1 + Math.floor(i / 7) };
    return { type: 'booster', booster: 'rapidFire', amount: 1 + Math.floor(i / 7) };
});

const ACHIEVEMENTS: Achievement[] = [
    { id: 'firstKill', name: 'First Kill', description: 'Destroy your first enemy.', icon: '🏆', condition: (stats) => stats.totalKills >= 1 },
    { id: 'wave5', name: 'Wave 5 Survivor', description: 'Survive until wave 5.', icon: '🌊', condition: (_, __, wave) => wave > 5 },
    { id: 'centurion', name: 'Centurion', description: 'Destroy 100 enemies in total.', icon: '💥', condition: (stats) => stats.totalKills >= 100 },
    { id: 'level10', name: 'Level 10', description: 'Reach player level 10.', icon: '⭐', condition: (_, level) => level >= 10 },
    { id: 'booster10', name: 'Booster Enthusiast', description: 'Use 10 boosters in total.', icon: '🚀', condition: (stats) => stats.boostersUsed >= 10 },
];

const BATTLE_PASS_REWARDS = [
    { level: 2, type: 'credits', amount: 200 },
    { level: 3, type: 'booster', booster: 'shield', amount: 2 },
    { level: 5, type: 'shipSkin', ship: 'ranger', skin: 'gold' },
    { level: 7, type: 'booster', booster: 'rapidFire', amount: 3 },
    { level: 10, type: 'credits', amount: 1000 },
];

let simulatedPlayers = ["StarLord", "Nova", "Cosmo", "Orion", "Celeste"];
const profanityList = ["badword1", "badword2"];

// Audio
let audioCtx: AudioContext;
let sfxGainNode: GainNode;
let musicGainNode: GainNode;
let musicSource: AudioBufferSourceNode | null = null;
const decodedAudioBuffers: { [key: string]: AudioBuffer } = {};

const SOUND_ASSETS: { [key: string]: string } = {
    laser: 'data:audio/wav;base64,UklGRigAAABXQVZFZm10IBIAAAABAAEARKwAAIhYAQACABAAAABkYXRhAgAAAAEA',
    explosion: 'data:audio/wav;base64,UklGRkoAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAAABkYXRhQgAAAEw/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/Pz8/P-8BAA',
    waveStart: 'data:audio/wav;base64,UklGRlIAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAAABkYXRhUAAAAIAAAP//h4eHiomKi4yNjo+QkZKTlJWWl5iZmpucnZ6foKGio6SlpqeoqaqrrK2ur7CxsrO0tba3uLm6u7y9vr/AwcLDxMXGx8jJysvMzc7P0NHS09TV1tfY2drb3N3e3+Dh4uPk5ebn6Onq6+zt7u/w8fLz9PX29/j5+vv8/f7/AAMCAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+/w=='
};

// =================================================================================
// Classes for Game Objects
// =================================================================================

class Player {
    x: number;
    y: number;
    width: number;
    height: number;
    speed: number;
    fireCooldown: number;
    lastFireTime: number;
    img: HTMLImageElement;
    invincible: boolean;
    invincibilityTimer: number;
    shieldActive: boolean;
    shieldImg: HTMLImageElement;
    weaponBoostActive: boolean;
    weaponBoostTimer: number;
    speedBoostActive: boolean;
    speedBoostTimer: number;
    glowColor: string | null;
    thrusterParticles: Particle[];

    constructor() {
        this.x = canvas.width / 2;
        this.y = canvas.height - 80;
        this.width = PLAYER_SIZE;
        this.height = PLAYER_SIZE;
        this.speed = SHIP_CONFIG[gameState.selectedShip].speed + gameState.upgrades.speed;
        this.fireCooldown = 200 - gameState.upgrades.fireRate * 20;
        this.lastFireTime = 0;
        this.img = new Image();
        this.updateShipSVG();
        this.invincible = false;
        this.invincibilityTimer = 0;
        this.shieldActive = false;
        this.shieldImg = new Image();
        this.shieldImg.src = `data:image/svg+xml;base64,${btoa('<svg width="70" height="70" viewBox="0 0 70 70"><circle cx="35" cy="35" r="33" fill="none" stroke="deepskyblue" stroke-width="2" stroke-opacity="0.7"/></svg>')}`;
        this.weaponBoostActive = false;
        this.weaponBoostTimer = 0;
        this.speedBoostActive = false;
        this.speedBoostTimer = 0;
        this.glowColor = null;
        this.thrusterParticles = [];
    }

    updateShipSVG() {
        const shipConf = SHIP_CONFIG[gameState.selectedShip];
        const selectedSkinId = gameState.selectedSkins[gameState.selectedShip] || 'default';
        const skin = shipConf.skins.find(s => s.id === selectedSkinId);
        const color = skin ? skin.color : 'cyan';
        const svgString = shipConf.svg.replace(/stroke="[^"]+"/, `stroke="${color}"`);
        this.img.src = `data:image/svg+xml;base64,${btoa(svgString)}`;
    }

    draw() {
        this.thrusterParticles.forEach(p => p.draw());
        if (this.invincible && Math.floor(Date.now() / 100) % 2 === 0) {
            // Blink when invincible
        } else {
            if (this.glowColor) {
                ctx.shadowBlur = 20;
                ctx.shadowColor = this.glowColor;
            }
            ctx.drawImage(this.img, this.x - this.width / 2, this.y - this.height / 2, this.width, this.height);
            ctx.shadowBlur = 0;
        }

        if (this.shieldActive) {
            ctx.drawImage(this.shieldImg, this.x - 35, this.y - 35, 70, 70);
        }
    }

    update() {
        this.handleMovement();
        this.handleShooting();
        this.updateThruster();

        if (this.invincibilityTimer > 0) {
            this.invincibilityTimer -= 1000 / 60;
            if (this.invincibilityTimer <= 0) {
                this.invincible = false;
            }
        }

        if (this.weaponBoostTimer > 0) {
            this.weaponBoostTimer -= 1000 / 60;
            if (this.weaponBoostTimer <= 0) {
                this.weaponBoostActive = false;
                this.fireCooldown = 200 - gameState.upgrades.fireRate * 20;
                this.updateGlow();
            }
        }
        if (this.speedBoostTimer > 0) {
            this.speedBoostTimer -= 1000 / 60;
            if (this.speedBoostTimer <= 0) {
                this.speedBoostActive = false;
                this.speed = SHIP_CONFIG[gameState.selectedShip].speed + gameState.upgrades.speed;
                this.updateGlow();
            }
        }
    }
    
    updateGlow() {
        if (this.weaponBoostActive) this.glowColor = '#00BFFF';
        else if (this.speedBoostActive) this.glowColor = '#FFD700';
        else this.glowColor = null;
    }

    updateThruster() {
        this.thrusterParticles.push(new Particle(this.x, this.y + this.height / 2, 'orange', 2, 0, 3));
        this.thrusterParticles = this.thrusterParticles.filter(p => p.life > 0);
        this.thrusterParticles.forEach(p => p.update());
    }

    handleMovement() {
        const currentSpeed = this.speed;
        if (keys['a'] || keys['ArrowLeft']) this.x -= currentSpeed;
        if (keys['d'] || keys['ArrowRight']) this.x += currentSpeed;
        if (keys['w'] || keys['ArrowUp']) this.y -= currentSpeed;
        if (keys['s'] || keys['ArrowDown']) this.y += currentSpeed;

        this.x = Math.max(this.width / 2, Math.min(canvas.width - this.width / 2, this.x));
        this.y = Math.max(this.height / 2, Math.min(canvas.height - this.height / 2, this.y));
    }

    handleShooting() {
        if (keys[' '] && Date.now() - this.lastFireTime > this.fireCooldown) {
            this.shoot();
            this.lastFireTime = Date.now();
        }
    }

    shoot() {
        projectiles.push(new Projectile(this.x, this.y));
        playSound('laser');
    }

    takeDamage() {
        if (this.invincible) return;
        if (this.shieldActive) {
            this.shieldActive = false;
            this.invincible = true;
            this.invincibilityTimer = 1500;
            return;
        }

        gameState.health--;
        updateHealthBar();
        createScreenShake(5, 0.2);
        playSound('playerHit');

        if (gameState.health <= 0) {
            lives--;
            updateLivesDisplay();
            if (lives <= 0) {
                gameOver();
            } else {
                gameState.health = gameState.maxHealth;
                this.invincible = true;
                this.invincibilityTimer = 3000;
            }
        } else {
            this.invincible = true;
            this.invincibilityTimer = 1500;
        }
    }
    
    applyPowerUp(type: 'health' | 'weaponBoost' | 'speedBoost') {
        playSound('achievement'); // Placeholder for powerup sound
        if (type === 'health') {
            gameState.health = Math.min(gameState.maxHealth, gameState.health + Math.floor(gameState.maxHealth * 0.25));
            updateHealthBar();
        } else if (type === 'weaponBoost') {
            this.weaponBoostActive = true;
            this.weaponBoostTimer = 10000;
            this.fireCooldown = (200 - gameState.upgrades.fireRate * 20) / 2;
            this.updateGlow();
        } else if (type === 'speedBoost') {
            this.speedBoostActive = true;
            this.speedBoostTimer = 10000;
            this.speed = (SHIP_CONFIG[gameState.selectedShip].speed + gameState.upgrades.speed) * 1.5;
            this.updateGlow();
        }
    }
}

class Projectile {
    x: number;
    y: number;
    width: number;
    height: number;
    constructor(x: number, y: number) {
        this.x = x;
        this.y = y;
        this.width = 5;
        this.height = 15;
    }
    draw() {
        ctx.fillStyle = 'cyan';
        ctx.shadowBlur = 10;
        ctx.shadowColor = 'cyan';
        ctx.fillRect(this.x - this.width / 2, this.y, this.width, this.height);
        ctx.shadowBlur = 0;
    }
    update() {
        this.y -= PROJECTILE_SPEED;
    }
}

class Enemy {
    x: number;
    y: number;
    width: number;
    height: number;
    speed: number;
    config: EnemyConfig;
    img: HTMLImageElement;
    health: number;
    lastFireTime: number;

    constructor(x: number, y: number, type: keyof typeof ENEMY_CONFIG) {
        this.config = ENEMY_CONFIG[type];
        this.x = x;
        this.y = y;
        const widthMatch = this.config.svg.match(/viewBox="0 0 (\d+)/);
        const heightMatch = this.config.svg.match(/viewBox="0 0 \d+ (\d+)/);
        this.width = widthMatch ? parseInt(widthMatch[1]) * 0.8 : 40;
        this.height = heightMatch ? parseInt(heightMatch[1]) * 0.8 : 40;
        this.speed = this.config.speed;
        this.health = this.config.health;
        this.img = new Image();
        this.img.src = `data:image/svg+xml;base64,${btoa(this.config.svg)}`;
        this.lastFireTime = Date.now();
    }

    draw() {
        ctx.drawImage(this.img, this.x - this.width / 2, this.y - this.height / 2, this.width, this.height);
    }

    update() {
        this.y += this.speed;
        if ('fireRate' in this.config && this.config.fireRate && Date.now() - this.lastFireTime > 1000 * (60 / this.config.fireRate)) {
            enemyProjectiles.push(new EnemyProjectile(this.x, this.y + this.height / 2));
            playSound('enemyLaser');
            this.lastFireTime = Date.now();
        }
    }
    
    takeDamage(amount: number) {
        this.health -= amount;
        for (let i = 0; i < 3; i++) {
            particles.push(new Particle(this.x, this.y, 'white', 2));
        }
    }
}

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
    }
    draw() {
        ctx.save();
        ctx.globalAlpha = this.life / this.maxLife;
        if (this.glow) {
            ctx.shadowBlur = 10;
            ctx.shadowColor = this.color;
        }
        ctx.fillStyle = this.color;
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();
    }
    update() {
        this.x += this.speedX;
        this.y += this.speedY;
        this.life -= 2;
    }
}

class Star {
    x: number;
    y: number;
    size: number;
    speed: number;
    opacity: number;
    layer: number;

    constructor() {
        this.x = Math.random() * canvas.width;
        this.y = Math.random() * canvas.height;
        this.layer = Math.ceil(Math.random() * 3);
        this.size = this.layer * 0.7;
        this.speed = this.layer * 0.5;
        this.opacity = this.layer / 3 * 0.8;
    }
    draw() {
        ctx.fillStyle = `rgba(255, 255, 255, ${this.opacity})`;
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
    }
}

class EnemyProjectile extends Projectile {
    speedX: number;
    speedY: number;

    constructor(x: number, y: number) {
        super(x, y);
        this.width = 5;
        this.height = 10;
        this.speedX = 0;
        this.speedY = PROJECTILE_SPEED * 0.7;
    }
    draw() {
        ctx.fillStyle = 'red';
        ctx.shadowBlur = 10;
        ctx.shadowColor = 'red';
        ctx.fillRect(this.x - this.width / 2, this.y, this.width, this.height);
        ctx.shadowBlur = 0;
    }
    update() {
        this.y += this.speedY;
        this.x += this.speedX;
    }
}

class PowerUp {
    x: number;
    y: number;
    size: number;
    speed: number;
    config: PowerUpConfig;
    img: HTMLImageElement;

    constructor(x: number, y: number, type: keyof typeof POWERUP_CONFIG) {
        this.config = POWERUP_CONFIG[type];
        this.x = x;
        this.y = y;
        this.size = 30;
        this.speed = 1.5;
        this.img = new Image();
        this.img.src = `data:image/svg+xml;base64,${btoa(this.config.svg)}`;
    }

    draw() {
        ctx.shadowBlur = 15;
        ctx.shadowColor = this.config.color;
        ctx.drawImage(this.img, this.x - this.size / 2, this.y - this.size / 2, this.size, this.size);
        ctx.shadowBlur = 0;
    }

    update() {
        this.y += this.speed;
    }
}

class Boss {
    x: number;
    y: number;
    width: number;
    height: number;
    speed: number;
    health: number;
    maxHealth: number;
    img: HTMLImageElement;
    phase: 1 | 2;
    lastFireTime: number;
    lastMinionSpawn: number;
    lastLaserTime: number;
    direction: number;

    constructor() {
        this.width = 200;
        this.height = 100;
        this.x = canvas.width / 2;
        this.y = -this.height;
        this.speed = 2;
        this.maxHealth = 200;
        this.health = this.maxHealth;
        this.phase = 1;
        this.lastFireTime = 0;
        this.lastMinionSpawn = 0;
        this.lastLaserTime = 0;
        this.direction = 1;
        this.img = new Image();
        this.img.src = `data:image/svg+xml;base64,${btoa(`<svg viewBox="0 0 200 100"><rect x="0" y="20" width="200" height="60" fill="none" stroke="purple" stroke-width="4"/><path d="M20 20 L0 50 L20 80 M180 20 L200 50 L180 80 M50 0 L70 20 M130 20 L150 0" stroke="purple" stroke-width="3"/></svg>`)}`;
    }

    draw() {
        ctx.drawImage(this.img, this.x - this.width / 2, this.y - this.height / 2, this.width, this.height);
    }

    update() {
        if (this.y < 150) {
            this.y += 1;
            return;
        }

        this.x += this.speed * this.direction;
        if (this.x > canvas.width - this.width / 2 || this.x < this.width / 2) {
            this.direction *= -1;
        }

        if (this.health <= this.maxHealth / 2 && this.phase === 1) {
            this.phase = 2;
            this.speed *= 1.5;
        }
        
        if(this.phase === 1) this.phase1Attack();
        else this.phase2Attack();
    }
    
    phase1Attack() {
        if (Date.now() - this.lastFireTime > 1000) {
             this.spreadShot(5, 60);
            this.lastFireTime = Date.now();
        }
        if (Date.now() - this.lastMinionSpawn > 5000) {
            enemies.push(new Enemy(this.x - 50, this.y + this.height/2, 'scout'));
            enemies.push(new Enemy(this.x + 50, this.y + this.height/2, 'scout'));
            this.lastMinionSpawn = Date.now();
        }
    }
    
    phase2Attack() {
        if (Date.now() - this.lastLaserTime > 4000) {
            lasers.push(new Laser(player.x, this.y + this.height/2, 2000));
            this.lastLaserTime = Date.now();
        }
         if (Date.now() - this.lastFireTime > 700) { // Fires faster in phase 2
            this.spreadShot(3, 40);
            this.lastFireTime = Date.now();
        }
    }
    
    spreadShot(count: number, angle: number) {
        const angleStep = angle / (count -1);
        const startAngle = -angle / 2;
        for(let i = 0; i < count; i++) {
            const currentAngle = (startAngle + i * angleStep) * (Math.PI / 180);
            const proj = new EnemyProjectile(this.x, this.y + this.height / 2);
            proj.speedX = Math.sin(currentAngle) * 4;
            proj.speedY = Math.cos(currentAngle) * 4;
            enemyProjectiles.push(proj);
        }
        playSound('enemyLaser');
    }

    takeDamage(amount: number) {
        this.health -= amount;
        updateBossHealthBar();
    }
}

class Laser {
    x: number;
    y: number;
    width: number;
    duration: number;
    startTime: number;
    warningTime: number;

    constructor(x: number, y: number, duration: number) {
        this.x = x;
        this.y = y;
        this.width = 15;
        this.duration = duration;
        this.startTime = Date.now();
        this.warningTime = 1000;
    }
    
    draw() {
        const elapsed = Date.now() - this.startTime;
        if (elapsed < this.warningTime) {
            ctx.fillStyle = 'rgba(255, 0, 0, 0.3)';
            ctx.fillRect(this.x - 2, this.y, 4, canvas.height - this.y);
        } else {
            ctx.fillStyle = 'red';
            ctx.shadowBlur = 20;
            ctx.shadowColor = 'red';
            ctx.fillRect(this.x - this.width/2, this.y, this.width, canvas.height - this.y);
            ctx.shadowBlur = 0;
        }
    }

    update() {}
    
    isActive() {
        return Date.now() - this.startTime > this.warningTime;
    }
}

// =================================================================================
// Game Initialization
// =================================================================================
window.onload = () => {
    canvas = document.getElementById('game-canvas') as HTMLCanvasElement;
    ctx = canvas.getContext('2d')!;
    
    // Check if running in Electron (standalone mode)
    const isElectron = navigator.userAgent.toLowerCase().indexOf(' electron/') > -1;
    
    gameContainer = document.getElementById('game-container')!;
    loginScreen = document.getElementById('login-screen')!;
    startScreen = document.getElementById('start-screen')!;
    gameOverScreen = document.getElementById('game-over-screen')!;
    gameUi = document.getElementById('game-ui')!;
    scoreEl = document.getElementById('score')!;
    livesEl = document.getElementById('lives')!;
    levelEl = document.getElementById('level')!;
    creditsEl = document.getElementById('credits')!;
    xpBar = document.getElementById('xp-bar')!;
    healthBar = document.getElementById('health-bar')!;
    finalScoreEl = document.getElementById('final-score')!;
    creditsEarnedEl = document.getElementById('credits-earned')!;
    levelUpNotification = document.getElementById('level-up-notification')!;
    achievementToast = document.getElementById('achievement-toast')!;
    waveCounterEl = document.getElementById('wave-counter')!;
    waveNotificationEl = document.getElementById('wave-notification')!;
    welcomeMessageEl = document.getElementById('welcome-message')!;
    playerCounterEl = document.getElementById('player-counter')!;
    shieldBoosterCountEl = document.getElementById('shield-booster-count')!;
    rapidFireBoosterCountEl = document.getElementById('rapid-fire-booster-count')!;
    doubleCreditsBoosterCountEl = document.getElementById('double-credits-booster-count')!;
    usernameInput = document.getElementById('username') as HTMLInputElement;
    emailInput = document.getElementById('email') as HTMLInputElement;
    passwordInput = document.getElementById('password') as HTMLInputElement;
    loginErrorEl = document.getElementById('login-error')!;
    chatContainer = document.getElementById('chat-container')!;
    chatMessages = document.getElementById('chat-messages')!;
    chatInput = document.getElementById('chat-input') as HTMLInputElement;
    sfxVolumeSlider = document.getElementById('sfx-volume') as HTMLInputElement;
    musicVolumeSlider = document.getElementById('music-volume') as HTMLInputElement;
    effectsToggle = document.getElementById('effects-toggle') as HTMLInputElement;
    hudScaleSlider = document.getElementById('hud-scale') as HTMLInputElement;
    hudPosTopRadio = document.getElementById('hud-pos-top') as HTMLInputElement;
    hudPosBottomRadio = document.getElementById('hud-pos-bottom') as HTMLInputElement;
    mobileControls = document.getElementById('mobile-controls')!;
    joystickArea = document.getElementById('joystick-area')!;
    joystickThumb = document.getElementById('joystick-thumb')!;
    bossHealthContainer = document.getElementById('boss-health-container')!;
    bossHealthBar = document.getElementById('boss-health-bar')!;
    fullscreenToggleButton = document.getElementById('fullscreen-toggle-button') as HTMLButtonElement;

    resizeCanvas();
    
    // If running in Electron, skip login and go straight to start screen
    if (isElectron) {
        initAudio();
        loadGameState('StandalonePlayer');
        gameState.username = 'Player';
        showScreen('start-screen');
        startMenuAnimation();
        document.getElementById('admin-panel-button')!.style.display = 'none';
        chatContainer.style.display = 'none'; // Hide chat in standalone
    } else {
        loadGameState('guest_default');
    }
    
    setupEventListeners();
    initStars();
    updateFullscreenButtonText();
    populateBoosterIcons();
    
    // Simulate player count fluctuation
    setInterval(() => {
        const baseCount = 123;
        const fluctuation = Math.floor(Math.random() * 20) - 10;
        playerCounterEl.innerText = `Players Online: ${baseCount + fluctuation}`;
    }, 5000);
    
    setInterval(() => {
        if (!gameRunning && simulatedPlayers.length > 0) {
            const randomPlayer = simulatedPlayers[Math.floor(Math.random() * simulatedPlayers.length)];
            const messages = ["gg", "nice shot", "lol", "close one", "anybody wanna team up?"];
            addChatMessage(randomPlayer, messages[Math.floor(Math.random() * messages.length)]);
        }
    }, 10000);
};

// =================================================================================
// Game Loop
// =================================================================================
function gameLoop() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    drawBackground();
    
    if (gameRunning) {
        handleInput();
        player.update();
        player.draw();

        if (boss) {
            boss.update();
            boss.draw();
        }

        updateAndDraw(projectiles);
        updateAndDraw(enemies);
        updateAndDraw(particles);
        updateAndDraw(enemyProjectiles);
        updateAndDraw(powerUps);
        updateAndDraw(lasers);

        handleCollisions();

        particles = particles.filter(p => p.life > 0);
        projectiles = projectiles.filter(p => p.y > 0);
        enemyProjectiles = enemyProjectiles.filter(p => p.y < canvas.height && p.x > 0 && p.x < canvas.width);
        enemies = enemies.filter(e => e.y < canvas.height + e.height);
        powerUps = powerUps.filter(p => p.y < canvas.height);
        lasers = lasers.filter(l => Date.now() - l.startTime < l.duration);

        if (!boss && enemies.length === 0) {
            nextWave();
        }
    } else {
        updateAndDraw(stars);
    }

    animationFrameId = requestAnimationFrame(gameLoop);
}

function updateAndDraw(arr: any[]) {
    for (let i = arr.length - 1; i >= 0; i--) {
        arr[i].update();
        arr[i].draw();
    }
}

function handleInput() {
    // This is handled by event listeners updating the 'keys' object
}

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

function createExplosion(x: number, y: number, color: string) {
    if(!effectsEnabled) return;
    for (let i = 0; i < PARTICLE_COUNT; i++) {
        particles.push(new Particle(x, y, color));
    }
    playSound('explosion');
    createScreenShake(3, 0.1);
}

function createScreenShake(intensity: number, durationSeconds: number) {
    if(!effectsEnabled) return;
    const shakeAmount = intensity;
    const shakeDuration = durationSeconds * 1000;
    let startTime = Date.now();
    
    function shake() {
        const elapsed = Date.now() - startTime;
        if (elapsed < shakeDuration) {
            const x = (Math.random() - 0.5) * shakeAmount;
            const y = (Math.random() - 0.5) * shakeAmount;
            canvas.style.transform = `translate(${x}px, ${y}px)`;
            requestAnimationFrame(shake);
        } else {
            canvas.style.transform = 'translate(0, 0)';
        }
    }
    shake();
}

// =================================================================================
// Event Listeners
// =================================================================================

function setupEventListeners() {
    window.addEventListener('resize', resizeCanvas);
    document.addEventListener('keydown', (e) => {
        keys[e.key.toLowerCase()] = true;
        if (e.key === 'Escape' && gameRunning) {
            quitGame();
        }
    });
    document.addEventListener('keyup', (e) => keys[e.key.toLowerCase()] = false);
    
    document.getElementById('signin-button')!.addEventListener('click', handleSignIn);
    document.getElementById('signup-button')!.addEventListener('click', handleSignUp);
    document.getElementById('guest-button')!.addEventListener('click', handleGuestLogin);
    
    document.getElementById('start-button')!.addEventListener('click', () => {
        //showModal('server-browser-modal');
        // TEMP: Direct start
        startMatchmaking();
    });
    document.getElementById('hangar-button')!.addEventListener('click', () => showModal('hangar-modal'));
    document.getElementById('upgrades-button')!.addEventListener('click', () => showModal('upgrades-modal'));
    document.getElementById('map-selector-button')!.addEventListener('click', () => showModal('map-selector-modal'));
    document.getElementById('achievements-button')!.addEventListener('click', () => showModal('achievements-modal'));
    document.getElementById('daily-reward-button')!.addEventListener('click', () => showModal('daily-reward-modal'));
    document.getElementById('settings-button')!.addEventListener('click', () => showModal('settings-modal'));
    document.getElementById('admin-panel-button')!.addEventListener('click', () => showModal('admin-panel-modal'));
    document.getElementById('battle-pass-button')!.addEventListener('click', () => showModal('battle-pass-modal'));

    document.getElementById('restart-button')!.addEventListener('click', startGame);
    document.getElementById('main-menu-button')!.addEventListener('click', () => {
        quitGame();
    });

    document.querySelectorAll('.close-button').forEach(btn => btn.addEventListener('click', (e) => {
        (e.target as HTMLElement).closest('.modal')!.classList.remove('active');
        playSound('uiClick');
    }));
    
    sfxVolumeSlider.addEventListener('input', (e) => {
        sfxVolume = parseFloat((e.target as HTMLInputElement).value);
        if(sfxGainNode) sfxGainNode.gain.setValueAtTime(sfxVolume, audioCtx.currentTime);
        gameState.settings.sfxVolume = sfxVolume;
        saveGameState();
    });
    musicVolumeSlider.addEventListener('input', (e) => {
        musicVolume = parseFloat((e.target as HTMLInputElement).value);
        if(musicGainNode) musicGainNode.gain.setValueAtTime(musicVolume, audioCtx.currentTime);
        gameState.settings.musicVolume = musicVolume;
        saveGameState();
    });
    effectsToggle.addEventListener('change', (e) => {
        effectsEnabled = (e.target as HTMLInputElement).checked;
        gameState.settings.effectsEnabled = effectsEnabled;
        saveGameState();
    });
    fullscreenToggleButton.addEventListener('click', toggleFullscreen);
    document.addEventListener('fullscreenchange', updateFullscreenButtonText);


    hudScaleSlider.addEventListener('input', (e) => {
        const scale = (e.target as HTMLInputElement).value;
        gameUi.style.setProperty('--hud-scale', scale);
        gameState.settings.hudScale = parseFloat(scale);
        saveGameState();
    });
    document.querySelectorAll('input[name="hud-position"]').forEach(radio => {
        radio.addEventListener('change', (e) => {
            const pos = (e.target as HTMLInputElement).value as 'top' | 'bottom';
            if (pos === 'bottom') gameUi.classList.add('bottom');
            else gameUi.classList.remove('bottom');
            gameState.settings.hudPosition = pos;
            saveGameState();
        });
    });

    setupMobileControls();
    
    chatInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' && chatInput.value.trim() !== '') {
            let message = chatInput.value.trim();
            profanityList.forEach(word => {
                const regex = new RegExp(`\\b${word}\\b`, 'gi');
                message = message.replace(regex, '****');
            });
            addChatMessage(gameState.username, message);
            chatInput.value = '';
        }
    });
    
    document.getElementById('grant-credits-button')!.addEventListener('click', () => {
        const amount = parseInt((document.getElementById('grant-credits-amount') as HTMLInputElement).value);
        if (!isNaN(amount)) {
            gameState.credits += amount;
            saveGameState();
            updateUI();
            populateAdminPanel();
        }
    });
    document.getElementById('unlock-all-maps-button')!.addEventListener('click', () => {
        gameState.unlockedMaps = Object.keys(MAP_CONFIG).map(Number);
        saveGameState();
        populateAdminPanel();
    });
    document.getElementById('ban-player-button')!.addEventListener('click', () => {
        const nameToBan = (document.getElementById('ban-player-name') as HTMLInputElement).value;
        simulatedPlayers = simulatedPlayers.filter(p => p !== nameToBan);
        populateAdminPanel();
    });
    
    // Booster Selection Logic
    document.querySelectorAll('.booster-item').forEach(item => {
        item.addEventListener('click', () => {
            if (item.classList.contains('selected')) {
                item.classList.remove('selected');
            } else {
                document.querySelectorAll('.booster-item').forEach(other => other.classList.remove('selected'));
                item.classList.add('selected');
            }
            playSound('uiClick');
        });
    });
}

function setupMobileControls() {
    if ('ontouchstart' in window) {
        mobileControls.style.display = 'flex';
        let joystickActive = false;
        let joystickStartX = 0, joystickStartY = 0;
        
        const handleMove = (x: number, y: number) => {
            const rect = joystickArea.getBoundingClientRect();
            joystickStartX = rect.left + rect.width / 2;
            joystickStartY = rect.top + rect.height / 2;
            
            const deltaX = x - joystickStartX;
            const deltaY = y - joystickStartY;
            const angle = Math.atan2(deltaY, deltaX);
            const distance = Math.min(joystickArea.clientWidth / 2 - joystickThumb.clientWidth / 2, Math.hypot(deltaX, deltaY));
            
            joystickThumb.style.transform = `translate(${Math.cos(angle) * distance}px, ${Math.sin(angle) * distance}px)`;

            keys['w'] = deltaY < -10;
            keys['s'] = deltaY > 10;
            keys['a'] = deltaX < -10;
            keys['d'] = deltaX > 10;
        };

        joystickArea.addEventListener('touchstart', (e) => {
            e.preventDefault();
            joystickActive = true;
            const touch = e.touches[0];
            handleMove(touch.clientX, touch.clientY);
        }, { passive: false });

        joystickArea.addEventListener('touchmove', (e) => {
            e.preventDefault();
            if (!joystickActive) return;
            const touch = e.touches[0];
            handleMove(touch.clientX, touch.clientY);
        }, { passive: false });

        joystickArea.addEventListener('touchend', (e) => {
            e.preventDefault();
            joystickActive = false;
            joystickThumb.style.transform = `translate(0px, 0px)`;
            keys['w'] = keys['s'] = keys['a'] = keys['d'] = false;
        }, { passive: false });

        const shootButton = document.getElementById('shoot-button-mobile')!;
        shootButton.addEventListener('touchstart', (e) => { e.preventDefault(); keys[' '] = true; }, { passive: false });
        shootButton.addEventListener('touchend', (e) => { e.preventDefault(); keys[' '] = false; }, { passive: false });
    }
}


function resizeCanvas() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
}

// =================================================================================
// Game State & Logic
// =================================================================================

function startMatchmaking() {
    // This is a simulation
    const matchmakingModal = document.getElementById('matchmaking-modal')!;
    const matchmakingStatus = document.getElementById('matchmaking-status')!;
    const playerSlots = document.querySelectorAll('.player-slot');
    
    (playerSlots[0] as HTMLElement).innerText = gameState.username;
    (playerSlots[1] as HTMLElement).innerText = 'Finding...';
    (playerSlots[2] as HTMLElement).innerText = 'Finding...';
    
    showModal('matchmaking-modal');
    
    setTimeout(() => {
        if(matchmakingStatus) matchmakingStatus.innerText = 'Found Player 2!';
        if(playerSlots[1]) (playerSlots[1] as HTMLElement).innerText = 'StarPilot_42';
    }, 1500);
    
    setTimeout(() => {
        if(matchmakingStatus) matchmakingStatus.innerText = 'Found Player 3!';
        if(playerSlots[2]) (playerSlots[2] as HTMLElement).innerText = 'Cosmo_Gamer';
    }, 3000);
    
    setTimeout(() => {
        if(matchmakingStatus) matchmakingStatus.innerText = 'Match Found! Starting...';
    }, 4000);

    setTimeout(() => {
        if(matchmakingModal) matchmakingModal.classList.remove('active');
        startGame();
    }, 5000);
}

function startGame() {
    playSound('uiClick');
    showScreen('none');
    gameUi.style.display = 'block';
    gameRunning = true;
    score = 0;
    lives = 3 + gameState.upgrades.extraLife;
    currentWave = 0;
    gameState.health = gameState.maxHealth;
    enemies = []; projectiles = []; enemyProjectiles = []; powerUps = []; particles = []; boss = null; lasers = [];
    
    player = new Player();
    
    const activeBoosterEl = document.querySelector('.booster-item.selected');
    if (activeBoosterEl) {
        const boosterType = activeBoosterEl.getAttribute('data-booster');
        if (boosterType) {
            applyBooster(boosterType);
        }
        activeBoosterEl.classList.remove('selected');
    }

    updateScoreDisplay();
    updateLivesDisplay();
    updateHealthBar();
    
    if(animationFrameId) cancelAnimationFrame(animationFrameId);
    gameLoop();
    
    playMusic('music');
    nextWave();
}

function gameOver() {
    gameRunning = false;
    stopMusic();
    showScreen('game-over-screen');
    const boosterUsed = gameState.boosters.doubleCredits < (JSON.parse(localStorage.getItem(`space_shooter_${gameState.username}`) || '{}').boosters?.doubleCredits || 0);
    const creditsMultiplier = boosterUsed ? 2 : 1;
    const creditsEarned = Math.floor(score / 10) * creditsMultiplier;

    finalScoreEl.innerText = score.toString();
    creditsEarnedEl.innerText = creditsEarned.toString();
    gameState.credits += creditsEarned;
    gameState.stats.wavesSurvived = Math.max(gameState.stats.wavesSurvived, currentWave);
    checkAchievements(true);
    saveGameState();
    updateUI();
}

function quitGame() {
    gameRunning = false;
    stopMusic();
    showScreen('start-screen');
    if(animationFrameId) cancelAnimationFrame(animationFrameId);
    animationFrameId = 0; // Reset
    startMenuAnimation();
    updateUI();
}


function nextWave() {
    currentWave++;
    updateWaveDisplay();
    showWaveNotification(`Wave ${currentWave}`);
    playSound('waveStart');
    
    if (currentWave % BOSS_WAVE === 0) {
        spawnBoss();
    } else {
        spawnEnemies();
    }
}

function spawnEnemies() {
    const enemyCount = Math.min(5 + currentWave * 2, 20);
    for (let i = 0; i < enemyCount; i++) {
        const x = Math.random() * (canvas.width - 50) + 25;
        const y = Math.random() * -canvas.height;
        let type: keyof typeof ENEMY_CONFIG = 'scout';
        if (currentWave > 2 && Math.random() > 0.7) type = 'brute';
        if (currentWave > 4 && Math.random() > 0.6) type = 'bomber';
        enemies.push(new Enemy(x, y, type));
    }
}

function spawnBoss() {
    stopMusic();
    setTimeout(() => {
        boss = new Boss();
        showBossHealthBar();
    }, 2000);
}


function handleCollisions() {
    // Projectiles vs Enemies
    for (let i = projectiles.length - 1; i >= 0; i--) {
        let projectileHit = false;
        for (let j = enemies.length - 1; j >= 0; j--) {
            if (isColliding(projectiles[i], enemies[j])) {
                enemies[j].takeDamage(1);
                if (enemies[j].health <= 0) {
                    createExplosion(enemies[j].x, enemies[j].y, 'orange');
                    updateScore(enemies[j].config.points);
                    gameState.stats.totalKills++;
                    if (Math.random() < 0.15) spawnPowerUp(enemies[j].x, enemies[j].y);
                    enemies.splice(j, 1);
                }
                projectiles.splice(i, 1);
                projectileHit = true;
                break; 
            }
        }
        if(projectileHit) continue;
        
        // Projectiles vs Boss
        if(boss && isColliding(projectiles[i], boss)) {
            boss.takeDamage(1);
            projectiles.splice(i, 1);
            if(boss.health <= 0) {
                for (let k = 0; k < 5; k++) {
                    setTimeout(() => createExplosion(boss!.x + (Math.random() - 0.5) * boss!.width, boss!.y + (Math.random() - 0.5) * boss!.height, 'purple'), k * 200);
                }
                createScreenShake(10, 1);
                updateScore(1000);
                boss = null;
                hideBossHealthBar();
                playMusic('music');
            }
        }
    }
    
    // Player vs Dangers
    if (!player.invincible) {
        for (const enemy of enemies) {
            if (isColliding(player, enemy)) { player.takeDamage(); break; }
        }
        for (let i = enemyProjectiles.length - 1; i >= 0; i--) {
             if (isColliding(player, enemyProjectiles[i])) { player.takeDamage(); enemyProjectiles.splice(i, 1); break; }
        }
        for(const laser of lasers) {
             if(laser.isActive() && isColliding(player, {x: laser.x, y: laser.y, width: laser.width, height: canvas.height})) { player.takeDamage(); break; }
        }
    }
    
    // Player vs PowerUps
    for (let i = powerUps.length - 1; i >= 0; i--) {
        if (isColliding(player, powerUps[i])) { player.applyPowerUp(powerUps[i].config.type); powerUps.splice(i, 1); }
    }
}

function isColliding(objA: any, objB: any) {
    return objA.x - objA.width/2 < objB.x + objB.width/2 &&
           objA.x + objA.width/2 > objB.x - objB.width/2 &&
           objA.y - objA.height/2 < objB.y + objB.height/2 &&
           objA.y + objA.height/2 > objB.y - objB.height/2;
}

function spawnPowerUp(x: number, y: number) {
    const types = Object.keys(POWERUP_CONFIG) as (keyof typeof POWERUP_CONFIG)[];
    const randomType = types[Math.floor(Math.random() * types.length)];
    powerUps.push(new PowerUp(x, y, randomType));
}

// =================================================================================
// UI & Display
// =================================================================================
function showScreen(screenId: string) {
    document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
    if (screenId !== 'none') document.getElementById(screenId)!.classList.add('active');
    if (screenId === 'start-screen') updateUI();
}

function showModal(modalId: string) {
    playSound('uiClick');
    document.querySelectorAll('.modal').forEach(m => m.classList.remove('active'));
    const modal = document.getElementById(modalId)!;
    
    if (modalId === 'hangar-modal') populateHangar();
    if (modalId === 'upgrades-modal') populateUpgrades();
    if (modalId === 'map-selector-modal') populateMapSelector();
    if (modalId === 'achievements-modal') populateAchievements();
    if (modalId === 'daily-reward-modal') populateDailyRewards();
    if (modalId === 'admin-panel-modal') populateAdminPanel();
    if (modalId === 'settings-modal') updateFullscreenButtonText();
    if (modalId === 'battle-pass-modal') populateBattlePass();
    if (modalId === 'server-browser-modal') populateServerBrowser();
    
    modal.classList.add('active');
}


function updateUI() {
    if (!gameState) return;
    levelEl.innerText = `Level: ${gameState.level}`;
    creditsEl.innerText = `Credits: ${gameState.credits}`;
    const xpForNextLevel = gameState.level * XP_PER_LEVEL;
    const levelBaseXp = (gameState.level - 1) * XP_PER_LEVEL;
    const currentLevelXp = gameState.xp - levelBaseXp;
    const totalXpForLevel = xpForNextLevel - levelBaseXp;
    xpBar.style.width = `${(currentLevelXp / totalXpForLevel) * 100}%`;
    
    shieldBoosterCountEl.innerText = `${gameState.boosters.shield}`;
    rapidFireBoosterCountEl.innerText = `${gameState.boosters.rapidFire}`;
    doubleCreditsBoosterCountEl.innerText = `${gameState.boosters.doubleCredits}`;
    
    welcomeMessageEl.innerText = `Welcome, ${gameState.username}!`;
}

function updateScoreDisplay() { scoreEl.innerText = `Score: ${score}`; }
function updateLivesDisplay() { livesEl.innerText = `Lives: ${lives}`; }
function updateWaveDisplay() { waveCounterEl.innerText = `Wave: ${currentWave}`; }
function updateHealthBar() {
    const percent = (gameState.health / gameState.maxHealth) * 100;
    healthBar.style.width = `${percent}%`;
    healthBar.style.backgroundColor = percent > 50 ? '#32cd32' : percent > 25 ? 'orange' : 'red';
}
function showBossHealthBar() {
    bossHealthContainer.style.display = 'block';
    updateBossHealthBar();
}
function hideBossHealthBar() {
    bossHealthContainer.style.display = 'none';
}
function updateBossHealthBar() {
    if (boss) {
        const percent = (boss.health / boss.maxHealth) * 100;
        bossHealthBar.style.width = `${percent}%`;
    }
}

// =================================================================================
// Data Persistence
// =================================================================================
function loadGameState(username: string) {
    const data = localStorage.getItem(`space_shooter_${username}`);
    const defaultState: GameState = {
        username: username,
        level: 1, xp: 0, credits: 0,
        upgrades: { fireRate: 0, speed: 0, extraLife: 0 },
        unlockedShips: ['ranger'], selectedShip: 'ranger',
        unlockedSkins: { ranger: ['default'], interceptor: ['default'], bruiser: ['default'] },
        selectedSkins: { ranger: 'default', interceptor: 'default', bruiser: 'default' },
        unlockedMaps: [1], selectedMap: 1,
        dailyRewardLastClaimed: null, claimedDays: [],
        boosters: { shield: 1, rapidFire: 1, doubleCredits: 1 },
        stats: { totalKills: 0, wavesSurvived: 0, boostersUsed: 0 },
        unlockedAchievements: [],
        settings: { sfxVolume: 0.5, musicVolume: 0.2, effectsEnabled: true, hudScale: 1, hudPosition: 'top'},
        health: 3, maxHealth: 3
    };

    if (data) {
        const parsedData = JSON.parse(data);
        gameState = { ...defaultState, ...parsedData };
        gameState.username = username; // Ensure username is always correct
        // Ensure nested objects are present
        gameState.upgrades = { ...defaultState.upgrades, ...parsedData.upgrades };
        gameState.boosters = { ...defaultState.boosters, ...parsedData.boosters };
        gameState.stats = { ...defaultState.stats, ...parsedData.stats };
        gameState.settings = { ...defaultState.settings, ...parsedData.settings };
        gameState.unlockedSkins = { ...defaultState.unlockedSkins, ...parsedData.unlockedSkins };
        gameState.selectedSkins = { ...defaultState.selectedSkins, ...parsedData.selectedSkins };

    } else {
        gameState = defaultState;
    }
    applySettings();
}

function saveGameState(username: string = gameState.username) {
    if(!username || username.startsWith('guest_')) return;
    localStorage.setItem(`space_shooter_${username}`, JSON.stringify(gameState));
}

// Authentication
function handleSignIn() {
    const user = usernameInput.value.trim();
    const pass = passwordInput.value;
    if (!user || !pass) {
        loginErrorEl.innerText = "Please enter username and password.";
        return;
    }
    if (user === 'admin' && pass === 'password') {
        loginSuccess('admin');
        return;
    }
    const savedData = localStorage.getItem(`acct_${user}`);
    if (savedData && JSON.parse(savedData).password === pass) {
        loginSuccess(user);
    } else {
        loginErrorEl.innerText = "Invalid username or password.";
    }
}

function handleSignUp() {
    const user = usernameInput.value.trim();
    const pass = passwordInput.value;
    const email = emailInput.value.trim();
    if (user.length < 3 || pass.length < 4) {
        loginErrorEl.innerText = "Username must be 3+ chars, password 4+.";
        return;
    }
    if (!email.includes('@')) {
        loginErrorEl.innerText = "Please enter a valid email.";
        return;
    }
    if (localStorage.getItem(`acct_${user}`)) {
        loginErrorEl.innerText = "Username already exists.";
        return;
    }
    localStorage.setItem(`acct_${user}`, JSON.stringify({ password: pass, email: email }));
    loginSuccess(user);
}

function handleGuestLogin() {
    let guestName = usernameInput.value.trim();
    if(guestName.length < 3) {
        loginErrorEl.innerText = "Guest name must be at least 3 characters.";
        return;
    }
    loginSuccess(guestName, true);
}

function loginSuccess(username: string, isGuest = false) {
    playSound('uiClick');
    initAudio();
    loadGameState(isGuest ? `guest_${username}` : username);
    gameState.username = username;
    
    showScreen('start-screen');
    startMenuAnimation();
    document.getElementById('admin-panel-button')!.style.display = (username === 'admin') ? 'inline-block' : 'none';
    chatContainer.style.display = 'flex';
}

function initStars() {
    for (let i = 0; i < STAR_COUNT; i++) stars.push(new Star());
}
function startMenuAnimation() {
    if(!gameRunning && !animationFrameId) gameLoop();
}

function toggleFullscreen() {
    if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen().catch(err => {
            alert(`Error attempting to enable full-screen mode: ${err.message} (${err.name})`);
        });
    }
    else if (document.exitFullscreen) document.exitFullscreen();
}

function updateFullscreenButtonText() {
    if (fullscreenToggleButton) {
        if (document.fullscreenElement) {
            fullscreenToggleButton.innerText = 'Exit Fullscreen';
        } else {
            fullscreenToggleButton.innerText = 'Enter Fullscreen';
        }
    }
}

function applySettings() {
    sfxVolume = gameState.settings.sfxVolume;
    musicVolume = gameState.settings.musicVolume;
    effectsEnabled = gameState.settings.effectsEnabled;
    sfxVolumeSlider.value = String(sfxVolume);
    musicVolumeSlider.value = String(musicVolume);
    effectsToggle.checked = effectsEnabled;
    gameUi.style.setProperty('--hud-scale', String(gameState.settings.hudScale));
    hudScaleSlider.value = String(gameState.settings.hudScale);
     if (gameState.settings.hudPosition === 'bottom') {
        gameUi.classList.add('bottom');
        hudPosBottomRadio.checked = true;
    } else {
        gameUi.classList.remove('bottom');
        hudPosTopRadio.checked = true;
    }
}

async function initAudio() {
    if (audioCtx) {
        if (audioCtx.state === 'suspended') {
            audioCtx.resume();
        }
        return;
    }
    audioCtx = new (window.AudioContext || (window as any).webkitAudioContext)();
    sfxGainNode = audioCtx.createGain();
    sfxGainNode.gain.setValueAtTime(sfxVolume, audioCtx.currentTime);
    sfxGainNode.connect(audioCtx.destination);
    
    musicGainNode = audioCtx.createGain();
    musicGainNode.gain.setValueAtTime(musicVolume, audioCtx.currentTime);
    musicGainNode.connect(audioCtx.destination);

    await Promise.all(Object.keys(SOUND_ASSETS).map(async key => {
        try {
            const response = await fetch(SOUND_ASSETS[key]);
            const arrayBuffer = await response.arrayBuffer();
            decodedAudioBuffers[key] = await audioCtx.decodeAudioData(arrayBuffer);
        } catch (e) { console.error(`Failed to decode audio: ${key}`, e); }
    }));
}

function playSound(sound: string) {
    if (!audioCtx || !decodedAudioBuffers[sound]) return;
    const source = audioCtx.createBufferSource();
    source.buffer = decodedAudioBuffers[sound];
    source.connect(sfxGainNode);
    source.start(0);
}

function playMusic(sound: string) {
    if (!audioCtx || !decodedAudioBuffers[sound] || musicSource) return;
    musicSource = audioCtx.createBufferSource();
    musicSource.buffer = decodedAudioBuffers[sound];
    musicSource.loop = true;
    musicSource.connect(musicGainNode);
    musicSource.start(0);
}

function stopMusic() {
    if (musicSource) { musicSource.stop(); musicSource = null; }
}

function updateScore(points: number) { 
    score += points; 
    gameState.xp += points;
    updateScoreDisplay(); 
    checkLevelUp();
    scoreEl.classList.add('hud-flash');
    setTimeout(() => scoreEl.classList.remove('hud-flash'), 300);
}

function checkLevelUp() {
    const oldLevel = gameState.level;
    const nextLevelXp = gameState.level * XP_PER_LEVEL;
    if (gameState.xp >= nextLevelXp) {
        gameState.level++;
        levelUpNotification.classList.add('show');
        playSound('levelUp');
        setTimeout(() => levelUpNotification.classList.remove('show'), 2000);
        checkAchievements(false);
    }
    if (oldLevel !== gameState.level) {
        checkBattlePassRewards();
    }
    updateUI();
}

function populateHangar() {
    const grid = document.getElementById('ship-grid')!;
    grid.innerHTML = '';
    Object.entries(SHIP_CONFIG).forEach(([key, ship]) => {
        const isUnlocked = gameState.unlockedShips.includes(key);
        const div = document.createElement('div');
        div.className = 'ship-item';
        if (!isUnlocked) div.classList.add('locked');
        if (gameState.selectedShip === key) div.classList.add('selected');

        const selectedSkinId = gameState.selectedSkins[key] || 'default';
        const skin = ship.skins.find(s => s.id === selectedSkinId);
        const color = skin ? skin.color : 'cyan';

        div.innerHTML = `
            <div class="ship-svg-container">${ship.svg.replace(/stroke="[^"]+"/, `stroke="${color}"`)}</div>
            <p>${ship.name}</p>
            ${isUnlocked ? '' : `<p class="unlock-req">Lvl ${ship.unlockLevel}</p><div class="lock-icon">🔒</div>`}
        `;
        if (isUnlocked) {
            div.onclick = () => {
                gameState.selectedShip = key;
                saveGameState();
                populateHangar();
                playSound('uiClick');
            };
        }
        grid.appendChild(div);
    });
    populateShipDetails(gameState.selectedShip);
}

function populateShipDetails(shipKey: string) {
    const detailsContainer = document.getElementById('ship-details-container')!;
    const shipConf = SHIP_CONFIG[shipKey];
    if (!shipConf) {
        detailsContainer.innerHTML = '';
        return;
    }

    const unlockedSkins = gameState.unlockedSkins[shipKey] || ['default'];
    const selectedSkin = gameState.selectedSkins[shipKey] || 'default';

    let skinsHtml = '<h3>Skins</h3><div class="skin-selector">';
    shipConf.skins.forEach(skin => {
        const isUnlocked = unlockedSkins.includes(skin.id);
        const isSelected = skin.id === selectedSkin;
        skinsHtml += `
            <div class="skin-item ${isUnlocked ? '' : 'locked'} ${isSelected ? 'selected' : ''}" data-skin-id="${skin.id}">
                <div class="skin-swatch" style="background-color: ${skin.color};"></div>
                <span>${skin.name}</span>
            </div>
        `;
    });
    skinsHtml += '</div>';
    detailsContainer.innerHTML = skinsHtml;

    detailsContainer.querySelectorAll('.skin-item').forEach(item => {
        item.addEventListener('click', () => {
            if (item.classList.contains('locked')) return;
            const skinId = item.getAttribute('data-skin-id')!;
            gameState.selectedSkins[shipKey] = skinId;
            saveGameState();
            populateHangar(); // Re-render hangar to update selection
            playSound('uiClick');
        });
    });
}


function populateUpgrades() {
    const upgrades = gameState.upgrades;
    const updateUpgradeUI = (type: keyof typeof upgrades, level: number, cost: number) => {
        (document.getElementById(`${type.toLowerCase()}-level`) as HTMLElement).innerText = `Lvl ${level}`;
        const btn = (document.getElementById(`upgrade-${type.toLowerCase()}-button`) as HTMLButtonElement);
        btn.innerText = `Upgrade (${cost} Cr)`;
        btn.disabled = gameState.credits < cost;
    };
    
    const costs = {
        fireRate: 50 * (upgrades.fireRate + 1),
        speed: 75 * (upgrades.speed + 1),
        extraLife: 200 * (upgrades.extraLife + 1)
    };

    updateUpgradeUI('fireRate', upgrades.fireRate, costs.fireRate);
    updateUpgradeUI('speed', upgrades.speed, costs.speed);
    updateUpgradeUI('extraLife', upgrades.extraLife, costs.extraLife);

    (document.getElementById('upgrade-fire-rate-button') as HTMLButtonElement).onclick = () => {
        if(gameState.credits >= costs.fireRate) {
            gameState.credits -= costs.fireRate;
            upgrades.fireRate++;
            saveGameState();
            populateUpgrades();
            updateUI();
        }
    };
     (document.getElementById('upgrade-speed-button') as HTMLButtonElement).onclick = () => {
        if(gameState.credits >= costs.speed) {
            gameState.credits -= costs.speed;
            upgrades.speed++;
            saveGameState();
            populateUpgrades();
            updateUI();
        }
    };
     (document.getElementById('upgrade-extra-life-button') as HTMLButtonElement).onclick = () => {
        if(gameState.credits >= costs.extraLife) {
            gameState.credits -= costs.extraLife;
            upgrades.extraLife++;
            gameState.maxHealth = 3 + upgrades.extraLife;
            saveGameState();
            populateUpgrades();
            updateUI();
        }
    };
}

function populateMapSelector() {
    const grid = document.getElementById('map-grid')!;
    grid.innerHTML = '';
    Object.entries(MAP_CONFIG).forEach(([key, map]) => {
        const mapNum = parseInt(key);
        const isUnlocked = gameState.unlockedMaps.includes(mapNum);
        const div = document.createElement('div');
        div.className = 'map-item';
        if (!isUnlocked) div.classList.add('locked');
        if (gameState.selectedMap === mapNum) div.classList.add('selected');
        div.innerHTML = `<span>${map.name}</span> ${!isUnlocked ? `(Lvl ${map.unlockLevel})` : ''}`;
        if(isUnlocked) {
            div.onclick = () => {
                gameState.selectedMap = mapNum;
                saveGameState();
                populateMapSelector();
                startMenuAnimation();
                playSound('uiClick');
            };
        }
        grid.appendChild(div);
    });
}
function populateAchievements() {
    const list = document.getElementById('achievements-list')!;
    list.innerHTML = '';
    ACHIEVEMENTS.forEach(ach => {
        const isUnlocked = gameState.unlockedAchievements.includes(ach.id);
        const div = document.createElement('div');
        div.className = 'achievement-item';
        if(isUnlocked) div.classList.add('unlocked');
        div.innerHTML = `
            <span class="achievement-icon">${ach.icon}</span>
            <div class="achievement-details">
                <h3>${ach.name}</h3>
                <p>${ach.description}</p>
            </div>
            ${isUnlocked ? '<span class="unlocked-check">✔</span>' : ''}
        `;
        list.appendChild(div);
    });
}
function populateDailyRewards() {
    const grid = document.getElementById('calendar')!;
    grid.innerHTML = '';
    const today = new Date().toDateString();
    DAILY_REWARDS.forEach((reward, i) => {
        const day = i + 1;
        const div = document.createElement('div');
        div.className = 'calendar-day';
        const isClaimed = gameState.claimedDays.includes(day);
        const canClaim = !isClaimed && gameState.claimedDays.length === i && gameState.dailyRewardLastClaimed !== today;

        if (isClaimed) div.classList.add('claimed');
        if (canClaim) div.classList.add('claimable');

        let rewardText = '';
        if(reward.type === 'credits') rewardText = `${reward.amount} Credits`;
        if(reward.type === 'booster') rewardText = `x${reward.amount} ${reward.booster}`;
        if(reward.type === 'mystery') rewardText = `Mystery Box`;

        div.innerHTML = `<span>Day ${day}</span><p>${rewardText}</p>`;
        
        if (canClaim) {
            div.onclick = () => {
                gameState.claimedDays.push(day);
                gameState.dailyRewardLastClaimed = today;
                if(reward.type === 'credits') gameState.credits += reward.amount;
                if(reward.type === 'booster') (gameState.boosters as any)[reward.booster] += reward.amount;
                if(reward.type === 'mystery') gameState.credits += 500; // Simplified mystery box
                saveGameState();
                updateUI();
                populateDailyRewards();
                playSound('levelUp');
            };
        }
        grid.appendChild(div);
    });
}

function populateAdminPanel() {
    const pre = document.getElementById('admin-data-pre')!;
    const adminState = {...gameState};
    (adminState as any).simulatedPlayers = simulatedPlayers;
    pre.innerText = JSON.stringify(adminState, null, 2);
}

function populateBoosterIcons() {
    document.getElementById('shield-booster-icon')!.innerHTML = BOOSTER_ICONS.shield;
    document.getElementById('rapid-fire-booster-icon')!.innerHTML = BOOSTER_ICONS.rapidFire;
    document.getElementById('double-credits-booster-icon')!.innerHTML = BOOSTER_ICONS.doubleCredits;
}

function populateBattlePass() {
    const track = document.getElementById('battle-pass-track')!;
    track.innerHTML = '';
    BATTLE_PASS_REWARDS.forEach(reward => {
        const isUnlocked = gameState.level >= reward.level;
        const rewardId = `bp_${reward.level}`;
        const isClaimed = gameState.unlockedAchievements.includes(rewardId);

        const div = document.createElement('div');
        div.className = 'battle-pass-tier';
        if (isClaimed) div.classList.add('unlocked');
        else if (isUnlocked) div.classList.add('claimable');
        
        let rewardText = '';
        if (reward.type === 'credits') rewardText = `${reward.amount} Credits`;
        if (reward.type === 'booster') rewardText = `x${reward.amount} ${(reward as any).booster}`;
        if (reward.type === 'shipSkin') {
            const shipName = SHIP_CONFIG[(reward as any).ship]?.name || 'Unknown';
            const skinName = SHIP_CONFIG[(reward as any).ship]?.skins.find(s => s.id === (reward as any).skin)?.name || 'Skin';
            rewardText = `${skinName} Skin for ${shipName}`;
        }
        
        div.innerHTML = `
            <div class="tier-level">Lvl ${reward.level}</div>
            <div class="tier-reward">${rewardText}</div>
            <div class="tier-status">${isClaimed ? 'Claimed' : isUnlocked ? 'Unlocked' : 'Locked'}</div>
        `;
        track.appendChild(div);
    });
    const levelIndicator = document.createElement('div');
    levelIndicator.id = 'battle-pass-level-indicator';
    levelIndicator.innerText = `Your Level: ${gameState.level}`;
    track.prepend(levelIndicator);
}

function populateServerBrowser() {
    const list = document.getElementById('server-list')!;
    list.innerHTML = '';
    const servers = [
        { name: 'US East', players: Math.floor(Math.random() * 3) + '/3' },
        { name: 'US West', players: Math.floor(Math.random() * 3) + '/3' },
        { name: 'Europe', players: Math.floor(Math.random() * 3) + '/3' },
        { name: 'Asia', players: '3/3' },
    ];
    servers.forEach(server => {
        const div = document.createElement('div');
        div.className = 'server-item';
        if (server.players === '3/3') {
            div.classList.add('full');
        }
        div.innerHTML = `
            <span class="server-name">${server.name}</span>
            <span class="server-players">${server.players}</span>
        `;
        if (server.players !== '3/3') {
            div.onclick = () => {
                playSound('uiClick');
                startMatchmaking();
            };
        }
        list.appendChild(div);
    });
}

function addChatMessage(user: string, message: string) {
    const msgEl = document.createElement('div');
    msgEl.innerHTML = `<span class="chat-user">${user}:</span> <span class="chat-message">${message}</span>`;
    chatMessages.appendChild(msgEl);
    chatMessages.scrollTop = chatMessages.scrollHeight;
}

function applyBooster(booster: string) {
    const boosterKey = booster as keyof typeof gameState.boosters;
    if (gameState.boosters[boosterKey] > 0) {
        gameState.boosters[boosterKey]--;
        gameState.stats.boostersUsed++;
        if (booster === 'shield') player.shieldActive = true;
        // rapidFire and doubleCredits are handled during gameplay logic
        updateUI();
        saveGameState();
    }
}
function checkAchievements(isGameOver: boolean) {
    ACHIEVEMENTS.forEach(ach => {
        if (!gameState.unlockedAchievements.includes(ach.id) && ach.condition(gameState.stats, gameState.level, currentWave)) {
            gameState.unlockedAchievements.push(ach.id);
            achievementToast.innerText = `${ach.icon} ${ach.name}`;
            achievementToast.classList.add('show');
            playSound('achievement');
            setTimeout(() => achievementToast.classList.remove('show'), 3000);
            saveGameState();
        }
    });
}
function showWaveNotification(text: string) {
    waveNotificationEl.innerText = text;
    waveNotificationEl.classList.add('show');
    setTimeout(() => waveNotificationEl.classList.remove('show'), 2000);
}

function checkBattlePassRewards() {
    BATTLE_PASS_REWARDS.forEach(reward => {
        if (gameState.level >= reward.level) {
            const rewardId = `bp_${reward.level}`;
            if (!gameState.unlockedAchievements.includes(rewardId)) { 
                if (reward.type === 'credits') gameState.credits += reward.amount;
                if (reward.type === 'booster') (gameState.boosters as any)[(reward as any).booster] += reward.amount;
                if (reward.type === 'shipSkin') unlockSkin((reward as any).ship, (reward as any).skin);
                gameState.unlockedAchievements.push(rewardId); 
                saveGameState();
            }
        }
    });
}

function unlockSkin(shipId: string, skinId: string) {
    if (!gameState.unlockedSkins[shipId]) {
        gameState.unlockedSkins[shipId] = ['default'];
    }
    if (!gameState.unlockedSkins[shipId].includes(skinId)) {
        gameState.unlockedSkins[shipId].push(skinId);
    }
}
