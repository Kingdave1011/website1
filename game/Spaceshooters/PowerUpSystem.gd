# Power-Up System with 5 Different Items
extends Node

# Power-Up Types
enum PowerUpType {
	HEALTH,        # Restores player health
	SHIELD,        # Temporary invincibility
	RAPID_FIRE,    # Faster shooting
	SPREAD_SHOT,   # Multiple bullets at once
	SPEED_BOOST    # Increased movement speed
}

# Power-Up Data
class PowerUp:
	var type: PowerUpType
	var duration: float = 0.0  # 0 for instant effects
	var icon_path: String
	var color: Color
	var description: String
	
	func _init(p_type: PowerUpType):
		type = p_type
		setup_powerup()
	
	func setup_powerup():
		match type:
			PowerUpType.HEALTH:
				duration = 0.0
				color = Color.GREEN
				description = "Restores 25 HP"
			PowerUpType.SHIELD:
				duration = 5.0
				color = Color.CYAN
				description = "Invincibility for 5 seconds"
			PowerUpType.RAPID_FIRE:
				duration = 10.0
				color = Color.ORANGE
				description = "2x Fire Rate for 10 seconds"
			PowerUpType.SPREAD_SHOT:
				duration = 8.0
				color = Color.PURPLE
				description = "Triple Shot for 8 seconds"
			PowerUpType.SPEED_BOOST:
				duration = 7.0
				color = Color.YELLOW
				description = "2x Speed for 7 seconds"

# Active power-ups tracking
var active_powerups: Dictionary = {}

func apply_powerup(player: Node, type: PowerUpType):
	var powerup = PowerUp.new(type)
	
	print("Power-up collected: ", powerup.description)
	
	match type:
		PowerUpType.HEALTH:
			apply_health(player)
		PowerUpType.SHIELD:
			apply_shield(player, powerup.duration)
		PowerUpType.RAPID_FIRE:
			apply_rapid_fire(player, powerup.duration)
		PowerUpType.SPREAD_SHOT:
			apply_spread_shot(player, powerup.duration)
		PowerUpType.SPEED_BOOST:
			apply_speed_boost(player, powerup.duration)

# POWER-UP 1: Health Restore
func apply_health(player: Node):
	if player.has_method("heal"):
		player.heal(25)
	else:
		# Fallback
		if "health" in player:
			player.health = min(player.health + 25, player.max_health if "max_health" in player else 100)
	
	# Visual effect
	create_heal_particles(player)

func create_heal_particles(player: Node):
	var particles = CPUParticles2D.new()
	particles.amount = 20
	particles.lifetime = 0.5
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.direction = Vector2(0, -1)
	particles.spread = 45
	particles.initial_velocity_min = 100
	particles.initial_velocity_max = 200
	particles.color = Color.GREEN
	player.add_child(particles)
	particles.emitting = true
	
	await get_tree().create_timer(0.5).timeout
	particles.queue_free()

# POWER-UP 2: Shield (Invincibility)
func apply_shield(player: Node, duration: float):
	# Add shield visual
	var shield_sprite = Sprite2D.new()
	shield_sprite.name = "Shield"
	shield_sprite.modulate = Color(0, 1, 1, 0.5)  # Cyan semi-transparent
	shield_sprite.scale = Vector2(1.5, 1.5)
	player.add_child(shield_sprite)
	
	# Make player invincible
	if player.has_method("set_invincible"):
		player.set_invincible(true)
	else:
		player.set_meta("invincible", true)
	
	# Track active powerup
	active_powerups["shield"] = duration
	
	# Remove after duration
	await get_tree().create_timer(duration).timeout
	
	if player.has_method("set_invincible"):
		player.set_invincible(false)
	else:
		player.set_meta("invincible", false)
	
	if player.has_node("Shield"):
		player.get_node("Shield").queue_free()
	
	active_powerups.erase("shield")

