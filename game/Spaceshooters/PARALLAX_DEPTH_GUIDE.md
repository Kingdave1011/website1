# 🌌 PARALLAX DEPTH EFFECT GUIDE - CREATE 2.5D LOOK!

## WHAT IS PARALLAX SCROLLING?

Parallax creates a **3D depth illusion** by moving background layers at different speeds:
- **Far layers** move slowly (stars, distant planets)
- **Near layers** move faster (asteroids, debris)
- **Creates realistic depth** perception

---

## 🎯 SETUP PARALLAX BACKGROUND IN GODOT

### Step 1: Open Your Map Scene

Example: `maps/AsteroidField.tscn`

### Step 2: Add ParallaxBackground Node

1. **Right-click root node** → Add Child Node
2. **Search for:** `ParallaxBackground`
3. **Click "Create"**
4. **Drag ParallaxBackground to TOP** of scene tree (renders behind everything)

### Step 3: Add Layer 4 (Farthest - Stars)

1. **Right-click ParallaxBackground** → Add Child Node → `ParallaxLayer`
2. **Rename to:** `Layer4_Stars`
3. **Right-click Layer4_Stars** → Add Child Node → `Sprite2D`
4. **Select Sprite2D:**
   - Inspector → Texture → Click folder icon
   - Navigate to: `res://assets/backgrounds/level1/4.png`
   - Select it
5. **Set Motion Scale** (makes it move slowest):
   - Click **Layer4_Stars** (not Sprite2D)
   - Inspector → Motion → Scale: **X = 0.2, Y = 0.2**
6. **Position Sprite2D:**
   - Select Sprite2D
   - Transform → Position: X = 0, Y = 0
   - ☑ Centered

### Step 4: Add Layer 3 (Far - Planets)

1. **Right-click ParallaxBackground** → Add Child Node → `ParallaxLayer`
2. **Rename to:** `Layer3_Planets`
3. **Right-click Layer3_Planets** → Add Child Node → `Sprite2D`
4. **Assign texture:** `level1/3.png`
5. **Set Motion Scale:**
   - Click Layer3_Planets
   - Motion → Scale: **X = 0.4, Y = 0.4**
6. **Position:** X = 0, Y = 0, Centered ☑

### Step 5: Add Layer 2 (Mid - Nebula/Gas)

1. **Right-click ParallaxBackground** → Add Child Node → `ParallaxLayer`
2. **Rename to:** `Layer2_Nebula`
3. **Add Sprite2D as child**
4. **Assign texture:** `level1/2.png`
5. **Set Motion Scale:**
   - Layer2_Nebula → Motion → Scale: **X = 0.6, Y = 0.6**
6. **Position:** X = 0, Y = 0, Centered ☑

### Step 6: Add Layer 1 (Near - Asteroids/Debris)

1. **Right-click ParallaxBackground** → Add Child Node → `ParallaxLayer`
2. **Rename to:** `Layer1_Debris`
3. **Add Sprite2D as child**
4. **Assign texture:** `level1/1.png`
5. **Set Motion Scale:**
   - Layer1_Debris → Motion → Scale: **X = 0.8, Y = 0.8**
6. **Position:** X = 0, Y = 0, Centered ☑

### Step 7: Configure Scroll

1. **Click ParallaxBackground** (root)
2. **In Inspector → Scroll:**
   - Base Offset: X = 0, Y = 0
   - Base Scale: X = 1, Y = 1
   - Limit Begin: X = 0, Y = 0
   - Limit End: X = 0, Y = 0
   - Ignore Camera Zoom: ☐ (unchecked)

### Step 8: Save & Test

1. **Press Ctrl+S** to save
2. **Press F5** to run game
3. **Move your player** - background layers should move at different speeds!

---

## 🎨 YOUR SCENE TREE SHOULD LOOK LIKE:

