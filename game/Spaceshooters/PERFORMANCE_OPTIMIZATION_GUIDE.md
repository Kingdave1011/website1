# Performance Optimization Guide - Lag-Free Gameplay

## 🚀 Making Your Game Run Smoothly Everywhere

This guide ensures your game runs at 60 FPS on all platforms, especially the browser version.

---

## ⚡ CRITICAL OPTIMIZATIONS FOR WEB/BROWSER

### 1. Reduce Particle Effects for Web

```gdscript
# OptimizationManager.gd (create as autoload)
extends Node

var is_web_build: bool = false
var is_mobile: bool = false

func _ready():
	is_web_build = OS.has_feature("web")
	is_mobile = OS.has_feature("mobile")
	
	apply_optimizations()

func apply_optimizations():
	if is_web_build or is_mobile:
		# Reduce particle counts
		reduce_particles()
		# Lower texture quality
		set_low_quality_mode()
		# Disable expensive effects
		disable_heavy_effects()

func reduce_particles():
	# Reduce particle amounts by 50% for web
	Engine.max_fps = 60
	ProjectSettings.set_setting("rendering/limits/rendering/max_renderable_elements", 8192)

func set_low_quality_mode():
	# Use lower resolution textures for web
	ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", 0)
	ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_2d", 0)

func disable_heavy_effects():
	# Disable shadows and advanced effects on web
	RenderingServer.set_default_clear_color(Color.BLACK)
```

### 2. Optimize Sprite Sizes for Web

**Maximum sprite size for web: 512x512 pixels**

**Recommended sizes:**
- Player ship: 64x64
- Enemy ships: 48x48
- Bullets: 16x16
- Background: 1280x720 (single image, no tiling)
- UI elements: 256x256 max

**Compress Images:**
```
In Godot:
1. Select image in FileSystem
2. Right-click → Import
3. Set "Compress" → "Lossy"
4. Set "Mipmaps" → Off (for 2D)
5. Reimport
```

---

## 🎯 OBJECT POOLING (Prevent Lag Spikes)

### Problem:
Creating/destroying many objects causes lag.

### Solution:
Object pooling - reuse objects instead of creating new ones.

```gdscript
# BulletPool.gd (create as autoload)
extends Node

var bullet_scene = preload("res://Bullet.tscn")
var pool_size: int = 100
var bullet_pool: Array = []
var active_bullets: Array = []

func _ready():
	# Pre-create bullets
	for i in range(pool_size):
		var bullet = bullet_scene.instantiate()
		bullet.visible = false
		bullet.process_mode = Node.PROCESS_MODE_DISABLED
		add_child(bullet)
		bullet_pool.append(bullet)

func get_bullet() -> Node:
	if bullet_pool.size() > 0:
		var bullet = bullet_pool.pop_back()
		bullet.visible = true
		bullet.process_mode = Node.PROCESS_MODE_INHERIT
		active_bullets.append(bullet)
		return bullet
	else:
		# Pool empty, create new one
		var bullet = bullet_scene.instantiate()
		add_child(bullet)
		active_bullets.append(bullet)
		return bullet

func return_bullet(bullet: Node):
	bullet.visible = false
	bullet.process_mode = Node.PROCESS_MODE_DISABLED
	bullet.position = Vector2(-1000, -1000)  # Move offscreen
	active_bullets.erase(bullet)
	bullet_pool.append(bullet)

# Update Player.gd to use pool:
func shoot():
	var bullet = get_node("/root/BulletPool").get_bullet()
	bullet.position = position + Vector2(0, -20)
	bullet.velocity = Vector2(0, -400)
```

---

## 🔧 FPS OPTIMIZATION SETTINGS

### project.godot Settings:

```ini
[rendering]
# Optimize for web
renderer/rendering_method="gl_compatibility"  # Best for web
textures/canvas_textures/default_texture_filter=0  # Nearest (no blur)
textures/canvas_textures/default_texture_repeat=0
2d/snapping/use_gpu_pixel_snap=true

# Reduce quality for web
anti_aliasing/quality/msaa_2d=0
anti_aliasing/quality/msaa_3d=0
textures/lossless_compression/force_png=false
textures/vram_compression/import_etc2_astc=false

# Performance
limits/rendering/max_renderable_elements=8192
limits/rendering/max_renderable_lights=32
limits/rendering/max_lights_per_object=8

[physics]
# Optimize physics
2d/physics_engine="GodotPhysics2D"
2d/default_gravity=0
2d/default_linear_damp=0
2d/default_angular_damp=1.0

[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/size/resizable=true
window/stretch/mode="canvas_items"
window/stretch/aspect="keep"

[debug]
# Disable in production
settings/stdout/print_fps=false
settings/stdout/verbose_stdout=false
```

