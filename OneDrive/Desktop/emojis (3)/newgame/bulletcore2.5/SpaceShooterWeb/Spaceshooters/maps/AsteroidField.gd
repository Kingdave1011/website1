# Asteroid Field Map - Enhanced with visual elements and music
extends Node2D

var asteroid_scene = preload("res://Enemy.tscn")
var enemy_scene = preload("res://Enemy.tscn")
var background_music: AudioStreamPlayer

func _ready():
	# Setup music
	_setup_map_music()
	
	# Connect timers
	$SpawnTimer.timeout.connect(_spawn_enemy)
	$AsteroidTimer.timeout.connect(_spawn_asteroid)
	
	# Add visual enhancements
	_add_ambient_glow()
	_add_space_dust()
	
	# Spawn initial asteroids
	for i in range(10):
		_spawn_asteroid()

func _setup_map_music():
	background_music = AudioStreamPlayer.new()
	background_music.name = "MapMusic"
	
	# Try to load Asteroid Field theme music
	var music_stream = load("res://sounds/dreams.mp3")
	if music_stream:
		background_music.stream = music_stream
		background_music.volume_db = -10
		background_music.autoplay = true
		background_music.bus = "Master"
		add_child(background_music)
		background_music.play()
	
	print("Asteroid Field music loaded")

func _add_ambient_glow():
	# Add glowing particles for atmospheric lighting
	var glow = CPUParticles2D.new()
	glow.name = "AmbientGlow"
	glow.amount = 40
	glow.lifetime = 30.0
	glow.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	glow.emission_sphere_radius = 500.0
	glow.position = Vector2(640, 360)
	glow.direction = Vector2(0, 0)
	glow.spread = 180
	glow.gravity = Vector2(0, 0)
	glow.initial_velocity_min = 2.0
	glow.initial_velocity_max = 5.0
	glow.scale_amount_min = 0.8
	glow.scale_amount_max = 1.5
	glow.color = Color(0.7, 0.5, 1.0, 0.3)  # Purple glow
	add_child(glow)

func _add_space_dust():
	# Add space dust particles
	var dust = CPUParticles2D.new()
	dust.name = "SpaceDust"
	dust.amount = 200
	dust.lifetime = 20.0
	dust.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	dust.emission_rect_extents = Vector2(640, 360)
	dust.position = Vector2(640, 360)
	dust.direction = Vector2(0, 1)
	dust.spread = 20
	dust.gravity = Vector2(0, 10)
	dust.initial_velocity_min = 5.0
	dust.initial_velocity_max = 15.0
	dust.scale_amount_min = 0.2
	dust.scale_amount_max = 0.5
	dust.color = Color(1, 1, 1, 0.4)
	add_child(dust)

func _spawn_asteroid():
	var asteroid = asteroid_scene.instantiate()
	asteroid.position = Vector2(randf_range(50, 1230), -50)
	asteroid.rotation = randf_range(0, TAU)
	$Asteroids.add_child(asteroid)

func _spawn_enemy():
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(randf_range(100, 1180), -50)
	$EnemySpawner.add_child(enemy)
