# Fix Missing Background Image Error

## 🔧 Error Shown:
```
res://assets/backgrounds/space_bg.png (NOT FOUND - red text)
```

---

## ✅ Quick Fix - 3 Options:

### Option 1: Use a Kenney Background (Easiest)

Your Kenney assets include background images!

**In Godot:**
1. Open `AsteroidField.tscn` (double-click in FileSystem)
2. Find the node that has the missing texture
3. Click on it in Scene tree
4. In Inspector → Texture property
5. Click the texture box
6. Select "Quick Load"
7. Navigate to: `kenney_space-shooter-redux/Backgrounds/` 
8. Pick any background (e.g., `purple.png`, `black.png`, `darkPurple.png`)
9. Click "Open"

✅ **Fixed!** Your map now has a proper space background!

---

### Option 2: Create a Simple Background

**Quick solid color background:**

1. In Godot, **open AsteroidField.tscn**
2. **Add a ColorRect node** as first child (so it's behind everything)
3. **Set Anchors** to Full Rect (fills whole screen)
4. **Set Color** to dark blue or black (space color)
5. **Save**

✅ **Done!** No missing file error.

---

### Option 3: Download Free Space Backgrounds

**Where to get backgrounds:**
1. **Kenney.nl** - https://kenney.nl/assets (search "space")
2. **OpenGameArt** - https://opengameart.org/ (search "space background")
3. **Itch.io** - https://itch.io/game-assets/free (search "space")

**After downloading:**
1. Put image in `d:\GalacticCombat\Assets\Backgrounds\`
2. In Godot → FileSystem → Navigate to that folder
3. Assign to your map's background sprite

---

## 🎨 Kenney Backgrounds Available:

Your asset packs include these ready-to-use backgrounds:

### From kenney_space-shooter-redux:
- `Backgrounds/black.png` - Pure black space
- `Backgrounds/blue.png` - Blue nebula
- `Backgrounds/darkPurple.png` - Dark purple space
- `Backgrounds/purple.png` - Purple nebula

### Path in Godot:
```
res://kenney_space-shooter-redux/Backgrounds/
```

---

## 🔧 Step-by-Step Fix in Godot:

### 1. Open the Map Scene
- FileSystem → `maps/AsteroidField.tscn`
- Double-click to open

### 2. Find the Background Node
Look in Scene tree for a node with texture/sprite that shows the error

### 3. Select That Node
Click on it (it might be called Background, Sprite2D, or TextureRect)

### 4. Fix the Texture Path
- Inspector (right side) → Texture property
- Click the texture → "Quick Load"
- Choose a Kenney background
- Click "Open"

### 5. Save the Scene
- Press **Ctrl+S** or File → Save

### 6. Test
- Press **F6** to run the map
- Background should now appear!

---

## 📋 Alternative: Change the Path in Scene File

If you know which background you want to use:

1. Open `d:\GalacticCombat\maps\AsteroidField.tscn` in text editor
2. Find line with: `res://assets/backgrounds/space_bg.png`
3. Replace with: `res://kenney_space-shooter-redux/Backgrounds/purple.png`
4. Save file
5. Reopen in Godot

✅ **Error gone!**

---

## ⚠️ If No Backgrounds Folder in Kenney Assets:

Create a simple colored background in Godot:

1. **Scene → New Scene → 2D Scene**
2. **Add ColorRect node**
3. **Set size to 1920x1080** (or your screen size)
4. **Set color to** RGB(10, 10, 30) - dark space blue
5. **Add some stars:**
   - Add multiple small Sprite2D nodes
   - Use white circle textures
   - Scatter around randomly
6. **Save as** `Assets/Backgrounds/space_bg.tscn`
7. **Instance this in your map**

---

## ✅ Success Checklist:

- [ ] Background texture assigned
- [ ] No red "NOT FOUND" errors in Orphan Resource Explorer
- [ ] Map opens without errors
- [ ] Background visible when running with F6
- [ ] Game looks good!

---

**Fastest fix: Use a Kenney background from `kenney_space-shooter-redux/Backgrounds/` - they're already there!** 🚀
