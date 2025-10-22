# Auto-Update System for Standalone Game

This guide will help you add automatic updates to your Windows standalone game so it updates itself when new versions are released.

## 🔄 How It Works

1. Game checks your server for latest version on startup
2. If newer version available, downloads and installs automatically
3. User gets notified and game restarts with new version

---

## 📦 Part 1: Install electron-updater

```bash
cd HideoutAdsWebsite/game
npm install --save electron-updater
```

---

## 🔧 Part 2: Update electron-main.cjs

Replace your electron-main.cjs with this updated version:

```javascript
const { app, BrowserWindow, Menu, ipcMain } = require('electron');
const { autoUpdater } = require('electron-updater');
const path = require('path');

let mainWindow;
let updateAvailable = false;

// Auto-updater configuration
autoUpdater.autoDownload = false;
autoUpdater.autoInstallOnAppQuit = true;

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 1280,
        height: 720,
        minWidth: 800,
        minHeight: 600,
        title: 'Space Shooter V5 - Halloween Edition',
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
            preload: path.join(__dirname, 'preload.js')
        },
        backgroundColor: '#000000',
        autoHideMenuBar: true,
        fullscreenable: true
    });

    if (app.isPackaged) {
        mainWindow.loadFile(path.join(__dirname, 'dist/index.html'));
    } else {
        mainWindow.loadFile('dist/index.html');
    }

    if (app.isPackaged) {
        Menu.setApplicationMenu(null);
    }

    mainWindow.on('closed', () => {
        mainWindow = null;
    });

    mainWindow.maximize();
    
    // Check for updates after window is ready
    mainWindow.webContents.on('did-finish-load', () => {
        if (app.isPackaged) {
            setTimeout(() => {
                autoUpdater.checkForUpdates();
            }, 3000);
        }
    });
}

// Auto-updater events
autoUpdater.on('checking-for-update', () => {
    console.log('Checking for updates...');
});

autoUpdater.on('update-available', (info) => {
    console.log('Update available:', info.version);
    updateAvailable = true;
    
    mainWindow.webContents.send('update-available', {
        version: info.version,
        releaseNotes: info.releaseNotes
    });
});

autoUpdater.on('update-not-available', () => {
    console.log('Game is up to date!');
});

autoUpdater.on('download-progress', (progress) => {
    console.log(`Download progress: ${progress.percent.toFixed(2)}%`);
    mainWindow.webContents.send('download-progress', progress.percent);
});

autoUpdater.on('update-downloaded', (info) => {
    console.log('Update downloaded, will install on quit');
    mainWindow.webContents.send('update-downloaded', info.version);
});

autoUpdater.on('error', (err) => {
    console.error('Update error:', err);
});

// IPC handlers for update commands from renderer
ipcMain.on('download-update', () => {
    if (updateAvailable) {
        autoUpdater.downloadUpdate();
    }
});

ipcMain.on('install-update', () => {
    autoUpdater.quitAndInstall(false, true);
});

app.whenReady().then(() => {
    createWindow();

    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) {
            createWindow();
        }
    });
});

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});
```

---

## 🔌 Part 3: Create preload.js

Create `HideoutAdsWebsite/game/preload.js`:

```javascript
const { contextBridge, ipcRenderer } = require('electron');

// Expose update API to renderer process
contextBridge.exposeInMainWorld('electronAPI', {
    onUpdateAvailable: (callback) => {
        ipcRenderer.on('update-available', (event, data) => callback(data));
    },
    onDownloadProgress: (callback) => {
        ipcRenderer.on('download-progress', (event, percent) => callback(percent));
    },
    onUpdateDownloaded: (callback) => {
        ipcRenderer.on('update-downloaded', (event, version) => callback(version));
    },
    downloadUpdate: () => {
        ipcRenderer.send('download-update');
    },
    installUpdate: () => {
        ipcRenderer.send('install-update');
    }
});
```

---

## 🎨 Part 4: Add Update UI to Game

Add this to your `index.html` or create a separate update component:

```html
<!-- Update Notification UI -->
<div id="update-notification" style="display: none; position: fixed; top: 20px; right: 20px; background: rgba(0, 198, 255, 0.95); color: white; padding: 20px; border-radius: 10px; z-index: 10000; box-shadow: 0 0 20px rgba(0, 198, 255, 0.5); max-width: 400px;">
    <h3 style="margin: 0 0 10px 0;">🎮 Update Available!</h3>
    <p id="update-version-text" style="margin: 0 0 15px 0;"></p>
    <div id="update-progress" style="display: none;">
        <div style="background: rgba(0, 0, 0, 0.3); height: 8px; border-radius: 4px; overflow: hidden; margin-bottom: 10px;">
            <div id="update-progress-bar" style="height: 100%; background: #00ff00; width: 0%; transition: width 0.3s;"></div>
        </div>
        <p id="update-progress-text" style="margin: 0; font-size: 0.9rem;">Downloading...</p>
    </div>
    <div id="update-buttons">
        <button id="download-update-btn" onclick="downloadUpdate()" style="background: #00ff00; color: #000; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; font-weight: bold; margin-right: 10px;">Download Update</button>
        <button onclick="dismissUpdate()" style="background: rgba(255, 255, 255, 0.2); color: #fff; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer;">Later</button>
    </div>
    <button id="install-update-btn" onclick="installUpdate()" style="display: none; background: #00ff00; color: #000; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; font-weight: bold; width: 100%;">Install & Restart</button>
</div>

<script>
// Auto-update handlers
if (window.electronAPI) {
    window.electronAPI.onUpdateAvailable((data) => {
        document.getElementById('update-notification').style.display = 'block';
        document.getElementById('update-version-text').textContent = `Version ${data.version} is available!`;
    });

    window.electronAPI.onDownloadProgress((percent) => {
        document.getElementById('update-progress').style.display = 'block';
        document.getElementById('update-buttons').style.display = 'none';
        document.getElementById('update-progress-bar').style.width = `${percent}%`;
        document.getElementById('update-progress-text').textContent = `Downloading: ${percent.toFixed(0)}%`;
    });

    window.electronAPI.onUpdateDownloaded((version) => {
        document.getElementById('update-progress').style.display = 'none';
        document.getElementById('install-update-btn').style.display = 'block';
        document.getElementById('update-version-text').textContent = `Version ${version} ready to install!`;
    });
}

function downloadUpdate() {
    if (window.electronAPI) {
        window.electronAPI.downloadUpdate();
    }
}

function installUpdate() {
    if (window.electronAPI) {
        window.electronAPI.installUpdate();
    }
}

function dismissUpdate() {
    document.getElementById('update-notification').style.display = 'none';
}
</script>
```