# POWER-UP 3: Rapid Fire
func apply_rapid_fire(player: Node, duration: float):
	var original_fire_rate = 0.25
	
	if "shoot_cooldown" in player:
		original_fire_rate = player.shoot_cooldown
		player.shoot_cooldown = original_fire_rate / 2  # 2x faster
	
	# Visual indicator
	add_powerup_glow(player, Color.ORANGE)
	
	# Track active powerup
	active_powerups["rapid_fire"] = duration
	
	# Restore after duration
	await get_tree().create_timer(duration).timeout
	
	if "shoot_cooldown" in player:
		player.shoot_cooldown = original_fire_rate
	
	remove_powerup_glow(player)
	active_powerups.erase("rapid_fire")

# POWER-UP 4: Spread Shot
func apply_spread_shot(player: Node, duration: float):
	# Enable spread shot mode
	player.set_meta("spread_shot", true)
	
	# Visual indicator
	add_powerup_glow(player, Color.PURPLE)
	
	# Track active powerup
	active_powerups["spread_shot"] = duration
	
	# Remove after duration
	await get_tree().create_timer(duration).timeout
	
	player.set_meta("spread_shot", false)
	remove_powerup_glow(player)
	active_powerups.erase("spread_shot")

# POWER-UP 5: Speed Boost
func apply_speed_boost(player: Node, duration: float):
	var original_speed = 300.0
	
	if "speed" in player:
		original_speed = player.speed
		player.speed = original_speed * 2  # 2x faster
	
	# Visual indicator - speed lines
	add_speed_lines(player)
	add_powerup_glow(player, Color.YELLOW)
	
	# Track active powerup
	active_powerups["speed_boost"] = duration
	
	# Restore after duration
	await get_tree().create_timer(duration).timeout
	
	if "speed" in player:
		player.speed = original_speed
	
	remove_speed_lines(player)
	remove_powerup_glow(player)
	active_powerups.erase("speed_boost")

# Visual Effects Helpers
func add_powerup_glow(player: Node, color: Color):
	if player.has_node("Sprite2D"):
		player.get_node("Sprite2D").modulate = color

func remove_powerup_glow(player: Node):
	if player.has_node("Sprite2D"):
		player.get_node("Sprite2D").modulate = Color.WHITE

func add_speed_lines(player: Node):
	var particles = CPUParticles2D.new()
	particles.name = "SpeedLines"
	particles.amount = 50
	particles.lifetime = 0.3
	particles.direction = Vector2(0, 1)  # Behind the ship
	particles.spread = 10
	particles.initial_velocity_min = 200
	particles.initial_velocity_max = 400
	particles.color = Color.YELLOW
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 1.0
	player.add_child(particles)
	particles.emitting = true

func remove_speed_lines(player: Node):
	if player.has_node("SpeedLines"):
		player.get_node("SpeedLines").queue_free()

# Get remaining time for active power-ups
func get_remaining_time(powerup_name: String) -> float:
	if active_powerups.has(powerup_name):
		return active_powerups[powerup_name]
	return 0.0

# Check if power-up is active
func is_active(powerup_name: String) -> bool:
	return active_powerups.has(powerup_name)


# ============================================
# POWER-UP COLLECTIBLE (PowerUp.gd)
# ============================================
# This would be a separate scene script
"""
extends Area2D
class_name PowerUpCollectible

var powerup_type: PowerUpSystem.PowerUpType

func _ready():
	# Random power-up type
	powerup_type = randi() % PowerUpSystem.PowerUpType.size()
	
	# Set color based on type
	var powerup = PowerUpSystem.PowerUp.new(powerup_type)
	if has_node("Sprite2D"):
		$Sprite2D.modulate = powerup.color
	
	# Connect collision
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Apply power-up
		var powerup_system = get_node("/root/PowerUpSystem")
		if powerup_system:
			powerup_system.apply_powerup(body, powerup_type)
		
		# Remove collectible
		queue_free()

func _process(delta):
	# Rotate for visual effect
	rotation += delta * 2
	
	# Bob up and down
	position.y += sin(Time.get_ticks_msec() / 200.0) * 0.5
"""
