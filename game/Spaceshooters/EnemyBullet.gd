extends Area2D

# Enemy bullet properties
@export var speed: float = 300.0
var direction: Vector2 = Vector2.DOWN

func _ready():
	add_to_group("enemy_bullet")

func _physics_process(delta):
	position += direction * speed * delta
	
	# Remove if off screen
	if position.y > get_viewport_rect().size.y + 50:
		queue_free()

func _on_area_entered(area):
	# Hit player
	if area.is_in_group("player"):
		area.get_parent().take_damage(1)
		queue_free()
