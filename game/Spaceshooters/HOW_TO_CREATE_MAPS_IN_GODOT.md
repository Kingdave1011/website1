# 🗺️ How to Create Map Files in Godot - Complete Guide

## ⚠️ Important Note

The map files **DO NOT exist yet** - you need to create them in the Godot Editor. This guide will show you exactly how to do that step-by-step.

---

## 📍 Where Map Files Will Be

After you create them, the map files will be located at:
```
d:/GalacticCombat/
└── maps/
    ├── Nebula.tscn
    ├── AsteroidBelt.tscn
    ├── WreckedShipyard.tscn
    ├── OrbitalStation.tscn
    └── SolarHazard.tscn
```

---

## 🎯 Step-by-Step Instructions

### Step 1: Open Your Project in Godot

1. Open **Godot Engine 4.x**
2. Click **"Import"** or **"Open"**
3. Navigate to `d:/GalacticCombat`
4. Select the `project.godot` file
5. Click **"Open"**

---

### Step 2: Create the Maps Folder

1. In the Godot **FileSystem** panel (bottom-left), right-click in the empty space
2. Select **"Create Folder"**
3. Name it: `maps`
4. Press Enter

---

### Step 3: Create Map 1 - Nebula Storm

#### 3.1: Create New Scene
1. Click **"Scene"** menu → **"New Scene"** (or press Ctrl+N)
2. Click **"2D Scene"** button (this creates a Node2D root)
3. In the **Scene** panel (top-left), right-click the Node2D node
4. Select **"Rename"** and change it to: `Nebula`

#### 3.2: Add Background
1. Right-click `Nebula` node → **"Add Child Node"**
2. Search for: `ColorRect`
3. Click **"Create"**
4. In the **Inspector** panel (right side):
   - Set **Size** to: `X: 1920, Y: 1080`
   - Under **Color**, click the color box
   - Choose a purple/blue color (e.g., RGB: 50, 20, 80)

#### 3.3: Add Spawn Points
1. Right-click `Nebula` node → **"Add Child Node"**
2. Search for: `Node2D`
3. Click **"Create"**
4. Rename it to: `SpawnPoints`
5. Right-click `SpawnPoints` → **"Add Child Node"**
6. Search for: `Marker2D`
7. Create **4 Marker2D** nodes, naming them:
   - `SpawnPoint1`
   - `SpawnPoint2`
   - `SpawnPoint3`
   - `SpawnPoint4`
8. Move each spawn point to different positions on the map by:
   - Selecting the Marker2D
   - Dragging it in the viewport (center area)
   - Or setting Position in Inspector (e.g., 200,200 / 800,200 / 200,600 / 800,600)

#### 3.4: Save the Scene
1. Press **Ctrl+S** or **Scene** → **Save Scene**
2. Navigate to the `maps` folder you created
3. Name the file: `Nebula.tscn`
4. Click **"Save"**

---

### Step 4: Create Map 2 - Asteroid Belt

1. Create **New Scene** (Ctrl+N) → **2D Scene**
2. Rename root to: `AsteroidBelt`
3. Add **ColorRect** child:
   - Size: 1920x1080
   - Color: Black (RGB: 0, 0, 0)
4. Add **SpawnPoints** (Node2D) with 4 **Marker2D** children (positioned differently)
5. Save as: `maps/AsteroidBelt.tscn`

---

### Step 5: Create Map 3 - Wrecked Shipyard

1. Create **New Scene** (Ctrl+N) → **2D Scene**
2. Rename root to: `WreckedShipyard`
3. Add **ColorRect** child:
   - Size: 1920x1080
   - Color: Dark gray (RGB: 30, 30, 30)
4. Add **SpawnPoints** (Node2D) with 4 **Marker2D** children
5. Save as: `maps/WreckedShipyard.tscn`

---

### Step 6: Create Map 4 - Orbital Station

1. Create **New Scene** (Ctrl+N) → **2D Scene**
2. Rename root to: `OrbitalStation`
3. Add **ColorRect** child:
   - Size: 1920x1080
   - Color: Dark blue (RGB: 10, 10, 50)
