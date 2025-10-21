# VERCEL DEPLOYMENT & BUTTON SETUP GUIDE

## 🎯 GOAL
Deploy your Godot game to Vercel and make all buttons work, with optional multiplayer using your AWS server.

---

## ⚠️ CRITICAL UNDERSTANDING

1. **Vercel = Web Game Hosting** (HTML5 game)
2. **AWS Server = Multiplayer Server** (for online play)
3. **Buttons must be connected in Godot Editor first!**

---

## 📋 PART 1: Setup Buttons in Godot (REQUIRED)

### Step 1: Open Project in Godot
1. Open Godot Engine 4.x
2. Click "Import"
3. Navigate to: `C:\Users\kinlo\OneDrive\Desktop\emojis (3)\newgame\bulletcore2.5\SpaceShooterWeb\Spaceshooters`
4. Select `project.godot`
5. Click "Import & Edit"

### Step 2: Connect Main Menu Buttons
1. Double-click `MainMenu.tscn` in FileSystem panel
2. For EACH button, do this:

**Play Button:**
- Click "PlayButton" in Scene tree
- Go to Node tab (right side)
- Double-click "pressed()" signal
- Click "Connect"
- Method: `_on_play_button_pressed`

**Online Button:**
- Click "OnlineButton"
- Double-click "pressed()" signal
- Connect to: `_on_online_button_pressed`

**Settings Button:**
- Click "SettingsButton"  
- Connect to: `_on_settings_button_pressed`

**Maps Button:**
- Click "MapsButton"
- Connect to: `_on_maps_button_pressed`

**Quit Button:**
- Click "QuitButton"
- Connect to: `_on_quit_button_pressed`

3. Press Ctrl+S to save scene

### Step 3: Test Locally
- Press F5 in Godot
- Click each button to verify they work
- Play button should start the game
- Other buttons should respond

---

## 🌐 PART 2: Export for Vercel

### Step 1: Setup HTML5 Export
1. In Godot, go to **Project** > **Export**
2. Click **Add** > **Web**
3. In export settings:
   - **Export Path**: `Space Shooter V2.html`
   - Check **Export With Debug** (for testing)
4. Click **Export Project**
5. Choose location: `SpaceShooterWeb` folder
6. Files created:
   - Space Shooter V2.html
   - Space Shooter V2.js
   - Space Shooter V2.wasm
   - Space Shooter V2.pck
   - Other support files

### Step 2: Prepare for Vercel
Your SpaceShooterWeb folder should have:
```
SpaceShooterWeb/
├── index.html (or Space Shooter V2.html)
├── Space Shooter V2.js
├── Space Shooter V2.wasm
├── Space Shooter V2.pck
├── Space Shooter V2.audio.worklet.js
└── .vercel/ (Vercel config)
```

### Step 3: Create/Update index.html
If you don't have index.html, rename `Space Shooter V2.html` to `index.html`

Or create a simple index.html:
```html
<!DOCTYPE html>
<html>
<head>
    <title>Space Shooter Game</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body {
            margin: 0;
            padding: 0;
            background: #000;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        #canvas {
            outline: none;
            border: none;
        }
    </style>
</head>
<body>
    <canvas id="canvas"></canvas>
    <script src="Space Shooter V2.js"></script>
</body>
</html>
```

---

## 📤 PART 3: Deploy to Vercel

### Method 1: Vercel CLI (Recommended)
1. **Install Vercel CLI:**
   ```cmd
   npm install -g vercel
   ```

2. **Login to Vercel:**
   ```cmd
   vercel login
   ```

3. **Deploy:**
   ```cmd
   cd C:\Users\kinlo\OneDrive\Desktop\emojis (3)\newgame\bulletcore2.5\SpaceShooterWeb
   vercel
   ```

4. **Follow prompts:**
   - Link to existing project or create new
   - Choose settings (usually defaults are fine)

5. **Production deployment:**
   ```cmd
   vercel --prod
   ```

### Method 2: Vercel Dashboard
1. Go to https://vercel.com
2. Click **Add New** > **Project**
3. Import Git repository (if you have one) OR:
4. Use **Deploy from CLI** option
5. Drag and drop SpaceShooterWeb folder

### Method 3: GitHub Integration
1. Push SpaceShooterWeb to GitHub repo
2. Connect GitHub to Vercel
3. Vercel auto-deploys on push

---

## 🎮 PART 4: Configure for Web Play

### SharedArrayBuffer Requirements
For Godot 4.x web games, you need these headers:

Create `vercel.json` in SpaceShooterWeb folder:
```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "Cross-Origin-Embedder-Policy",
          "value": "require-corp"
        },
        {
          "key": "Cross-Origin-Opener-Policy",
          "value": "same-origin"
        }
      ]
    }
  ]
}
```

