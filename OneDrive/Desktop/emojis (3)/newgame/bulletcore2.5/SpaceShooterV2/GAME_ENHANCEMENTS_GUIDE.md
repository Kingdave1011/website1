# Space Shooter V2 - Game Enhancements Guide

This guide covers implementing all the new features for your Space Shooter game:
1. **Better Button Layout & UI**
2. **Screen Orientation Support (Portrait/Landscape)**
3. **3-Player Matchmaking with AI Bots**
4. **Improved Ship Designs**

---

## Part 1: Better Button Layout & UI

### Step 1: Create Enhanced Mobile Controls Script

Create `EnhancedMobileControls.gd`:

```gdscript
extends CanvasLayer

# Touch controls
var touch_joystick: Control
var fire_button: Control
var joystick_center: Vector2
var joystick_radius: float = 80
var touch_index: int = -1
var joystick_vector: Vector2 = Vector2.ZERO

signal move_input(direction: Vector2)
signal fire_pressed
signal fire_released

func _ready():
	setup_controls()

func setup_controls():
	# Create joystick background
	var joystick_bg = ColorRect.new()
	joystick_bg.color = Color(0.2, 0.2, 0.2, 0.3)
	joystick_bg.size = Vector2(200, 200)
	joystick_bg.position = Vector2(50, DisplayServer.window_get_size().y - 250)
	joystick_bg.custom_minimum_size = Vector2(200, 200)
	add_child(joystick_bg)
	
	# Create joystick center indicator
	touch_joystick = Control.new()
	var circle = ColorRect.new()
	circle.color = Color(0.5, 0.5, 0.5, 0.6)
	circle.size = Vector2(80, 80)
	circle.position = Vector2(-40, -40)
	touch_joystick.add_child(circle)
	touch_joystick.position = joystick_bg.position + Vector2(100, 100)
	joystick_center = touch_joystick.position
	add_child(touch_joystick)
	
	# Create fire button (styled better)
	fire_button = Button.new()
	fire_button.text = "FIRE"
	fire_button.custom_minimum_size = Vector2(150, 150)
	fire_button.position = Vector2(
		DisplayServer.window_get_size().x - 200,
		DisplayServer.window_get_size().y - 200
	)
	
	# Style the fire button
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.8, 0.2, 0.2, 0.6)
	style_normal.border_width_all = 3
	style_normal.border_color = Color(1, 0.3, 0.3, 0.8)
	style_normal.corner_radius_all = 75
	
	var style_pressed = StyleBoxFlat.new()
	style_pressed.bg_color = Color(1, 0.3, 0.3, 0.8)
	style_pressed.border_width_all = 3
	style_pressed.border_color = Color(1, 0.5, 0.5, 1)
	style_pressed.corner_radius_all = 75
	
	fire_button.add_theme_stylebox_override("normal", style_normal)
	fire_button.add_theme_stylebox_override("pressed", style_pressed)
	fire_button.add_theme_font_size_override("font_size", 32)
	
	fire_button.button_down.connect(_on_fire_pressed)
	fire_button.button_up.connect(_on_fire_released)
	add_child(fire_button)

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			var touch_pos = event.position
			var distance = touch_pos.distance_to(joystick_center)
			if distance < joystick_radius + 50:
				touch_index = event.index
		else:
			if event.index == touch_index:
				touch_index = -1
				joystick_vector = Vector2.ZERO
				touch_joystick.position = joystick_center
				move_input.emit(Vector2.ZERO)
	
	elif event is InputEventScreenDrag:
		if event.index == touch_index:
			var offset = event.position - joystick_center
			if offset.length() > joystick_radius:
				offset = offset.normalized() * joystick_radius
			touch_joystick.position = joystick_center + offset
			joystick_vector = offset / joystick_radius
			move_input.emit(joystick_vector)

func _on_fire_pressed():
	fire_pressed.emit()

func _on_fire_released():
	fire_released.emit()
```

---

## Part 2: Screen Orientation Support

### Step 1: Update Project Settings

In Godot Editor:
1. Go to **Project > Project Settings**
2. Under **Display > Window**:
   - Enable **Resizable**
   - Set **Mode** to "canvas_items"
3. Under **Display > Window > Handheld**:
   - Set **Orientation** to "sensor"

### Step 2: Create Orientation Manager

Create `OrientationManager.gd`:

