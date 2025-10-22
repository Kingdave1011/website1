# Space Station Map - Tactical combat near orbital station
extends Node2D

var enemy_scene = preload("res://Enemy.tscn")

func _ready():
	# Connect timer
	$SpawnTimer.timeout.connect(_spawn_enemy)
	
	# Spawn moderate number of initial enemies
	for i in range(4):
		_spawn_enemy()

func _spawn_enemy():
	var enemy = enemy_scene.instantiate()
	# Spawn from sides and top for tactical positioning
	var spawn_side = randi() % 3
	match spawn_side:
		0:  # Top
			enemy.position = Vector2(randf_range(100, 1180), -50)
		1:  # Left side
			enemy.position = Vector2(50, randf_range(100, 620))
		2:  # Right side
			enemy.position = Vector2(1230, randf_range(100, 620))
	
	$EnemySpawner.add_child(enemy)
