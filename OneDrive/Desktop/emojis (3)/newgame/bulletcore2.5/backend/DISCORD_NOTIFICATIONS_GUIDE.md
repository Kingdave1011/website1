# Discord Notifications System Guide

This guide explains how to send automated Discord notifications for your website updates, player activities, and system status.

## 🚀 Quick Start

Your Discord webhook is already configured in the `.env` file:
- **Updates Webhook**: For general website updates, features, and player activities
- **Security Webhook**: For security alerts and server status notifications

## 📡 API Endpoints

### 1. Website Update Notification
Send notifications about website updates, new features, or bug fixes.

**Endpoint**: `POST /api/notify-update`

**Request Body**:
```json
{
  "type": "new-feature",
  "title": "Dark Mode Added",
  "description": "Players can now switch between light and dark themes!",
  "details": {
    "Version": "2.5.0",
    "Release Date": "2025-10-22"
  }
}
```

**Update Types**:
- `new-feature` - Green color, for new features
- `bug-fix` - Orange color, for bug fixes
- `update` - Blue color, for general updates
- `maintenance` - Gold color, for maintenance notices
- `security` - Red color, for security updates

**cURL Example**:
```bash
curl -X POST http://localhost:3000/api/notify-update \
  -H "Content-Type: application/json" \
  -d '{
    "type": "new-feature",
    "title": "Leaderboard System Live",
    "description": "Check out the new global leaderboard!",
    "details": {
      "Players Registered": "1,234",
      "Top Score": "999,999"
    }
  }'
```

### 2. Player Activity Notification
Notify about player achievements and milestones.

**Endpoint**: `POST /api/notify-player-activity`

**Request Body**:
```json
{
  "playerName": "King_davez",
  "activity": "achieved a new high score!",
  "score": "150000",
  "details": "Level 50 completed"
}
```

**JavaScript Example**:
```javascript
fetch('http://localhost:3000/api/notify-player-activity', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    playerName: 'King_davez',
    activity: 'unlocked legendary ship',
    score: '150000',
    details: 'First player to reach this milestone!'
  })
});
```

### 3. Server Status Notification
Send server status updates (online, offline, warnings).

**Endpoint**: `POST /api/notify-status`

**Request Body**:
```json
{
  "status": "online",
  "message": "All systems operational. Server running smoothly!"
}
```

**Status Options**:
- `online` - Green, server is running
- `offline` - Red, server is down
- `warning` - Orange, server issues detected

### 4. Leaderboard Update
Share top players with your Discord community.

**Endpoint**: `POST /api/notify-leaderboard`

**Request Body**:
```json
{
  "topPlayers": [
    { "name": "Player1", "score": 100000 },
    { "name": "Player2", "score": 95000 },
    { "name": "Player3", "score": 90000 },
    { "name": "Player4", "score": 85000 },
    { "name": "Player5", "score": 80000 }
  ]
}
```

## 🖥️ Command Line Usage

You can send notifications directly from the command line using the utility script.

### Basic Commands

```bash
# Navigate to backend directory
cd backend

# Send a general update
node discord-notify.js update "New Feature" "Added multiplayer support"

# Announce a new feature
node discord-notify.js feature "Shop System" "Players can now purchase upgrades!"

# Report a bug fix
node discord-notify.js bugfix "Fixed Crash Bug" "Resolved issue with level loading"

# Send maintenance notice
node discord-notify.js maintenance "Scheduled Maintenance" "Server will be down for updates" "2 hours"

# Notify about player achievement
node discord-notify.js player "King_davez" "got the highest score" "999999"

# Update server status
node discord-notify.js status "online" "Server is running smoothly"
```

### Help Command
```bash
node discord-notify.js
```
This displays all available commands and examples.

## 🌐 Website Integration Examples

### Example 1: Notify on New High Score
Add to your game code:

```javascript
async function onGameOver(playerName, score) {
  if (score > currentHighScore) {
    await fetch('http://localhost:3000/api/notify-player-activity', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        playerName: playerName,
        activity: 'set a new high score!',
        score: score.toString(),
        details: `Beat previous record by ${score - currentHighScore} points`
      })
    });
  }
}
```