```gdscript
extends Node

enum Orientation {
	PORTRAIT,
	LANDSCAPE
}

var current_orientation: Orientation = Orientation.LANDSCAPE

func _ready():
	get_tree().root.size_changed.connect(_on_viewport_size_changed)
	_check_orientation()

func _on_viewport_size_changed():
	_check_orientation()

func _check_orientation():
	var viewport_size = get_viewport().get_visible_rect().size
	var new_orientation: Orientation
	
	if viewport_size.x > viewport_size.y:
		new_orientation = Orientation.LANDSCAPE
	else:
		new_orientation = Orientation.PORTRAIT
	
	if new_orientation != current_orientation:
		current_orientation = new_orientation
		_apply_orientation_layout()

func _apply_orientation_layout():
	# Notify all UI elements to reposition
	get_tree().call_group("ui_elements", "_on_orientation_changed", current_orientation)
	
	# Adjust camera
	var camera = get_viewport().get_camera_2d()
	if camera:
		if current_orientation == Orientation.PORTRAIT:
			camera.zoom = Vector2(1.2, 1.2)
		else:
			camera.zoom = Vector2.ONE
```

---

## Part 3: 3-Player Matchmaking with AI Bots

### Step 1: Create AI Player Script

Create `AIPlayer.gd`:

```gdscript
extends CharacterBody2D

var speed: float = 350.0
var shoot_cooldown: float = 0.3
var health: int = 3
var player_id: int = 0
var is_ai: bool = true

var bullet_scene = preload("res://Bullet.tscn")
var can_shoot: bool = true
var target_position: Vector2
var ai_think_timer: float = 0
var ai_shoot_timer: float = 0

signal health_changed(player_id, new_health)
signal player_died(player_id)

func _ready():
	add_to_group("players")
	target_position = position

func _physics_process(delta):
	if not is_ai:
		return
	
	# AI thinking
	ai_think_timer += delta
	ai_shoot_timer += delta
	
	# Choose new target position every 2 seconds
	if ai_think_timer > 2.0:
		ai_think_timer = 0
		target_position = Vector2(
			randf_range(50, get_viewport_rect().size.x - 50),
			randf_range(50, get_viewport_rect().size.y / 2)
		)
	
	# Move toward target
	var direction = (target_position - position).normalized()
	velocity = direction * speed * 0.7
	move_and_slide()
	
	# Keep on screen
	position.x = clamp(position.x, 20, get_viewport_rect().size.x - 20)
	position.y = clamp(position.y, 20, get_viewport_rect().size.y - 20)
	
	# AI shooting (shoot at enemies)
	if ai_shoot_timer > 0.5 and can_shoot:
		var enemies = get_tree().get_nodes_in_group("enemy")
		if enemies.size() > 0:
			shoot()
			ai_shoot_timer = 0

func shoot():
	if not can_shoot:
		return
	
	can_shoot = false
	
	var bullet = bullet_scene.instantiate()
	bullet.position = position + Vector2(0, -30)
	bullet.direction = Vector2.UP
	get_parent().add_child(bullet)
	
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true

func take_damage(amount: int):
	health -= amount
	health_changed.emit(player_id, health)
	
	# Flash effect
	modulate = Color(1, 0.2, 0.2)
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if health <= 0:
		die()

func die():
	player_died.emit(player_id)
	queue_free()
```

### Step 2: Create Matchmaking Manager

Create `MatchmakingManager.gd`:

```gdscript
extends Node

signal match_found(players: Array)
signal match_started

const MAX_PLAYERS = 3
var connected_players: Array = []
var ai_player_scene = preload("res://AIPlayer.tscn")
var game_started: bool = false

func find_match():
	# Simulate finding players (in real game, this would connect to a server)
	connected_players.clear()
	
	# Add human player
	connected_players.append({
		"id": 1,
		"is_ai": false,
		"name": "Player"
	})
	
	# Fill remaining slots with AI
	for i in range(MAX_PLAYERS - 1):
		connected_players.append({
			"id": i + 2,
			"is_ai": true,
			"name": "AI Bot " + str(i + 1)
		})
	
	match_found.emit(connected_players)
	
	# Start match after brief delay
	await get_tree().create_timer(1.0).timeout
	start_match()

func start_match():
	game_started = true
	match_started.emit()
	
	# Spawn all players
	var main_scene = get_tree().current_scene
	var spawn_positions = [
		Vector2(200, 500),
		Vector2(400, 500),
		Vector2(600, 500)
	]
	
	for i in range(connected_players.size()):
		var player_data = connected_players[i]
		
		if player_data["is_ai"]:
			var ai_player = ai_player_scene.instantiate()
			ai_player.position = spawn_positions[i]
			ai_player.player_id = player_data["id"]
			ai_player.is_ai = true
			main_scene.add_child(ai_player)
```

