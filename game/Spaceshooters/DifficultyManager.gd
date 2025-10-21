extends Node

# Difficulty Manager - Global difficulty settings
enum Difficulty {
	EASY,
	NORMAL,
	HARD,
	INSANE
}

var current_difficulty: Difficulty = Difficulty.NORMAL

# Difficulty settings
var difficulty_settings = {
	Difficulty.EASY: {
		"name": "Easy",
		"description": "Relaxed gameplay, perfect for beginners",
		"enemy_health_multiplier": 0.7,
		"enemy_speed_multiplier": 0.8,
		"enemy_shoot_rate_multiplier": 1.5,  # Slower shooting
		"spawn_rate_multiplier": 1.3,  # Slower spawning
		"player_health": 5,
		"enemy_damage": 1,
		"score_multiplier": 0.8
	},
	Difficulty.NORMAL: {
		"name": "Normal",
		"description": "Balanced challenge for most players",
		"enemy_health_multiplier": 1.0,
		"enemy_speed_multiplier": 1.0,
		"enemy_shoot_rate_multiplier": 1.0,
		"spawn_rate_multiplier": 1.0,
		"player_health": 3,
		"enemy_damage": 1,
		"score_multiplier": 1.0
	},
	Difficulty.HARD: {
		"name": "Hard",
		"description": "Intense combat for experienced pilots",
		"enemy_health_multiplier": 1.3,
		"enemy_speed_multiplier": 1.3,
		"enemy_shoot_rate_multiplier": 0.7,  # Faster shooting
		"spawn_rate_multiplier": 0.8,  # Faster spawning
		"player_health": 2,
		"enemy_damage": 1,
		"score_multiplier": 1.5
	},
	Difficulty.INSANE: {
		"name": "Insane",
		"description": "Brutal difficulty for masters only!",
		"enemy_health_multiplier": 1.5,
		"enemy_speed_multiplier": 1.5,
		"enemy_shoot_rate_multiplier": 0.5,  # Much faster shooting
		"spawn_rate_multiplier": 0.6,  # Much faster spawning
		"player_health": 1,
		"enemy_damage": 2,
		"score_multiplier": 2.0
	}
}

func set_difficulty(difficulty: Difficulty):
	current_difficulty = difficulty
	print("Difficulty set to: ", difficulty_settings[difficulty]["name"])

func get_difficulty_name() -> String:
	return difficulty_settings[current_difficulty]["name"]

func get_difficulty_description() -> String:
	return difficulty_settings[current_difficulty]["description"]

func get_setting(setting_name: String):
	return difficulty_settings[current_difficulty][setting_name]

func get_all_difficulties() -> Array:
	return [
		{"id": Difficulty.EASY, "name": "Easy", "description": difficulty_settings[Difficulty.EASY]["description"]},
		{"id": Difficulty.NORMAL, "name": "Normal", "description": difficulty_settings[Difficulty.NORMAL]["description"]},
		{"id": Difficulty.HARD, "name": "Hard", "description": difficulty_settings[Difficulty.HARD]["description"]},
		{"id": Difficulty.INSANE, "name": "Insane", "description": difficulty_settings[Difficulty.INSANE]["description"]}
	]
