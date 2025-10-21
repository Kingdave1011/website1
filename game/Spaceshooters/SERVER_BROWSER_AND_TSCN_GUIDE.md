# Server Browser System & .tscn Files Guide

## 🌐 SERVER BROWSER SYSTEM (Code Ready!)

ServerBrowserSystem.gd already exists with this functionality:
- Multiple server listings
- Server names, player counts, ping
- Server health status

### Example Servers Config:
```gdscript
var servers = [
    {
        "name": "US East - Galactic Warzone",
        "ip": "18.116.74.232",
        "port": 7777,
        "players": 12,
        "max_players": 32,
        "ping": 45,
        "region": "US-EAST"
    },
    {
        "name": "EU West - Nebula Battle",
        "ip": "YOUR_EU_SERVER_IP",
        "port": 7777,
        "players": 8,
        "max_players": 32,
        "ping": 120,
        "region": "EU-WEST"
    },
    {
        "name": "Asia - Space Station Alpha",
        "ip": "YOUR_ASIA_SERVER_IP",
        "port": 7777,
        "players": 5,
        "max_players": 16,
        "ping": 200,
        "region": "ASIA"
    }
]
```

## 📝 REQUIRED .TSCN FILES:

### 1. **ServerBrowser.tscn** (Main server list screen)
**What it needs:**
- ScrollContainer for server list
- VBoxContainer to hold server entries
- Refresh button
- Back button
- Search/filter options

**How to create:**
1. In Godot: **Scene** menu → **New Scene**
2. **Root node:** Control
3. **Save as:** ServerBrowser.tscn
4. Add children: ScrollContainer, VBoxContainer, Buttons
5. **Attach script:** ServerBrowserSystem.gd

### 2. **ServerEntry.tscn** (Individual server listing)
**What it needs:**
- Panel background
- Labels for: Name, Players, Ping, Region
- Join button
- Health indicator (ColorRect - green/yellow/red)

**How to create:**
1. **New Scene** → Root: Panel
2. **Add Labels:** ServerName, PlayerCount, Ping, Region
3. **Add Button:** JoinButton
4. **Add ColorRect:** HealthIndicator
5. **Save as:** ServerEntry.tscn

### 3. **MapSelection.tscn** (Choose map before playing)
**What it needs:**
- GridContainer for map buttons
- Labels showing map info
- Confirm/Back buttons

**How to create:**
1. **New Scene** → Root: Control
2. **Add:** GridContainer
3. **Add:** Confirm and Back buttons
4. **Save as:** MapSelection.tscn

### 4. **Settings.tscn** (Already exists at SpaceShooterV2/Settings.tscn!)
**Copy it to D:/GalacticCombat:**
- Has volume sliders
- Graphics options
- Control remapping

### 5. **Lobby.tscn** (Multiplayer waiting room)
**What it needs:**
- Player list
- Chat box
- Ready button
- Map selection
- Start button (host only)

**How to create:**
1. **New Scene** → Root: Control
2. Follow structure in Lobby.gd (already has code!)
3. **Save as:** Lobby.tscn
4. **Attach:** Lobby.gd script

## 🔧 QUICK SETUP - Copy Existing .tscn Files:

You already have working .tscn files in other projects!

### From SpaceShooterV2 folder:
```
Copy these to D:/GalacticCombat:
- Settings.tscn (settings menu)
- ShipSelection.tscn (can adapt for server browser)
```

### From Spacegame folder:
```
- MainMenu.tscn (reference for UI layout)
- Main.tscn (reference for game scene)
```

## 📋 .TSCN FILES - WHAT THEY ARE:

**.tscn files** are Godot scene files containing:
- Node hierarchy
- UI layout
- Positions, sizes, colors
- Connected signals
- Resource references

**You CANNOT create them with code - must use Godot editor!**

## 🎯 TO CREATE .TSCN FILES IN GODOT:

### Basic Steps:
1. **Scene** menu → **New Scene**
2. **Choose root node type** (Control, Panel, etc.)
3. **Add child nodes** (Buttons, Labels, etc.)
4. **Position** everything in viewport
5. **Save Scene** (Ctrl+S) → Name it
6. **Attach script** if needed

## 🌟 SIMPLER ALTERNATIVE:

Instead of creating all .tscn files yourself, use:

### Option 1: Duplicate Existing Scenes
1. **Copy** Settings.tscn from SpaceShooterV2
2. **Rename** it to ServerBrowser.tscn
3. **Edit** the layout for server list
4. **Attach** ServerBrowserSystem.gd

### Option 2: Use Godot Asset Library
1. **AssetLib** tab in Godot
2. **Search:** "Multiplayer" or "UI"
3. **Download** pre-made templates
4. **Adapt** to your game

## 📊 SERVER HEALTH INDICATORS:

Already coded in ServerBrowserSystem.gd!

**Health based on:**
- 🟢 Green: 0-50 ping, <75% full
- 🟡 Yellow: 50-150 ping, 75-90% full
- 🔴 Red: >150 ping, >90% full

## ⚠️ REALITY CHECK:

Creating professional UI scenes takes:
- **ServerBrowser.tscn:** 30-60 minutes
- **Settings.tscn:** 45-90 minutes
- **MapSelection.tscn:** 20-40 minutes
- **Lobby.tscn:** 60-120 minutes

**Total:** 3-5 hours of UI design work in Godot editor

## 💡 MY RECOMMENDATION:

1. **Get basic game working first** (add Player node)
2. **Copy Settings.tscn** from SpaceShooterV2
3. **Create simple ServerBrowser** later
4. **Focus on gameplay** before multiplayer UI

All the CODE for servers is ready! UI scenes are the remaining work!

## 📖 EXISTING .TSCN FILES IN YOUR PROJECT:

You already have these you can reference/copy:
- SpaceShooterV2/Settings.tscn
- SpaceShooterV2/ShipSelection.tscn
- SpaceShooterV2/MainMenu.tscn
- Spacegame/MainMenu.tscn
- Many map .tscn files

Study these in Godot to learn the structure!