---

## 🌐 PART 5: Optional Multiplayer Setup

**Important:** Vercel cannot host game servers (WebSocket servers). For multiplayer, you need your AWS server.

### On AWS Server (18.116.64.173):

1. **Install Godot Headless:**
   ```cmd
   # Download Godot 4.x Headless from godotengine.org
   # Extract to C:\GodotServer\
   ```

2. **Export Server Version:**
   - In Godot: Project > Export
   - Add "Linux/X11" or "Windows Desktop" preset
   - Check "Export as dedicated server"
   - Export and upload to AWS

3. **Run Server:**
   ```cmd
   cd C:\GodotServer
   Godot_v4.x_win64_headless.exe --path ".\Game" --headless --server
   ```

4. **Open Port 9999:**
   ```cmd
   netsh advfirewall firewall add rule name="Game Server" dir=in action=allow protocol=TCP localport=9999
   ```

5. **AWS Security Group:**
   - Add inbound rule: TCP port 9999
   - Source: 0.0.0.0/0 (for testing)

### Update NetworkManager
In Godot, open `NetworkManager.gd`:
```gdscript
const DEFAULT_SERVER_IP = "18.116.64.173"  # Your AWS server IP
const DEFAULT_PORT = 9999
```

---

## ✅ PART 6: Testing

### Test Web Version (Vercel):
1. Go to your Vercel URL (e.g., `yourproject.vercel.app`)
2. Game should load in browser
3. Test buttons:
   - ✅ Play - starts game
   - ✅ Online - opens lobby (if Lobby.tscn exists)
   - ✅ Settings - responds
   - ✅ Quit - closes game

### Test Multiplayer (AWS):
1. Start AWS game server
2. In web game, click "Online"
3. Enter server IP: 18.116.64.173
4. Click "Join Game"
5. Should connect to server

---

## 🐛 Troubleshooting

### "SharedArrayBuffer is not defined"
- Add `vercel.json` with headers (Part 4)
- Redeploy to Vercel

### Buttons don't work
- You must connect them in Godot Editor (Part 1)
- Export again after connecting
- Redeploy to Vercel

### Game doesn't load
- Check browser console for errors
- Verify all files deployed (html, js, wasm, pck)
- Check Vercel build logs

### Can't connect to multiplayer
- Verify AWS server is running
- Check port 9999 is open
- Test with localhost first
- Update NetworkManager.gd with correct IP

### Game is slow/laggy
- Use "Export without debug" in Godot
- Enable compression in export settings
- Optimize assets (smaller images, compressed audio)

---

## 📊 Deployment Checklist

### Before Export:
- [x] All buttons connected in Godot
- [x] Tested locally (F5 in Godot)
- [x] NetworkManager configured (if using multiplayer)
- [x] All scenes saved

### Export Settings:
- [x] HTML5/Web export template installed
- [x] Export path set
- [x] Exported successfully

### Vercel Deployment:
- [x] vercel.json created with headers
- [x] All game files in folder
- [x] Deployed to Vercel
- [x] Game loads on Vercel URL
- [x] All buttons work in browser

### Multiplayer (Optional):
- [ ] AWS server running
- [ ] Port 9999 open
- [ ] NetworkManager IP configured
- [ ] Can connect from web game

---

## 🚀 Quick Commands

### Re-export After Changes:
```
1. Make changes in Godot
2. File > Save All
3. Project > Export > Export Project
4. Overwrite existing files
```

### Re-deploy to Vercel:
```cmd
cd SpaceShooterWeb
vercel --prod
```

### Check Vercel Logs:
```cmd
vercel logs [deployment-url]
```

---

## 💡 Pro Tips

1. **Always test locally first** (F5 in Godot)
2. **Connect buttons before exporting**
3. **Use "Export without debug" for production**
4. **Keep AWS server separate** (Vercel is for web game only)
5. **Enable CORS if needed** for multiplayer
6. **Optimize assets** for faster web loading
7. **Test in multiple browsers** (Chrome, Firefox, Edge)

---

## 🎯 What Each Platform Does

- **Godot**: Game development & export
- **Vercel**: Hosts the web game (HTML5)
- **AWS Server**: Multiplayer game server (WebSocket)
- **Your PC**: Development & testing

Web Game Flow:
```
Player → Vercel (loads game) → AWS Server (for multiplayer)
```

---

## 📝 Summary

1. ✅ Connect buttons in Godot Editor
2. ✅ Export as HTML5
3. ✅ Deploy to Vercel
4. ✅ Test in browser
5. ⭐ (Optional) Setup AWS for multiplayer

The game files are ready - you just need to:
1. Open in Godot
2. Connect the buttons
3. Export for web
4. Deploy to Vercel

That's it!
