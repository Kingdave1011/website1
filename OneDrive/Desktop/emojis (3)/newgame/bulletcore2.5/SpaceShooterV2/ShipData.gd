extends Node

# Ship configurations and unlock system

# Ship definitions
const SHIPS = {
	"starter": {
		"name": "Vanguard",
		"description": "Balanced starter ship",
		"speed": 400.0,
		"fire_rate": 0.2,
		"health": 3,
		"unlock_requirement": 0,  # Always unlocked
		"fire_mode": "normal",
		"color_primary": Color(0.25, 0.65, 0.95),
		"color_secondary": Color(0.15, 0.45, 0.75)
	},
	"speed": {
		"name": "Interceptor",
		"description": "Fast and agile - Beam Laser",
		"speed": 550.0,
		"fire_rate": 0.15,
		"health": 2,
		"unlock_requirement": 500,  # Unlock at 500 score
		"fire_mode": "beam",
		"color_primary": Color(0.9, 0.3, 0.9),
		"color_secondary": Color(0.7, 0.2, 0.7)
	},
	"tank": {
		"name": "Fortress",
		"description": "Heavy armor - Shotgun Spread",
		"speed": 300.0,
		"fire_rate": 0.25,
		"health": 5,
		"unlock_requirement": 1000,  # Unlock at 1000 score
		"fire_mode": "shotgun",
		"color_primary": Color(0.9, 0.6, 0.2),
		"color_secondary": Color(0.7, 0.4, 0.1)
	},
	"rapid": {
		"name": "Stinger",
		"description": "Rapid fire specialist",
		"speed": 420.0,
		"fire_rate": 0.1,
		"health": 3,
		"unlock_requirement": 2000,  # Unlock at 2000 score
		"fire_mode": "normal",
		"color_primary": Color(0.2, 0.9, 0.3),
		"color_secondary": Color(0.1, 0.7, 0.2)
	},
	"elite": {
		"name": "Phoenix",
		"description": "Ultimate warship - Charge Cannon",
		"speed": 480.0,
		"fire_rate": 0.12,
		"health": 4,
		"unlock_requirement": 5000,  # Unlock at 5000 score
		"fire_mode": "charge",
		"color_primary": Color(1, 0.3, 0.2),
		"color_secondary": Color(0.8, 0.2, 0.1)
	}
}

# Player save data
var unlocked_ships = ["starter"]  # Starter ship always unlocked
var selected_ship = "starter"
var high_score = 0

func _ready():
	load_progress()

func get_ship_config(ship_id: String) -> Dictionary:
	return SHIPS.get(ship_id, SHIPS["starter"])

func is_ship_unlocked(ship_id: String) -> bool:
	return ship_id in unlocked_ships

func select_ship(ship_id: String) -> bool:
	if is_ship_unlocked(ship_id):
		selected_ship = ship_id
		save_progress()
		return true
	return false

func check_unlocks(score: int):
	# Check if any new ships should be unlocked based on score
	for ship_id in SHIPS.keys():
		if not is_ship_unlocked(ship_id):
			if score >= SHIPS[ship_id]["unlock_requirement"]:
				unlock_ship(ship_id)

func unlock_ship(ship_id: String):
	if not is_ship_unlocked(ship_id):
		unlocked_ships.append(ship_id)
		save_progress()

func update_high_score(score: int):
	if score > high_score:
		high_score = score
		check_unlocks(score)
		save_progress()

func save_progress():
	var save_data = {
		"unlocked_ships": unlocked_ships,
		"selected_ship": selected_ship,
		"high_score": high_score
	}
	var file = FileAccess.open("user://ship_progress.save", FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()

func load_progress():
	if FileAccess.file_exists("user://ship_progress.save"):
		var file = FileAccess.open("user://ship_progress.save", FileAccess.READ)
		if file:
			var save_data = file.get_var()
			file.close()
			
			unlocked_ships = save_data.get("unlocked_ships", ["starter"])
			selected_ship = save_data.get("selected_ship", "starter")
			high_score = save_data.get("high_score", 0)
	else:
		# First time playing - set defaults
		unlocked_ships = ["starter"]
		selected_ship = "starter"
		high_score = 0
