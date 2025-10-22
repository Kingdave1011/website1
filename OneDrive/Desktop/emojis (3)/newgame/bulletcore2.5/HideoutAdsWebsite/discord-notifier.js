/**
 * Discord Notification Helper for HideoutAds Website
 * Easy integration for sending updates to Discord
 */

const BACKEND_URL = 'http://localhost:3000'; // Change to your production URL

class DiscordNotifier {
    constructor(backendUrl = BACKEND_URL) {
        this.backendUrl = backendUrl;
    }

    /**
     * Send a general website update notification
     * @param {string} type - Type of update: 'new-feature', 'bug-fix', 'update', 'maintenance', 'security'
     * @param {string} title - Title of the update
     * @param {string} description - Description of the update
     * @param {object} details - Optional additional details
     */
    async sendUpdate(type, title, description, details = {}) {
        try {
            const response = await fetch(`${this.backendUrl}/api/notify-update`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    type,
                    title,
                    description,
                    details
                })
            });
            
            const result = await response.json();
            return result.success;
        } catch (error) {
            console.error('Failed to send Discord notification:', error);
            return false;
        }
    }

    /**
     * Send a player achievement notification
     * @param {string} playerName - Name of the player
     * @param {string} activity - What they achieved
     * @param {number|string} score - Their score
     * @param {string} details - Additional details
     */
    async sendPlayerAchievement(playerName, activity, score, details = 'N/A') {
        try {
            const response = await fetch(`${this.backendUrl}/api/notify-player-activity`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    playerName,
                    activity,
                    score: score.toString(),
                    details
                })
            });
            
            const result = await response.json();
            return result.success;
        } catch (error) {
            console.error('Failed to send Discord notification:', error);
            return false;
        }
    }

    /**
     * Send a server status notification
     * @param {string} status - 'online', 'offline', or 'warning'
     * @param {string} message - Status message
     */
    async sendServerStatus(status, message) {
        try {
            const response = await fetch(`${this.backendUrl}/api/notify-status`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    status,
                    message
                })
            });
            
            const result = await response.json();
            return result.success;
        } catch (error) {
            console.error('Failed to send Discord notification:', error);
            return false;
        }
    }

    /**
     * Send a leaderboard update
     * @param {Array} topPlayers - Array of {name, score} objects
     */
    async sendLeaderboardUpdate(topPlayers) {
        try {
            const response = await fetch(`${this.backendUrl}/api/notify-leaderboard`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    topPlayers
                })
            });
            
            const result = await response.json();
            return result.success;
        } catch (error) {
            console.error('Failed to send Discord notification:', error);
            return false;
        }
    }
}

// Create a singleton instance
const discordNotifier = new DiscordNotifier();

// ==================== USAGE EXAMPLES ====================

// Example 1: New Feature Announcement
async function announceNewFeature() {
    await discordNotifier.sendUpdate(
        'new-feature',
        'Dark Mode Added!',
        'Players can now switch between light and dark themes in settings.',
        {
            'Version': '2.5.0',
            'Release Date': new Date().toLocaleDateString()
        }
    );
}

// Example 2: Bug Fix Notification
async function announceBugFix() {
    await discordNotifier.sendUpdate(
        'bug-fix',
        'Collision Bug Fixed',
        'Fixed issue where bullets would pass through enemies on higher difficulty.',
        {
            'Affected Levels': '15-20',
            'Status': 'Resolved'
        }
    );
}

// Example 3: Player Achievement (integrate into game)
async function notifyHighScore(playerName, score) {
    await discordNotifier.sendPlayerAchievement(
        playerName,
        'achieved a new high score!',
        score,
        `Wave ${Math.floor(score / 1000)} completed`
    );
}

// Example 4: Maintenance Notice
async function notifyMaintenance() {
    await discordNotifier.sendUpdate(
        'maintenance',
        'Scheduled Maintenance',
        'Server will be down for updates on Sunday at 3 AM EST.',
        {
            'Duration': '2 hours',
            'Services Affected': 'Multiplayer, Leaderboards'
        }
    );
}

// Example 5: Daily Leaderboard Update (run this daily)
async function sendDailyLeaderboard(players) {
    const topPlayers = players.slice(0, 5).map(player => ({
        name: player.username,
        score: player.highScore
    }));
    
    await discordNotifier.sendLeaderboardUpdate(topPlayers);
}

// Example 6: New Player Welcome (when someone signs up)
async function welcomeNewPlayer(username) {
    await discordNotifier.sendPlayerAchievement(
        username,
        'just joined the game!',
        0,
        'Welcome to the community! 🎮'
    );
}

// Example 7: Milestone Achievement
async function notifyMilestone(playerName, milestone) {
    const milestones = {
        '100k': { score: 100000, title: 'reached 100,000 points!' },
        '1mil': { score: 1000000, title: 'reached 1 MILLION points!' },
        'wave50': { score: 50000, title: 'survived to Wave 50!' },
        'wave100': { score: 100000, title: 'survived to Wave 100! 🏆' }
    };
    
    const achievement = milestones[milestone];
    if (achievement) {
        await discordNotifier.sendPlayerAchievement(
            playerName,
            achievement.title,
            achievement.score,
            'Amazing achievement!'
        );
    }
}

// ==================== INTEGRATION HOOKS ====================

// Hook into game over event
window.addEventListener('gameOver', async (event) => {
    const { playerName, score, wave } = event.detail;
    
    // Notify if new high score
    if (score > getLocalHighScore()) {
        await notifyHighScore(playerName, score);
    }
    
    // Notify if reached major milestone
    if (wave >= 50 && wave % 25 === 0) {
        await notifyMilestone(playerName, `wave${wave}`);
    }
});

// Hook into new user registration
window.addEventListener('userRegistered', async (event) => {
    const { username } = event.detail;
    await welcomeNewPlayer(username);
});

// Hook into page load to check for announcements
window.addEventListener('DOMContentLoaded', () => {
    // Check if there's a pending announcement to make
    const announcement = sessionStorage.getItem('pendingAnnouncement');
    if (announcement) {
        const data = JSON.parse(announcement);
        discordNotifier.sendUpdate(
            data.type,
            data.title,
            data.description,
            data.details
        );
        sessionStorage.removeItem('pendingAnnouncement');
    }
});

// Helper function (implement based on your storage)
function getLocalHighScore() {
    return parseInt(localStorage.getItem('highScore') || '0');
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { DiscordNotifier, discordNotifier };
}
