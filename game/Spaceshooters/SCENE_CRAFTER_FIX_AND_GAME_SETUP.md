# Scene Crafter Fix + Complete Game Setup Guide

## 🔧 Fixing Scene Crafter Errors

### Error Explanation:
The HTTPRequest errors mean the backend Python server isn't running. Scene Crafter has two modes:

**Mode 1: Basic (No Backend)** - Works without Python server
- UI and scene creation tools
- No AI generation

**Mode 2: Full AI (Requires Backend)** - Needs Python server running
- AI-powered scene generation
- Natural language processing

### Quick Fix - Use Basic Mode:

The plugin is installed and works! The errors are just because the AI backend isn't running. You can still use the UI tools.

To use **Full AI mode later:**
```bash
cd "Spacegame\Space-Shooter\addons\scene-crafter-main\python-scripts\backend"
python app.py
```

---

## 🎨 Adding Kenney Assets to Your Game

### Step 1: Download Kenney Assets (if you haven't)

**Free Space Shooter Assets:**
- https://kenney.nl/assets/space-shooter-redux
- https://kenney.nl/assets/space-shooter-extension
- https://kenney.nl/assets/ui-pack-space-expansion

### Step 2: Import Assets to GalacticCombat

1. **Create assets folder structure:**
```
GalacticCombat/
├── assets/
│   ├── ships/
│   ├── enemies/
│   ├── backgrounds/
│   ├── ui/
│   ├── projectiles/
│   └── effects/
```

2. **In Godot:**
   - Open GalacticCombat project
   - Drag Kenney PNG files into the assets folders
   - Godot will auto-import them

3. **Import Settings:**
   - For pixel art: Set Filter to **Nearest** (keeps crisp pixels)
   - Right-click image → Import → Change to Nearest

---

## 🗺️ Creating Maps from Your Files

You already have map system files! Let's use them:

### Your Existing Map Files:
- ✅ `MapSystem.gd` - Map management
- ✅ `HOW_TO_ADD_MAPS.md` - Map guide
- ✅ `WHERE_TO_GET_MAP_BACKGROUNDS.md` - Background sources

### Create Map Scenes:

#### Map 1: Asteroid Field

**Create:** `res://maps/AsteroidField.tscn`

```gdscript
# AsteroidField.gd
extends Node2D

@onready var background = $ParallaxBackground
@onready var asteroids = $Asteroids
@onready var spawn_timer = $SpawnTimer

func _ready():
	spawn_timer.timeout.connect(_spawn_asteroid)
	spawn_timer.start()

func _spawn_asteroid():
	var asteroid = preload("res://enemies/Asteroid.tscn").instantiate()
	asteroid.position = Vector2(randf_range(50, 750), -50)
	asteroids.add_child(asteroid)
```

#### Map 2: Nebula Zone

**Create:** `res://maps/NebulaZone.tscn`

```gdscript
# NebulaZone.gd
extends Node2D

func _ready():
	# Add nebula particle effects
	setup_nebula_effects()

func setup_nebula_effects():
	var particles = CPUParticles2D.new()
	particles.amount = 100
	particles.lifetime = 5.0
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(400, 300)
	particles.gravity = Vector2.ZERO
	add_child(particles)
```

#### Map 3: Space Station

**Create:** `res://maps/SpaceStation.tscn`

```gdscript
# SpaceStation.gd
extends Node2D

var station_health = 1000

func _ready():
	setup_station_defenses()

func setup_station_defenses():
	# Add turrets, shields, etc.
	pass
```

---

## 📱 Mobile Controls Integration

You already have `MobileControls.gd`! Let's integrate it properly.

### Step 1: Update Player for Mobile

```gdscript
# Player.gd - Add mobile support
extends CharacterBody2D

var speed = 300.0
var mobile_input = Vector2.ZERO

func _ready():
	# Connect to mobile controls if they exist
	if has_node("/root/MobileControls"):
		var mobile = get_node("/root/MobileControls")
		mobile.connect("direction_changed", _on_mobile_direction_changed)
		mobile.connect("shoot_pressed", _on_mobile_shoot)

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	
	# Desktop controls
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	
	# Mobile controls
	input_vector += mobile_input
	
	velocity = input_vector.normalized() * speed
	move_and_slide()

func _on_mobile_direction_changed(direction: Vector2):
	mobile_input = direction

func _on_mobile_shoot():
	shoot()
```

### Step 2: Add Mobile UI to Main Scene

```gdscript
# Main.tscn - Add mobile controls
# In the scene tree, add:
- CanvasLayer
  - MobileControls (load your MobileControls.gd)
    - Left Joystick (for movement)
    - Right Button (for shooting)
```

### Step 3: Auto-Detect Mobile

```gdscript
# In Main.gd or GameManager.gd
func _ready():
	if OS.has_feature("mobile") or OS.has_feature("web"):
		show_mobile_controls()
	else:
		hide_mobile_controls()

func show_mobile_controls():
	if has_node("CanvasLayer/MobileControls"):
		$CanvasLayer/MobileControls.visible = true

func hide_mobile_controls():
	if has_node("CanvasLayer/MobileControls"):
		$CanvasLayer/MobileControls.visible = false
```

---

## 🎮 Complete Game Structure

```
GalacticCombat/
├── assets/
│   ├── kenney_ships/ (your Kenney assets)
│   ├── backgrounds/
│   └── ui/
├── maps/
│   ├── AsteroidField.tscn
│   ├── NebulaZone.tscn
│   ├── SpaceStation.tscn
│   ├── DeepSpace.tscn
│   └── BossBattle.tscn
├── scenes/
│   ├── Player.tscn
│   ├── Enemy.tscn
│   ├── Bullet.tscn
│   └── Explosion.tscn
├── scripts/
│   ├── Player.gd
│   ├── GameManager.gd
│   ├── MapSystem.gd
│   ├── MobileControls.gd
│   └── NetworkManager.gd
├── ui/
│   ├── MainMenu.tscn
│   ├── Lobby.tscn
│   └── HUD.tscn
└── addons/
    └── scene-crafter/
```