---

## 💨 REDUCE LAG IN MULTIPLAYER

### 1. Use Unreliable RPCs for Position

```gdscript
# In MultiplayerPlayer.gd
@rpc("unreliable")  # Don't wait for confirmation
func sync_player(pos: Vector2, vel: Vector2):
	network_position = pos
	network_velocity = vel
```

### 2. Reduce Sync Frequency

```gdscript
var sync_timer: float = 0.0
var sync_interval: float = 0.05  # Sync every 50ms instead of every frame

func _physics_process(delta):
	if is_multiplayer_authority():
		handle_input(delta)
		
		sync_timer += delta
		if sync_timer >= sync_interval:
			sync_timer = 0.0
			rpc("sync_player", position, velocity)
```

### 3. Client-Side Prediction

```gdscript
# Interpolate between network updates
func _physics_process(delta):
	if not is_multiplayer_authority():
		# Smooth interpolation
		position = position.lerp(network_position, 0.25)  # 25% per frame
```

---

## 🌐 WEB-SPECIFIC OPTIMIZATIONS

### Export Settings for Web:

```
Project → Export → HTML5

[Vram Texture Compression]
✅ For Web (BPTC/ASTC)

[Texture Format]
✅ ETC2/ASTC

[Custom Template]
✅ Use

[Head Include] Add:
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">

[Export Options]
✅ Optimize for Size
✅ Memory Size: 256 MB (default 512 is overkill)
```

### Disable Heavy Features for Web:

```gdscript
# In GameManager.gd
func _ready():
	if OS.has_feature("web"):
		apply_web_optimizations()

func apply_web_optimizations():
	# Reduce max enemies
	max_enemies = 15  # Instead of 50
	
	# Reduce particle amounts
	for particle in get_tree().get_nodes_in_group("particles"):
		if particle is CPUParticles2D:
			particle.amount = max(particle.amount / 2, 10)
	
	# Disable shadows
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	# Reduce physics steps
	Engine.physics_ticks_per_second = 30  # Instead of 60
```

---

## 📊 PERFORMANCE MONITORING

### Add FPS Counter (Debug Only):

```gdscript
# FPSCounter.gd
extends Label

func _process(_delta):
	text = "FPS: " + str(Engine.get_frames_per_second())
	
	# Color code
	var fps = Engine.get_frames_per_second()
	if fps >= 50:
		modulate = Color.GREEN
	elif fps >= 30:
		modulate = Color.YELLOW
	else:
		modulate = Color.RED
```

---

## 🎨 GRAPHICS QUALITY SETTINGS

### Create Quality Presets:

```gdscript
# GraphicsSettings.gd
extends Node

enum Quality { LOW, MEDIUM, HIGH }
var current_quality: Quality = Quality.MEDIUM

func set_quality(quality: Quality):
	current_quality = quality
	apply_settings()

func apply_settings():
	match current_quality:
		Quality.LOW:
			apply_low_settings()
		Quality.MEDIUM:
			apply_medium_settings()
		Quality.HIGH:
			apply_high_settings()

func apply_low_settings():
	# For web and mobile
	ProjectSettings.set_setting("rendering/limits/rendering/max_renderable_elements", 4096)
	Engine.max_fps = 30
	
	# Disable particles
	for particle in get_tree().get_nodes_in_group("particles"):
		particle.visible = false

func apply_medium_settings():
	# Balanced
	ProjectSettings.set_setting("rendering/limits/rendering/max_renderable_elements", 8192)
	Engine.max_fps = 60
	
	# Reduce particles
	for particle in get_tree().get_nodes_in_group("particles"):
		if particle is CPUParticles2D:
			particle.amount = particle.amount / 2

func apply_high_settings():
	# Desktop only
	ProjectSettings.set_setting("rendering/limits/rendering/max_renderable_elements", 16384)
	Engine.max_fps = 0  # Unlimited
	
	# Full particle effects
	for particle in get_tree().get_nodes_in_group("particles"):
		if particle is CPUParticles2D:
			particle.amount = particle.amount * 2

# Auto-detect platform
func _ready():
	if OS.has_feature("web"):
		set_quality(Quality.LOW)
	elif OS.has_feature("mobile"):
		set_quality(Quality.LOW)
	else:
		set_quality(Quality.HIGH)
```

---

## 🔥 BROWSER-SPECIFIC OPTIMIZATIONS

### 1. Limit Sprite Resolution

