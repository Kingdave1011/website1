# Spaceship Selection Screen
extends Control

# Ship Data Structure
class Ship:
	var id: int
	var name: String
	var speed: float
	var health: int
	var fire_rate: float
	var special_ability: String
	var sprite_path: String
	var color: Color
	
	func _init(p_id: int, p_name: String, p_speed: float, p_health: int, p_fire_rate: float, p_ability: String):
		id = p_id
		name = p_name
		speed = p_speed
		health = p_health
		fire_rate = p_fire_rate
		special_ability = p_ability
		color = Color.WHITE

# Available Ships
var ships: Array = []
var selected_ship_index: int = 0

# UI Elements
@onready var ship_preview = $ShipPreview
@onready var ship_name_label = $ShipInfo/ShipName
@onready var stats_label = $ShipInfo/Stats
@onready var ability_label = $ShipInfo/Ability
@onready var prev_button = $Buttons/PrevButton
@onready var next_button = $Buttons/NextButton
@onready var select_button = $Buttons/SelectButton

func _ready():
	setup_ships()
	connect_buttons()
	display_ship(0)

func setup_ships():
	# Ship 1: Fighter - Balanced
	ships.append(Ship.new(
		0,
		"Star Fighter",
		350.0,  # Speed
		100,    # Health
		0.25,   # Fire rate
		"Rapid Fire Burst - Hold shoot for 3x speed"
	))
	ships[0].color = Color.BLUE
	
	# Ship 2: Interceptor - Fast, Low Health
	ships.append(Ship.new(
		1,
		"Interceptor",
		500.0,  # Very fast
		60,     # Low health
		0.20,   # Fast fire
		"Speed Dash - Double tap direction for quick dash"
	))
	ships[1].color = Color.CYAN
	
	# Ship 3: Tank - Slow, High Health
	ships.append(Ship.new(
		2,
		"Heavy Cruiser",
		200.0,  # Slow
		200,    # High health
		0.35,   # Slow fire
		"Shield Boost - Press special for 3s invincibility"
	))
	ships[2].color = Color.GREEN
	
	# Ship 4: Sniper - Long Range
	ships.append(Ship.new(
		3,
		"Sniper Class",
		280.0,  # Medium speed
		80,     # Low-medium health
		0.50,   # Very slow fire
		"Piercing Shot - Bullets go through multiple enemies"
	))
	ships[3].color = Color.YELLOW
	
	# Ship 5: Assault - Spread Shots
	ships.append(Ship.new(
		4,
		"Assault Bomber",
		300.0,  # Medium speed
		120,    # Medium-high health
		0.30,   # Medium fire
		"Spread Shot - Fires 3 bullets at once"
	))
	ships[4].color = Color.RED

func connect_buttons():
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	select_button.pressed.connect(_on_select_pressed)

func display_ship(index: int):
	selected_ship_index = index
	var ship = ships[index]
	
	# Update ship name
	ship_name_label.text = ship.name
	
	# Update stats
	stats_label.text = "STATS:\n"
	stats_label.text += "Speed: " + str(ship.speed) + "\n"
	stats_label.text += "Health: " + str(ship.health) + "\n"
	stats_label.text += "Fire Rate: " + str(1.0 / ship.fire_rate) + " shots/sec\n"
	
	# Update ability
	ability_label.text = "SPECIAL ABILITY:\n" + ship.special_ability
	
	# Update preview visual
	if ship_preview:
		ship_preview.modulate = ship.color
		# Add rotation animation
		var tween = create_tween()
		tween.tween_property(ship_preview, "rotation_degrees", 360, 2.0).from(0)
		tween.set_loops()

func _on_prev_pressed():
	var new_index = selected_ship_index - 1
	if new_index < 0:
		new_index = ships.size() - 1
	display_ship(new_index)
	play_ui_sound()

func _on_next_pressed():
	var new_index = selected_ship_index + 1
	if new_index >= ships.size():
		new_index = 0
	display_ship(new_index)
	play_ui_sound()

func _on_select_pressed():
	# Save selected ship data
	var ship = ships[selected_ship_index]
	save_ship_selection(ship)
	
	# Transition to game or lobby
	if multiplayer.is_server() or multiplayer.get_peers().size() > 0:
		# Multiplayer - go to lobby
		get_tree().change_scene_to_file("res://Lobby.tscn")
	else:
		# Single player - start game
		get_tree().change_scene_to_file("res://Main.tscn")

func save_ship_selection(ship: Ship):
	# Save to GameData singleton
	if has_node("/root/GameData"):
		var game_data = get_node("/root/GameData")
		game_data.selected_ship_id = ship.id
		game_data.selected_ship_name = ship.name
		game_data.selected_ship_stats = {
			"speed": ship.speed,
			"health": ship.health,
			"fire_rate": ship.fire_rate,
			"ability": ship.special_ability
		}

func play_ui_sound():
	# Play selection sound if you have one
	if has_node("AudioStreamPlayer"):
		$AudioStreamPlayer.play()

# Keyboard navigation
func _input(event):
	if event.is_action_pressed("ui_left"):
		_on_prev_pressed()
	elif event.is_action_pressed("ui_right"):
		_on_next_pressed()
	elif event.is_action_pressed("ui_accept"):
		_on_select_pressed()


# ============================================
# SHIP SELECTION SCENE STRUCTURE
# ============================================
"""
ShipSelection (Control)
├── Background (ColorRect or Sprite)
├── Title (Label)
│   └── Text: "SELECT YOUR SHIP"
├── ShipPreview (Sprite2D)
│   └── Shows selected ship with rotation
├── ShipInfo (VBoxContainer)
│   ├── ShipName (Label)
│   ├── Stats (Label)
│   └── Ability (Label)
├── Buttons (HBoxContainer)
│   ├── PrevButton (Button) "< PREVIOUS"
│   ├── SelectButton (Button) "SELECT"
│   └── NextButton (Button) "NEXT >"
└── AudioStreamPlayer (for UI sounds)
"""

# ============================================
# SCENE SETUP IN GODOT
# ============================================
"""
1. Create new scene: ShipSelection.tscn
2. Root node: Control (full rect)
3. Add child nodes as shown above
4. Attach this script to root
5. Configure button signals (or use code connections)
6. Add ship preview sprite (will be colored automatically)
7. Style with your theme

Suggested Layout:
- Title: Top center (size 48, bold)
- Ship Preview: Center (256x256)
- Stats: Right side panel
- Buttons: Bottom center
- Background: Space theme
"""
