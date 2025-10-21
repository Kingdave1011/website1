# Quick Asset Integration Guide - 3 Simple Steps

## 🚀 Make Your Game Look Professional in 15 Minutes!

Follow these 3 simple steps to upgrade your game with Kenney assets.

---

## Step 1: Replace Player Ship Sprite (5 minutes)

### In Godot:
1. **Open Player.tscn** (FileSystem → double-click Player.tscn)
2. **In Scene tree** (top-left), look for ANY node with a sprite/texture
   - Could be named: Sprite2D, AnimatedSprite2D, Spaceship, MainBody, etc.
3. **Click on that node** (it highlights blue)
4. **Look at Inspector** (right side)
5. **Find "Texture" property**
6. **Click on the texture box** → Select "Quick Load"
7. **Navigate to:** `kenney_space-shooter-redux/PNG/playerShip1_blue.png`
8. **Click "Open"**
9. **Press Ctrl+S** to save

✅ **Done!** Your player now has a professional ship sprite!

---

## Step 2: Add Laser Sound Effect (3 minutes)

### In Godot:
1. **Still in Player.tscn** (from Step 1)
2. **Right-click on "Player"** (root node) → **Add Child Node**
3. **Search for:** `AudioStreamPlayer`
4. **Click "Create"**
5. **With AudioStreamPlayer selected**, look at Inspector
6. **Find "Stream" property**
7. **Click the empty box** → "Quick Load"
8. **Navigate to:** `kenney_sci-fi-sounds/Audio/laserSmall_001.ogg`
9. **Click "Open"**
10. **Save** (Ctrl+S)

### Add Code to Play Sound:
1. **Open Player.gd** (double-click in FileSystem)
2. **Find the shoot() or fire() function**
3. **Add this line inside the function:**
   ```gdscript
   $AudioStreamPlayer.play()
   ```
4. **Save** (Ctrl+S)

✅ **Done!** Your ship now makes laser sounds when shooting!

---

## Step 3: Replace Enemy Sprite (3 minutes)

### In Godot:
1. **Open Enemy.tscn** (FileSystem → double-click Enemy.tscn)
2. **Find the sprite node** in Scene tree
3. **Click on it**
4. **Inspector → Texture → Quick Load**
5. **Navigate to:** `kenney_space-shooter-redux/PNG/Enemies/enemyRed1.png`
6. **Click "Open"**
7. **Save** (Ctrl+S)

✅ **Done!** Enemies now look professional!

---

## 🎨 Optional: Add Explosion Particle Effect (4 minutes)

### In Godot:
1. **Open Enemy.tscn**
2. **Right-click "Enemy"** → **Add Child Node**
3. **Search for:** `CPUParticles2D`
4. **Click "Create"**
5. **With CPUParticles2D selected:**
   - Inspector → **Texture** → Quick Load
   - Navigate to: `kenney_particle-pack/PNG (Transparent)/fire_01.png`
   - Click "Open"
6. **Set these properties in Inspector:**
   - **Emitting:** false (OFF)
   - **One Shot:** true (ON)
   - **Amount:** 50
   - **Lifetime:** 1.0
   - **Explosiveness:** 1.0

### Add Code to Trigger Explosion:
1. **Open Enemy.gd**
2. **Find the die() or death() function**
3. **Add this line at the start:**
   ```gdscript
   $CPUParticles2D.emitting = true
   ```
4. **Save**

✅ **Done!** Enemies now explode with cool particle effects!

---

## ✅ Test Your Improvements:

**Press F5** in Godot to run your game!

You should now see:
- ✅ Professional player ship sprite
- ✅ Laser sound when shooting
- ✅ Professional enemy sprites  
- ✅ Particle explosion effects

---

## 🚀 What's Next?

After completing these 3 steps, you can:
1. **Add more sounds** (explosions, UI clicks, engine hum)
2. **Replace bullet sprites** with Kenney lasers
3. **Add engine trail particles** to player ship
4. **Animate menu buttons** with Tween nodes
5. **Add background music**

---

## 💡 Quick Tips:

- **Any time you see a texture**, you can replace it with Kenney assets
- **Sound effects** are added with AudioStreamPlayer nodes
- **Particle effects** use CPUParticles2D or GPUParticles2D
- **Animations** use AnimationPlayer or Tween nodes

---

## 📚 For More Details:

See `KENNEY_ASSETS_USAGE_GUIDE.md` for complete examples and code snippets!

**That's it! You've just upgraded your game with professional assets in 15 minutes!** 🎉
