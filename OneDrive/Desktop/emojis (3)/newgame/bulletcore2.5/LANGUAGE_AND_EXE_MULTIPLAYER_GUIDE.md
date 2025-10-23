# Language Selection & Windows .exe Multiplayer Guide

## Overview
This guide explains how to add language selection to your Space Shooter game and enable online multiplayer in the Windows .exe standalone version.

## ✅ Current Status

### Languages Available (8 Total)
Your game already has translations.js with support for:
- 🇺🇸 English (en)
- 🇪🇸 Spanish (es)
- 🇫🇷 French (fr)
- 🇩🇪 German (de)
- 🇯🇵 Japanese (ja)
- 🇨🇳 Chinese (zh)
- 🇧🇷 Portuguese (pt)
- 🇷🇺 Russian (ru)

### What Needs to Be Added

#### 1. Language Selection UI in Game
Add a language picker in the Settings modal

#### 2. Enable Multiplayer in Windows .exe
Modify electron-main.cjs to allow WebSocket connections

---

## Part 1: Add Language Selection to Game

### Step 1: Update Settings Modal in index.html

Add language selector after the existing settings. Find the settings modal and add:

```html
<div id="settings-modal" class="modal hidden">
    <div class="modal-content">
        <span class="close-button">&times;</span>
        <h2>Settings</h2>
        
        <!-- EXISTING SETTINGS -->
        <div class="setting-item">
            <label for="effects-toggle">Enable Special Effects</label>
            <input type="checkbox" id="effects-toggle" checked>
        </div>
        <div class="setting-item">
            <label for="sfx-volume">SFX Volume</label>
            <input type="range" id="sfx-volume" min="0" max="1" step="0.1" value="0.5">
        </div>
        <div class="setting-item">
            <label for="music-volume">Music Volume</label>
            <input type="range" id="music-volume" min="0" max="1" step="0.1" value="0.2">
        </div>
        
        <!-- ADD THIS NEW LANGUAGE SETTING -->
        <div class="setting-item">
            <label for="language-select">🌐 Language</label>
            <select id="language-select" style="padding: 8px; background: rgba(0,0,0,0.5); border: 2px solid #00C6FF; border-radius: 5px; color: #00C6FF; font-family: 'Orbitron', sans-serif; cursor: pointer;">
                <option value="en">🇺🇸 English</option>
                <option value="es">🇪🇸 Español</option>
                <option value="fr">🇫🇷 Français</option>
                <option value="de">🇩🇪 Deutsch</option>
                <option value="ja">🇯🇵 日本語</option>
                <option value="zh">🇨🇳 中文</option>
                <option value="pt">🇧🇷 Português</option>
                <option value="ru">🇷🇺 Русский</option>
            </select>
        </div>
    </div>
</div>
```

### Step 2: Add Language Manager Script to index.html

Add this BEFORE the closing `</head>` tag:

```html
<script src="../translations.js"></script>
<script>
    // Initialize language system when game loads
    window.addEventListener('DOMContentLoaded', () => {
        // Load saved language preference
        const savedLang = localStorage.getItem('game_language') || 'en';
        
        // Set language select dropdown
        const langSelect = document.getElementById('language-select');
        if (langSelect) {
            langSelect.value = savedLang;
            
            // Listen for language changes
            langSelect.addEventListener('change', (e) => {
                const newLang = e.target.value;
                localStorage.setItem('game_language', newLang);
                
                // Show notification
                const notif = document.getElementById('wave-notification');
                if (notif) {
                    notif.innerText = '🌐 Language changed! Restart game to apply.';
                    notif.classList.add('show');
                    setTimeout(() => notif.classList.remove('show'), 3000);
                }
                
                console.log(`Language changed to: ${newLang}`);
            });
        }
    });
</script>
```

### Step 3: Use Translations in Game Code (index.tsx)

In your game code, add this near the top of index.tsx:

```typescript
// Get current language
const currentLanguage = localStorage.getItem('game_language') || 'en';

// Translation helper function
function translate(key: string): string {
    if (typeof (window as any).LanguageManager !== 'undefined') {
        return (window as any).LanguageManager.get(key);
    }
    return key; // Fallback to key if translation system not loaded
}

// Example usage in your existing functions:
// Instead of: welcomeMessageEl.innerText = `Welcome, ${gameState.username}!`;
// Use: welcomeMessageEl.innerText = `${translate('notifications.welcomeToGame')}, ${gameState.username}!`;
```

---

## Part 2: Enable Online Multiplayer in Windows .exe

### Problem
The Electron app has Content Security Policy (CSP) that blocks WebSocket connections by default.

### Solution
Modify `electron-main.cjs` to allow WebSocket connections to your multiplayer server.

### Step 1: Update electron-main.cjs

Find the `webPreferences` section and update it:

