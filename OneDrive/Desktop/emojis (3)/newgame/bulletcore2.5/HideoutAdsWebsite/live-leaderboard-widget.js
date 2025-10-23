// Live Leaderboard Widget for HideoutAds.online
// Auto-updates every 5 seconds with real-time player data from Supabase

class LiveLeaderboard {
    constructor(containerId, options = {}) {
        this.container = document.getElementById(containerId);
        this.updateInterval = options.updateInterval || 5000; // 5 seconds default
        this.maxEntries = options.maxEntries || 10;
        this.showPlaytime = options.showPlaytime !== false;
        this.showKills = options.showKills !== false;
        this.showWave = options.showWave !== false;
        this.intervalId = null;
        
        // Supabase connection
        this.supabaseUrl = 'https://flnbfizlfofqfbrdjttk.supabase.co';
        this.supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZsbmJmaXpsZm9mcWZicmRqdHRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEwOTg4MzQsImV4cCI6MjA3NjY3NDgzNH0.8lHxwyudvSJA7S-FDtj1XYVm6Zrpc0_myIzrUClzH4g';
        
        if (!this.container) {
            console.error('LiveLeaderboard: Container not found');
            return;
        }
        
        this.init();
    }
    
    init() {
        // Create initial structure
        this.container.innerHTML = `
            <div class="live-leaderboard-widget" style="
                background: linear-gradient(135deg, rgba(0, 0, 0, 0.9), rgba(0, 50, 100, 0.9));
                border: 2px solid #00C6FF;
                border-radius: 15px;
                padding: 20px;
                font-family: 'Orbitron', sans-serif;
                box-shadow: 0 0 30px rgba(0, 198, 255, 0.5);
                animation: pulseGlow 2s infinite;
            ">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                    <h3 style="margin: 0; color: #00C6FF; font-size: 1.5rem; text-shadow: 0 0 10px rgba(0, 198, 255, 0.8);">
                        🏆 LIVE LEADERBOARD
                    </h3>
                    <div id="update-indicator" style="
                        width: 10px;
                        height: 10px;
                        background: #32CD32;
                        border-radius: 50%;
                        box-shadow: 0 0 10px #32CD32;
                        animation: blink 1s infinite;
                    "></div>
                </div>
                <div id="leaderboard-entries" style="
                    max-height: 500px;
                    overflow-y: auto;
                    scrollbar-width: thin;
                    scrollbar-color: #00C6FF rgba(0, 0, 0, 0.3);
                ">
                    <div style="text-align: center; padding: 20px; color: #888;">
                        Loading leaderboard data...
                    </div>
                </div>
                <div style="text-align: center; margin-top: 15px; font-size: 0.8rem; color: #888;">
                    Auto-updates every ${this.updateInterval / 1000}s
                </div>
            </div>
            <style>
                @keyframes pulseGlow {
                    0%, 100% { box-shadow: 0 0 20px rgba(0, 198, 255, 0.5); }
                    50% { box-shadow: 0 0 40px rgba(0, 198, 255, 0.8); }
                }
                @keyframes blink {
                    0%, 100% { opacity: 1; }
                    50% { opacity: 0.3; }
                }
                .live-leaderboard-widget::-webkit-scrollbar {
                    width: 8px;
                }
                .live-leaderboard-widget::-webkit-scrollbar-track {
                    background: rgba(0, 0, 0, 0.3);
                    border-radius: 10px;
                }
                .live-leaderboard-widget::-webkit-scrollbar-thumb {
                    background: #00C6FF;
                    border-radius: 10px;
                }
                .live-leaderboard-widget::-webkit-scrollbar-thumb:hover {
                    background: #00FFFF;
                }
                .leaderboard-entry {
                    background: rgba(0, 198, 255, 0.1);
                    border: 1px solid rgba(0, 198, 255, 0.3);
                    border-radius: 8px;
                    padding: 12px;
                    margin-bottom: 10px;
                    transition: all 0.3s;
                    animation: slideIn 0.5s ease-out;
                }
                .leaderboard-entry:hover {
                    background: rgba(0, 198, 255, 0.2);
                    transform: translateX(5px);
                    border-color: #00C6FF;
                }
                .leaderboard-entry.rank-1 {
                    background: linear-gradient(135deg, rgba(255, 215, 0, 0.2), rgba(255, 215, 0, 0.1));
                    border-color: gold;
                }
                .leaderboard-entry.rank-2 {
                    background: linear-gradient(135deg, rgba(192, 192, 192, 0.2), rgba(192, 192, 192, 0.1));
                    border-color: silver;
                }
                .leaderboard-entry.rank-3 {
                    background: linear-gradient(135deg, rgba(205, 127, 50, 0.2), rgba(205, 127, 50, 0.1));
                    border-color: #CD7F32;
                }
                @keyframes slideIn {
                    from {
                        opacity: 0;
                        transform: translateX(-20px);
                    }
                    to {
                        opacity: 1;
                        transform: translateX(0);
                    }
                }
            </style>
        `;
        
        // Start auto-updating
        this.startAutoUpdate();
    }
    
