extends Node

# Map definitions with all 7 arenas
const MAPS = {
	"asteroid_field": {
		"name": "Asteroid Field",
		"description": "Navigate through dangerous asteroid fields",
		"scene_path": "res://maps/AsteroidField.tscn",
		"difficulty": "Medium",
		"max_players": 8
	},
	"nebula_cloud": {
		"name": "Nebula Cloud",
		"description": "Battle in a mysterious blue nebula",
		"scene_path": "res://maps/NebulaCloud.tscn",
		"difficulty": "Easy",
		"max_players": 8
	},
	"asteroid_belt": {
		"name": "Asteroid Belt",
		"description": "Intense combat in dense asteroid field",
		"scene_path": "res://maps/AsteroidBelt.tscn",
		"difficulty": "Hard",
		"max_players": 6
	},
	"space_station": {
		"name": "Space Station",
		"description": "Tactical combat near orbital station",
		"scene_path": "res://maps/SpaceStation.tscn",
		"difficulty": "Medium",
		"max_players": 8
	},
	"deep_space": {
		"name": "Deep Space",
		"description": "Combat in the void of deep space",
		"scene_path": "res://maps/DeepSpace.tscn",
		"difficulty": "Easy",
		"max_players": 8
	},
	"ice_field": {
		"name": "Ice Field",
		"description": "Frozen asteroid field with icy obstacles",
		"scene_path": "res://maps/IceField.tscn",
		"difficulty": "Medium",
		"max_players": 8
	},
	"debris_field": {
		"name": "Debris Field",
		"description": "Dense field of ship wreckage and space debris",
		"scene_path": "res://maps/DebrisField.tscn",
		"difficulty": "Hard",
		"max_players": 6
	}
}

var current_map_id: String = "asteroid_field"
var selected_map: Dictionary = {}

func _ready():
	selected_map = MAPS[current_map_id]

func get_all_maps() -> Dictionary:
	return MAPS

func get_map(map_id: String) -> Dictionary:
	return MAPS.get(map_id, {})

func set_current_map(map_id: String) -> bool:
	if MAPS.has(map_id):
		current_map_id = map_id
		selected_map = MAPS[map_id]
		return true
	return false

func get_current_map() -> Dictionary:
	return selected_map

func load_current_map():
	if selected_map.has("scene_path"):
		get_tree().change_scene_to_file(selected_map["scene_path"])