```javascript
const { app, BrowserWindow } = require('electron');
const path = require('path');

function createWindow() {
    const win = new BrowserWindow({
        width: 1280,
        height: 720,
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
            sandbox: true,
            // IMPORTANT: Allow insecure content for localhost multiplayer server
            webSecurity: true,
            allowRunningInsecureContent: false
        },
        icon: path.join(__dirname, 'icon.png')
    });

    win.loadFile('index.html');
    
    // Open DevTools in development (optional)
    // win.webContents.openDevTools();
    
    // Handle external links
    win.webContents.setWindowOpenHandler(({ url }) => {
        require('electron').shell.openExternal(url);
        return { action: 'deny' };
    });
    
    // IMPORTANT: Set Content Security Policy to allow WebSocket connections
    win.webContents.session.webRequest.onHeadersReceived((details, callback) => {
        callback({
            responseHeaders: {
                ...details.responseHeaders,
                'Content-Security-Policy': [
                    "default-src 'self' 'unsafe-inline' 'unsafe-eval' https://flnbfizlfofqfbrdjttk.supabase.co https://cdn.jsdelivr.net; " +
                    "connect-src 'self' https://flnbfizlfofqfbrdjttk.supabase.co wss://*.onrender.com ws://localhost:* wss://localhost:* https://*.onrender.com; " +
                    "img-src 'self' data: https:; " +
                    "script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.jsdelivr.net; " +
                    "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; " +
                    "font-src 'self' data: https://fonts.gstatic.com;"
                ]
            }
        });
    });
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        createWindow();
    }
});
```

### Step 2: Update Multiplayer Server URL

In your game code (index.tsx), make sure the multiplayer server connection uses the correct URL:

```typescript
// Multiplayer WebSocket connection
let multiplayerWs: WebSocket | null = null;

function connectToMultiplayerServer() {
    // Use production server when deployed, localhost for development
    const serverUrl = 'wss://your-app-name.onrender.com'; // Change to your Render.com URL
    // Or use: 'ws://localhost:3001' for local testing
    
    try {
        multiplayerWs = new WebSocket(serverUrl);
        
        multiplayerWs.onopen = () => {
            console.log('✅ Connected to multiplayer server!');
            showWaveNotification('🌐 Connected to server!');
        };
        
        multiplayerWs.onerror = (error) => {
            console.error('❌ WebSocket error:', error);
            showWaveNotification('❌ Connection failed!');
        };
        
        multiplayerWs.onclose = () => {
            console.log('Disconnected from multiplayer server');
        };
        
        multiplayerWs.onmessage = (event) => {
            const data = JSON.parse(event.data);
            console.log('Received:', data);
            // Handle multiplayer messages here
        };
    } catch (err) {
        console.error('Failed to connect:', err);
    }
}
```

---

## Part 3: Testing

### Test Language Selection
1. Open the game
2. Click Settings ⚙️
3. Select a different language from the dropdown
4. You'll see "Language changed! Restart game to apply."
5. Restart the game to see changes (menu items will be in the new language)

### Test Windows .exe Multiplayer
1. Build the Windows .exe:
   ```bash
   cd HideoutAdsWebsite/game
   npm run build:win
   ```

2. Deploy your multiplayer server to Render.com (see multiplayer-server/README.md)

3. Update the WebSocket URL in your game code to point to Render.com:
   ```typescript
   const serverUrl = 'wss://your-app-name.onrender.com';
   ```

4. Rebuild the .exe and test multiplayer connection

---

## Part 4: Deploy Multiplayer Server to Render.com

### Quick Steps:
1. Go to https://render.com and sign up (free)
2. Click "New +" → "Web Service"
3. Connect your GitHub repository
4. Select the `multiplayer-server` folder
5. Configure:
   - **Name**: space-shooter-server
   - **Environment**: Node
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Plan**: Free
6. Click "Create Web Service"
7. Wait 5-10 minutes for deployment
8. Copy your server URL: `https://space-shooter-server.onrender.com`
9. Update game code with this URL

---

## Summary

### ✅ Language Selection
- Added dropdown in Settings modal
- 8 languages supported
- Saves preference to localStorage
- Shows notification when changed

### ✅ Windows .exe Multiplayer
- Modified electron-main.cjs CSP
- Allows WebSocket connections
- Works with Render.com server
- Supports wss:// and ws:// protocols

### 📝 Next Steps
1. Add language selection UI to Settings modal (HTML changes)
2. Update electron-main.cjs with CSP changes
3. Deploy multiplayer server to Render.com
4. Update game code with production server URL
5. Rebuild Windows .exe
6. Test both features

---

## Support

If you encounter issues:
- **Language not changing**: Check browser console for errors, ensure translations.js is loaded
- **Multiplayer not connecting**: Check CSP headers, verify server is running, check WebSocket URL
- **Build errors**: Run `npm install` in game folder, ensure all dependencies are installed

Good luck! 🚀🎮