---

## 📝 Part 5: Create version.json

Create `HideoutAdsWebsite/game/version.json`:

```json
{
  "version": "5.0.0",
  "releaseDate": "2025-10-22",
  "downloadUrl": "https://hideoutads.online/downloads/SpaceShooterV5-Setup.exe",
  "releaseNotes": "Halloween event, difficulty system, improved UI"
}
```

---

## 🔨 Part 6: Update package.json

Add to your package.json:

```json
{
  "name": "space-shooter-v5",
  "version": "5.0.0",
  "description": "Space Shooter V5 - Halloween Edition",
  "main": "electron-main.cjs",
  "author": "Your Name",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "electron": "electron .",
    "electron:dev": "npm run build && electron .",
    "dist": "npm run build && electron-builder",
    "dist:win": "npm run build && electron-builder --win --x64",
    "publish": "npm run build && electron-builder --win --x64 --publish always"
  },
  "build": {
    "appId": "com.yourcompany.spaceshooter",
    "productName": "Space Shooter V5",
    "directories": {
      "output": "release"
    },
    "files": [
      "dist/**/*",
      "electron-main.cjs",
      "preload.js",
      "package.json"
    ],
    "win": {
      "target": ["nsis"],
      "publish": {
        "provider": "generic",
        "url": "https://hideoutads.online/updates/"
      }
    },
    "nsis": {
      "oneClick": false,
      "allowToChangeInstallationDirectory": true,
      "createDesktopShortcut": true,
      "createStartMenuShortcut": true
    },
    "publish": {
      "provider": "generic",
      "url": "https://hideoutads.online/updates/"
    }
  },
  "dependencies": {
    "@google/genai": "^1.25.0",
    "react": "^19.2.0",
    "react-dom": "^19.2.0"
  },
  "devDependencies": {
    "@types/node": "^22.18.12",
    "@vitejs/plugin-react": "^5.0.0",
    "electron": "^38.4.0",
    "electron-builder": "^26.0.12",
    "electron-updater": "^6.1.7",
    "typescript": "~5.8.2",
    "vite": "^6.2.0"
  }
}
```

---

## 📤 Part 7: Hosting Updates

### On Your Website:

1. **Create updates folder** on your website: `https://hideoutads.online/updates/`

2. **After building**, upload these files to the updates folder:
   - `latest.yml` (auto-generated by electron-builder)
   - `Space-Shooter-V5-Setup-5.0.0.exe` (your installer)
   - `Space-Shooter-V5-5.0.0-full.nupkg` (update package)

### Example latest.yml:

```yaml
version: 5.0.0
files:
  - url: Space-Shooter-V5-Setup-5.0.0.exe
    sha512: [hash]
    size: 85000000
path: Space-Shooter-V5-Setup-5.0.0.exe
sha512: [hash]
releaseDate: '2025-10-22T00:00:00.000Z'
```

---

## 🚀 Part 8: Building & Publishing

### Build with auto-update:

```bash
cd HideoutAdsWebsite/game
npm run dist:win
```

This creates in `release/` folder:
- Installer .exe
- Update packages (.nupkg files)
- latest.yml

### Upload to your website:

```bash
# Upload to hideoutads.online/updates/
# - latest.yml
# - *.exe
# - *.nupkg
```

---

## ✅ Implementation Checklist

- [ ] Install electron-updater
- [ ] Update electron-main.cjs with auto-update code
- [ ] Create preload.js
- [ ] Add update UI to game
- [ ] Update package.json with publish config
- [ ] Create version.json
- [ ] Build with electron-builder
- [ ] Create /updates/ folder on website
- [ ] Upload latest.yml and installers
- [ ] Test auto-update

---

## 🎮 User Experience

When users launch your game:
1. Game checks for updates (silent, 3 seconds after load)
2. If update found, shows notification in top-right
3. User clicks "Download Update"
4. Progress bar shows download status
5. When done, "Install & Restart" button appears
6. Game restarts with new version!

---

## 🔄 Updating Process

### For each new version:

1. Update version in package.json
2. Make your changes to the game
3. Run `npm run dist:win`
4. Upload new files to website/updates/
5. Users automatically get notified!

---

## 📋 Quick Commands

```bash
# Build with auto-update
npm run dist:win

# Publish (if configured with GitHub releases)
npm run publish
```

Your game now has professional auto-update functionality! 🎮✨