    async fetchLeaderboardData() {
        try {
            const response = await fetch(
                `${this.supabaseUrl}/rest/v1/leaderboard?select=*&order=score.desc&limit=${this.maxEntries}`,
                {
                    headers: {
                        'apikey': this.supabaseKey,
                        'Authorization': `Bearer ${this.supabaseKey}`
                    }
                }
            );
            
            if (!response.ok) throw new Error('Failed to fetch leaderboard');
            
            const data = await response.json();
            return data;
        } catch (error) {
            console.error('Error fetching leaderboard:', error);
            return [];
        }
    }
    
    formatPlaytime(seconds) {
        if (!seconds) return '0m';
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        if (hours > 0) return `${hours}h ${minutes}m`;
        return `${minutes}m`;
    }
    
    getRankEmoji(rank) {
        switch(rank) {
            case 1: return '🥇';
            case 2: return '🥈';
            case 3: return '🥉';
            default: return `#${rank}`;
        }
    }
    
    async updateDisplay() {
        const data = await this.fetchLeaderboardData();
        const entriesContainer = document.getElementById('leaderboard-entries');
        
        if (!entriesContainer) return;
        
        if (data.length === 0) {
            entriesContainer.innerHTML = `
                <div style="text-align: center; padding: 20px; color: #888;">
                    No leaderboard data available yet. Play the game to be the first!
                </div>
            `;
            return;
        }
        
        entriesContainer.innerHTML = data.map((entry, index) => {
            const rank = index + 1;
            const rankClass = rank <= 3 ? `rank-${rank}` : '';
            
            return `
                <div class="leaderboard-entry ${rankClass}">
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <div style="display: flex; align-items: center; gap: 15px; flex: 1;">
                            <div style="
                                font-size: 1.5rem;
                                font-weight: bold;
                                color: ${rank === 1 ? 'gold' : rank === 2 ? 'silver' : rank === 3 ? '#CD7F32' : '#00C6FF'};
                                min-width: 50px;
                                text-align: center;
                            ">
                                ${this.getRankEmoji(rank)}
                            </div>
                            <div style="flex: 1;">
                                <div style="font-size: 1.1rem; font-weight: bold; color: white; margin-bottom: 5px;">
                                    ${entry.player_name || 'Anonymous'}
                                </div>
                                <div style="display: flex; gap: 15px; font-size: 0.9rem; color: #888;">
                                    <span style="color: #FFD700;">💰 ${entry.score.toLocaleString()}</span>
                                    ${this.showKills ? `<span>☠️ ${entry.kills || 0}</span>` : ''}
                                    ${this.showWave ? `<span>🌊 Wave ${entry.wave || 1}</span>` : ''}
                                    ${this.showPlaytime && entry.duration_seconds ? `<span>⏱️ ${this.formatPlaytime(entry.duration_seconds)}</span>` : ''}
                                </div>
                            </div>
                        </div>
                        <div style="text-align: right; color: #666; font-size: 0.8rem;">
                            ${new Date(entry.created_at).toLocaleDateString()}
                        </div>
                    </div>
                </div>
            `;
        }).join('');
        
        // Flash update indicator
        const indicator = document.getElementById('update-indicator');
        if (indicator) {
            indicator.style.background = '#32CD32';
            indicator.style.boxShadow = '0 0 15px #32CD32';
            setTimeout(() => {
                indicator.style.background = '#32CD32';
                indicator.style.boxShadow = '0 0 10px #32CD32';
            }, 200);
        }
    }
    
    startAutoUpdate() {
        // Update immediately
        this.updateDisplay();
        
        // Then update at interval
        this.intervalId = setInterval(() => {
            this.updateDisplay();
        }, this.updateInterval);
    }
    
    stopAutoUpdate() {
        if (this.intervalId) {
            clearInterval(this.intervalId);
            this.intervalId = null;
        }
    }
    
    destroy() {
        this.stopAutoUpdate();
        if (this.container) {
            this.container.innerHTML = '';
        }
    }
}

// Easy initialization function
window.initLiveLeaderboard = function(containerId, options) {
    return new LiveLeaderboard(containerId, options);
};

// Auto-initialize if container exists on page load
if (typeof window !== 'undefined') {
    window.addEventListener('DOMContentLoaded', () => {
        const container = document.getElementById('live-leaderboard-container');
        if (container) {
            window.liveLeaderboard = new LiveLeaderboard('live-leaderboard-container');
        }
    });
}

// Export for module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = LiveLeaderboard;
}