---

## 🎨 Well-Designed Space Maps

### Map Design Principles:

#### 1. **Asteroid Field Map**
**Theme:** Dense obstacles, high difficulty
- Parallax background with moving stars
- Random asteroid spawning
- Power-ups hidden behind asteroids
- Enemy ambush points
- Safe zones for players to regroup

**Layout:**
```
Top: Enemy spawn zone
Middle: Asteroid field (obstacle course)
Bottom: Player starting area
Left/Right: Wraparound or boundaries
```

#### 2. **Nebula Zone Map**
**Theme:** Low visibility, strategic play
- Colorful nebula clouds (use particles)
- Reduced enemy detection range
- Hidden paths through clouds
- Stealth gameplay opportunities

**Features:**
- CPUParticles2D for nebula effect
- Fog of war mechanic
- Surprise enemy encounters

#### 3. **Space Station Map**
**Theme:** Objective-based, defense
- Central space station to protect
- Multiple attack lanes
- Station defenses (turrets)
- Repair zones

**Objectives:**
- Defend station from waves
- Repair damage between waves
- Co-op roles (attacker/defender)

#### 4. **Deep Space Map**
**Theme:** Open combat, boss battles
- Wide open space
- Minimal obstacles
- Perfect for boss fights
- Multiple player positions

#### 5. **Planet Orbit Map**
**Theme:** Gravity mechanics
- Planet in center with gravity pull
- Orbital paths
- Satellite obstacles
- Strategic positioning

---

## 🛠️ Step-by-Step Implementation

### Day 1: Import Assets
1. ✅ Download Kenney assets
2. ✅ Create folder structure
3. ✅ Import into Godot
4. ✅ Set import settings (Nearest filter)

### Day 2: Create 5 Maps
1. ✅ AsteroidField.tscn
2. ✅ NebulaZone.tscn
3. ✅ SpaceStation.tscn
4. ✅ DeepSpace.tscn
5. ✅ PlanetOrbit.tscn

### Day 3: Mobile Integration
1. ✅ Update Player.gd
2. ✅ Add mobile UI to Main.tscn
3. ✅ Test on mobile/tablet
4. ✅ Adjust button sizes

### Day 4: Map Testing
1. ✅ Test each map
2. ✅ Balance difficulty
3. ✅ Add map-specific enemies
4. ✅ Test multiplayer on each map

### Day 5: Polish
1. ✅ Add map preview images
2. ✅ Create map selection UI
3. ✅ Add map descriptions
4. ✅ Test full game loop

---

## 📱 Mobile Export Settings

### Android Export:
```ini
[preset.0.options]
screen/orientation=0  # Landscape
screen/support_small=true
screen/support_normal=true
screen/support_large=true
screen/support_xlarge=true
```

### Touch Controls:
- Joystick: 150x150 pixels (bottom-left)
- Shoot Button: 100x100 pixels (bottom-right)
- Pause: 50x50 pixels (top-right)

---

## 🗺️ Using Your Existing Map System

Your `MapSystem.gd` is ready! Here's how to use it:

```gdscript
# In Lobby.gd or GameManager.gd
var map_system = preload("res://MapSystem.gd").new()

func _ready():
	add_child(map_system)
	
	# Register your maps
	map_system.register_map("asteroid_field", "res://maps/AsteroidField.tscn")
	map_system.register_map("nebula_zone", "res://maps/NebulaZone.tscn")
	map_system.register_map("space_station", "res://maps/SpaceStation.tscn")
	
	# Load a map
	map_system.load_map("asteroid_field")
```

---

## 🎮 Map Selection UI

```gdscript
# MapSelection.gd
extends Control

@onready var map_list = $VBoxContainer/MapList

func _ready():
	populate_maps()

func populate_maps():
	var maps = [
		{"name": "Asteroid Field", "difficulty": "Hard", "scene": "res://maps/AsteroidField.tscn"},
		{"name": "Nebula Zone", "difficulty": "Medium", "scene": "res://maps/NebulaZone.tscn"},
		{"name": "Space Station", "difficulty": "Easy", "scene": "res://maps/SpaceStation.tscn"},
		{"name": "Deep Space", "difficulty": "Medium", "scene": "res://maps/DeepSpace.tscn"},
		{"name": "Planet Orbit", "difficulty": "Hard", "scene": "res://maps/PlanetOrbit.tscn"}
	]
	
	for map_data in maps:
		var button = Button.new()
		button.text = map_data["name"] + " - " + map_data["difficulty"]
		button.pressed.connect(func(): load_map(map_data["scene"]))
		map_list.add_child(button)

func load_map(map_scene: String):
	get_tree().change_scene_to_file(map_scene)
```

---

## ✅ Testing Checklist

### Desktop:
- [ ] Keyboard controls work
- [ ] Mouse shooting works
- [ ] All 5 maps load
- [ ] Enemies spawn correctly
- [ ] Multiplayer works

### Mobile:
- [ ] Touch joystick works
- [ ] Shoot button responsive
- [ ] UI scales properly
- [ ] Performance is smooth (60 FPS)
- [ ] Maps work on mobile

### Multiplayer:
- [ ] Host can select maps
- [ ] Clients see map selection
- [ ] All maps work in multiplayer
- [ ] Players sync correctly
- [ ] Chat works on all maps

---

Your complete space shooter with Kenney assets, 5 maps, and mobile support is ready to build! 🚀