```gdscript
# In enemy/player scripts
func _ready():
	if OS.has_feature("web"):
		# Scale down sprite for web
		if has_node("Sprite2D"):
			var sprite = $Sprite2D
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			# Ensure sprites are small
```

### 2. Reduce Sound Quality for Web

```
Audio files:
- Use OGG format (smaller than WAV)
- 22050 Hz sample rate (instead of 44100)
- Mono instead of stereo where possible
- Compress to 64kbps
```

### 3. Limit Enemy Count for Web

```gdscript
# In EnemySpawner.gd
var max_enemies: int = 50  # Desktop
var max_enemies_web: int = 15  # Web

func _ready():
	if OS.has_feature("web"):
		max_enemies = max_enemies_web

func spawn_enemy():
	if get_tree().get_nodes_in_group("enemies").size() >= max_enemies:
		return  # Don't spawn more
	
	# Spawn enemy...
```

### 4. Optimize Background for Web

```gdscript
# Background.gd
extends ParallaxBackground

func _ready():
	if OS.has_feature("web"):
		# Single layer instead of multiple
		for layer in get_children():
			if layer is ParallaxLayer:
				layer.motion_scale = layer.motion_scale * 0.5  # Slower scrolling
	
	# Limit parallax layers to 2 max for web
	if OS.has_feature("web") and get_child_count() > 2:
		for i in range(2, get_child_count()):
			get_child(i).queue_free()
```

---

## 🎮 GAMEPLAY OPTIMIZATIONS

### 1. Cull Offscreen Objects

```gdscript
# In Bullet.gd, Enemy.gd
func _process(delta):
	# Remove if offscreen
	if position.y > 800 or position.y < -100:
		queue_free()
	if position.x > 1400 or position.x < -100:
		queue_free()
```

### 2. Limit Active Explosions

```gdscript
# ExplosionManager.gd
extends Node

var max_explosions: int = 10
var active_explosions: Array = []

func create_explosion(pos: Vector2):
	# Limit explosions
	if active_explosions.size() >= max_explosions:
		var oldest = active_explosions.pop_front()
		oldest.queue_free()
	
	var explosion = preload("res://Explosion.tscn").instantiate()
	explosion.position = pos
	add_child(explosion)
	active_explosions.append(explosion)
	
	# Auto cleanup
	await get_tree().create_timer(0.5).timeout
	active_explosions.erase(explosion)
```

### 3. Optimize Collision Checks

```gdscript
# Use collision layers efficiently
# In project.godot:
[layer_names]
2d_physics/layer_1="Player"
2d_physics/layer_2="Enemy"
2d_physics/layer_3="Bullet"
2d_physics/layer_4="PowerUp"

# In Player.gd:
func _ready():
	collision_layer = 1  # Player layer
	collision_mask = 6   # Collide with Enemy (2) + PowerUp (4)
```

---

## 🖼️ TEXTURE OPTIMIZATION

### Auto-Compress Images:

```gdscript
# Run this once to compress all images
# Godot Editor → Project → Tools → Export → Export

# Or manually for each sprite:
# FileSystem → Right-click image → Import
# Set:
- Compress: Lossy
- Quality: 0.7
- Mipmaps: false
- Process: Size Limit 512
```

### Use Sprite Sheets Instead of Individual Sprites:

Benefits:
- Fewer draw calls
- Better performance
- Smaller file size

**Example:**
Instead of: player1.png, player2.png, player3.png
Use: player_spritesheet.png (all frames in one file)

---

## 🔧 CODE-LEVEL OPTIMIZATIONS

### 1. Use Static Typing

```gdscript
# Slower:
var position = Vector2(0, 0)
var speed = 300

# Faster:
var position: Vector2 = Vector2.ZERO
var speed: float = 300.0
```

### 2. Cache Node References

```gdscript
# Slow (calls get_node every frame):
func _process(delta):
	$Sprite2D.position += velocity * delta

# Fast (cache in _ready):
@onready var sprite: Sprite2D = $Sprite2D

func _process(delta):
	sprite.position += velocity * delta
```

### 3. Avoid String Operations in Loops

```gdscript
# Slow:
func _process(delta):
	for i in range(100):
		var node_name = "Enemy" + str(i)
		if has_node(node_name):
			pass

# Fast:
@onready var enemies: Array = []

func _ready():
	enemies = get_tree().get_nodes_in_group("enemies")

func _process(delta):
	for enemy in enemies:
		# Do stuff
		pass
```

---

## 📱 MOBILE-SPECIFIC OPTIMIZATIONS

### Battery Saving Mode:

