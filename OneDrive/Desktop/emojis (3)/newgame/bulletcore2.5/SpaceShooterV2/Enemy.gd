extends CharacterBody2D

# Enemy properties
@export var speed: float = 150.0
@export var health: int = 2
@export var points_value: int = 10

# References
var explosion_scene = preload("res://Explosion.tscn")

# Signals
signal enemy_destroyed(points)

func _ready():
	# Add to enemy group
	add_to_group("enemy")

func _physics_process(delta):
	# Move downward
	velocity = Vector2.DOWN * speed
	move_and_slide()
	
	# Remove if off screen
	if position.y > get_viewport_rect().size.y + 50:
		queue_free()

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
