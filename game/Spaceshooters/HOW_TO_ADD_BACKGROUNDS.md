# 🖼️ HOW TO ADD BACKGROUNDS - EXACT STEPS

## ADDING BACKGROUND TO MAIN MENU

### Step-by-Step in Godot:

1. **Open MainMenu.tscn**
   - In FileSystem panel (bottom left)
   - Double-click `MainMenu.tscn`

2. **Add Sprite2D Node**
   - Look at Scene tree (top left)
   - Right-click **MainMenu** (the root node)
   - Select "Add Child Node"
   - Search for: `Sprite2D`
   - Click "Create"

3. **Move Sprite2D to Top**
   - In Scene tree, **drag Sprite2D** above all other nodes
   - It should be the first child of MainMenu
   - This makes it render behind everything

4. **Add Background Image**
   - Click **Sprite2D** in Scene tree
   - Look at Inspector panel (right side)
   - Find "Texture" property
   - Click the **folder icon** next to it
   - Navigate to: `res://assets/gui/Main_Menu/BG.png`
   - Double-click `BG.png`

5. **Position the Background**
   - Still in Inspector, find "Transform" section
   - Set **Position:** X = 0, Y = 0
   - Check ☑ **Centered** (if available)
   - Or set **Offset:** X = 0, Y = 0

6. **Scale to Fit (if needed)**
   - In Inspector → Transform → Scale
   - Try Scale: X = 2, Y = 2 (adjust as needed)
   - Or use **Texture → Region** settings

7. **Save**
   - Press **Ctrl+S**

**Done! Your main menu now has a space background!**

---

## ADDING BACKGROUND TO A MAP

### Example: Add to AsteroidField.tscn

1. **Open Map Scene**
   - FileSystem panel → Double-click `maps/AsteroidField.tscn`

2. **Add Sprite2D**
   - Right-click root node → Add Child Node → Sprite2D
   - **Drag Sprite2D to TOP** of scene tree

3. **Add Background**
   - Click Sprite2D
   - Inspector → Texture → Click folder icon
   - Navigate to: `res://assets/backgrounds/level1/orig_big.png`
   - Double-click it

4. **Position**
   - Transform → Position: X = 0, Y = 0
   - ☑ Centered

5. **Scale to Fill**
   - Scale: X = 1, Y = 1 (or adjust)
   - Make sure it covers your game viewport

6. **Save** (Ctrl+S)

---

## QUICK REFERENCE: WHICH BACKGROUND FOR WHICH MAP

### Suggested Assignments:

**AsteroidField.tscn** → `level1/orig_big.png` (blue space with planet)
**NebulaCloud.tscn** → `level2/orig_big.png` (purple nebula)
**SpaceStation.tscn** → `level3/orig_big.png` (red space)
**DeepSpace.tscn** → `level4/orig_big.png` (dark space)
**IceField.tscn** → `level1/orig_big.png` (blue matches ice theme)
**AsteroidBelt.tscn** → `level3/orig_big.png` (red dramatic look)
**DebrisField.tscn** → `level4/orig_big.png` (dark ominous feel)

---

## TESTING YOUR BACKGROUNDS

1. **Press F5** to run the game
2. **Navigate to the scene** you added background to
3. **You should see** the space background
4. **If it's too small/big:**
   - Stop game
   - Select Sprite2D
   - Adjust Scale in Inspector
   - Test again

---

## TROUBLESHOOTING

### Background not showing:
- **Check:** Sprite2D is at TOP of scene tree
- **Check:** Texture is assigned in Inspector
- **Check:** File path is correct (res://assets/backgrounds/...)
- **Check:** Position is (0, 0)

### Background too small:
- **Increase Scale:** Try 2, 2 or higher
- **Or use Region:** Inspector → Texture → Region Enabled ☑

### Background not centered:
- **Enable Centered:** Inspector → Offset → Centered ☑
- **Or adjust Offset:** Manually center it

### Can't find assets folder:
- **Refresh:** In FileSystem panel, click refresh button or F5
- **Check path:** Make sure you're in SpaceShooterWeb/Spaceshooters project

---

## ADVANCED: PARALLAX BACKGROUNDS

For moving backgrounds (parallax effect):

1. **Add ParallaxBackground node** (instead of Sprite2D)
2. **Add ParallaxLayer as child**
3. **Add Sprite2D as child of ParallaxLayer**
4. **Assign texture** to Sprite2D
5. **Set Motion Scale:** In ParallaxLayer → Motion → Scale (e.g., 0.5, 0.5)
6. **Repeat** with multiple layers using 1.png, 2.png, 3.png

---

## ✅ SUMMARY

**To add any background:**
1. Open scene in Godot
2. Add Sprite2D node at top
3. Assign texture from assets/backgrounds/
4. Position at (0, 0)
5. Scale to fit
6. Save and test

**That's it! Follow these exact steps for any scene!** 🎮
