extends Node

# Game state
var score: int = 0
var game_over: bool = false
var spawn_timer: float = 0.0
var spawn_interval: float = 1.5

# References
var enemy_scene = preload("res://Enemy.tscn")
@onready var player = $Player
@onready var ui = $UI

# Signals
signal score_changed(new_score)
signal game_ended

func _ready():
	# Connect player signals
	if player:
		player.health_changed.connect(_on_player_health_changed)
		player.player_died.connect(_on_player_died)

func _process(delta):
	if game_over:
		return
	
	# Spawn enemies
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_enemy()
		spawn_timer = 0.0
		
		# Gradually increase difficulty
		spawn_interval = max(0.5, spawn_interval - 0.01)

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	
	# Random horizontal position
	var spawn_x = randf_range(50, get_viewport().get_visible_rect().size.x - 50)
	enemy.position = Vector2(spawn_x, -50)
	
	# Connect enemy signal
	enemy.enemy_destroyed.connect(_on_enemy_destroyed)
	
	add_child(enemy)

func _on_enemy_destroyed(points: int):
	score += points
	score_changed.emit(score)
	ui.update_score(score)
	
	# Update high score for ship unlocks
	ShipData.update_high_score(score)

func _on_player_health_changed(new_health: int):
	ui.update_health(new_health)

func _on_player_died():
	game_over = true
	game_ended.emit()
	
	# Final high score update
	ShipData.update_high_score(score)
	
	ui.show_game_over(score)

func restart_game():
	get_tree().reload_current_scene()

func _input(event):
	if game_over and Input.is_action_just_pressed("restart"):
		restart_game()
