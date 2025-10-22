# Nebula Cloud Map
extends Node2D

var enemy_scene = preload("res://Enemy.tscn")

func _ready():
	# Connect timer
	$SpawnTimer.timeout.connect(_spawn_enemy)
	
	# Spawn initial enemies
	for i in range(3):
		_spawn_enemy()

func _spawn_enemy():
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(randf_range(100, 1180), -50)
	$EnemySpawner.add_child(enemy)
