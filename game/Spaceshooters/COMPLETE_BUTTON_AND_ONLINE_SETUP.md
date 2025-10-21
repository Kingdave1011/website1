# COMPLETE SETUP GUIDE - Make All Buttons and Online Work

## 🎯 GOAL
Make every button in your game work properly and get online multiplayer functioning with your AWS servers.

---

## ⚠️ CRITICAL: You MUST do this in Godot Editor
**You cannot make buttons work just by copying files!** You must open Godot and connect the buttons manually.

---

## 📋 STEP 1: Open Your Game in Godot

1. Open Godot Engine 4.x
2. Click "Import" and navigate to:
   ```
   C:\Users\kinlo\OneDrive\Desktop\emojis (3)\newgame\bulletcore2.5\SpaceShooterWeb\Spaceshooters
   ```
3. Select `project.godot` and click "Import & Edit"
4. Wait for Godot to load the project

---

## 🔘 STEP 2: Connect Main Menu Buttons

### A. Open MainMenu Scene
1. In Godot, double-click `MainMenu.tscn` in the FileSystem panel
2. You should see the scene with buttons

### B. Connect Each Button (DO THIS FOR EACH):

**Play Button:**
1. Click on "PlayButton" in the Scene tree (left side)
2. Go to Node tab (right side)
3. Click on "pressed()" signal
4. Click "Connect"
5. Select "MainMenu" node
6. In the "Receiver Method" field, type: `_on_play_button_pressed`
7. Click "Connect"

**Online Button:**
1. Click on "OnlineButton"
2. Go to Node tab
3. Click on "pressed()" signal
4. Click "Connect"
5. Select "MainMenu" node
6. Type: `_on_online_button_pressed`
7. Click "Connect"

**Settings Button:**
1. Click on "SettingsButton"
2. Go to Node tab
3. Click on "pressed()" signal
4. Click "Connect"
5. Select "MainMenu" node
6. Type: `_on_settings_button_pressed`
7. Click "Connect"

**Maps Button:**
1. Click on "MapsButton"
2. Go to Node tab
3. Click on "pressed()" signal
4. Click "Connect"
5. Select "MainMenu" node
6. Type: `_on_maps_button_pressed`
7. Click "Connect"

**Quit Button:**
1. Click on "QuitButton"
2. Go to Node tab
3. Click on "pressed()" signal
4. Click "Connect"
5. Select "MainMenu" node
6. Type: `_on_quit_button_pressed`
7. Click "Connect"

### C. Save the Scene
Press Ctrl+S or File > Save Scene

---

## 🌐 STEP 3: Setup Network Manager for Online Play

### A. Open NetworkManager.gd Script
1. In FileSystem, double-click `NetworkManager.gd`
2. Find this line near the top:
   ```gdscript
   const DEFAULT_SERVER_IP = "127.0.0.1"  # Change this to your AWS server IP
   ```
3. Change it to your AWS server IP:
   ```gdscript
   const DEFAULT_SERVER_IP = "18.116.64.173"  # Your Windows AWS server
   ```
4. Press Ctrl+S to save

### B. Configure Port (if needed)
- Default port is 9999
- Make sure this port is open in your AWS Security Group
- To change port, find:
  ```gdscript
  const DEFAULT_PORT = 9999
  ```

---

## 🎮 STEP 4: Create/Setup Lobby Scene

### Check if Lobby.tscn Exists
1. Look in FileSystem for `Lobby.tscn`
2. If it exists, double-click to open it

### If Lobby Scene Doesn't Exist, Create It:
1. Click Scene menu > New Scene
2. Choose "User Interface" as root node
3. Name it "Lobby"
4. Add these nodes:
   - VBoxContainer (child of Lobby)
     - Label (name it "TitleLabel", text: "ONLINE MULTIPLAYER")
     - LineEdit (name it "PlayerNameInput", placeholder: "Enter Your Name")
     - LineEdit (name it "ServerIPInput", placeholder: "Server IP")
     - Button (name it "HostButton", text: "HOST GAME")
     - Button (name it "JoinButton", text: "JOIN GAME")
     - Button (name it "BackButton", text: "BACK TO MENU")
     - RichTextLabel (name it "ChatDisplay")
     - HBoxContainer
       - LineEdit (name it "ChatInput", placeholder: "Type message...")
       - Button (name it "SendButton", text: "SEND")

5. Select Lobby root node
6. In Inspector, click the script icon, attach `Lobby.gd`
7. Connect buttons:
   - HostButton.pressed → `_on_host_button_pressed`
   - JoinButton.pressed → `_on_join_button_pressed`
   - BackButton.pressed → `_on_back_button_pressed`
   - SendButton.pressed → `_on_send_button_pressed`
   - ChatInput.text_submitted → `_on_chat_input_text_submitted`

8. Save as `Lobby.tscn`

---

## 🎮 STEP 5: Setup Game Scene (Main.tscn)

### A. Open Main.tscn
1. Double-click `Main.tscn` in FileSystem

### B. Add Player Node (if missing)
1. Look for "Player" node in scene tree
2. If missing:
   - Right-click root node
   - Add Child Node
   - Search for "CharacterBody2D"
   - Name it "Player"
   - Attach `Player.gd` script
   - Add a Sprite2D child (for player visual)
   - Add CollisionShape2D child (for collision)