4. Add **SpawnPoints** (Node2D) with 4 **Marker2D** children
5. Save as: `maps/OrbitalStation.tscn`

---

### Step 7: Create Map 5 - Solar Hazard

1. Create **New Scene** (Ctrl+N) → **2D Scene**
2. Rename root to: `SolarHazard`
3. Add **ColorRect** child:
   - Size: 1920x1080
   - Color: Orange/Red (RGB: 150, 50, 20)
4. Add **SpawnPoints** (Node2D) with 4 **Marker2D** children
5. Save as: `maps/SolarHazard.tscn`

---

## ✅ Verify Your Maps

After creating all maps, your FileSystem should look like this:

```
res://
├── maps/
│   ├── Nebula.tscn ✓
│   ├── AsteroidBelt.tscn ✓
│   ├── WreckedShipyard.tscn ✓
│   ├── OrbitalStation.tscn ✓
│   └── SolarHazard.tscn ✓
├── NetworkManager.gd
├── ChatManager.gd
├── MapSystem.gd
├── Lobby.gd
└── ... (other files)
```

---

## 🎨 Optional: Make Maps Look Better (Later)

After the basic maps work, you can enhance them by adding:

### For Nebula:
- Add **Sprite2D** nodes with cloud textures
- Add **ParallaxBackground** for depth
- Add **AnimatedSprite2D** for electrical effects

### For Asteroid Belt:
- Add **RigidBody2D** nodes as asteroids
- Add **Sprite2D** for asteroid textures
- Add **CollisionShape2D** for asteroid collisions

### For Wrecked Shipyard:
- Add **Sprite2D** for shipyard ruins
- Add **StaticBody2D** for debris obstacles

### For Orbital Station:
- Add **Sprite2D** for station structure
- Add **AnimatedSprite2D** for rotating parts

### For Solar Hazard:
- Add **Sprite2D** with glow shader for the sun
- Add **AnimatedSprite2D** for solar flares
- Add **CPUParticles2D** for heat waves

---

## 🔧 Troubleshooting

### "I can't find the FileSystem panel"
- Go to **View** → **FileSystem** to show it

### "I can't see the maps folder"
- Make sure you're in the `res://` (root) directory in FileSystem
- Try refreshing: Right-click in FileSystem → **"Reimport"**

### "Maps don't load in multiplayer"
- Make sure map file names match exactly:
  - `Nebula.tscn` (not nebula.tscn or Nebula Storm.tscn)
  - `AsteroidBelt.tscn` (not Asteroid_Belt.tscn)
  - etc.

### "Spawn points not working"
- Make sure each map has a `SpawnPoints` node with at least 4 `Marker2D` children
- Make sure Marker2D nodes are positioned in different locations

---

## 🚀 Quick Summary

1. Open Godot and load `d:/GalacticCombat` project
2. Create `maps` folder in FileSystem
3. Create 5 new 2D scenes
4. For each scene:
   - Add ColorRect for background
   - Add SpawnPoints (Node2D) with 4 Marker2D children
   - Save with correct name in `maps/` folder
5. Done! Maps are ready to use

---

## 📹 Visual Guide

### Scene Structure (All Maps):
```
MapName (Node2D)
├── ColorRect (background)
└── SpawnPoints (Node2D)
    ├── SpawnPoint1 (Marker2D)
    ├── SpawnPoint2 (Marker2D)
    ├── SpawnPoint3 (Marker2D)
    └── SpawnPoint4 (Marker2D)
```

### Spawn Point Positions Example:
- SpawnPoint1: (200, 200)
- SpawnPoint2: (1000, 200)
- SpawnPoint3: (200, 700)
- SpawnPoint4: (1000, 700)

This spreads players across the map!

---

## ✨ You're Ready!

Once you've created all 5 map files, your multiplayer system will be fully functional! The maps will automatically appear in the lobby's map selection grid.

**Next:** Follow the SETUP_GUIDE.md to complete the lobby scene and MainMenu integration.
