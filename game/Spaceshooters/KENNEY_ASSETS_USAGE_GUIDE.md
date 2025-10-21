# Kenney Assets Usage Guide for Godot

## ✅ Assets Successfully Imported

All Kenney asset packs have been copied to `d:\GalacticCombat\Assets\`:

- **kenney_space-shooter-redux** (314 files) - Ships, enemies, bullets, effects
- **kenney_space-shooter-extension** (566 files) - Additional ships and variations
- **kenney_alien-ufo-pack** (57 files) - UFO ships and lasers
- **kenney_particle-pack** (195 files) - Particle effects (explosions, smoke, fire, etc.)
- **kenney_sci-fi-sounds** (76 files) - Space sound effects (lasers, engines, explosions)

**Total: 1,208 professional game assets ready to use!**

---

## 🎮 How to Use These Assets in Godot

### Step 1: Open Your Project in Godot
1. Launch Godot 4.x
2. Open your GalacticCombat project at `d:\GalacticCombat\`
3. Godot will automatically detect and import the new assets

### Step 2: Wait for Asset Import
- The first time you open the project after adding assets, Godot will import them
- This may take a few minutes depending on the number of files
- You'll see a progress bar in the bottom right corner
- **DO NOT close Godot during import!**

### Step 3: Access Assets in FileSystem Panel
1. Look at the bottom-left panel in Godot (FileSystem)
2. Navigate to `res://Assets/`
3. You'll see all 5 Kenney asset pack folders

---

## 🚀 Using Ship Sprites

### Location
- `Assets/kenney_space-shooter-redux/PNG/`
- `Assets/kenney_space-shooter-extension/PNG/`
- `Assets/kenney_alien-ufo-pack/PNG/`

### How to Add a Ship to Your Game
1. **Create a new scene** (Scene → New Scene → 2D Scene)
2. **Add a Sprite2D node** (click the root node, then click the + icon)
3. **Assign the texture:**
   - Select the Sprite2D node
   - In Inspector panel (right side), find "Texture"
   - Click the dropdown → "Quick Load"
   - Navigate to `Assets/kenney_space-shooter-redux/PNG/`
   - Select a ship sprite (e.g., `playerShip1_blue.png`)

### Example Ships to Use
- **Player ships:** `playerShip1_blue.png`, `playerShip2_red.png`, `playerShip3_green.png`
- **Enemy ships:** `enemyBlack1.png`, `enemyRed1.png`, `ufoGreen.png`
- **Boss ships:** Large enemy variants or UFOs

---

## 💥 Using Particle Effects

### Location
- `Assets/kenney_particle-pack/PNG (Transparent)/`
- `Assets/kenney_particle-pack/PNG (Black background)/`

### Recommended: Use Transparent Background Versions

### Creating an Explosion Effect
1. **Add a CPUParticles2D or GPUParticles2D node** to your scene
2. **Create a new material:**
   - Select the particle node
   - Inspector → Process Material → "New ParticleProcessMaterial"
   - Click the material to edit it
3. **Assign particle texture:**
   - Texture → "Quick Load"
   - Navigate to `Assets/kenney_particle-pack/PNG (Transparent)/`
   - Choose an effect (e.g., `fire_01.png`, `smoke_01.png`, `star_01.png`)
4. **Configure particle settings:**
   - Amount: 50-100 particles
   - Lifetime: 0.5-2 seconds
   - Initial Velocity: Set X and Y ranges
   - Gravity: Y = 0 for space
   - Scale: Random between 0.5-1.5

### Popular Effects to Use
- **Explosions:** `fire_01.png`, `fire_02.png`
- **Engine trails:** `flame_05.png`, `flame_06.png`, `trace_01.png`
- **Hit effects:** `spark_01.png`, `spark_02.png`
- **Smoke:** `smoke_01.png` through `smoke_10.png`
- **Stars/sparkles:** `star_01.png` through `star_09.png`

---

## 🔫 Using Bullets and Lasers

### Location
- `Assets/kenney_space-shooter-redux/PNG/Lasers/`
- `Assets/kenney_alien-ufo-pack/PNG/`

### Creating a Bullet
1. **Create a new scene** for your bullet
2. **Add Area2D node** (root)
3. **Add Sprite2D node** as child
4. **Add CollisionShape2D** as child
5. **Assign laser texture to Sprite2D:**
   - Select a laser from `Assets/kenney_space-shooter-redux/PNG/Lasers/`
   - Examples: `laserBlue01.png`, `laserRed01.png`, `laserGreen01.png`
