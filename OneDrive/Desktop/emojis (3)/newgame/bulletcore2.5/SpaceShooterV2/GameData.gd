extends Node

# Game progression data
var current_level: int = 1
var lives: int = 3
var score: int = 0
var max_lives: int = 3

# Level configuration
const LEVEL_NAMES = [
	"Asteroid Belt",
	"Nebula Clouds",
	"Alien Ruins",
	"Crystal Caverns",
	"Derelict Space Station",
	"Black Hole Edge",
	"Frozen Comet Fields",
	"Volcanic Planet Orbit",
	"Galactic Core",
	"Final Boss Arena"
]

# Enemy configurations per level
const ENEMY_CONFIGS = {
	1: {"types": ["basic"], "spawn_rate": 1.5, "speed_mult": 1.0},
	2: {"types": ["basic", "shielded"], "spawn_rate": 1.3, "speed_mult": 1.2},
	3: {"types": ["basic", "swarm"], "spawn_rate": 1.0, "speed_mult": 1.3},
	4: {"types": ["basic", "shielded", "swarm"], "spawn_rate": 0.9, "speed_mult": 1.4},
	5: {"types": ["advanced", "shielded"], "spawn_rate": 0.8, "speed_mult": 1.5},
	6: {"types": ["advanced", "swarm"], "spawn_rate": 0.7, "speed_mult": 1.6},
	7: {"types": ["elite", "advanced"], "spawn_rate": 0.6, "speed_mult": 1.7},
	8: {"types": ["elite", "shielded"], "spawn_rate": 0.5, "speed_mult": 1.8},
	9: {"types": ["elite", "advanced", "swarm"], "spawn_rate": 0.4, "speed_mult": 2.0},
	10: {"types": ["boss"], "spawn_rate": 999.0, "speed_mult": 2.5}
}

# Signals
signal lives_changed(new_lives)
signal level_changed(new_level)
signal game_over

func _ready():
	reset_game()

func reset_game():
	lives = max_lives
	score = 0
	current_level = 1

func lose_life():
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		game_over.emit()
	
func gain_life():
	if lives < max_lives:
		lives += 1
		lives_changed.emit(lives)

func add_score(points: int):
	score += points

func next_level():
	if current_level < 10:
		current_level += 1
		level_changed.emit(current_level)
		return true
	return false

func get_level_name() -> String:
	if current_level <= LEVEL_NAMES.size():
		return LEVEL_NAMES[current_level - 1]
	return "Unknown Level"

func get_enemy_config() -> Dictionary:
	return ENEMY_CONFIGS.get(current_level, ENEMY_CONFIGS[1])
