extends Node

# Game state
var score: int = 0
var game_over: bool = false
var paused: bool = false
var spawn_timer: float = 0.0
var spawn_interval: float = 1.5
var current_wave: int = 1
var enemies_in_wave: int = 10
var enemies_spawned: int = 0
var game_time: float = 0.0

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
	if game_over or paused:
		return
	
	# Update game time
	game_time += delta
	ui.update_timer(game_time)
	
	# Spawn enemies for current wave
	if enemies_spawned < enemies_in_wave:
		spawn_timer += delta
		if spawn_timer >= spawn_interval:
			spawn_enemy()
			spawn_timer = 0.0
			enemies_spawned += 1
	else:
		# Check if wave is complete
		if get_tree().get_nodes_in_group("enemy").size() == 0:
			start_next_wave()

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

func _on_player_health_changed(new_health: int):
	ui.update_health(new_health)

func _on_player_died():
	game_over = true
	game_ended.emit()
	ui.show_game_over(score)

func restart_game():
	get_tree().reload_current_scene()

func _input(event):
	# ESC key for pause/quit
	if Input.is_action_just_pressed("ui_cancel") and not game_over:
		toggle_pause()
	
	if game_over and Input.is_action_just_pressed("restart"):
		restart_game()

func toggle_pause():
	paused = !paused
	get_tree().paused = paused
	ui.show_pause_menu(paused)

func start_next_wave():
	current_wave += 1
	enemies_in_wave = current_wave * 10 + 5
	enemies_spawned = 0
	spawn_interval = max(0.3, 1.5 - (current_wave * 0.1))
	ui.show_wave_transition(current_wave)
