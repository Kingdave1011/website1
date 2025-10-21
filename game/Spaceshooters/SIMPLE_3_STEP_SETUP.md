# 🎯 SIMPLE 3-STEP SETUP - DO THIS NOW!

Follow these 3 simple steps to make everything work!

---

## 📍 STEP 1: CREATE MapSelection.tscn (5 minutes)

### In Godot:

1. **Click "Scene" menu (top left) → "New Scene"**
2. **Select "User Interface"**
3. **In Scene tree, rename "Control" to:** `MapSelection`
4. **Right-click MapSelection → "Attach Script"**
   - Browse to: **MapSelection.gd**
   - Click "Open"
5. **Right-click MapSelection → "Add Child Node"**
   - Search: `VBoxContainer`
   - Click "Create"
6. **Right-click VBoxContainer → "Add Child Node" → `Label`**
   - In Inspector (right) → Name: `TitleLabel`
   - In Inspector → Text: `SELECT MAP`
7. **Right-click VBoxContainer → "Add Child Node" → `ScrollContainer`**
8. **Right-click ScrollContainer → "Add Child Node" → `VBoxContainer`**
   - In Inspector → Name: `MapList`
9. **Right-click VBoxContainer (the first one) → "Add Child Node" → `Button`**
   - In Inspector → Name: `BackButton`
   - In Inspector → Text: `BACK TO MENU`
10. **Click BackButton → Node tab (right) → Double-click "pressed()"**
    - In popup, type: `_on_back_pressed`
    - Click "Connect"
11. **Press Ctrl+S → Save as:** `MapSelection.tscn`

**Done! The script will auto-create map buttons when you run it.**

---

## 🔌 STEP 2: CONNECT ALL BUTTONS (10 minutes)

### A. MainMenu Buttons:

1. **Open MainMenu.tscn** (double-click it in FileSystem panel)
2. **For each button, do this:**

**PlayButton:**
- Click "PlayButton" in Scene tree
- Node tab (right) → Double-click "pressed()"
- Type: `_on_play_button_pressed`
- Click "Connect"

**OnlineButton:**
- Click "OnlineButton"
- Node tab → Double-click "pressed()"
- Type: `_on_online_button_pressed`
- Click "Connect"

**MapsButton:**
- Click "MapsButton"
- Node tab → Double-click "pressed()"
- Type: `_on_maps_button_pressed`
- Click "Connect"

**SettingsButton:**
- Click "SettingsButton"
- Node tab → Double-click "pressed()"
- Type: `_on_settings_button_pressed`
- Click "Connect"

**QuitButton:**
- Click "QuitButton"
- Node tab → Double-click "pressed()"
- Type: `_on_quit_button_pressed`
- Click "Connect"

3. **Save:** Ctrl+S

### B. LoginScreen Buttons:

1. **Open LoginScreen.tscn**
2. **Connect these buttons:**

**GuestPlayButton:**
- Click it → Node tab → "pressed()" → `_on_guest_play_pressed` → Connect

**LoginButton:**
- Click it → Node tab → "pressed()" → `_on_login_pressed` → Connect

**SignupButton:**
- Click it → Node tab → "pressed()" → `_on_signup_pressed` → Connect

**ResetPasswordButton:**
- Click it → Node tab → "pressed()" → `_on_reset_password_pressed` → Connect

3. **Save:** Ctrl+S

---

## ⚙️ STEP 3: ADD AUTOLOADS (5 minutes)

### In Godot:

1. **Click "Project" menu (top) → "Project Settings"**
2. **Click "Autoload" tab (left side)**
3. **For each script below, do this:**
   - Click folder icon (🗁) next to Path field
   - Navigate to the .gd file
   - Double-click it
   - Click "Add"

### Add These 11 Scripts (in order):

1. **AccountManager.gd**
   - Path: `res://AccountManager.gd`
   - Name: `AccountManager`
   - Click "Add"

2. **AntiCheatManager.gd**
   - Path: `res://AntiCheatManager.gd`
   - Name: `AntiCheatManager`
   - Click "Add"

3. **ChatManager.gd**
   - Path: `res://ChatManager.gd`
   - Name: `ChatManager`
   - Click "Add"

4. **ThemeManager.gd**
   - Path: `res://ThemeManager.gd`
   - Name: `ThemeManager`
   - Click "Add"

5. **DisplayManager.gd**
   - Path: `res://DisplayManager.gd`
   - Name: `DisplayManager`
   - Click "Add"

6. **GameData.gd**
   - Path: `res://GameData.gd`
   - Name: `GameData`
   - Click "Add"

7. **ShipData.gd**
   - Path: `res://ShipData.gd`
   - Name: `ShipData`
   - Click "Add"

8. **SettingsManager.gd**
   - Path: `res://SettingsManager.gd`
   - Name: `SettingsManager`
   - Click "Add"

9. **NetworkManager.gd**
   - Path: `res://NetworkManager.gd`
   - Name: `NetworkManager`
   - Click "Add"

10. **MapSystem.gd**
    - Path: `res://MapSystem.gd`
    - Name: `MapSystem`
    - Click "Add"

11. **DifficultyManager.gd**
    - Path: `res://DifficultyManager.gd`
    - Name: `DifficultyManager`
    - Click "Add"

4. **Click "Close"**

**Done! All managers are now loaded automatically when game starts.**

---

## ✅ VERIFICATION

### After completing all 3 steps:

1. **Press F5** to run the game
2. **You should see:**
   - Main menu with all buttons
   - No error messages in console
   - "AccountManager" prints in console
   - "MapSystem" prints in console

3. **Test buttons:**
   - **PLAY** → Should start game immediately
   - **MAPS** → Should show map selection screen with 7 maps
   - **ONLINE** → Should show login screen with 4 tabs
   - **SETTINGS** → Should open settings (if Settings.tscn exists)
   - **QUIT** → Should close game

---

## 🚨 COMMON ISSUES

### "Invalid get index" error:
- **Problem:** Button not connected
- **Fix:** Go back to Step 2, reconnect the button

### "Scene not found" error:
- **Problem:** .tscn file missing or misnamed
- **Fix:** Make sure LoginScreen.tscn (not .tscn.tscn) and MapSelection.tscn exist

### "AutoLoad not found" error:
- **Problem:** Manager not in Autoloads
- **Fix:** Go back to Step 3, add the missing manager

### MapSelection shows no maps:
- **Problem:** MapSystem not in Autoloads
- **Fix:** Add MapSystem.gd to Autoloads (Step 3 #10)

---

## 🎮 THAT'S IT!

After these 3 steps, your game will have:
- ✅ Working Play button (solo game)
- ✅ Working Maps button (choose from 7 maps)
- ✅ Working Online button (login system)
- ✅ Working Settings button
- ✅ Working Quit button

**Total time: About 20 minutes! 🚀**
