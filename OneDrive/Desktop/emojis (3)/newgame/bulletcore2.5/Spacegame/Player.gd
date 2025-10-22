extends CharacterBody2D

# Player properties
@export var speed: float = 400.0
@export var shoot_cooldown: float = 0.2
@export var health: int = 3

# References
var bullet_scene = preload("res://Bullet.tscn")
var can_shoot: bool = true

# Signals
signal health_changed(new_health)
signal player_died

func _ready():
	health_changed.emit(health)

func _physics_process(delta):
	# Get input direction
	var input_direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	# Normalize diagonal movement
	if input_direction.length() > 1.0:
		input_direction = input_direction.normalized()
	
	# Set velocity and move
	velocity = input_direction * speed
	move_and_slide()
	
	# Keep player on screen
	position.x = clamp(position.x, 20, get_viewport_rect().size.x - 20)
	position.y = clamp(position.y, 20, get_viewport_rect().size.y - 20)
	
	# Shooting
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func shoot():
	can_shoot = false
	
	# Play laser shoot sound
	var shoot_sound = AudioStreamPlayer.new()
	add_child(shoot_sound)
	var laser_sfx = load("res://sounds/shoot.mp3")
	if laser_sfx:
		shoot_sound.stream = laser_sfx
		shoot_sound.volume_db = -5
		shoot_sound.play()
		shoot_sound.finished.connect(func(): shoot_sound.queue_free())
	
	# Create bullet
	var bullet = bullet_scene.instantiate()
	bullet.position = position + Vector2(0, -30)
	bullet.direction = Vector2.UP
	get_parent().add_child(bullet)
	
	# Reset shoot cooldown
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true

func take_damage(amount: int):
	health -= amount
	health_changed.emit(health)
	
	# Screen shake effect
	var camera = get_viewport().get_camera_2d()
	if camera:
		camera.offset = Vector2(randf_range(-10, 10), randf_range(-10, 10))
		await get_tree().create_timer(0.05).timeout
		camera.offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
		await get_tree().create_timer(0.05).timeout
		camera.offset = Vector2.ZERO
	
	# Enhanced flash effect with glow
	modulate = Color(1, 0.2, 0.2)
	scale = Vector2(1.2, 1.2)
	await get_tree().create_timer(0.08).timeout
	modulate = Color(1, 0.5, 0.5)
	scale = Vector2(1.1, 1.1)
	await get_tree().create_timer(0.08).timeout
	modulate = Color.WHITE
	scale = Vector2.ONE
	
	if health <= 0:
		die()

func die():
	# Play explosion sound
	var explosion_sound = AudioStreamPlayer.new()
	get_parent().add_child(explosion_sound)
	var explosion_sfx = load("res://sounds/explosion.wav")
	if explosion_sfx:
		explosion_sound.stream = explosion_sfx
		explosion_sound.volume_db = 0
		explosion_sound.play()
	
	# Create explosion effect
	var explosion_scene = load("res://Explosion.tscn")
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		explosion.position = position
		get_parent().add_child(explosion)
	
	player_died.emit()
	queue_free()

func _on_area_2d_area_entered(area):
	# Collision with enemies
	if area.is_in_group("enemy"):
		take_damage(1)
		area.get_parent().queue_free()
