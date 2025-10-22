extends Node

# Game state
var score: int = 0
var game_over: bool = false
var spawn_timer: float = 0.0
var spawn_interval: float = 1.5

# Halloween event
var halloween_active: bool = false
var halloween_spawn_chance: float = 0.2  # 20% chance for Halloween enemies

# Star background
var stars: Array = []
var num_stars: int = 100

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
	
	# Check if Halloween event is active (October)
	check_halloween_event()
	
	# Generate star background
	generate_star_background()

func _process(delta):
	if game_over:
		return
	
	# Animate star background
	animate_stars(delta)
	
	# Spawn enemies
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_enemy()
		spawn_timer = 0.0
		
		# Gradually increase difficulty
		spawn_interval = max(0.5, spawn_interval - 0.01)

func check_halloween_event():
	# Check if current month is October
	var date = Time.get_datetime_dict_from_system()
	halloween_active = (date["month"] == 10)
	
	if halloween_active:
		print("🎃 Halloween Event Active! 🎃")

func generate_star_background():
	var viewport_size = get_viewport().get_visible_rect().size
	
	for i in range(num_stars):
		var star = {
			"position": Vector2(randf() * viewport_size.x, randf() * viewport_size.y),
			"speed": randf_range(20, 80),
			"size": randf_range(1, 3)
		}
		stars.append(star)

func animate_stars(delta):
	var viewport_size = get_viewport().get_visible_rect().size
	
	for star in stars:
		star["position"].y += star["speed"] * delta
		
		# Reset star to top when it goes off screen
		if star["position"].y > viewport_size.y:
			star["position"].y = 0
			star["position"].x = randf() * viewport_size.x
	
	queue_redraw()

func _draw():
	# Draw animated star background
	for star in stars:
		var alpha = star["size"] / 3.0
		draw_circle(star["position"], star["size"], Color(1, 1, 1, alpha))

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	
	# Random horizontal position
	var spawn_x = randf_range(50, get_viewport().get_visible_rect().size.x - 50)
	enemy.position = Vector2(spawn_x, -50)
	
	# Halloween special enemies
	if halloween_active and randf() < halloween_spawn_chance:
		apply_halloween_theme(enemy)
	
	# Connect enemy signal
	enemy.enemy_destroyed.connect(_on_enemy_destroyed)
	
	add_child(enemy)

func apply_halloween_theme(enemy):
	# Make enemy orange/pumpkin colored
	enemy.modulate = Color(1.0, 0.5, 0.0)
	# Increase points for Halloween enemies
	if enemy.has_method("set_points"):
		enemy.set_points(enemy.points * 2)

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
