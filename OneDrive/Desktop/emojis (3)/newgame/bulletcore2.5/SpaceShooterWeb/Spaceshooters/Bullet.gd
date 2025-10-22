extends Area2D

# Bullet properties
@export var speed: float = 600.0
var direction: Vector2 = Vector2.UP

func _ready():
	# Add to bullet group for identification
	add_to_group("bullet")

func _physics_process(delta):
	position += direction * speed * delta
	
	# Remove bullet when off screen
	if position.y < -50 or position.y > get_viewport_rect().size.y + 50:
		queue_free()

func _on_area_entered(area):
	# Hit an enemy
	if area.is_in_group("enemy"):
		queue_free()
