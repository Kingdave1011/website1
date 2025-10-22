# Build Windows Standalone Game Guide

Complete guide to package your React/TypeScript Space Shooter game as a Windows standalone executable.

## 🎵 Part 1: Add Halloween Sound Effects

First, let's add the Halloween audio assets to your game.

### Add to SOUND_ASSETS in index.tsx

```typescript
const HALLOWEEN_SOUNDS = {
    // Witch cackle - eerie laugh
    witchLaugh: 'data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAAAAA=',
    
    // Ghost moan - spooky whisper
    ghostMoan: 'data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAAAAA=',
    
    // Pumpkin smash - satisfying crunch
    pumpkinSmash: 'data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAAAAA=',
    
    // Eerie ambience - background atmosphere
    eerieAmbience: 'data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAAAAA=',
    
    // Lantern break - glass shatter
    lanternBreak: 'data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAAAAA=',
    
    // Witch spell cast
    spellCast: 'data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAAAAA=',
    
    // Candy collect - sweet sound
    candyCollect: 'data:audio/wav;base64,UklGRiQAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQAAAAA='
};

// Merge with existing SOUND_ASSETS
const SOUND_ASSETS = {
    laser: 'data:audio/wav;base64,...',
    explosion: 'data:audio/wav;base64,...',
    // ... existing sounds
    ...HALLOWEEN_SOUNDS
};
```

### Use Halloween Sounds

```typescript
// When pumpkin drone explodes
function onPumpkinDroneDestroyed() {
    playSound('pumpkinSmash');
    gameState.stats.pumpkinDronesDestroyed++;
}

// When ghost ship is destroyed
function onGhostShipDestroyed() {
    playSound('ghostMoan');
    gameState.stats.ghostShipsDestroyed++;
}

// When witch boss attacks
function onWitchBossAttack() {
    playSound('spellCast');
    playSound('witchLaugh');
}

// When collecting candy power-up
function onCandyCollected() {
    playSound('candyCollect');
}

// Halloween ambient background (if on Halloween map)
function startHalloweenAmbience() {
    if (isHalloweenEventActive()) {
        playMusic('eerieAmbience');
    }
}
```

---

## 🖥️ Part 2: Build Windows Standalone with Electron

### Step 1: Install Dependencies

Navigate to your game directory and install Electron:

```bash
cd HideoutAdsWebsite/game
npm install --save-dev electron electron-builder
npm install --save-dev @types/node
```

### Step 2: Create Electron Main Process

Create `electron-main.cjs`:

```javascript
const { app, BrowserWindow, Menu } = require('electron');
const path = require('path');

let mainWindow;

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 1280,
        height: 720,
        minWidth: 800,
        minHeight: 600,
        title: 'Space Shooter V5 - Halloween Edition',
        icon: path.join(__dirname, 'dist/favicon.ico'),
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
            enableRemoteModule: false,
            devTools: false // Disable in production
        },
        backgroundColor: '#000000',
        autoHideMenuBar: true,
        fullscreenable: true
    });

    // Load the game
    if (app.isPackaged) {
        mainWindow.loadFile(path.join(__dirname, 'dist/index.html'));
    } else {
        mainWindow.loadFile('dist/index.html');
    }

    // Remove menu in production
    if (app.isPackaged) {
        Menu.setApplicationMenu(null);
    }

    // Handle window closed
    mainWindow.on('closed', () => {
        mainWindow = null;
    });

    // Maximize on start (optional)
    mainWindow.maximize();
}

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

### Step 3: Update package.json

Add these fields to your `package.json`:

```json
{
  "name": "space-shooter-v5",
  "version": "5.0.0",
  "description": "Space Shooter V5 - Halloween Edition",
  "main": "electron-main.cjs",
  "author": "Your Name",
  "license": "MIT",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "electron": "electron .",
    "electron:dev": "npm run build && electron .",
    "pack": "npm run build && electron-builder --dir",
    "dist": "npm run build && electron-builder",
    "dist:win": "npm run build && electron-builder --win --x64"
  },
  "build": {
    "appId": "com.yourcompany.spaceshooter",
    "productName": "Space Shooter V5",
    "directories": {
      "buildResources": "build",
      "output": "release"
    },
    "files": [
      "dist/**/*",
      "electron-main.cjs",
      "package.json"
    ],
    "win": {
      "target": ["nsis", "portable"],
      "icon": "build/icon.ico",
      "artifactName": "${productName}-${version}-${os}-${arch}.${ext}"
    },
    "nsis": {
      "oneClick": false,
      "allowToChangeInstallationDirectory": true,
      "createDesktopShortcut": true,
      "createStartMenuShortcut": true,
      "shortcutName": "Space Shooter V5"
    },
    "portable": {
      "artifactName": "${productName}-${version}-Portable.${ext}"
    }
  }
}
```

### Step 4: Create Icon

Create a `build` folder and add your icon:
- `build/icon.ico` - Windows icon (256x256 recommended)
- `build/icon.png` - PNG version for fallback

### Step 5: Build the Game

```bash
# Build for Windows
npm run dist:win
```

This will create:
- `release/Space Shooter V5-5.0.0-win-x64.exe` (installer)
- `release/Space Shooter V5-5.0.0-Portable.exe` (portable version)

---

## 📦 Part 3: Alternative - Standalone HTML Package

If you prefer a simpler approach without Electron:

### Create Self-Contained HTML Build

Create `build-standalone.js`:

```javascript
const fs = require('fs');
const path = require('path');