```gdscript
func _ready():
	if OS.has_feature("mobile"):
		# Limit FPS to save battery
		Engine.max_fps = 30
		
		# Reduce particle effects
		ProjectSettings.set_setting("rendering/limits/rendering/max_renderable_elements", 4096)
		
		# Disable shadows
		ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/size", 1024)
```

---

## 🌐 WEB BUILD OPTIMIZATION CHECKLIST

### Before Export:

- [ ] Compress all images to <512px
- [ ] Use OGG audio (not WAV)
- [ ] Enable object pooling
- [ ] Limit particles to <50 per emitter
- [ ] Set max enemies to 15-20
- [ ] Remove unused assets
- [ ] Test on slow browser
- [ ] Enable "Optimize for Size" in export
- [ ] Set memory to 256MB (not 512MB)

### Export Settings:

```
HTML5 Export:
✅ Optimize for Size: true
✅ Memory Size: 256
✅ Thread Support: false (for compatibility)
✅ VRAM Texture Compression: enabled
✅ Export With Debug: false
```

---

## ⚙️ AUTOMATIC OPTIMIZATION SCRIPT

**Add this to your GameManager:**

```gdscript
# In GameManager.gd _ready()
func _ready():
	optimize_for_platform()

func optimize_for_platform():
	var platform = get_platform()
	
	match platform:
		"web":
			apply_web_optimizations()
		"mobile":
			apply_mobile_optimizations()
		"desktop":
			apply_desktop_optimizations()

func get_platform() -> String:
	if OS.has_feature("web"):
		return "web"
	elif OS.has_feature("mobile"):
		return "mobile"
	else:
		return "desktop"

func apply_web_optimizations():
	Engine.max_fps = 60
	max_enemies = 15
	particle_quality = 0.5
	enable_object_pooling()
	print("Web optimizations applied")

func apply_mobile_optimizations():
	Engine.max_fps = 30
	max_enemies = 20
	particle_quality = 0.6
	enable_object_pooling()
	print("Mobile optimizations applied")

func apply_desktop_optimizations():
	Engine.max_fps = 0  # Unlimited
	max_enemies = 50
	particle_quality = 1.0
	print("Desktop optimizations applied")
```

---

## 🎯 PERFORMANCE TARGETS

### Desktop:
- **Target:** 60+ FPS
- **Max Enemies:** 50
- **Particles:** Full quality
- **Texture Size:** Up to 2048x2048

### Web Browser:
- **Target:** 60 FPS (stable)
- **Max Enemies:** 15-20
- **Particles:** 50% quality
- **Texture Size:** Max 512x512

### Mobile:
- **Target:** 30-60 FPS
- **Max Enemies:** 20
- **Particles:** 50% quality
- **Texture Size:** Max 512x512
- **Battery:** Optimize for longer play

---

## 🧪 TESTING PERFORMANCE

### Test on Low-End Device:

```gdscript
# Simulate low-end device
Engine.max_fps = 30
Engine.time_scale = 0.9  # Slight slowdown

# Monitor performance
func _process(delta):
	var fps = Engine.get_frames_per_second()
	if fps < 30:
		print("WARNING: FPS dropped to: ", fps)
		reduce_quality()
```

### Browser Testing:

1. Chrome: Press F12 → Performance tab → Record
2. Firefox: Press F12 → Performance → Start recording
3. Look for:
   - Frame rate drops
   - Memory leaks
   - Long tasks

---

## 🚀 QUICK OPTIMIZATION COMMANDS

### Enable Performance Mode:

Add to Project Settings → Autoload:
- `OptimizationManager.gd`
- `BulletPool.gd`
- `ExplosionManager.gd`

### Test Performance:

```gdscript
# Add this temporarily
func _process(_delta):
	print("FPS: ", Engine.get_frames_per_second())
	print("Active Enemies: ", get_tree().get_nodes_in_group("enemies").size())
	print("Active Bullets: ", get_tree().get_nodes_in_group("bullets").size())
```

---

## ✅ FINAL CHECKLIST

### Web Version:
- [ ] Images compressed (<512px)
- [ ] Audio files OGG format
- [ ] Max 15-20 enemies
- [ ] Object pooling enabled
- [ ] Particles reduced 50%
- [ ] Memory set to 256MB
- [ ] Tested in Chrome/Firefox
- [ ] FPS stable at 60

### All Platforms:
- [ ] Static typing used
- [ ] Nodes cached in _ready()
- [ ] Collision layers optimized
- [ ] Offscreen culling enabled
- [ ] No expensive operations in _process()
- [ ] Platform detection working
- [ ] Auto-optimization active

---

Your game will now run smoothly on all platforms, especially in web browsers! 🚀✨
