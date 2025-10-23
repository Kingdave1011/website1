// AI Helper Chatbot for HideoutAds.online Space Shooter
// Helps users with game questions, website navigation, and troubleshooting

class AIHelperChatbot {
    constructor() {
        this.isOpen = false;
        this.knowledgeBase = this.initKnowledgeBase();
        this.init();
    }
    
    initKnowledgeBase() {
        return {
            game: {
                controls: "Desktop: WASD/Arrows to move, Space to shoot, Q for Special Ability, ESC to quit. Mobile: Use joystick to move, tap shoot button, tap purple ⚡ for special ability.",
                specialAbility: "Press Q (desktop) or tap purple ⚡ button (mobile). Clears ALL enemies instantly! 15-second cooldown.",
                multiplayer: "Click 🌐 Online Multiplayer button. Choose Quick Match or select a regional server (US East/West, Europe, Asia). Game supports 100 players per server.",
                upgrades: "Open Upgrades menu from main screen. Spend credits on: Fire Rate, Ship Speed, Extra Life. Each upgrade costs more as level increases.",
                ships: "3 ship types: Ranger (balanced), Interceptor (fast), Bruiser (tank). Each has 6 skins. Unlock ships by leveling up.",
                powerups: "15 types including Health, Weapon Boost, Speed Boost, Triple Shot, Laser Beam, Invincibility, and more. Spawn randomly when enemies die.",
                boss: "Boss appears every 10 waves. Has 2 phases, shoots spread patterns, spawns minions, and fires lasers. Defeat for 1000 points.",
                maps: "20 unlockable maps across 3 themes: Space (1-7), Nebula (8-14), Asteroids (15-20). Unlock by leveling up.",
                achievements: "50+ achievements covering combat, waves, levels, collections, and special challenges. Check Achievements menu to view progress.",
                dailyRewards: "28-day calendar with credits and boosters. Claim once per day. Resets monthly.",
                battlePass: "Free progression system. Earn rewards at levels 2, 3, 5, 7, and 10 including skins and boosters."
            },
            website: {
                account: "Sign in/up at top-right. Get 1000 credits + boosters on first sign-up. Progress syncs between website and game.",
                leaderboard: "Real-time leaderboard updates every 5 seconds. Shows top players with scores, kills, waves, and playtime. Top 3 get special highlighting.",
                languages: "8 languages supported: English, Spanish, French, German, Japanese, Chinese, Portuguese, Russian. Change in Settings.",
                themes: "6 themes available: Cosmic Blue, Neon Green, Sunset Orange, Matrix Green, Purple Galaxy, Halloween Spooky. Click Theme button to cycle.",
                profile: "View your stats, level, achievements, and progress. Access via Profile link in navigation.",
                download: "Click 'Download for PC' for Windows .exe standalone version. Includes offline play and online multiplayer support.",
                admin: "Admin panel for King_davez only (password: Peaguyxx300!). Grants credits, unlocks maps, manages players.",
                cookies: "Non-intrusive cookie banner. Saves preferences (language, theme, login). Accept or decline - we respect your choice."
            },
            technical: {
                database: "Supabase PostgreSQL with 8 tables: leaderboard, player_profiles, match_history, achievements, and more. Auto-syncs every 5 seconds.",
                server: "24/7 cloud multiplayer on Render.com (FREE). Deploy to multiple regions. Supports 100 players per server with auto-restart.",
                performance: "Optimized for 60 FPS. Reduced particles, capped enemies, mobile optimizations. Works smooth on all devices.",
                build: "Windows .exe built with Electron. Includes auto-updater. See HOW_TO_BUILD_EXE_STANDALONE.md for build instructions."
            },
            troubleshooting: {
                stuck: "If controls stuck, press ESC or refresh page. Game clears keys when window loses focus.",
                multiplayer: "If can't connect: Check server is running, verify firewall allows port 3001, see FIX_EC2_WEBSOCKET_CONNECTION.md",
                saves: "Progress saves to localStorage automatically. For cloud sync, sign in to account. Guest progress is temporary.",
                lag: "Reduce particle effects in Settings, lower graphics quality, close other browser tabs, or use Windows .exe version.",
                firewall: "For hosting: Open port 3001 in Windows Firewall. See FIREWALL_SETUP_PORT_3001.md for instructions."
            }
        };
    }
    