// Read the built files
const html = fs.readFileSync('dist/index.html', 'utf-8');
const css = fs.readFileSync('dist/assets/index.css', 'utf-8');
const js = fs.readFileSync('dist/assets/index.js', 'utf-8');

// Inline everything into a single HTML file
const standalone = html
    .replace(/<link[^>]*href="[^"]*\.css"[^>]*>/g, `<style>${css}</style>`)
    .replace(/<script[^>]*src="[^"]*\.js"[^>]*><\/script>/g, `<script>${js}</script>`);

// Save standalone version
fs.writeFileSync('dist/standalone.html', standalone);
console.log('✅ Standalone HTML created at dist/standalone.html');
```

Then run:
```bash
npm run build
node build-standalone.js
```

---

## 🎃 Part 4: Halloween Build Configuration

### Create Halloween-Specific Build

Create `vite.config.halloween.ts`:

```typescript
import { defineConfig } from 'vite';

export default defineConfig({
    build: {
        outDir: 'dist-halloween',
        rollupOptions: {
            output: {
                manualChunks: undefined
            }
        }
    },
    define: {
        'HALLOWEEN_EVENT_ACTIVE': true,
        'BUILD_VERSION': '"5.0.0-halloween"'
    }
});
```

Build Halloween version:
```bash
vite build --config vite.config.halloween.ts
```

---

## 🚀 Complete Build Script

Create `build-all-platforms.bat` for Windows:

```batch
@echo off
echo ========================================
echo Building Space Shooter V5 - Halloween Edition
echo ========================================

echo.
echo [1/4] Installing dependencies...
call npm install

echo.
echo [2/4] Building web version...
call npm run build

echo.
echo [3/4] Building Windows standalone...
call npm run dist:win

echo.
echo [4/4] Creating portable ZIP...
cd release
powershell -Command "Compress-Archive -Path 'Space Shooter V5-5.0.0-Portable.exe' -DestinationPath 'SpaceShooterV5-Windows-Portable.zip' -Force"
cd ..

echo.
echo ========================================
echo ✅ Build Complete!
echo ========================================
echo.
echo 📦 Installer: release\Space Shooter V5-5.0.0-win-x64.exe
echo 📦 Portable: release\SpaceShooterV5-Windows-Portable.zip
echo 🌐 Web: dist\index.html
echo.
pause
```

---

## 📋 Build Checklist

### Prerequisites
- [ ] Node.js installed (v18+)
- [ ] npm installed
- [ ] All dependencies installed

### Build Process
- [ ] Run `npm install` to install Electron
- [ ] Create `electron-main.cjs`
- [ ] Update `package.json` with build config
- [ ] Create icon files in `build/` folder
- [ ] Add Halloween sounds to game code
- [ ] Run `npm run build` to build React app
- [ ] Run `npm run dist:win` to create Windows exe
- [ ] Test the standalone executable
- [ ] Create ZIP for distribution

### Distribution
- [ ] Test installer on clean Windows machine
- [ ] Test portable version
- [ ] Upload to your website
- [ ] Share download link

---

## 🎮 Quick Build Commands

```bash
# Development test
npm run electron:dev

# Create Windows installer
npm run dist:win

# Create both installer and portable
npm run dist
```

---

## 📁 Expected Output

After building, you'll have:

```
release/
├── Space Shooter V5-5.0.0-win-x64.exe          (Installer - ~80MB)
├── Space Shooter V5-5.0.0-Portable.exe         (Portable - ~75MB)
└── SpaceShooterV5-Windows-Portable.zip         (Compressed portable)
```

---

## 🔧 Troubleshooting

### "electron-builder not found"
```bash
npm install -g electron-builder
```

### "Icon not found"
- Ensure `build/icon.ico` exists
- Use 256x256 PNG converted to ICO

### Game doesn't load
- Check `dist/` folder exists after `npm run build`
- Verify paths in electron-main.cjs

### Performance issues
- Disable dev tools in electron-main.cjs
- Enable hardware acceleration

---

## ✨ Final Steps

1. **Build the game**: `npm run dist:win`
2. **Test the executable**: Double-click the .exe file
3. **Distribute**: Share the installer or portable ZIP
4. **Upload to website**: Add download link on hideoutads.online

Your Windows standalone game with Halloween sounds is ready! 🎃👻
