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
    type: 'health' | 'weaponBoost' | 'speedBoost' | 'tripleShot' | 'spreadShot' | 'laserBeam' | 'homingMissiles' | 'timeSlowdown' | 'invincibility' | 'creditMultiplier' | 'megaBomb' | 'magneticField' | 'regeneration' | 'reflectShield' | 'ghostMode';
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

// Special Ability System
let specialAbilityCooldown = 0;
let specialAbilityReady = true;
const SPECIAL_ABILITY_COOLDOWN_MS = 15000; // 15 seconds
let abilityButton: HTMLButtonElement;
let abilityButtonMobile: HTMLButtonElement;
let abilityCooldownOverlay: HTMLElement;
let abilityCooldownOverlayMobile: HTMLElement;
let abilityCooldownText: HTMLElement;
let abilityCooldownTextMobile: HTMLElement;

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

// Assign ability button references after DOM loads
let abilityButtonDesktop: HTMLButtonElement;
let abilityButtonMob: HTMLButtonElement;


const PLAYER_SIZE = 50;
const PROJECTILE_SPEED = 7;
const PARTICLE_COUNT = 15; // Reduced from 30 for better performance
const STAR_COUNT = 100; // Reduced from 200 for better performance
const XP_PER_LEVEL = 1000;
const BOSS_WAVE = 10;
const MAX_PARTICLES = 200; // Cap total particles on screen
const MAX_ENEMIES = 15; // Cap enemies per wave for performance

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
    bomber: { name: 'Bomber', svg: `<svg viewBox="0 0 50 50"><circle cx="25" cy="25" r="20" fill="none" stroke="magenta" stroke-width="2"/><path d="M25 0 V50 M0 25 H50" stroke="magenta" stroke-width="1"/></svg>`, speed: 2, health: 3, points: 30, fireRate: 120 },
    sniper: { name: 'Sniper', svg: `<svg viewBox="0 0 45 45"><path d="M22.5 0 L45 30 L22.5 25 L0 30 Z M22.5 25 V45" fill="none" stroke="lime" stroke-width="2"/></svg>`, speed: 2, health: 2, points: 40, fireRate: 60 },
    kamikaze: { name: 'Kamikaze', svg: `<svg viewBox="0 0 35 35"><circle cx="17.5" cy="17.5" r="15" fill="none" stroke="yellow" stroke-width="2"/><path d="M17.5 5 V30 M5 17.5 H30" stroke="yellow" stroke-width="2"/></svg>`, speed: 5, health: 1, points: 25 },
    tank: { name: 'Tank', svg: `<svg viewBox="0 0 70 50"><rect x="5" y="10" width="60" height="30" fill="none" stroke="gray" stroke-width="3"/><rect x="20" y="0" width="30" height="10" fill="none" stroke="gray" stroke-width="2"/></svg>`, speed: 0.5, health: 15, points: 100 },
    splitter: { name: 'Splitter', svg: `<svg viewBox="0 0 50 50"><path d="M25 5 L45 25 L25 45 L5 25 Z" fill="none" stroke="purple" stroke-width="2"/><path d="M25 5 L25 45 M5 25 H45" stroke="purple" stroke-width="1"/></svg>`, speed: 2, health: 3, points: 60 },
    healer: { name: 'Healer', svg: `<svg viewBox="0 0 55 55"><circle cx="27.5" cy="27.5" r="25" fill="none" stroke="pink" stroke-width="2"/><path d="M27.5 10 V45 M10 27.5 H45" stroke="pink" stroke-width="3"/></svg>`, speed: 1.5, health: 4, points: 70 },
    teleporter: { name: 'Teleporter', svg: `<svg viewBox="0 0 45 45"><path d="M22.5 0 L45 22.5 L22.5 45 L0 22.5 Z" fill="none" stroke="cyan" stroke-width="2" stroke-dasharray="5,5"/></svg>`, speed: 4, health: 2, points: 50 },
    minelayer: { name: 'Minelayer', svg: `<svg viewBox="0 0 55 55"><rect x="10" y="15" width="35" height="25" fill="none" stroke="brown" stroke-width="2"/><circle cx="27.5" cy="10" r="5" fill="brown"/><circle cx="27.5" cy="45" r="5" fill="brown"/></svg>`, speed: 1, health: 4, points: 80 }
} as const;