### Example 2: Notify on Website Deploy
Add to your deployment script:

```javascript
const { sendDiscordNotification, notificationPresets } = require('./discord-notify');

async function notifyDeploy(version) {
  const message = notificationPresets.newFeature(
    'Website Updated!',
    `Version ${version} is now live!`,
    {
      'Version': version,
      'Deploy Time': new Date().toLocaleString(),
      'Status': '✅ Successful'
    }
  );
  
  await sendDiscordNotification(message, 'updates');
}

notifyDeploy('2.5.0');
```

### Example 3: Daily Leaderboard Summary
Schedule this to run daily:

```javascript
async function sendDailyLeaderboard() {
  // Fetch top players from your database
  const topPlayers = await getTopPlayersFromDatabase();
  
  await fetch('http://localhost:3000/api/notify-leaderboard', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ topPlayers })
  });
}

// Run daily at 8 PM
const schedule = require('node-schedule');
schedule.scheduleJob('0 20 * * *', sendDailyLeaderboard);
```

## 🎨 Customization

### Color Codes
Discord embed colors (decimal values):
- Green (Success): `5763719`
- Blue (Info): `3447003`
- Orange (Warning): `15105570`
- Red (Error): `15158332`
- Gold (Special): `15844367`

### Adding Custom Notification Types

Edit `backend/index.js` to add new endpoints:

```javascript
app.post('/api/notify-custom', async (req, res) => {
  const { title, description, color } = req.body;
  
  const message = {
    title: `🎮 ${title}`,
    description: description,
    color: color || 3447003,
    fields: []
  };
  
  const success = await sendDiscordNotification(message);
  res.json({ success });
});
```

## 🔧 Troubleshooting

### Notifications Not Sending

1. **Check webhook URL**:
   ```bash
   # View your .env file
   cat backend/.env | grep DISCORD_WEBHOOK
   ```

2. **Verify server is running**:
   ```bash
   cd backend
   node index.js
   ```

3. **Test webhook manually**:
   ```bash
   curl -X POST "YOUR_WEBHOOK_URL" \
     -H "Content-Type: application/json" \
     -d '{"content": "Test message"}'
   ```

4. **Check Discord webhook settings**:
   - Go to your Discord server
   - Server Settings → Integrations → Webhooks
   - Verify the webhook exists and is active

### Rate Limiting
Discord limits webhook requests:
- **30 requests per minute per webhook**
- **5 requests per second globally**

If you hit limits, implement throttling:

```javascript
const throttle = require('lodash.throttle');

const sendThrottled = throttle(async (message) => {
  await sendDiscordNotification(message);
}, 2000); // Max 1 every 2 seconds
```

## 📝 Best Practices

1. **Don't spam**: Only send important notifications
2. **Use appropriate webhooks**: Updates vs Security
3. **Include relevant details**: Help your community stay informed
4. **Test first**: Use a test channel before going live
5. **Handle errors gracefully**: Don't let failed notifications crash your app

## 🎯 Use Cases

### When to Send Notifications

**Updates Webhook** (General channel):
- ✅ New features released
- ✅ Bug fixes deployed
- ✅ Scheduled maintenance announcements
- ✅ Player achievements and milestones
- ✅ Daily/weekly leaderboard updates
- ✅ Special events starting

**Security Webhook** (Admin/mod channel):
- ✅ Server startup/shutdown
- ✅ Security alerts
- ✅ Critical errors
- ✅ Suspicious activity detected
- ✅ System performance warnings

## 🚀 Next Steps

1. Start your backend server: `cd backend && node index.js`
2. Test a notification: `node discord-notify.js update "Test" "Testing notifications"`
3. Check your Discord channel for the message
4. Integrate into your website using the API endpoints
5. Set up automated notifications for key events

## 📞 Support

If you need help:
- Check the console logs for error messages
- Verify your `.env` configuration
- Test the webhook URL directly in Discord
- Review the API endpoint examples above

Your Discord webhook is ready to use! 🎉