6. **Set up collision shape** to match the laser size
7. **Attach bullet movement script** (use existing Bullet.gd as reference)

### Laser Color Options
- **Blue lasers:** Player weapons
- **Red lasers:** Enemy weapons
- **Green lasers:** Special weapons
- **Different sizes:** Small (fast), Medium (balanced), Large (slow but powerful)

---

## 🔊 Using Sound Effects

### Location
- `Assets/kenney_sci-fi-sounds/Audio/`

### How to Add Sounds
1. **Add an AudioStreamPlayer node** to your scene (or AudioStreamPlayer2D for positional audio)
2. **Assign the audio file:**
   - Select the AudioStreamPlayer
   - Inspector → Stream → "Quick Load"
   - Navigate to `Assets/kenney_sci-fi-sounds/Audio/`
   - Select a sound file (e.g., `laserSmall_001.ogg`)
3. **Play the sound in code:**
   ```gdscript
   $AudioStreamPlayer.play()
   ```

### Sound Categories

**Laser Sounds (Player Shooting):**
- `laserSmall_001.ogg` through `laserSmall_004.ogg` - Quick pew pew sounds
- `laserLarge_001.ogg` through `laserLarge_004.ogg` - Powerful laser sounds
- `laserRetro_001.ogg` through `laserRetro_004.ogg` - Classic arcade style

**Explosion Sounds (Enemy Death):**
- `explosionCrunch_000.ogg` through `explosionCrunch_004.ogg` - Impact explosions
- `lowFrequency_explosion_000.ogg`, `lowFrequency_explosion_001.ogg` - Deep explosions

**Engine Sounds (Ship Movement):**
- `spaceEngine_000.ogg` through `spaceEngine_003.ogg` - Generic engines
- `thrusterFire_000.ogg` through `thrusterFire_004.ogg` - Boost/thrust sounds
- `engineCircular_000.ogg` through `engineCircular_004.ogg` - Looping engine hum

**Impact Sounds (Getting Hit):**
- `impactMetal_000.ogg` through `impactMetal_004.ogg` - Ship damage sounds
- `forceField_000.ogg` through `forceField_004.ogg` - Shield hit sounds

---

## 🎨 Quick Integration Examples

### Example 1: Replace Player Ship Sprite
1. Open `Player.tscn`
2. Select the Sprite2D node
3. In Inspector → Texture → Click the current texture
4. "Quick Load" → Navigate to `Assets/kenney_space-shooter-redux/PNG/`
5. Select `playerShip1_blue.png`
6. Adjust collision shape if needed

### Example 2: Add Laser Sound to Shooting
1. Open `Player.gd` script
2. Add AudioStreamPlayer node to Player scene named "LaserSound"
3. Assign `laserSmall_001.ogg` to its Stream property
4. In the shooting function, add:
   ```gdscript
   func shoot():
       # Existing bullet spawning code...
       $LaserSound.play()
   ```

### Example 3: Create Explosion Particle Effect
1. Open `Enemy.tscn`
2. Add CPUParticles2D node
3. Set properties:
   - Emitting: false
   - One Shot: true
   - Explosiveness: 1.0
   - Amount: 50
   - Lifetime: 1.0
4. Texture: `Assets/kenney_particle-pack/PNG (Transparent)/fire_01.png`
5. In `Enemy.gd` when enemy dies:
   ```gdscript
   func die():
       $CPUParticles2D.emitting = true
       # Rest of death code...
   ```

---

## 📁 Asset Organization Tips

### Recommended Folder Structure
```
Assets/
├── kenney_space-shooter-redux/    (Main ships & bullets)
├── kenney_space-shooter-extension/ (Extra ships)
├── kenney_alien-ufo-pack/         (UFO enemies)
├── kenney_particle-pack/          (All effects)
└── kenney_sci-fi-sounds/          (All audio)
```

### Creating Custom Collections
You can create custom folders in `res://` to organize specific assets:
```
res://
├── Ships/          (Copy your favorite ship sprites here)
├── Weapons/        (Copy bullet/laser sprites here)
├── Effects/        (Copy particle textures here)
└── Sounds/         (Link to sci-fi-sounds or copy)
```