### C. Position Player
1. Select Player node
2. In Inspector, set Position to: `(576, 500)` (center bottom of screen)

### D. Save Scene
Press Ctrl+S

---

## 🖥️ STEP 6: Setup AWS Server

### On Your AWS Windows Server (18.116.64.173):

1. **Connect to AWS Server:**
   - Use Remote Desktop Connection
   - IP: 18.116.64.173

2. **Install Godot Headless Server:**
   - Download Godot 4.x Headless from godotengine.org
   - Extract to: `C:\GodotServer\`

3. **Copy Game Files:**
   - Copy the entire `SpaceShooterWeb\Spaceshooters` folder to server
   - Place at: `C:\GodotServer\Game\`

4. **Export Your Game:**
   - In Godot on your PC, go to Project > Export
   - Add "Windows Desktop" preset
   - Export as: `SpaceGame.exe`
   - Copy to server

5. **Run Dedicated Server:**
   Open Command Prompt and run:
   ```cmd
   cd C:\GodotServer
   Godot_v4.x_win64_headless.exe --path "C:\GodotServer\Game" --headless --server
   ```

6. **Open Firewall Port:**
   ```cmd
   netsh advfirewall firewall add rule name="Godot Game Server" dir=in action=allow protocol=TCP localport=9999
   ```

### AWS Security Group:
1. Go to AWS Console > EC2 > Security Groups
2. Find your server's security group
3. Add Inbound Rule:
   - Type: Custom TCP
   - Port: 9999
   - Source: 0.0.0.0/0 (or your IP for testing)

---

## ✅ STEP 7: Test Everything

### Test Main Menu Buttons:
1. Press F5 in Godot to run the game
2. Test each button:
   - ✅ **Play** - Should load Main.tscn and start game
   - ✅ **Online** - Should load Lobby.tscn
   - ✅ **Settings** - Will print message (not fully implemented yet)
   - ✅ **Maps** - Will print map list
   - ✅ **Quit** - Should close game

### Test Online Multiplayer:
1. **Start Server:**
   - Run headless server on AWS (Step 6)

2. **Test Local First:**
   - Click "Online" button
   - Enter player name
   - Click "Host Game"
   - Open another Godot instance
   - Click "Join Game" with IP: 127.0.0.1
   - Both should connect

3. **Test AWS Server:**
   - Click "Online" button
   - Enter server IP: 18.116.64.173
   - Enter player name
   - Click "Join Game"
   - Should connect to AWS server

---

## 🐛 TROUBLESHOOTING

### Buttons Don't Work:
- Make sure you CONNECTED them in Godot (Step 2)
- Check Output tab for errors
- Verify function names match exactly

### "Lobby scene not found":
- Create Lobby.tscn (Step 4)
- Make sure it's saved in root directory
- Check file exists: `res://Lobby.tscn`

### Can't Connect to Server:
- Verify server is running
- Check AWS Security Group has port 9999 open
- Test with localhost first (127.0.0.1)
- Check NetworkManager has correct IP

### Player Not Visible:
- Open Main.tscn
- Add Player node (Step 5B)
- Make sure Player has Sprite2D child with texture

### No Enemies Spawning:
- Check GameManager script is attached to Main scene
- Verify Enemy.tscn exists
- Check spawn timer is running

---

## 📝 WHAT YOU NEED TO CREATE IN GODOT EDITOR

**You CANNOT create these by copying files - must use Godot:**

1. ✅ MainMenu.tscn - Connect 5 buttons
2. ✅ Lobby.tscn - Create scene and connect buttons
3. ✅ Settings.tscn - Create settings menu (optional)
4. ✅ ServerBrowser.tscn - Create server list UI (optional)
5. ✅ Main.tscn - Add Player node if missing

---

## 🎯 QUICK TEST CHECKLIST

After setup, verify:
- [ ] Game launches (F5)
- [ ] Main menu shows all buttons
- [ ] Play button starts game
- [ ] Online button opens lobby
- [ ] Can host local game
- [ ] Can join local game (two instances)
- [ ] AWS server runs headless
- [ ] Can connect to AWS server
- [ ] Multiple players can join
- [ ] Players see each other in game

---

## 💡 NEXT STEPS AFTER BASIC SETUP WORKS

1. **Create Settings Menu:**
   - Volume controls
   - Graphics settings
   - Key bindings

2. **Create Server Browser:**
   - Show available servers
   - Player count
   - Ping display

3. **Add Chat System:**
   - In-game chat
   - Team chat
   - Lobby chat

4. **Polish Multiplayer:**
   - Player names display
   - Score synchronization
   - Smooth interpolation

---

## 📞 NEED HELP?

If buttons still don't work:
1. Check Godot Output tab for errors
2. Verify all signals are connected (green icon next to button in Scene tree)
3. Make sure script names match exactly (`MainMenu.gd`, `Lobby.gd`)
4. Test one button at a time

Remember: **The most important step is STEP 2 - connecting buttons in Godot editor!**
Files alone won't make buttons work - you must connect the signals manually.