    init() {
        // Create chatbot widget
        const chatbot = document.createElement('div');
        chatbot.id = 'ai-helper-chatbot';
        chatbot.style.cssText = `
            position: fixed;
            bottom: 20px;
            right: 20px;
            z-index: 10001;
            font-family: 'Orbitron', sans-serif;
        `;
        
        chatbot.innerHTML = `
            <!-- Chatbot Toggle Button -->
            <div id="chatbot-toggle" style="
                width: 60px;
                height: 60px;
                background: linear-gradient(135deg, #00C6FF, #0072FF);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                box-shadow: 0 0 20px rgba(0, 198, 255, 0.6);
                transition: all 0.3s;
                font-size: 2rem;
            ">
                🤖
            </div>
            
            <!-- Chatbot Window (hidden by default) -->
            <div id="chatbot-window" style="
                display: none;
                position: absolute;
                bottom: 75px;
                right: 0;
                width: 350px;
                max-width: 90vw;
                height: 500px;
                max-height: 70vh;
                background: rgba(0, 0, 0, 0.95);
                border: 2px solid #00C6FF;
                border-radius: 15px;
                box-shadow: 0 0 40px rgba(0, 198, 255, 0.5);
                backdrop-filter: blur(20px);
                display: flex;
                flex-direction: column;
            ">
                <!-- Header -->
                <div style="
                    background: linear-gradient(135deg, #00C6FF, #0072FF);
                    padding: 15px;
                    border-radius: 13px 13px 0 0;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                ">
                    <div>
                        <div style="font-weight: bold; font-size: 1.1rem;">🤖 AI Helper</div>
                        <div style="font-size: 0.75rem; opacity: 0.9;">Ask me anything!</div>
                    </div>
                    <button id="chatbot-close" style="
                        background: none;
                        border: none;
                        color: white;
                        font-size: 1.5rem;
                        cursor: pointer;
                        padding: 0;
                        width: 30px;
                        height: 30px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                    ">×</button>
                </div>
                
                <!-- Messages Container -->
                <div id="chatbot-messages" style="
                    flex: 1;
                    overflow-y: auto;
                    padding: 15px;
                    scrollbar-width: thin;
                    scrollbar-color: #00C6FF rgba(0, 0, 0, 0.3);
                ">
                    <div class="bot-message" style="
                        background: rgba(0, 198, 255, 0.1);
                        border-left: 3px solid #00C6FF;
                        padding: 10px;
                        border-radius: 8px;
                        margin-bottom: 10px;
                        color: #E0E0E0;
                        font-size: 0.9rem;
                    ">
                        👋 Hi! I'm your AI helper. Ask me about:
                        <br>• Game controls & features
                        <br>• Multiplayer setup
                        <br>• Website navigation
                        <br>• Troubleshooting
                        <br><br>Type your question below!
                    </div>
                </div>
                
                <!-- Quick Actions -->
                <div style="
                    padding: 10px;
                    border-top: 1px solid rgba(0, 198, 255, 0.3);
                    display: flex;
                    gap: 5px;
                    flex-wrap: wrap;
                ">
                    <button class="quick-action" data-question="How do I play?">🎮 How to play</button>
                    <button class="quick-action" data-question="What is special ability?">⚡ Special Ability</button>
                    <button class="quick-action" data-question="How do I join multiplayer?">🌐 Multiplayer</button>
                </div>
                
                <!-- Input Area -->
                <div style="
                    padding: 15px;
                    border-top: 1px solid rgba(0, 198, 255, 0.3);
                    display: flex;
                    gap: 10px;
                ">
                    <input 
                        type="text" 
                        id="chatbot-input" 
                        placeholder="Ask me anything..."
                        style="
                            flex: 1;
                            padding: 10px;
                            background: rgba(0, 198, 255, 0.1);
                            border: 1px solid rgba(0, 198, 255, 0.3);
                            border-radius: 8px;
                            color: white;
                            font-family: 'Orbitron', sans-serif;
                            font-size: 0.85rem;
                        "
                    />
                    <button id="chatbot-send" style="
                        padding: 10px 20px;
                        background: linear-gradient(135deg, #00C6FF, #0072FF);
                        border: none;
                        border-radius: 8px;
                        color: white;
                        cursor: pointer;
                        font-family: 'Orbitron', sans-serif;
                        font-weight: bold;
                    ">Send</button>
                </div>
            </div>
            
            <style>
                #chatbot-toggle:hover {
                    transform: scale(1.1);
                    box-shadow: 0 0 30px rgba(0, 198, 255, 0.8);
                }
                #chatbot-messages::-webkit-scrollbar {
                    width: 6px;
                }
                #chatbot-messages::-webkit-scrollbar-track {
                    background: rgba(0, 0, 0, 0.3);
                }
                #chatbot-messages::-webkit-scrollbar-thumb {
                    background: #00C6FF;
                    border-radius: 3px;
                }
                .quick-action {
                    padding: 5px 10px;
                    background: rgba(0, 198, 255, 0.2);
                    border: 1px solid rgba(0, 198, 255, 0.3);
                    border-radius: 15px;
                    color: #00C6FF;
                    cursor: pointer;
                    font-size: 0.75rem;
                    font-family: 'Orbitron', sans-serif;
                    transition: all 0.2s;
                }
                .quick-action:hover {
                    background: rgba(0, 198, 255, 0.4);
                    border-color: #00C6FF;
                }
                .bot-message {
                    animation: slideIn 0.3s ease-out;
                }
                .user-message {
                    background: rgba(138, 43, 226, 0.2);
                    border-left: 3px solid #8A2BE2;
                    padding: 10px;
                    border-radius: 8px;
                    margin-bottom: 10px;
                    color: #E0E0E0;
                    font-size: 0.9rem;
                    text-align: right;
                    animation: slideIn 0.3s ease-out;
                }
                @keyframes slideIn {
                    from {
                        opacity: 0;
                        transform: translateY(10px);
                    }
                    to {
                        opacity: 1;
                        transform: translateY(0);
                    }
                }
            </style>
        `;
        
        document.body.appendChild(chatbot);
        this.setupEventListeners();
    }
    