```
AsteroidField (Node2D or whatever your root is)
└── ParallaxBackground
    ├── Layer4_Stars (ParallaxLayer) - Motion Scale: 0.2
    │   └── Sprite2D (texture: level1/4.png)
    ├── Layer3_Planets (ParallaxLayer) - Motion Scale: 0.4
    │   └── Sprite2D (texture: level1/3.png)
    ├── Layer2_Nebula (ParallaxLayer) - Motion Scale: 0.6
    │   └── Sprite2D (texture: level1/2.png)
    └── Layer1_Debris (ParallaxLayer) - Motion Scale: 0.8
        └── Sprite2D (texture: level1/1.png)
```

---

## 🎯 MOTION SCALE EXPLAINED:

**Lower number = Moves slower = Appears farther**
**Higher number = Moves faster = Appears closer**

- Layer 4 (0.2) = Farthest background (stars)
- Layer 3 (0.4) = Far (planets)
- Layer 2 (0.6) = Mid (nebula)
- Layer 1 (0.8) = Near (asteroids)
- Player (1.0) = Closest (default)

**This creates realistic depth!**

---

## 🗺️ BACKGROUNDS FOR EACH LEVEL:

### AsteroidField.tscn:
- Layer 4: `level1/4.png`
- Layer 3: `level1/3.png`
- Layer 2: `level1/2.png`
- Layer 1: `level1/1.png`

### NebulaCloud.tscn:
- Layer 3: `level2/3.png`
- Layer 2: `level2/2.png`
- Layer 1: `level2/1.png`

### SpaceStation.tscn:
- Layer 2: `level3/2.png`
- Layer 1: `level3/1.png`

### DeepSpace.tscn / IceField.tscn / AsteroidBelt.tscn / DebrisField.tscn:
- Layer 2: `level4/2.png`
- Layer 1: `level4/1.png`

**Mix and match as you like!**

---

## 📈 ADVANCED: AUTO-SCROLLING BACKGROUNDS

Add to ParallaxBackground script to make backgrounds scroll automatically:

```gdscript
extends ParallaxBackground

var scroll_speed = Vector2(20, 0)  # Scroll right at 20 pixels/sec

func _process(delta):
    scroll_offset += scroll_speed * delta
```

**This makes backgrounds scroll continuously even when player is still!**

---

## 🌟 ENHANCED DEPTH EFFECTS:

### 1. **Add Rotating Sprites**
- Place rotating asteroid/debris sprites at different Z-indices
- Larger sprites in front (z_index = 2)
- Smaller sprites behind (z_index = -2)

### 2. **Add Particle Effects**
- Space dust particles
- Move slower in back layers
- Move faster in front layers

### 3. **Color Tinting**
- Far layers: Slightly blue/darker tint
- Near layers: Full color/brighter
- Inspector → Modulate color

### 4. **Add Parallax to Clouds**
- Use Cloud_01.png through Cloud_04.png
- Different motion scales
- Creates atmospheric depth

---

## ✅ TESTING CHECKLIST:

After setup:
- [ ] Run game (F5)
- [ ] Move player left/right
- [ ] Background layers move at different speeds
- [ ] Far stars move slowly
- [ ] Near debris moves faster
- [ ] Creates depth illusion

---

## 🚨 TROUBLESHOOTING:

### Layers don't move:
- **Check:** ParallaxBackground is at top of scene
- **Check:** Camera2D exists in scene
- **Check:** Motion Scale is set on ParallaxLayer (not Sprite2D)

### All layers move same speed:
- **Check:** Each ParallaxLayer has different Motion Scale values
- **Check:** Values are set correctly (0.2, 0.4, 0.6, 0.8)

### Layers show gaps/seams:
- **Use orig_big.png** instead of numbered files
- **Or tile textures:** Inspector → Texture → Repeat Enabled

### Can't see layers:
- **Check:** Sprite2D has texture assigned
- **Check:** Sprite2D is child of ParallaxLayer
- **Check:** Position is (0, 0) and Centered ☑

---

## 🎮 RESULT:

**With parallax scrolling, your game will have:**
- ✅ Realistic 3D depth feeling
- ✅ Professional look
- ✅ Dynamic backgrounds that react to player movement
- ✅ Atmospheric immersion
- ✅ 2.5D effect without needing 3D models!

**Follow this guide for each map to create amazing depth effects!** 🌌🚀
