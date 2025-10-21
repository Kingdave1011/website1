extends Node

# Wave System - Spawns enemies in waves with increasing difficulty

signal wave_started(wave_number)
signal wave_completed(wave_number)
signal all_waves_completed()
signal enemy_spawned(enemy)

# Wave configuration
@export var waves_enabled: bool = true
@export var time_between_waves: float = 5.0
@export var endless_mode: bool = false

# Current wave data
var current_wave: int = 0
var enemies_in_wave: int = 0
var enemies_remaining: int = 0
var wave_active: bool = false
var spawn_timer: float = 0.0

# Enemy scenes
var enemy_scene = preload("res://Enemy.tscn")
var spawn_positions: Array = []

# Wave configurations
const WAVE_DATA = {
	1: {
		"enemy_count": 5,
		"spawn_interval": 2.0,
		"enemy_health": 1,
		"enemy_speed": 100,
		"reward_multiplier": 1.0
	},
	2: {
		"enemy_count": 8,
		"spawn_interval": 1.5,
		"enemy_health": 2,
		"enemy_speed": 120,
		"reward_multiplier": 1.2
	},
	3: {
		"enemy_count": 10,
		"spawn_interval": 1.2,
		"enemy_health": 2,
		"enemy_speed": 140,
		"reward_multiplier": 1.5
	},
	4: {
		"enemy_count": 12,
		"spawn_interval": 1.0,
		"enemy_health": 3,
		"enemy_speed": 150,
		"reward_multiplier": 1.8
	},
	5: {
		"enemy_count": 15,
		"spawn_interval": 0.8,
		"enemy_health": 3,
		"enemy_speed": 170,
		"reward_multiplier": 2.0,
		"has_boss": true
	}
}

func _ready():
	# Setup default spawn positions (top of screen)
	var screen_width = get_viewport().get_visible_rect().size.x
	for i in range(5):
		var x_pos = (screen_width / 6) * (i + 1)
		spawn_positions.append(Vector2(x_pos, -50))

func _process(delta):
	if not wave_active or not waves_enabled:
		return
	
	# Handle enemy spawning
	if enemies_in_wave > 0:
		spawn_timer -= delta
		if spawn_timer <= 0:
			spawn_enemy()
			enemies_in_wave -= 1
			
			# Reset timer for next spawn
			var wave_data = get_wave_data(current_wave)
			spawn_timer = wave_data.spawn_interval

func start_next_wave():
	if wave_active:
		return
	
	current_wave += 1
	
	# Check if we have wave data
	var wave_data = get_wave_data(current_wave)
	if wave_data.is_empty() and not endless_mode:
		all_waves_completed.emit()
		return
	
	# Start the wave
	wave_active = true
	enemies_in_wave = wave_data.enemy_count
	enemies_remaining = wave_data.enemy_count
	spawn_timer = wave_data.spawn_interval
	
	wave_started.emit(current_wave)
	print("Wave ", current_wave, " started! Enemies: ", enemies_in_wave)

func spawn_enemy():
	if enemy_scene == null:
		return
	
	var enemy = enemy_scene.instantiate()
	
	# Set spawn position
	var spawn_pos = spawn_positions[randi() % spawn_positions.size()]
	enemy.position = spawn_pos
	
	# Apply wave modifiers
	var wave_data = get_wave_data(current_wave)
	if enemy.has_method("set_stats"):
		enemy.set_stats(wave_data.enemy_health, wave_data.enemy_speed)
	else:
		enemy.health = wave_data.enemy_health
		enemy.speed = wave_data.enemy_speed
	
	# Increase point value based on wave
	enemy.points_value = int(enemy.points_value * wave_data.reward_multiplier)
	
	# Connect to enemy death signal
	if enemy.has_signal("enemy_destroyed"):
		enemy.enemy_destroyed.connect(_on_enemy_destroyed)
	
	# Add to scene
	get_tree().current_scene.add_child(enemy)
	enemy_spawned.emit(enemy)

func _on_enemy_destroyed(_points):
	enemies_remaining -= 1
	
	if enemies_remaining <= 0 and enemies_in_wave <= 0:
		# Wave complete!
		complete_wave()

func complete_wave():
	wave_active = false
	wave_completed.emit(current_wave)
	print("Wave ", current_wave, " completed!")
	
	# Auto-start next wave after delay
	await get_tree().create_timer(time_between_waves).timeout
	start_next_wave()

func get_wave_data(wave_num: int) -> Dictionary:
	# Return predefined wave data if available
	if WAVE_DATA.has(wave_num):
		return WAVE_DATA[wave_num]
	
	# Generate procedural wave for endless mode
	if endless_mode:
		return generate_endless_wave(wave_num)
	
	return {}

func generate_endless_wave(wave_num: int) -> Dictionary:
	# Procedurally generate harder waves
	var base_multiplier = 1.0 + (wave_num * 0.15)
	
	return {
		"enemy_count": 5 + (wave_num * 2),
		"spawn_interval": max(0.3, 2.0 - (wave_num * 0.1)),
		"enemy_health": 1 + int(wave_num / 3),
		"enemy_speed": 100 + (wave_num * 10),
		"reward_multiplier": base_multiplier,
		"has_boss": (wave_num % 5 == 0)  # Boss every 5 waves
	}

func reset_waves():
	current_wave = 0
	wave_active = false
	enemies_in_wave = 0
	enemies_remaining = 0

func set_spawn_positions(positions: Array):
	spawn_positions = positions

func get_current_wave() -> int:
	return current_wave

func get_enemies_remaining() -> int:
	return enemies_remaining

func is_wave_active() -> bool:
	return wave_active