    setupEventListeners() {
        const toggle = document.getElementById('chatbot-toggle');
        const window = document.getElementById('chatbot-window');
        const close = document.getElementById('chatbot-close');
        const send = document.getElementById('chatbot-send');
        const input = document.getElementById('chatbot-input');
        
        toggle.addEventListener('click', () => this.toggleChat());
        close.addEventListener('click', () => this.toggleChat());
        send.addEventListener('click', () => this.handleSend());
        input.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') this.handleSend();
        });
        
        // Quick action buttons
        document.querySelectorAll('.quick-action').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const question = e.target.getAttribute('data-question');
                this.handleUserMessage(question);
            });
        });
    }
    
    toggleChat() {
        this.isOpen = !this.isOpen;
        const window = document.getElementById('chatbot-window');
        const toggle = document.getElementById('chatbot-toggle');
        
        if (this.isOpen) {
            window.style.display = 'flex';
            toggle.innerHTML = '▼';
        } else {
            window.style.display = 'none';
            toggle.innerHTML = '🤖';
        }
    }
    
    handleSend() {
        const input = document.getElementById('chatbot-input');
        const message = input.value.trim();
        
        if (message) {
            this.handleUserMessage(message);
            input.value = '';
        }
    }
    
    handleUserMessage(message) {
        const messagesContainer = document.getElementById('chatbot-messages');
        
        // Add user message
        const userMsg = document.createElement('div');
        userMsg.className = 'user-message';
        userMsg.textContent = message;
        messagesContainer.appendChild(userMsg);
        
        // Get AI response
        setTimeout(() => {
            const response = this.getResponse(message);
            const botMsg = document.createElement('div');
            botMsg.className = 'bot-message';
            botMsg.style.cssText = `
                background: rgba(0, 198, 255, 0.1);
                border-left: 3px solid #00C6FF;
                padding: 10px;
                border-radius: 8px;
                margin-bottom: 10px;
                color: #E0E0E0;
                font-size: 0.9rem;
            `;
            botMsg.innerHTML = response;
            messagesContainer.appendChild(botMsg);
            
            // Auto-scroll to bottom
            messagesContainer.scrollTop = messagesContainer.scrollHeight;
        }, 500);
        
        // Auto-scroll to bottom
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }
    
    getResponse(question) {
        const q = question.toLowerCase();
        
        // Game Controls
        if (q.includes('control') || q.includes('how to play') || q.includes('how do i play')) {
            return `🎮 <strong>Controls:</strong><br>${this.knowledgeBase.game.controls}`;
        }
        
        // Special Ability
        if (q.includes('special') || q.includes('ability') || q.includes('q key')) {
            return `⚡ <strong>Special Ability:</strong><br>${this.knowledgeBase.game.specialAbility}`;
        }
        
        // Multiplayer
        if (q.includes('multiplayer') || q.includes('online') || q.includes('server') || q.includes('join')) {
            return `🌐 <strong>Multiplayer:</strong><br>${this.knowledgeBase.game.multiplayer}`;
        }
        
        // Upgrades
        if (q.includes('upgrade') || q.includes('improve') || q.includes('credits')) {
            return `⬆️ <strong>Upgrades:</strong><br>${this.knowledgeBase.game.upgrades}`;
        }
        
        // Ships
        if (q.includes('ship') || q.includes('unlock') || q.includes('hangar')) {
            return `🚀 <strong>Ships:</strong><br>${this.knowledgeBase.game.ships}`;
        }
        
        // Power-ups
        if (q.includes('power') || q.includes('boost') || q.includes('pickup')) {
            return `⚡ <strong>Power-ups:</strong><br>${this.knowledgeBase.game.powerups}`;
        }
        
        // Boss
        if (q.includes('boss') || q.includes('wave 10')) {
            return `👹 <strong>Boss Battles:</strong><br>${this.knowledgeBase.game.boss}`;
        }
        
        // Maps
        if (q.includes('map') || q.includes('level') || q.includes('sector')) {
            return `🗺️ <strong>Maps:</strong><br>${this.knowledgeBase.game.maps}`;
        }
        
        // Account/Sign-in
        if (q.includes('account') || q.includes('sign in') || q.includes('login') || q.includes('register')) {
            return `👤 <strong>Account System:</strong><br>${this.knowledgeBase.website.account}`;
        }
        
        // Leaderboard
        if (q.includes('leaderboard') || q.includes('ranking') || q.includes('top player')) {
            return `🏆 <strong>Leaderboard:</strong><br>${this.knowledgeBase.website.leaderboard}`;
        }
        
        // Languages
        if (q.includes('language') || q.includes('translation') || q.includes('spanish') || q.includes('french')) {
            return `🌐 <strong>Languages:</strong><br>${this.knowledgeBase.website.languages}`;
        }
        
        // Download
        if (q.includes('download') || q.includes('windows') || q.includes('.exe') || q.includes('standalone')) {
            return `💻 <strong>Download:</strong><br>${this.knowledgeBase.website.download}`;
        }
        
        // Admin
        if (q.includes('admin') || q.includes('king_davez') || q.includes('developer')) {
            return `👑 <strong>Admin Panel:</strong><br>${this.knowledgeBase.website.admin}`;
        }
        
        // Troubleshooting - Stuck
        if (q.includes('stuck') || q.includes('frozen') || q.includes('not moving')) {
            return `🔧 <strong>Stuck Controls:</strong><br>${this.knowledgeBase.troubleshooting.stuck}`;
        }
        
        // Troubleshooting - Connection
        if (q.includes('connect') || q.includes('offline') || q.includes('connection')) {
            return `🔧 <strong>Connection Issues:</strong><br>${this.knowledgeBase.troubleshooting.multiplayer}`;
        }
        
        // Troubleshooting - Lag
        if (q.includes('lag') || q.includes('slow') || q.includes('fps') || q.includes('performance')) {
            return `🔧 <strong>Performance:</strong><br>${this.knowledgeBase.troubleshooting.lag}`;
        }
        
        // Database
        if (q.includes('database') || q.includes('supabase') || q.includes('sync')) {
            return `🗄️ <strong>Database:</strong><br>${this.knowledgeBase.technical.database}`;
        }
        
        // Server hosting
        if (q.includes('host') || q.includes('deploy') || q.includes('render')) {
            return `☁️ <strong>Server Hosting:</strong><br>${this.knowledgeBase.technical.server}`;
        }
        
        // Generic response with helpful links
        return `
            🤖 I can help you with:<br><br>
            <strong>Game:</strong> controls, special ability, upgrades, ships, power-ups, boss battles, maps<br>
            <strong>Website:</strong> account, leaderboard, languages, themes, downloads<br>
            <strong>Technical:</strong> multiplayer setup, database, server hosting<br>
            <strong>Troubleshooting:</strong> stuck controls, connection issues, lag<br><br>
            Try asking a specific question like "How do I use special ability?" or "How to join multiplayer?"<br><br>
            📚 For detailed guides, check the documentation files in your project folder!
        `;
    }
}

// Initialize chatbot when DOM is ready
if (typeof window !== 'undefined') {
    window.addEventListener('DOMContentLoaded', () => {
        window.aiHelper = new AIHelperChatbot();
        console.log('✅ AI Helper Chatbot initialized!');
    });
}

// Export for module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = AIHelperChatbot;
}
