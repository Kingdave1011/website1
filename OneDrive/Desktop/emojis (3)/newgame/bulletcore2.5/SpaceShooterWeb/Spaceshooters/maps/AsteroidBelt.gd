# Asteroid Belt Map - Hard difficulty with dense asteroids
extends Node2D

var asteroid_scene = preload("res://Enemy.tscn")
var enemy_scene = preload("res://Enemy.tscn")

func _ready():
	# Connect timers
	$SpawnTimer.timeout.connect(_spawn_enemy)
	$AsteroidTimer.timeout.connect(_spawn_asteroid)
	
	# Spawn many initial asteroids for dense field
	for i in range(15):
		_spawn_asteroid()

func _spawn_asteroid():
	var asteroid = asteroid_scene.instantiate()
	asteroid.position = Vector2(randf_range(50, 1230), randf_range(-100, -50))
	asteroid.rotation = randf_range(0, TAU)
	$Asteroids.add_child(asteroid)

func _spawn_enemy():
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(randf_range(100, 1180), -50)
	$EnemySpawner.add_child(enemy)