---

## 🎯 Performance Tips

### For Sprites
- Use `.png` files (already optimized)
- Godot automatically creates `.import` files (don't delete these!)
- Sprites are lightweight and fast

### For Particles
- Use CPUParticles2D for simple effects (better performance)
- Use GPUParticles2D for complex effects with many particles
- Limit particle count to 100-200 for mobile devices
- Pre-load particle textures

### For Audio
- `.ogg` format is already optimized for Godot
- For looping sounds (engines), enable "Loop" in AudioStreamPlayer
- Use AudioStreamPlayer2D for positional sounds (explosions near player)
- Use AudioStreamPlayer for UI sounds and music

---

## 🐛 Troubleshooting

### Assets Not Showing Up?
1. Restart Godot (File → Quit, then reopen)
2. Check FileSystem panel → right-click → "Reimport"
3. Verify files are in correct location: `d:\GalacticCombat\Assets\`

### Textures Look Blurry?
1. Select the texture in FileSystem
2. Go to Import tab (next to Scene/Inspector)
3. Set Filter: Nearest (for pixel-perfect) or Linear (for smooth)
4. Click "Reimport"

### Sounds Not Playing?
1. Verify the audio file path is correct
2. Check that AudioStreamPlayer's Bus is set to "Master"
3. Increase the Volume DB if too quiet (try 0 to +6 dB)
4. Make sure `.play()` is being called in code

### Particles Not Appearing?
1. Set "Emitting" to true in Inspector
2. Check that Amount > 0 and Lifetime > 0
3. Verify particle texture is assigned
4. Make sure Initial Velocity is not zero
5. Check Layer/Mask settings if using visibility layers

---

## 🎨 Advanced: Creating Custom Variations

### Recoloring Sprites
Many Kenney sprites come in multiple colors. You can also:
1. Use Godot's Modulate property (Inspector → CanvasItem → Modulate)
2. Create shader materials for dynamic color changes
3. Use image editing software to create custom colors

### Combining Particle Effects
Create complex explosions by:
1. Layering multiple CPUParticles2D nodes
2. Using different textures (fire + smoke + sparks)
3. Varying timing and lifetime for each layer

### Dynamic Sound Variations
Make sounds less repetitive:
```gdscript
var laser_sounds = [
    preload("res://Assets/kenney_sci-fi-sounds/Audio/laserSmall_001.ogg"),
    preload("res://Assets/kenney_sci-fi-sounds/Audio/laserSmall_002.ogg"),
    preload("res://Assets/kenney_sci-fi-sounds/Audio/laserSmall_003.ogg")
]

func shoot():
    $AudioStreamPlayer.stream = laser_sounds[randi() % laser_sounds.size()]
    $AudioStreamPlayer.play()
```

---

## 📚 Additional Resources

### Kenney Asset Website
- Visit: https://kenney.nl
- More free assets available
- License: CC0 (Public Domain) - Use freely!

### Godot Documentation
- Sprites: https://docs.godotengine.org/en/stable/classes/class_sprite2d.html
- Particles: https://docs.godotengine.org/en/stable/classes/class_cpuparticles2d.html
- Audio: https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer.html

---

## ✨ Next Steps

1. **Open Godot and explore the assets** in the FileSystem panel
2. **Replace placeholder graphics** in your existing game with Kenney assets
3. **Add sound effects** to shooting, explosions, and UI interactions
4. **Create particle effects** for explosions and engine trails
5. **Test and iterate** - try different combinations!

**Your GalacticCombat game now has professional-quality assets! 🚀**

---

## 📝 Quick Reference Card

| Asset Type | Location | Common Uses |
|------------|----------|-------------|
| Player Ships | `space-shooter-redux/PNG/` | Main character, ship selection |
| Enemy Ships | `space-shooter-redux/PNG/Enemies/` | Enemies, bosses |
| UFOs | `alien-ufo-pack/PNG/` | Special enemies, bosses |
| Lasers | `space-shooter-redux/PNG/Lasers/` | Bullets, projectiles |
| Particles | `particle-pack/PNG (Transparent)/` | Explosions, effects |
| Sounds | `sci-fi-sounds/Audio/` | All audio effects |

---

**Congratulations! You're ready to create an amazing space shooter with professional assets!** 🎮✨
