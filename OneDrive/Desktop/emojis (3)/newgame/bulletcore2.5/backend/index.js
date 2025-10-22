require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Discord Webhook Utility
async function sendDiscordNotification(message, webhookType = 'updates') {
    const webhookUrl = webhookType === 'security' 
        ? process.env.DISCORD_WEBHOOK_SECURITY 
        : process.env.DISCORD_WEBHOOK_UPDATES;
    
    if (!webhookUrl) {
        console.error('Discord webhook URL not configured');
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
                    color: message.color || 3447003, // Blue
                    fields: message.fields || [],
                    timestamp: new Date().toISOString(),
                    footer: {
                        text: 'HideoutAds Space Shooter'
                    }
                }]
            })
        });

        if (!response.ok) {
            console.error('Discord notification failed:', response.statusText);
            return false;
        }

        console.log('✅ Discord notification sent successfully');
        return true;
    } catch (error) {
        console.error('Error sending Discord notification:', error);
        return false;
    }
}

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', message: 'Space Shooter Backend is running!' });
});

// Leaderboard endpoint (mock data - replace with database)
app.get('/api/leaderboard', (req, res) => {
    res.json({
        success: true,
        data: []  // Empty initially - will be populated by Supabase
    });
});

// Save player data endpoint
app.post('/api/save-player', (req, res) => {
    const playerData = req.body;
    // This will be handled by Supabase on frontend
    res.json({ success: true, message: 'Use Supabase for data persistence' });
});

// Website Update Notification Endpoint
app.post('/api/notify-update', async (req, res) => {
    const { type, title, description, details } = req.body;
    
    const fields = [];
    if (details) {
        Object.keys(details).forEach(key => {
            fields.push({
                name: key,
                value: details[key],
                inline: true
            });
        });
    }
    
    const colors = {
        'new-feature': 5763719, // Green
        'bug-fix': 15105570,    // Orange
        'update': 3447003,      // Blue
        'maintenance': 15844367, // Gold
        'security': 15158332    // Red
    };
    
    const message = {
        title: `${getEmoji(type)} ${title}`,
        description: description,
        color: colors[type] || colors['update'],
        fields: fields
    };
    
    const success = await sendDiscordNotification(message, type === 'security' ? 'security' : 'updates');
    
    res.json({ 
        success, 
        message: success ? 'Update notification sent to Discord' : 'Failed to send notification' 
    });
});

// Player Activity Notification
app.post('/api/notify-player-activity', async (req, res) => {
    const { playerName, activity, score, details } = req.body;
    
    const message = {
        title: '🎯 Player Achievement',
        description: `**${playerName}** ${activity}`,
        color: 15844367, // Gold
        fields: [
            { name: 'Score', value: score?.toString() || 'N/A', inline: true },
            { name: 'Details', value: details || 'N/A', inline: true }
        ]
    };
    
    const success = await sendDiscordNotification(message);
    res.json({ success });
});

// Server Status Notification
app.post('/api/notify-status', async (req, res) => {
    const { status, message: statusMessage } = req.body;
    
    const colors = {
        'online': 5763719,   // Green
        'offline': 15158332, // Red
        'warning': 15105570  // Orange
    };
    
    const message = {
        title: `🔔 Server Status: ${status.toUpperCase()}`,
        description: statusMessage,
        color: colors[status] || colors['warning']
    };
    
    const success = await sendDiscordNotification(message, 'security');
    res.json({ success });
});

// Leaderboard Update Notification
app.post('/api/notify-leaderboard', async (req, res) => {
    const { topPlayers } = req.body;
    
    const leaderboardText = topPlayers
        .slice(0, 5)
        .map((player, index) => `${index + 1}. **${player.name}** - ${player.score} points`)
        .join('\n');
    
    const message = {
        title: '🏆 Leaderboard Update',
        description: 'Top 5 Players:\n' + leaderboardText,
        color: 15844367 // Gold
    };
    
    const success = await sendDiscordNotification(message);
    res.json({ success });
});

// Helper function to get emoji based on update type
function getEmoji(type) {
    const emojis = {
        'new-feature': '✨',
        'bug-fix': '🔧',
        'update': '📢',
        'maintenance': '⚙️',
        'security': '🔒'
    };
    return emojis[type] || '📢';
}

// Start server
app.listen(PORT, () => {
    console.log(`✅ Space Shooter Backend running on port ${PORT}`);
    console.log(`📍 http://localhost:${PORT}/api/health`);
    console.log(`🔔 Discord webhooks configured`);
    
    // Send startup notification
    sendDiscordNotification({
        title: '🚀 Server Started',
        description: 'The Space Shooter backend server is now online!',
        color: 5763719,
        fields: [
            { name: 'Port', value: PORT.toString(), inline: true },
            { name: 'Environment', value: process.env.NODE_ENV || 'development', inline: true }
        ]
    }, 'security');
});
