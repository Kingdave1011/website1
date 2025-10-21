extends CharacterBody2D

# Enemy properties
@export var speed: float = 150.0
@export var health: int = 2
@export var points_value: int = 10
@export var can_shoot: bool = true
@export var shoot_cooldown: float = 2.0

# References
var explosion_scene = preload("res://Explosion.tscn")
var bullet_scene = preload("res://Bullet.tscn")
var player: Node = null
var shoot_timer: float = 0.0

# Signals
signal enemy_destroyed(points)

func _ready():
	# Add to enemy group
	add_to_group("enemy")
	
	# Make enemy RED to distinguish from player
	modulate = Color(1.0, 0.2, 0.2)  # Bright red enemy ship
	
	# Find player
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	# Randomize initial shoot timer
	shoot_timer = randf_range(0, shoot_cooldown)

func _physics_process(delta):
	# Move downward
	velocity = Vector2.DOWN * speed
	move_and_slide()
	
	# Shooting behavior
	if can_shoot and player:
		shoot_timer -= delta
		if shoot_timer <= 0:
			shoot_at_player()
			shoot_timer = shoot_cooldown
	
	# Remove if off screen
	if position.y > get_viewport_rect().size.y + 50:
		queue_free()

func shoot_at_player():
	if bullet_scene == null or player == null:
		return
	
	var bullet = bullet_scene.instantiate()
	bullet.position = position + Vector2(0, 20)
	
	# Aim towards player
	var direction = (player.position - position).normalized()
	bullet.direction = direction
	bullet.speed = 300  # Enemy bullets slightly slower
	
	# Make bullet red for enemies
	bullet.modulate = Color.RED
	
	# Add to enemy_bullet group to avoid hitting other enemies
	bullet.add_to_group("enemy_bullet")
	bullet.remove_from_group("bullet")
	
	get_parent().add_child(bullet)

func set_stats(new_health: int, new_speed: float):
	health = new_health
	speed = new_speed

func take_damage(amount: int):
	health -= amount
	
	# Flash effect
	modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.05).timeout
	modulate = Color.WHITE
	
	if health <= 0:
		die()

func die():
	enemy_destroyed.emit(points_value)
	
	# Create explosion effect
	var explosion = explosion_scene.instantiate()
	explosion.position = position
	get_parent().add_child(explosion)
	
	queue_free()

func _on_area_2d_area_entered(area):
	# Hit by bullet
	if area.is_in_group("bullet"):
		take_damage(1)
