#!/usr/bin/env node
require('dotenv').config();

/**
 * Discord Notification Utility
 * Send notifications to Discord webhooks from command line or programmatically
 * 
 * Usage from command line:
 * node discord-notify.js update "New Feature" "Added dark mode support"
 * node discord-notify.js player "PlayerName" "achieved high score" "1000"
 * node discord-notify.js status "online" "Server is running smoothly"
 */

const WEBHOOK_URLS = {
    updates: process.env.DISCORD_WEBHOOK_UPDATES,
    security: process.env.DISCORD_WEBHOOK_SECURITY
};

async function sendDiscordNotification(message, webhookType = 'updates') {
    const webhookUrl = WEBHOOK_URLS[webhookType];
    
    if (!webhookUrl) {
        console.error(`❌ Discord webhook URL not configured for type: ${webhookType}`);
        console.error('Please check your .env file');
        return false;
    }

    try {
        const response = await fetch(webhookUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                embeds: [{
                    title: message.title || '🎮 Website Update',
                    description: message.description || '',
                    color: message.color || 3447003,
                    fields: message.fields || [],
                    timestamp: new Date().toISOString(),
                    footer: {
                        text: 'HideoutAds Space Shooter'
                    }
                }]
            })
        });

        if (!response.ok) {
            console.error('❌ Discord notification failed:', response.statusText);
            return false;
        }

        console.log('✅ Discord notification sent successfully');
        return true;
    } catch (error) {
        console.error('❌ Error sending Discord notification:', error.message);
        return false;
    }
}

// Preset notification types
const notificationPresets = {
    update: (title, description, details = {}) => ({
        title: `📢 ${title}`,
        description,
        color: 3447003,
        fields: Object.keys(details).map(key => ({
            name: key,
            value: details[key],
            inline: true
        }))
    }),
    
    newFeature: (title, description, details = {}) => ({
        title: `✨ ${title}`,
        description,
        color: 5763719,
        fields: Object.keys(details).map(key => ({
            name: key,
            value: details[key],
            inline: true
        }))
    }),
    
    bugFix: (title, description) => ({
        title: `🔧 ${title}`,
        description,
        color: 15105570
    }),
    
    maintenance: (title, description, downtime = 'Unknown') => ({
        title: `⚙️ ${title}`,
        description,
        color: 15844367,
        fields: [
            { name: 'Expected Downtime', value: downtime, inline: true }
        ]
    }),
    
    security: (title, description) => ({
        title: `🔒 ${title}`,
        description,
        color: 15158332
    }),
    
    playerActivity: (playerName, activity, score = 'N/A', details = 'N/A') => ({
        title: '🎯 Player Achievement',
        description: `**${playerName}** ${activity}`,
        color: 15844367,
        fields: [
            { name: 'Score', value: score.toString(), inline: true },
            { name: 'Details', value: details, inline: true }
        ]
    }),
    
    serverStatus: (status, message) => {
        const colors = {
            'online': 5763719,
            'offline': 15158332,
            'warning': 15105570
        };
        return {
            title: `🔔 Server Status: ${status.toUpperCase()}`,
            description: message,
            color: colors[status] || colors['warning']
        };
    },
    
    leaderboard: (topPlayers) => {
        const leaderboardText = topPlayers
            .slice(0, 5)
            .map((player, index) => `${index + 1}. **${player.name}** - ${player.score} points`)
            .join('\n');
        
        return {
            title: '🏆 Leaderboard Update',
            description: 'Top 5 Players:\n' + leaderboardText,
            color: 15844367
        };
    }
};

// CLI interface
async function main() {
    const args = process.argv.slice(2);
    
    if (args.length === 0) {
        console.log(`
Discord Notification Utility
============================

Usage:
  node discord-notify.js <type> <arg1> <arg2> [arg3]

Types:
  update <title> <description>          - Send general update
  feature <title> <description>         - New feature announcement
  bugfix <title> <description>          - Bug fix notification
  maintenance <title> <description> <downtime>  - Maintenance notice
  player <name> <activity> <score>      - Player achievement
  status <status> <message>             - Server status (online/offline/warning)
  
Examples:
  node discord-notify.js update "New Feature" "Added dark mode"
  node discord-notify.js player "John" "got high score" "1000"
  node discord-notify.js status "online" "Server running"
        `);
        return;
    }

    const type = args[0];
    let message;
    let webhookType = 'updates';

    switch (type) {
        case 'update':
            message = notificationPresets.update(args[1], args[2]);
            break;
        case 'feature':
            message = notificationPresets.newFeature(args[1], args[2]);
            break;
        case 'bugfix':
            message = notificationPresets.bugFix(args[1], args[2]);
            break;
        case 'maintenance':
            message = notificationPresets.maintenance(args[1], args[2], args[3] || 'Unknown');
            break;
        case 'player':
            message = notificationPresets.playerActivity(args[1], args[2], args[3] || 'N/A');
            break;
        case 'status':
            message = notificationPresets.serverStatus(args[1], args[2]);
            webhookType = 'security';
            break;
        default:
            console.error(`❌ Unknown notification type: ${type}`);
            return;
    }

    await sendDiscordNotification(message, webhookType);
}

// Run if called from command line
if (require.main === module) {
    main();
}

// Export for programmatic use
module.exports = {
    sendDiscordNotification,
    notificationPresets
};
