extends Node2D

# Debris Field Map - Dense field of ship wreckage and debris
# Theme: Dark red/orange, destroyed ships, space junk
# Difficulty: Hard
# Features: Dense obstacles, wreckage everywhere, claustrophobic combat

func _ready():
	_setup_background()
	_add_debris_particles()
	_add_wreckage_obstacles()

func _setup_background():
	# Create parallax background with debris/destruction theme
	var parallax = ParallaxBackground.new()
	add_child(parallax)
	
	# Main dark background layer
	var layer = ParallaxLayer.new()
	layer.motion_scale = Vector2(0.5, 0.5)
	parallax.add_child(layer)
	
	var sprite = Sprite2D.new()
	sprite.texture = load("res://kenney_space-shooter-redux/Backgrounds/black.png")
	sprite.centered = false
	sprite.modulate = Color(0.8, 0.5, 0.4, 1.0)  # Dark red/orange tint
	layer.add_child(sprite)
	
	# Add dim star layer
	var star_layer = ParallaxLayer.new()
	star_layer.motion_scale = Vector2(0.3, 0.3)
	parallax.add_child(star_layer)
	
	var stars = Sprite2D.new()
	stars.texture = load("res://kenney_space-shooter-redux/Backgrounds/black.png")
	stars.centered = false
	stars.modulate = Color(1.0, 0.6, 0.4, 0.2)  # Dim orange stars
	star_layer.add_child(stars)

func _add_debris_particles():
	# Dense debris particles
	var debris = CPUParticles2D.new()
	debris.position = Vector2(640, 360)
	debris.emitting = true
	debris.amount = 80
	debris.lifetime = 30.0
	debris.preprocess = 15.0
	
	# Debris appearance
	debris.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	debris.emission_rect_extents = Vector2(700, 400)
	
	# Dark red/orange/brown debris color
	var debris_gradient = Gradient.new()
	debris_gradient.add_point(0.0, Color(0.6, 0.3, 0.2, 0.9))  # Dark red-brown
	debris_gradient.add_point(0.5, Color(0.7, 0.4, 0.2, 0.7))  # Rust orange
	debris_gradient.add_point(1.0, Color(0.4, 0.2, 0.1, 0.4))  # Dark brown
	debris.color_ramp = debris_gradient
	
	# Varied sizes for debris chunks
	debris.scale_amount_min = 2.0
	debris.scale_amount_max = 6.0
	
	# Slow floating movement
	debris.direction = Vector2(1, 0.5)
	debris.spread = 30.0
	debris.gravity = Vector2(3, 2)
	debris.initial_velocity_min = 3.0
	debris.initial_velocity_max = 10.0
	
	add_child(debris)
	
	# Add sparks/fire particles
	var sparks = CPUParticles2D.new()
	sparks.position = Vector2(640, 360)
	sparks.emitting = true
	sparks.amount = 50
	sparks.lifetime = 10.0
	sparks.preprocess = 5.0
	
	sparks.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	sparks.emission_rect_extents = Vector2(700, 400)
	
	# Orange/red spark color
	var spark_gradient = Gradient.new()
	spark_gradient.add_point(0.0, Color(1.0, 0.6, 0.2, 1.0))  # Bright orange
	spark_gradient.add_point(0.5, Color(1.0, 0.4, 0.1, 0.6))  # Orange-red
	spark_gradient.add_point(1.0, Color(0.8, 0.2, 0.0, 0.2))  # Dark red
	sparks.color_ramp = spark_gradient
	
	sparks.scale_amount_min = 1.0
	sparks.scale_amount_max = 3.0
	
	sparks.direction = Vector2(0, -1)
	sparks.spread = 180.0
	sparks.gravity = Vector2(0, 5)
	sparks.initial_velocity_min = 10.0
	sparks.initial_velocity_max = 30.0
	
	add_child(sparks)

func _add_wreckage_obstacles():
	# Add dense wreckage obstacles
	var obstacle_count = 25  # More obstacles for hard difficulty
	
	for i in range(obstacle_count):
		var obstacle = Sprite2D.new()
		
		# Use various meteor and damage sprites as wreckage
		var wreckage_types = [
			"res://kenney_space-shooter-redux/PNG/Meteors/meteorBrown_big1.png",
			"res://kenney_space-shooter-redux/PNG/Meteors/meteorBrown_big2.png",
			"res://kenney_space-shooter-redux/PNG/Meteors/meteorBrown_big3.png",
			"res://kenney_space-shooter-redux/PNG/Meteors/meteorBrown_med1.png",
			"res://kenney_space-shooter-redux/PNG/Meteors/meteorGrey_big1.png",
			"res://kenney_space-shooter-redux/PNG/Meteors/meteorGrey_big2.png",
			"res://kenney_space-shooter-redux/PNG/Meteors/meteorGrey_med1.png",
			"res://kenney_space-shooter-redux/PNG/Meteors/meteorGrey_med2.png"
		]
		
		obstacle.texture = load(wreckage_types[randi() % wreckage_types.size()])
		obstacle.modulate = Color(0.7, 0.4, 0.3, 1.0)  # Dark red-brown tint for burnt wreckage
		
		# Random position avoiding center spawn area
		var pos = Vector2(
			randf_range(50, 1230),
			randf_range(50, 670)
		)
		
		# Keep center area clear but smaller than other maps (harder difficulty)
		if pos.distance_to(Vector2(640, 360)) < 150:
			pos = pos.normalized() * 180 + Vector2(640, 360)
		
		obstacle.position = pos
		obstacle.rotation = randf_range(0, TAU)
		obstacle.scale = Vector2(0.9, 0.9) * randf_range(0.6, 1.4)
		
		add_child(obstacle)

func get_map_info():
	return {
		"name": "Debris Field",
		"description": "Dense field of ship wreckage and space debris",
		"difficulty": "Hard",
		"theme": "destruction",
		"spawn_positions": [
			Vector2(640, 360),  # Center
			Vector2(400, 360),  # Left
			Vector2(880, 360),  # Right
			Vector2(640, 240)   # Top
		]
	}