### Step 3: Update MainMenu for Matchmaking

Update `MainMenu.gd` to add matchmaking button:

```gdscript
extends Control

func _ready():
	# Add matchmaking button
	var matchmaking_btn = Button.new()
	matchmaking_btn.text = "FIND MATCH (3 PLAYERS)"
	matchmaking_btn.custom_minimum_size = Vector2(300, 60)
	matchmaking_btn.position = Vector2(
		get_viewport_rect().size.x / 2 - 150,
		400
	)
	matchmaking_btn.pressed.connect(_on_matchmaking_pressed)
	add_child(matchmaking_btn)

func _on_matchmaking_pressed():
	var matchmaking = MatchmakingManager.new()
	add_child(matchmaking)
	matchmaking.match_started.connect(_on_match_started)
	matchmaking.find_match()

func _on_match_started():
	get_tree().change_scene_to_file("res://Main.tscn")
```

---

## Part 4: Improved Ship Designs

### Step 1: Enhanced Ship Visual Design

Update `Player.tscn` or create better ship graphics. Here's how to make ships look more like actual spaceships:

**In Godot Editor:**

1. **Open Player.tscn**
2. **Select the Spaceship node**
3. **Add more Polygon2D nodes for detail:**
   - Wings (left and right)
   - Cockpit
   - Engine glow
   - Weapons

### Step 2: Create Ship Design Script

Create `EnhancedShipDesign.gd`:

```gdscript
extends Node2D

@export var ship_color: Color = Color.CYAN
@export var glow_color: Color = Color.AQUA

func _ready():
	create_ship_geometry()

func create_ship_geometry():
	# Main body
	var body = Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(0, -40),
		Vector2(15, 0),
		Vector2(10, 20),
		Vector2(-10, 20),
		Vector2(-15, 0)
	])
	body.color = ship_color
	add_child(body)
	
	# Wings
	var left_wing = Polygon2D.new()
	left_wing.polygon = PackedVector2Array([
		Vector2(-15, -10),
		Vector2(-30, 10),
		Vector2(-15, 15)
	])
	left_wing.color = ship_color.darkened(0.2)
	add_child(left_wing)
	
	var right_wing = Polygon2D.new()
	right_wing.polygon = PackedVector2Array([
		Vector2(15, -10),
		Vector2(30, 10),
		Vector2(15, 15)
	])
	right_wing.color = ship_color.darkened(0.2)
	add_child(right_wing)
	
	# Cockpit
	var cockpit = Polygon2D.new()
	cockpit.polygon = PackedVector2Array([
		Vector2(0, -35),
		Vector2(8, -15),
		Vector2(-8, -15)
	])
	cockpit.color = glow_color
	add_child(cockpit)
	
	# Engine glow
	var engine = Polygon2D.new()
	engine.polygon = PackedVector2Array([
		Vector2(-8, 20),
		Vector2(-5, 30),
		Vector2(5, 30),
		Vector2(8, 20)
	])
	engine.color = Color(1, 0.5, 0, 0.8)
	add_child(engine)
	
	# Add glow effect
	var glow = PointLight2D.new()
	glow.position = Vector2(0, -20)
	glow.energy = 0.5
	glow.texture_scale = 2
	glow.color = glow_color
	add_child(glow)
```

---

## Implementation Steps

### Step 1: Add Scripts to Project
1. Open your project in Godot Engine
2. Create all the new script files mentioned above
3. Attach scripts to appropriate nodes

### Step 2: Update Autoload Singletons
1. Go to **Project > Project Settings > Autoload**
2. Add:
   - `OrientationManager.gd`
   - `MatchmakingManager.gd`

### Step 3: Update Main Scene
1. Add `EnhancedMobileControls` as a child of Main scene
2. Connect its signals to Player script

### Step 4: Test Changes
1. Run the game in Godot
2. Test on different screen orientations
3. Test matchmaking
4. Test AI players

### Step 5: Export for Web
1. Go to **Project > Export**
2. Select **HTML5**
3. Export the project
4. Upload to itch.io

---

## Quick Setup Checklist

- [ ] Create all new script files
- [ ] Add EnhancedMobileControls to UI
- [ ] Set up OrientationManager as autoload
- [ ] Set up MatchmakingManager as autoload  
- [ ] Create AIPlayer scene
- [ ] Update ship visuals
- [ ] Update MainMenu with matchmaking
- [ ] Test everything
- [ ] Export to HTML5
- [ ] Upload to itch.io

---

## Need Help?

If you need assistance implementing any of these features, let me know which part you're working on!
