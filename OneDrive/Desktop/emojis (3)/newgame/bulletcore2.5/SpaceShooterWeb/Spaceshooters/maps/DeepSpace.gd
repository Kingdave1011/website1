# Deep Space Map - Minimal obstacles, pure combat focus
extends Node2D

var enemy_scene = preload("res://Enemy.tscn")

func _ready():
	# Connect timer
	$SpawnTimer.timeout.connect(_spawn_enemy)
	
	# Spawn fewer initial enemies for open combat
	for i in range(2):
		_spawn_enemy()

func _spawn_enemy():
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(randf_range(200, 1080), -50)
	$EnemySpawner.add_child(enemy)
