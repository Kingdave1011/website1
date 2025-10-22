extends Node2D

# Ice Field Map - Frozen asteroid field with icy obstacles
# Theme: Cyan/white ice crystals, frozen asteroids
# Difficulty: Medium
# Features: Slippery movement zones, ice obstacles

func _ready():
	_setup_background()
	_add_ice_particles()
	_add_frozen_obstacles()

func _setup_background():
	# Create parallax background with ice theme
	var parallax = ParallaxBackground.new()
	add_child(parallax)
	
	# Main ice background layer
	var layer = ParallaxLayer.new()
	layer.motion_scale = Vector2(0.5, 0.5)
	parallax.add_child(layer)
	
	var sprite = Sprite2D.new()
	sprite.texture = load("res://kenney_space-shooter-redux/Backgrounds/blue.png")
	sprite.centered = false
	sprite.modulate = Color(0.7, 0.9, 1.0, 1.0)  # Cyan tint for ice
	layer.add_child(sprite)
	
	# Add star layer
	var star_layer = ParallaxLayer.new()
	star_layer.motion_scale = Vector2(0.3, 0.3)
	parallax.add_child(star_layer)
	
	var stars = Sprite2D.new()
	stars.texture = load("res://kenney_space-shooter-redux/Backgrounds/blue.png")
	stars.centered = false
	stars.modulate = Color(1.0, 1.0, 1.0, 0.3)
	star_layer.add_child(stars)

func _add_ice_particles():
	# Cyan ice crystal particles
	var ice_crystals = CPUParticles2D.new()
	ice_crystals.position = Vector2(640, 360)
	ice_crystals.emitting = true
	ice_crystals.amount = 30
	ice_crystals.lifetime = 25.0
	ice_crystals.preprocess = 10.0
	
	# Ice crystal appearance
	ice_crystals.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	ice_crystals.emission_rect_extents = Vector2(700, 400)
	
	# Ice crystal color (cyan/white)
	var cyan_gradient = Gradient.new()
	cyan_gradient.add_point(0.0, Color(0.3, 0.8, 1.0, 0.8))  # Bright cyan
	cyan_gradient.add_point(0.5, Color(0.6, 0.9, 1.0, 0.6))  # Light cyan
	cyan_gradient.add_point(1.0, Color(0.9, 0.95, 1.0, 0.3)) # Almost white
	ice_crystals.color_ramp = cyan_gradient
	
	# Scale variation for ice crystals
	ice_crystals.scale_amount_min = 3.0
	ice_crystals.scale_amount_max = 8.0
	
	# Slow floating movement
	ice_crystals.direction = Vector2(0, 1)
	ice_crystals.spread = 20.0
	ice_crystals.gravity = Vector2(0, 5)
	ice_crystals.initial_velocity_min = 5.0
	ice_crystals.initial_velocity_max = 15.0
	
	add_child(ice_crystals)
	
	# Add smaller sparkle particles
	var sparkles = CPUParticles2D.new()
	sparkles.position = Vector2(640, 360)
	sparkles.emitting = true
	sparkles.amount = 100
	sparkles.lifetime = 15.0
	sparkles.preprocess = 5.0
	
	sparkles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	sparkles.emission_rect_extents = Vector2(700, 400)
	
	# White sparkle color
	var sparkle_gradient = Gradient.new()
	sparkle_gradient.add_point(0.0, Color(1.0, 1.0, 1.0, 1.0))
	sparkle_gradient.add_point(1.0, Color(0.8, 0.95, 1.0, 0.2))
	sparkles.color_ramp = sparkle_gradient
	
	sparkles.scale_amount_min = 1.0
	sparkles.scale_amount_max = 2.0
	
	sparkles.direction = Vector2(0, 1)
	sparkles.spread = 180.0
	sparkles.gravity = Vector2(0, 2)
	sparkles.initial_velocity_min = 2.0
	sparkles.initial_velocity_max = 8.0
	
	add_child(sparkles)

func _add_frozen_obstacles():
	# Add frozen asteroid obstacles (ice-themed)
	var obstacle_count = 15
	
	for i in range(obstacle_count):
		var obstacle = Sprite2D.new()
		
		# Use meteor sprites as frozen asteroids
		var meteor_types = [
			"res://kenney_space-shooter-redux/PNG/Meteors/meteorBrown_big1.png",
			"res://kenney_space-shooter-redux/PNG/Meteors/meteorBrown_med1.png",
			"res://kenney_space-shooter-redux/PNG/Meteors/meteorGrey_big1.png",
			"res://kenney_space-shooter-redux/PNG/Meteors/meteorGrey_med1.png"
		]
		
		obstacle.texture = load(meteor_types[randi() % meteor_types.size()])
		obstacle.modulate = Color(0.7, 0.9, 1.0, 1.0)  # Cyan ice tint
		
		# Random position avoiding center spawn area
		var pos = Vector2(
			randf_range(100, 1180),
			randf_range(100, 620)
		)
		
		# Keep center clear for spawning
		if pos.distance_to(Vector2(640, 360)) < 200:
			pos = pos.normalized() * 250 + Vector2(640, 360)
		
		obstacle.position = pos
		obstacle.rotation = randf_range(0, TAU)
		obstacle.scale = Vector2(0.8, 0.8) * randf_range(0.7, 1.3)
		
		add_child(obstacle)

func get_map_info():
	return {
		"name": "Ice Field",
		"description": "Frozen asteroid field with icy obstacles",
		"difficulty": "Medium",
		"theme": "ice",
		"spawn_positions": [
			Vector2(640, 360),  # Center
			Vector2(320, 360),  # Left
			Vector2(960, 360),  # Right
			Vector2(640, 180)   # Top
		]
	}
