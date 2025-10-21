extends Area2D

# Power-up types
enum PowerUpType {
	HEALTH,
	SPEED_BOOST,
	RAPID_FIRE,
	SHIELD,
	DOUBLE_DAMAGE
}

@export var powerup_type: PowerUpType = PowerUpType.HEALTH
@export var duration: float = 10.0  # Duration for temporary powerups
@export var value: int = 50  # Health amount or boost value

# Visual
var colors = {
	PowerUpType.HEALTH: Color.GREEN,
	PowerUpType.SPEED_BOOST: Color.YELLOW,
	PowerUpType.RAPID_FIRE: Color.ORANGE,
	PowerUpType.SHIELD: Color.BLUE,
	PowerUpType.DOUBLE_DAMAGE: Color.RED
}

func _ready():
	# Set color based on type
	_set_color()
	
	# Connect collision
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	# Float animation
	_start_float_animation()
	
	# Auto-destroy after 30 seconds if not picked up
	get_tree().create_timer(30.0).timeout.connect(queue_free)

# Set visual color
func _set_color():
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = colors[powerup_type]
		return
	
	var color_rect = get_node_or_null("ColorRect")
	if color_rect:
		color_rect.color = colors[powerup_type]
		return
	
	# Create visual if none exists
	var rect = ColorRect.new()
	rect.size = Vector2(24, 24)
	rect.position = Vector2(-12, -12)
	rect.color = colors[powerup_type]
	add_child(rect)

# Floating animation
func _start_float_animation():
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "position:y", position.y - 10, 1.0)
	tween.tween_property(self, "position:y", position.y + 10, 1.0)

# Collision with player
func _on_area_entered(area):
	if area.is_in_group("player"):
		_apply_powerup(area)

func _on_body_entered(body):
	if body.is_in_group("player"):
		_apply_powerup(body)

# Apply power-up effect to player
func _apply_powerup(player: Node):
	print("Power-up collected: ", PowerUpType.keys()[powerup_type])
	
	match powerup_type:
		PowerUpType.HEALTH:
			if player.has_method("heal"):
				player.heal(value)
				print("Player healed for ", value)
		
		PowerUpType.SPEED_BOOST:
			if player.has("speed"):
				var original_speed = player.speed
				player.speed *= 1.5
				print("Speed boost activated!")
				# Revert after duration
				await get_tree().create_timer(duration).timeout
				if is_instance_valid(player):
					player.speed = original_speed
					print("Speed boost ended")
		
		PowerUpType.RAPID_FIRE:
			if player.has("fire_rate"):
				var original_rate = player.fire_rate
				player.fire_rate *= 0.5  # Fire twice as fast
				print("Rapid fire activated!")
				await get_tree().create_timer(duration).timeout
				if is_instance_valid(player):
					player.fire_rate = original_rate
					print("Rapid fire ended")
		
		PowerUpType.SHIELD:
			# Add temporary shield
			if player.has("health"):
				var shield_amount = value
				player.health += shield_amount
				print("Shield activated! +", shield_amount, " health")
		
		PowerUpType.DOUBLE_DAMAGE:
			# Double damage for duration
			print("Double damage activated!")
			# This would need to be implemented in bullet damage system
			await get_tree().create_timer(duration).timeout
			print("Double damage ended")
	
	# Destroy power-up
	queue_free()
