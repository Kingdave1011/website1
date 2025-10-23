# 🎮 How to Build Space Shooter .EXE Standalone

## Complete Step-by-Step Guide to Creating Windows Executable

### ✅ What You've Already Got
- `HideoutAdsWebsite/game/electron-main.cjs` - Electron configuration file
- `HideoutAdsWebsite/game/package.json` - Build scripts
- Working game in `HideoutAdsWebsite/game/`

---

## 📋 Prerequisites

### 1. Install Node.js (if not already installed)
- Download from: https://nodejs.org/
- Use LTS version (20.x or higher)
- Verify installation:
```bash
node --version
npm --version
```

---

## 🚀 Build Instructions

### Method 1: Using NPM (Recommended)

**Step 1: Navigate to Game Directory**
```bash
cd HideoutAdsWebsite/game
```

**Step 2: Install Dependencies (First Time Only)**
```bash
npm install
```

**Step 3: Build the .EXE**
```bash
npm run build:electron
```

This will:
- Bundle your game using Vite
- Package it with Electron
- Create a Windows executable in `dist-electron/`

**Step 4: Find Your .EXE**
- Location: `HideoutAdsWebsite/game/dist-electron/win-unpacked/`
- Executable name: `Space Shooter.exe`

---

### Method 2: Manual Build Process

If the automated build fails, try this:

**Step 1: Build Web Version**
```bash
cd HideoutAdsWebsite/game
npm run build
```

**Step 2: Build Electron Package**
```bash
npm run electron:build
```

**Step 3: Package for Windows**
```bash
npx electron-builder --win --x64
```

---

## 📦 Distribution Package

### Create Installer (Optional)

**For Professional Distribution:**
```bash
npm run dist
```

This creates:
- `Space Shooter Setup.exe` - Installer
- `Space Shooter-win.zip` - Portable version

Output location: `HideoutAdsWebsite/game/dist-electron/`

---

## 🔧 Troubleshooting

### Issue: "Module not found" errors
**Solution:**
```bash
npm install
npm install --save-dev electron electron-builder
```

### Issue: Build fails with TypeScript errors
**Solution:**
```bash
npm run build -- --no-type-check
```

### Issue: .exe won't run or shows blank screen
**Solution:**
1. Check if all assets are included
2. Verify `electron-main.cjs` has correct paths
3. Try running: `npm run electron:dev` to test

### Issue: Antivirus flags the .exe
**Solution:**
- This is normal for unsigned executables
- Add exception in Windows Defender
- For distribution, consider code signing (costs money)

---

## 📝 Configuration Files

### package.json Build Section
```json
{
  "build": {
    "appId": "com.hideoutads.spaceshooter",
    "productName": "Space Shooter",
    "win": {
      "target": "nsis",
      "icon": "assets/icon.ico"
    },
    "files": [
      "dist/**/*",
      "electron-main.cjs"
    ]
  }
}
```

---

## 🎯 Testing the .EXE

**Before Distribution:**
1. Run the .exe on your machine
2. Test all features:
   - Login system
   - Game mechanics
   - Special ability (Q key)
   - Save/Load functionality
   - Settings
3. Test on a clean Windows machine (no dev tools)

---

## 📤 Sharing Your Game

### Option 1: Direct .EXE
- Zip the `win-unpacked` folder
- Share via file hosting (Google Drive, Dropbox)
- Users extract and run `Space Shooter.exe`

### Option 2: Installer
- Share `Space Shooter Setup.exe`
- Users run installer (more professional)
- Adds to Start Menu automatically

### Option 3: Upload to Itch.io
```bash
# Build first
npm run dist

# Upload to https://itch.io
# 1. Create project
# 2. Upload Space Shooter-win.zip
# 3. Mark as Windows executable
```

---

## 🔐 Code Signing (Advanced)

For production distribution without antivirus warnings:

1. Purchase code signing certificate ($100-500/year)
2. Add to electron-builder config:
```json
"win": {
  "certificateFile": "path/to/cert.pfx",
  "certificatePassword": "your-password"
}
```

---

## 📊 Build Output Files

After successful build:
```
dist-electron/
├── win-unpacked/          # Portable version
│   ├── Space Shooter.exe  # Main executable
│   ├── resources/         # Game assets
│   └── ...
├── Space Shooter Setup.exe  # Installer
└── Space Shooter-win.zip    # Compressed
```

---

## ✨ Features Included in .EXE

✅ Offline play capability
✅ Local save/load system
✅ Full game features
✅ Special ability system
✅ Supabase cloud sync
✅ No browser required
✅ Desktop notifications
✅ Auto-updater (if configured)

---

## 🎮 Quick Commands Reference

```bash
# Install dependencies
npm install

# Build .exe
npm run build:electron

# Test before building
npm run electron:dev

# Create installer
npm run dist

# Clean build
npm run clean
npm run build:electron
```

---

## 💡 Pro Tips

1. **Icon**: Replace default icon with custom one (256x256 PNG → ICO)
2. **Version**: Update version in `package.json` before each build
3. **Size**: Optimize images before building to reduce .exe size
4. **Updates**: Implement electron-updater for auto-updates
5. **Testing**: Always test on multiple Windows versions (10, 11)

---

## 🆘 Need Help?

If build fails:
1. Delete `node_modules` and `dist` folders
2. Run `npm install` again
3. Try `npm run build` first
4. Then `npm run electron:build`
5. Check console for specific errors

---

## 🎉 Success!

Your game is now a standalone Windows .EXE!

Share it with players at:
- `HideoutAdsWebsite/game/dist-electron/win-unpacked/Space Shooter.exe`

Players can now enjoy your game without needing a browser! 🚀
