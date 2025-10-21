# 🎨 Where To Download Free Map Backgrounds

## Free Space Background Resources

You don't need to create backgrounds from scratch! Here are sites with **free** space backgrounds:

---

## 🌟 Best Free Resources

### 1. OpenGameArt.org
**Link:** https://opengameart.org/art-search-advanced?keys=space+background

**What You'll Find:**
- Free space backgrounds
- Nebulas, stars, planets
- Licensed for games (CC0, CC-BY)
- PNG format, various sizes

**How To Use:**
1. Search "space background"
2. Download PNG files
3. Put in `D:\GalacticCombat\` folder
4. Use in your game!

---

### 2. Itch.io Asset Packs
**Link:** https://itch.io/game-assets/free/tag-space

**What You'll Find:**
- Complete space asset packs
- Backgrounds, sprites, effects
- Many are free or pay-what-you-want

---

### 3. Kenney.nl (Highly Recommended!)
**Link:** https://kenney.nl/assets?q=space

**What You'll Find:**
- Professional quality
- 100% free, public domain
- Space shooter packs
- Backgrounds included

**Popular Packs:**
- "Space Shooter Redux"
- "Planets"  
- "Space Kit"

---

### 4. Pixabay (Photos & AI)
**Link:** https://pixabay.com/images/search/space/

**What You'll Find:**
- Real NASA photos
- AI-generated space scenes
- Free for commercial use
- High resolution

---

## 🚀 Quick Start: Use What You Already Have!

**Your SpaceShooterV2 folder might already have backgrounds!**

Check:
```
SpaceShooterV2/backgrounds/
SpaceShooterV2/assets/
```

Or use the **icon.png** or other images temporarily while testing.

---

## 💡 Or Create Simple Colored Backgrounds

**No downloads needed!** Use Godot's ColorRect:

### In Main.tscn:

1. Add ColorRect node
2. Set Anchor Preset to "Full Rect"
3. Change color in Inspector

**Map Colors:**
- **Space Station:** Dark Blue (#0a0e27)
- **Nebula:** Purple (#2d1b4e)
- **Asteroid Field:** Gray (#1a1a1a)
- **Desert Planet:** Orange/Brown (#4a3520)

**Super easy and looks good!**

---

## 📥 How To Add Downloaded Backgrounds

### Step 1: Download Image
- Get a PNG or JPG space image
- Size: 1920x1080 recommended (or larger)

### Step 2: Copy To Project
```
D:\GalacticCombat\bg_space.png
D:\GalacticCombat\bg_nebula.png
D:\GalacticCombat\bg_asteroids.png
```

### Step 3: Use In Game
In Main.tscn, add Sprite2D:
```gdscript
func _ready():
	$Background.texture = load("res://bg_space.png")
```

---

## ✅ Recommended Approach

**Start with colored backgrounds** (no download needed!)
- Use ColorRect with different colors
- Test your map system works
- **Then** add fancy images later

**Your game works now - keep it simple and polish gameplay first!**

---

## 📚 More Resources

- **Reddit:** r/gameassets
- **Game Dev Market:** (search "space backgrounds")
- **Unity Asset Store:** (many work in Godot too)
- **Google Images:** (filter by "Labeled for reuse")

**Remember:** Always check the license! CC0 and Public Domain are safest for games.