const POWERUP_CONFIG: { [key: string]: PowerUpConfig } = {
    health: { type: 'health', svg: `<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#32cd32" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14M5 12h14"/></svg>`, color: '#32cd32' },
    weaponBoost: { type: 'weaponBoost', svg: `<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#00BFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>`, color: '#00BFFF' },
    speedBoost: { type: 'speedBoost', svg: `<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#FFD700" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M13 17l5-5-5-5M6 17l5-5-5-5"/></svg>`, color: '#FFD700' },
    tripleShot: { type: 'weaponBoost', svg: `<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#FF1493" stroke-width="2"><path d="M12 2v20M6 8l6-6 6 6M6 16l6 6 6-6"/></svg>`, color: '#FF1493' },
    spreadShot: { type: 'weaponBoost', svg: `<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#FF6347" stroke-width="2"><path d="M12 2L2 12L12 22L22 12Z"/><path d="M12 12L2 22M12 12L22 22M12 12L2 2M12 12L22 2"/></svg>`, color: '#FF6347' },
    laserBeam: { type: 'weaponBoost', svg: `<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#00FF00" stroke-width="2"><rect x="10" y="2" width="4" height="20"/><path d="M8 2h8M8 22h8"/></svg>`, color: '#00FF00' },
    homingMissiles: { type: 'weaponBoost', svg: `<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#FF4500" stroke-width="2"><path d="M12 2L4 10L12 18L20 10Z"/><circle cx="12" cy="10" r="3"/></svg>`, color: '#FF4500' },
    timeSlowdown: { type: 'speedBoost', svg: `<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#9370DB" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 4"/></svg>`, color: '#9370DB' },
    invincibility: { type: 'health', svg: `<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#FFD700" stroke-width="2"><path d="M12 2L15 8L22 9L17 14L18 21L12 18L6 21L7 14L2 9L9 8Z"/></svg>`, color: '#FFD700' },
    creditMultiplier: { type: 'speedBoost', svg: `<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#32CD32" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 6v12M16 8H9a3 3 0 000 6h6a3 3 0 010 6H8"/></svg>`, color: '#32CD32' },
    megaBomb: { type: 'weaponBoost', svg: `<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#FF0000" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 2v4M12 18v4M2 12h4M18 12h4M5 5l3 3M16 16l3 3M19 5l-3 3M8 16l-3 3"/></svg>`, color: '#FF0000' },
    magneticField: { type: 'speedBoost', svg: `<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#4169E1" stroke-width="2"><path d="M6 15v-2a6 6 0 0112 0v2M6 15a2 2 0 002 2h8a2 2 0 002-2"/></svg>`, color: '#4169E1' },
    regeneration: { type: 'health', svg: `<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#FF69B4" stroke-width="2"><path d="M20.8 12A9 9 0 1112 3.2M12 3v9l4 4"/></svg>`, color: '#FF69B4' },
    reflectShield: { type: 'health', svg: `<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#00CED1" stroke-width="2"><path d="M12 2L4 6v6c0 5.5 3.8 10.7 8 12 4.2-1.3 8-6.5 8-12V6l-8-4z"/><path d="M8 12l3 3 5-5"/></svg>`, color: '#00CED1' },
    ghostMode: { type: 'speedBoost', svg: `<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="#E6E6FA" stroke-width="2"><path d="M12 2C8 2 5 5 5 9v13l3-2 2 2 2-2 2 2 2-2 3 2V9c0-4-3-7-7-7z"/><circle cx="9" cy="10" r="1"/><circle cx="15" cy="10" r="1"/></svg>`, color: '#E6E6FA' }
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
    // Combat Achievements
    { id: 'firstKill', name: 'First Kill', description: 'Destroy your first enemy.', icon: '🏆', condition: (stats) => stats.totalKills >= 1 },
    { id: 'sharpshooter', name: 'Sharpshooter', description: 'Destroy 100 enemies.', icon: '🎯', condition: (stats) => stats.totalKills >= 100 },
    { id: 'ace', name: 'Ace Pilot', description: 'Destroy 500 enemies.', icon: '⭐', condition: (stats) => stats.totalKills >= 500 },
    { id: 'legend', name: 'Living Legend', description: 'Destroy 1000 enemies.', icon: '👑', condition: (stats) => stats.totalKills >= 1000 },
    { id: 'master', name: 'Combat Master', description: 'Destroy 5000 enemies.', icon: '💎', condition: (stats) => stats.totalKills >= 5000 },
    { id: 'firstBoss', name: 'Boss Hunter', description: 'Defeat your first boss.', icon: '🐲', condition: (stats) => stats.totalKills >= 10 },
    { id: 'bossSlayer', name: 'Boss Slayer', description: 'Defeat 10 bosses.', icon: '⚔️', condition: (stats) => stats.totalKills >= 100 },
    { id: 'rapidFire', name: 'Rapid Fire', description: 'Fire 1000 shots.', icon: '🔫', condition: (stats) => stats.totalKills >= 50 },
    { id: 'sniper', name: 'Sniper Elite', description: '90% accuracy in a wave.', icon: '🎯', condition: (stats) => stats.totalKills >= 10 },
    { id: 'untouchable', name: 'Untouchable', description: 'Complete 5 waves without taking damage.', icon: '🛡️', condition: (stats) => stats.totalKills >= 50 },
    
    // Wave/Survival Achievements
    { id: 'wave5', name: 'Wave 5 Survivor', description: 'Survive until wave 5.', icon: '🌊', condition: (_, __, wave) => wave >= 5 },
    { id: 'wave10', name: 'Wave 10 Warrior', description: 'Survive until wave 10.', icon: '🌊', condition: (_, __, wave) => wave >= 10 },
    { id: 'wave20', name: 'Wave 20 Champion', description: 'Survive until wave 20.', icon: '🌊', condition: (_, __, wave) => wave >= 20 },
    { id: 'wave50', name: 'Wave 50 Legend', description: 'Survive until wave 50.', icon: '🌊', condition: (_, __, wave) => wave >= 50 },
    { id: 'speedRunner', name: 'Speed Runner', description: 'Complete a wave in under 60s.', icon: '⚡', condition: (stats) => stats.totalKills >= 20 },
    { id: 'endurance', name: 'Endurance Test', description: 'Survive 30 waves in one session.', icon: '💪', condition: (_, __, wave) => wave >= 30 },
    
    // Level/Progression Achievements
    { id: 'level5', name: 'Novice', description: 'Reach level 5.', icon: '📈', condition: (_, level) => level >= 5 },
    { id: 'level10', name: 'Experienced', description: 'Reach level 10.', icon: '⭐', condition: (_, level) => level >= 10 },
    { id: 'level20', name: 'Veteran', description: 'Reach level 20.', icon: '🎖️', condition: (_, level) => level >= 20 },
    { id: 'level50', name: 'Elite Commander', description: 'Reach level 50.', icon: '👑', condition: (_, level) => level >= 50 },
    { id: 'level100', name: 'Grand Master', description: 'Reach level 100.', icon: '💎', condition: (_, level) => level >= 100 },
    
    // Collection Achievements
    { id: 'firstShip', name: 'New Ride', description: 'Unlock your first ship.', icon: '🚀', condition: (stats) => stats.totalKills >= 1 },
    { id: 'shipCollector', name: 'Ship Collector', description: 'Unlock all ships.', icon: '🛸', condition: (stats) => stats.totalKills >= 50 },
    { id: 'firstSkin', name: 'Fashionable', description: 'Unlock your first skin.', icon: '🎨', condition: (stats) => stats.totalKills >= 10 },
    { id: 'skinCollector', name: 'Skin Collector', description: 'Unlock 10 skins.', icon: '👕', condition: (stats) => stats.totalKills >= 100 },
    { id: 'fashionista', name: 'Fashionista', description: 'Unlock all skins.', icon: '✨', condition: (stats) => stats.totalKills >= 200 },
    { id: 'mapExplorer', name: 'Map Explorer', description: 'Visit 10 different maps.', icon: '🗺️', condition: (stats) => stats.totalKills >= 50 },
    { id: 'worldTraveler', name: 'World Traveler', description: 'Visit all maps.', icon: '🌍', condition: (stats) => stats.totalKills >= 100 },
    
    // Social/Multiplayer Achievements
    { id: 'teamPlayer', name: 'Team Player', description: 'Play 10 multiplayer matches.', icon: '🤝', condition: (stats) => stats.totalKills >= 50 },
    { id: 'chatty', name: 'Chatty', description: 'Send 100 chat messages.', icon: '💬', condition: (stats) => stats.totalKills >= 30 },
    { id: 'helpful', name: 'Helpful Commander', description: 'Help teammates destroy 100 enemies.', icon: '🆘', condition: (stats) => stats.totalKills >= 100 },
    
    // Special Achievements
    { id: 'luckyShot', name: 'Lucky Shot', description: 'Destroy 3 enemies with one shot.', icon: '🎲', condition: (stats) => stats.totalKills >= 20 },
    { id: 'comeback', name: 'Comeback King', description: 'Win with 1 life remaining.', icon: '💫', condition: (stats) => stats.totalKills >= 30 },
    { id: 'perfectWave', name: 'Perfect Wave', description: 'Complete a wave without missing.', icon: '✨', condition: (stats) => stats.totalKills >= 15 },
    { id: 'booster10', name: 'Booster Enthusiast', description: 'Use 10 boosters.', icon: '🚀', condition: (stats) => stats.boostersUsed >= 10 },
    { id: 'booster50', name: 'Boost Master', description: 'Use 50 boosters.', icon: '💊', condition: (stats) => stats.boostersUsed >= 50 },
    { id: 'powerUpCollector', name: 'Power-Up Collector', description: 'Collect 100 power-ups.', icon: '⚡', condition: (stats) => stats.totalKills >= 100 },
    { id: 'survivor', name: 'Survivor', description: 'Survive with 1 HP.', icon: '❤️', condition: (stats) => stats.totalKills >= 20 },
    { id: 'noDamage', name: 'Untouched', description: 'Complete 3 waves without damage.', icon: '🛡️', condition: (stats) => stats.totalKills >= 30 },
    { id: 'closeCall', name: 'Close Call', description: 'Dodge 100 enemy bullets.', icon: '🌪️', condition: (stats) => stats.totalKills >= 50 },
    
    // Credits/Economy Achievements
    { id: 'richPilot', name: 'Rich Pilot', description: 'Earn 10,000 credits.', icon: '💰', condition: (stats) => stats.totalKills >= 100 },
    { id: 'millionaire', name: 'Millionaire', description: 'Earn 100,000 credits.', icon: '💎', condition: (stats) => stats.totalKills >= 1000 },
    { id: 'bigSpender', name: 'Big Spender', description: 'Spend 5,000 credits.', icon: '💸', condition: (stats) => stats.totalKills >= 50 },
    { id: 'upgradeAll', name: 'Fully Upgraded', description: 'Max out all upgrades.', icon: '⚙️', condition: (stats) => stats.totalKills >= 200 },
    
    // Time-based Achievements
    { id: 'earlyBird', name: 'Early Bird', description: 'Play 5 matches before noon.', icon: '🌅', condition: (stats) => stats.totalKills >= 25 },
    { id: 'nightOwl', name: 'Night Owl', description: 'Play 5 matches after midnight.', icon: '🦉', condition: (stats) => stats.totalKills >= 25 },
    { id: 'dedication', name: 'Dedication', description: 'Play 7 days in a row.', icon: '📅', condition: (stats) => stats.totalKills >= 70 },
    { id: 'loyalPlayer', name: 'Loyal Player', description: 'Play 30 days total.', icon: '🎖️', condition: (stats) => stats.totalKills >= 300 },
    
    // Miscellaneous Achievements
    { id: 'tutorial', name: 'Quick Learner', description: 'Complete tutorial.', icon: '📚', condition: (stats) => stats.totalKills >= 1 },
    { id: 'settings', name: 'Customizer', description: 'Change 5 settings.', icon: '⚙️', condition: (stats) => stats.totalKills >= 5 },
    { id: 'referral', name: 'Recruiter', description: 'Refer a friend.', icon: '🎁', condition: (stats) => stats.totalKills >= 10 },
    { id: 'reviewer', name: 'Game Critic', description: 'Rate the game.', icon: '⭐', condition: (stats) => stats.totalKills >= 20 }
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
            if (this.glowColor && effectsEnabled) {
                ctx.shadowBlur = 15; // Reduced from 20
                ctx.shadowColor = this.glowColor;
            }
            ctx.drawImage(this.img, this.x - this.width / 2, this.y - this.height / 2, this.width, this.height);
            if (this.glowColor && effectsEnabled) ctx.shadowBlur = 0;
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
        // Reduce thruster particle frequency for performance
        if (effectsEnabled && Math.random() < 0.5) { // Only 50% of frames
            this.thrusterParticles.push(new Particle(this.x, this.y + this.height / 2, 'orange', 2, 0, 3));
        }
        // Limit thruster particles
        if (this.thrusterParticles.length > 10) {
            this.thrusterParticles = this.thrusterParticles.slice(-10);
        }
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
    
    applyPowerUp(type: string) {
        playSound('achievement'); // Placeholder for powerup sound
        if (type === 'health') {
            gameState.health = Math.min(gameState.maxHealth, gameState.health + Math.floor(gameState.maxHealth * 0.25));
            updateHealthBar();
        } else if (type === 'weaponBoost' || type === 'tripleShot' || type === 'spreadShot' || type === 'laserBeam' || type === 'homingMissiles' || type === 'megaBomb') {
            this.weaponBoostActive = true;
            this.weaponBoostTimer = 10000;
            this.fireCooldown = (200 - gameState.upgrades.fireRate * 20) / 2;
            this.updateGlow();
        } else if (type === 'speedBoost' || type === 'timeSlowdown' || type === 'creditMultiplier' || type === 'magneticField' || type === 'ghostMode') {
            this.speedBoostActive = true;
            this.speedBoostTimer = 10000;
            this.speed = (SHIP_CONFIG[gameState.selectedShip].speed + gameState.upgrades.speed) * 1.5;
            this.updateGlow();
        } else if (type === 'invincibility' || type === 'reflectShield') {
            this.invincible = true;
            this.invincibilityTimer = 10000;
        } else if (type === 'regeneration') {
            // Regeneration handled in update loop
            this.weaponBoostActive = true;
            this.weaponBoostTimer = 10000;
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
        // Removed shadow blur for performance
        ctx.fillRect(this.x - this.width / 2, this.y, this.width, this.height);
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
        // Removed shadow blur for performance
        ctx.fillRect(this.x - this.width / 2, this.y, this.width, this.height);
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
        // Only apply glow effect if effects are enabled
        if (effectsEnabled) {
            ctx.shadowBlur = 10; // Reduced from 15
            ctx.shadowColor = this.config.color;
        }
        ctx.drawImage(this.img, this.x - this.size / 2, this.y - this.size / 2, this.size, this.size);
        if (effectsEnabled) ctx.shadowBlur = 0;
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
            // Only apply glow if effects enabled
            if (effectsEnabled) {
                ctx.shadowBlur = 15; // Reduced from 20
                ctx.shadowColor = 'red';
            }
            ctx.fillRect(this.x - this.width/2, this.y, this.width, canvas.height - this.y);
            if (effectsEnabled) ctx.shadowBlur = 0;
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
    
    // Special Ability Button References
    abilityButton = document.getElementById('special-ability-button') as HTMLButtonElement;
    abilityButtonMobile = document.getElementById('special-ability-button-mobile') as HTMLButtonElement;
    abilityCooldownOverlay = document.getElementById('ability-cooldown-overlay')!;
    abilityCooldownOverlayMobile = document.getElementById('ability-cooldown-overlay-mobile')!;
    abilityCooldownText = document.getElementById('ability-cooldown-text')!;
    abilityCooldownTextMobile = document.getElementById('ability-cooldown-text-mobile')!;

    resizeCanvas();
    
    // Check if user is already logged in from website
    checkWebsiteAuth();
    
    setupEventListeners();
    initStars();
    startMenuAnimation();
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
        
        // Update special ability cooldown
        updateAbilityCooldown();

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
    const mapNum = gameState.selectedMap;
    
    // Enhanced visuals for all 20 maps
    if (mapNum <= 7) {
        // Space theme - different dark tones
        const spaceColors = ['#000000', '#0a0a0f', '#050510', '#0f0a0a', '#0a0f0a', '#10050a', '#0a0510'];
        ctx.fillStyle = spaceColors[(mapNum - 1) % spaceColors.length];
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
        // Asteroid theme - darker with variety
        const darkColors = ['#0a0a0a', '#111118', '#181820', '#1a1a22', '#14141c', '#1c1c28'];
        const colorIndex = (mapNum - 15) % darkColors.length;
        ctx.fillStyle = darkColors[colorIndex];
    }
    
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    // Add animated nebula effects for nebula maps
    if (mapNum > 7 && mapNum <= 14 && effectsEnabled) {
        ctx.save();
        ctx.globalAlpha = 0.15;
        const nebulaX = Math.sin(Date.now() / 5000) * 100;
        const nebulaY = Math.cos(Date.now() / 5000) * 100;
        const nebulaGradient = ctx.createRadialGradient(
            canvas.width/2 + nebulaX, canvas.height/2 + nebulaY, 0,
            canvas.width/2 + nebulaX, canvas.height/2 + nebulaY, canvas.width/2
        );
        const nebulaColors = ['#ff00ff', '#00ffff', '#ff0066', '#00ff66', '#ff6600', '#0066ff', '#ff0099'];
        const colorIndex = (mapNum - 8) % nebulaColors.length;
        nebulaGradient.addColorStop(0, nebulaColors[colorIndex]);
        nebulaGradient.addColorStop(1, 'transparent');
        ctx.fillStyle = nebulaGradient;
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctx.restore();
    }
    
    updateAndDraw(stars);
}

function createExplosion(x: number, y: number, color: string) {
    if(!effectsEnabled) return;
    // Cap total particles for performance
    if (particles.length < MAX_PARTICLES) {
        for (let i = 0; i < PARTICLE_COUNT; i++) {
            particles.push(new Particle(x, y, color));
        }
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
    
    // Fix: Reset all keys when window loses focus to prevent stuck keys
    window.addEventListener('blur', () => {
        keys = {};
    });
    
    document.getElementById('signin-button')!.addEventListener('click', handleSignIn);
    document.getElementById('signup-button')!.addEventListener('click', handleSignUp);
    document.getElementById('guest-button')!.addEventListener('click', handleGuestLogin);
    
    document.getElementById('start-button')!.addEventListener('click', () => startGame());
    document.getElementById('multiplayer-button')!.addEventListener('click', () => showModal('server-browser-modal'));
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
    
    document.getElementById('ingame-menu-button')!.addEventListener('click', () => {
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
    setupSpecialAbility();
    
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
    
    document.getElementById('quick-match-button')!.addEventListener('click', () => {
        document.getElementById('server-browser-modal')!.classList.remove('active');
        startMatchmaking();
    });
    
    document.getElementById('cancel-matchmaking')!.addEventListener('click', () => {
        document.getElementById('matchmaking-modal')!.classList.remove('active');
        playSound('uiClick');
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

function setupSpecialAbility() {
    // Desktop keyboard control (Q key)
    document.addEventListener('keydown', (e) => {
        if (e.key.toLowerCase() === 'q' && gameRunning && specialAbilityReady) {
            activateSpecialAbility();
        }
    });
    
    // Desktop button click
    if (abilityButton) {
        abilityButton.addEventListener('click', () => {
            if (gameRunning && specialAbilityReady) {
                activateSpecialAbility();
            }
        });
    }
    
    // Mobile button touch
    if (abilityButtonMobile) {
        abilityButtonMobile.addEventListener('touchstart', (e) => {
            e.preventDefault();
            if (gameRunning && specialAbilityReady) {
                activateSpecialAbility();
            }
        }, { passive: false });
    }
}

function activateSpecialAbility() {
    if (!specialAbilityReady) return;
    
    // Trigger special ability - Clear all enemies on screen!
    const enemiesDestroyed = enemies.length;
    
    // Create massive explosion effect
    enemies.forEach(enemy => {
        createExplosion(enemy.x, enemy.y, '#FF00FF');
        updateScore(enemy.config.points);
        gameState.stats.totalKills++;
    });
    
    // Clear all enemies
    enemies = [];
    
    // Clear enemy projectiles too
    enemyProjectiles = [];
    
    // Visual effects
    createScreenShake(15, 0.5);
    showWaveNotification('⚡ SPECIAL ABILITY ACTIVATED! ⚡');
    playSound('explosion');
    
    // Particle burst from player
    for (let i = 0; i < 50; i++) {
        const angle = (Math.PI * 2 * i) / 50;
        particles.push(new Particle(
            player.x,
            player.y,
            '#FF00FF',
            4,
            Math.cos(angle) * 10,
            Math.sin(angle) * 10,
            true
        ));
    }
    
    // Set cooldown
    specialAbilityReady = false;
    specialAbilityCooldown = SPECIAL_ABILITY_COOLDOWN_MS;
    
    // Update button states
    if (abilityButton) {
        abilityButton.disabled = true;
        abilityButton.style.opacity = '0.5';
        abilityButton.style.cursor = 'not-allowed';
    }
    if (abilityButtonMobile) {
        abilityButtonMobile.disabled = true;
        abilityButtonMobile.style.opacity = '0.5';
    }
    
    // Start cooldown display
    updateAbilityCooldown();
}

function updateAbilityCooldown() {
    if (!gameRunning) return;
    
    if (specialAbilityCooldown > 0) {
        const secondsRemaining = Math.ceil(specialAbilityCooldown / 1000);
        
        // Show cooldown overlays
        if (abilityCooldownOverlay) {
            abilityCooldownOverlay.style.display = 'flex';
            abilityCooldownText.innerText = secondsRemaining.toString();
        }
        if (abilityCooldownOverlayMobile) {
            abilityCooldownOverlayMobile.style.display = 'flex';
            abilityCooldownTextMobile.innerText = secondsRemaining.toString();
        }
        
        specialAbilityCooldown -= 1000 / 60; // Decrease by frame time
        
        if (specialAbilityCooldown <= 0) {
            specialAbilityReady = true;
            
            // Hide cooldown overlays
            if (abilityCooldownOverlay) abilityCooldownOverlay.style.display = 'none';
            if (abilityCooldownOverlayMobile) abilityCooldownOverlayMobile.style.display = 'none';
            
            // Re-enable buttons
            if (abilityButton) {
                abilityButton.disabled = false;
                abilityButton.style.opacity = '1';
                abilityButton.style.cursor = 'pointer';
            }
            if (abilityButtonMobile) {
                abilityButtonMobile.disabled = false;
                abilityButtonMobile.style.opacity = '1';
            }
            
            // Notify player
            showWaveNotification('⚡ Special Ability Ready! ⚡');
            playSound('levelUp');
        }
    }
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
    
    // Reset special ability
    specialAbilityReady = true;
    specialAbilityCooldown = 0;
    if (abilityButton) {
        abilityButton.disabled = false;
        abilityButton.style.opacity = '1';
        abilityButton.style.cursor = 'pointer';
    }
    if (abilityButtonMobile) {
        abilityButtonMobile.disabled = false;
        abilityButtonMobile.style.opacity = '1';
    }
    if (abilityCooldownOverlay) abilityCooldownOverlay.style.display = 'none';
    if (abilityCooldownOverlayMobile) abilityCooldownOverlayMobile.style.display = 'none';
    
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
    
    // Save score to Supabase leaderboard
    if (typeof (window as any).savePlayerScore === 'function' && !gameState.username.startsWith('guest_')) {
        (window as any).savePlayerScore(gameState.username, score, gameState.stats.totalKills, currentWave)
            .then(() => console.log('Score saved to leaderboard'))
            .catch((err: any) => console.error('Failed to save score:', err));
    }
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
    
    console.log(`Starting wave ${currentWave}`);
    
    if (currentWave % BOSS_WAVE === 0) {
        spawnBoss();
    } else {
        // Clear any dead enemies first
        enemies = enemies.filter(e => e.health > 0);
        spawnEnemies();
        
        // Safety check - ensure enemies were spawned
        if (enemies.length === 0) {
            console.warn('No enemies spawned! Adding fallback enemies.');
            for (let i = 0; i < 5; i++) {
                enemies.push(new Enemy(
                    Math.random() * (canvas.width - 50) + 25,
                    Math.random() * -200 - 50,
                    'scout'
                ));
            }
        }
    }
}

function spawnEnemies() {
    // Cap enemy count for better performance
    const isMobile = 'ontouchstart' in window;
    const maxEnemies = isMobile ? 10 : MAX_ENEMIES;
    const enemyCount = Math.min(5 + currentWave * 2, maxEnemies);
    
    console.log(`Wave ${currentWave}: Spawning ${enemyCount} enemies`);
    
    for (let i = 0; i < enemyCount; i++) {
        const x = Math.random() * (canvas.width - 50) + 25;
        const y = Math.random() * -canvas.height - 50; // Spawn further off-screen
        let type: keyof typeof ENEMY_CONFIG = 'scout';
        
        // Fix for wave 3+ enemy variety
        if (currentWave >= 3 && Math.random() > 0.7) type = 'brute';
        if (currentWave >= 4 && Math.random() > 0.6) type = 'bomber';
        if (currentWave >= 5 && Math.random() > 0.8) type = 'sniper';
        
        enemies.push(new Enemy(x, y, type));
    }
    
    console.log(`Total enemies in array: ${enemies.length}`);
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
    if (user === 'King_davez' && pass === 'Peaguyxx300!') {
        loginSuccess('King_davez', false, true);
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

function loginSuccess(username: string, isGuest = false, isAdmin = false) {
    playSound('uiClick');
    initAudio();
    loadGameState(isGuest ? `guest_${username}` : username);
    gameState.username = username;
    
    showScreen('start-screen');
    startMenuAnimation();
    document.getElementById('admin-panel-button')!.style.display = (username === 'King_davez' || isAdmin) ? 'inline-block' : 'none';
    chatContainer.style.display = 'flex';
}

function checkWebsiteAuth() {
    // Check if user is already authenticated from website
    const websiteAuth = sessionStorage.getItem('space_shooter_auth');
    const websiteUser = sessionStorage.getItem('space_shooter_username');
    
    if (websiteAuth === 'true' && websiteUser) {
        // User is already logged in from website, auto-login to game
        console.log('Auto-login detected from website:', websiteUser);
        initAudio();
        loadGameState(websiteUser);
        gameState.username = websiteUser;
        showScreen('start-screen');
        startMenuAnimation();
        document.getElementById('admin-panel-button')!.style.display = (websiteUser === 'King_davez') ? 'inline-block' : 'none';
        chatContainer.style.display = 'flex';
        
        // Show welcome notification
        showWaveNotification(`Welcome to the game, ${websiteUser}!`);
    } else {
        // No website auth, show login screen
        loadGameState('guest_default');
        showScreen('login-screen');
    }
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

function createBackgroundMusic() {
    if (!audioCtx) return;
    
    // Create ambient space music using oscillators
    const oscillator1 = audioCtx.createOscillator();
    const oscillator2 = audioCtx.createOscillator();
    const oscillator3 = audioCtx.createOscillator();
    
    const gainNode1 = audioCtx.createGain();
    const gainNode2 = audioCtx.createGain();
    const gainNode3 = audioCtx.createGain();
    
    // Bass layer
    oscillator1.type = 'sine';
    oscillator1.frequency.value = 55;
    gainNode1.gain.value = 0.15;
    
    // Mid layer
    oscillator2.type = 'triangle';
    oscillator2.frequency.value = 110;
    gainNode2.gain.value = 0.1;
    
    // High layer
    oscillator3.type = 'sine';
    oscillator3.frequency.value = 220;
    gainNode3.gain.value = 0.08;
    
    // Connect to music gain
    oscillator1.connect(gainNode1);
    oscillator2.connect(gainNode2);
    oscillator3.connect(gainNode3);
    
    gainNode1.connect(musicGainNode);
    gainNode2.connect(musicGainNode);
    gainNode3.connect(musicGainNode);
    
    // Start oscillators
    oscillator1.start();
    oscillator2.start();
    oscillator3.start();
    
    musicSource = oscillator1 as any; // Store reference
}

function playMusic(sound: string) {
    if (!audioCtx || musicSource) return;
    createBackgroundMusic();
}

function stopMusic() {
    if (musicSource) { 
        try { musicSource.stop(); } catch(e) {}
        musicSource = null; 
    }
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
    const container = document.getElementById('admin-info')!;
    
    if (gameState.username !== 'King_davez') {
        container.innerHTML = '<p style="color: red;">Access Denied</p>';
        return;
    }
    
    container.innerHTML = `
        <div style="padding: 20px;">
            <h3 style="color: #00FF00;">👑 Admin Controls - King_davez</h3>
            
            <div style="margin: 20px 0; padding: 15px; background: rgba(0,255,0,0.1); border: 2px solid #00FF00; border-radius: 8px;">
                <h4>Grant Credits</h4>
                <input type="number" id="grant-credits-amount" placeholder="Amount" style="padding: 8px; width: 150px; margin-right: 10px;">
                <button id="grant-credits-button" style="padding: 8px 15px; background: #00FF00; color: black; border: none; border-radius: 5px; cursor: pointer;">Grant Credits</button>
            </div>
            
            <div style="margin: 20px 0; padding: 15px; background: rgba(0,255,255,0.1); border: 2px solid #00FFFF; border-radius: 8px;">
                <h4>Unlock All Maps</h4>
                <button id="unlock-all-maps-button" style="padding: 10px 20px; background: #00FFFF; color: black; border: none; border-radius: 5px; cursor: pointer;">Unlock All Maps</button>
            </div>
            
            <div style="margin: 20px 0; padding: 15px; background: rgba(255,0,255,0.1); border: 2px solid #FF00FF; border-radius: 8px;">
                <h4>Reset Player Progress</h4>
                <p style="color: #FF00FF; margin: 10px 0;">⚠️ This will reset YOUR progress to level 1!</p>
                <button id="reset-player-button" style="padding: 10px 20px; background: #FF00FF; color: white; border: none; border-radius: 5px; cursor: pointer;">Reset My Progress</button>
            </div>
            
            <div style="margin: 20px 0; padding: 15px; background: rgba(255,0,0,0.1); border: 2px solid #FF0000; border-radius: 8px;">
                <h4>Ban Player (Simulated)</h4>
                <input type="text" id="ban-player-name" placeholder="Player name" style="padding: 8px; width: 150px; margin-right: 10px;">
                <button id="ban-player-button" style="padding: 8px 15px; background: #FF0000; color: white; border: none; border-radius: 5px; cursor: pointer;">Ban Player</button>
            </div>
            
            <div style="margin: 20px 0; padding: 15px; background: rgba(255,215,0,0.1); border: 2px solid #FFD700; border-radius: 8px;">
                <h4>Current Game State</h4>
                <pre id="admin-data-pre" style="background: black; color: #00FF00; padding: 15px; border-radius: 5px; overflow: auto; max-height: 300px; font-size: 12px;"></pre>
            </div>
        </div>
    `;
    
    const pre = document.getElementById('admin-data-pre')!;
    const adminState = {...gameState};
    (adminState as any).simulatedPlayers = simulatedPlayers;
    pre.innerText = JSON.stringify(adminState, null, 2);
    
    // Rebind admin buttons
    document.getElementById('grant-credits-button')!.addEventListener('click', () => {
        const amount = parseInt((document.getElementById('grant-credits-amount') as HTMLInputElement).value);
        if (!isNaN(amount)) {
            gameState.credits += amount;
            saveGameState();
            updateUI();
            populateAdminPanel();
            showWaveNotification(`✅ Granted ${amount} credits!`);
        }
    });
    
    document.getElementById('unlock-all-maps-button')!.addEventListener('click', () => {
        gameState.unlockedMaps = Object.keys(MAP_CONFIG).map(Number);
        saveGameState();
        populateAdminPanel();
        showWaveNotification('✅ All maps unlocked!');
    });
    
    document.getElementById('reset-player-button')!.addEventListener('click', () => {
        if (confirm('⚠️ Are you sure you want to reset your progress? This cannot be undone!')) {
            localStorage.removeItem(`space_shooter_King_davez`);
            loadGameState('King_davez');
            updateUI();
            populateAdminPanel();
            showWaveNotification('✅ Progress reset!');
        }
    });
    
    document.getElementById('ban-player-button')!.addEventListener('click', () => {
        const nameToBan = (document.getElementById('ban-player-name') as HTMLInputElement).value;
        if (nameToBan) {
            simulatedPlayers = simulatedPlayers.filter(p => p !== nameToBan);
            populateAdminPanel();
            showWaveNotification(`✅ Banned ${nameToBan}!`);
        }
    });
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
