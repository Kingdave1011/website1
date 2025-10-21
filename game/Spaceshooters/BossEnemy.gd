extends CharacterBody2D

# Boss stats
@export var max_health: int = 1000
@export var speed: float = 50.0
@export var damage: int = 50
@export var shoot_interval: float = 1.0

# Bullet scenes
@export var boss_bullet_scene: PackedScene

# State
var health: int
var player: Node2D
var can_shoot: bool = true
var current_phase: int = 1

# Attack patterns
enum AttackPattern {
	SPREAD_SHOT,
	CIRCLE_SHOT,
	LASER_BEAM,
	MISSILE_BARRAGE
}

var current_pattern: AttackPattern = AttackPattern.SPREAD_SHOT

# Signals
signal boss_died()
signal phase_changed(new_phase: int)
signal attack_pattern_changed(pattern: AttackPattern)

func _ready():
	print("Boss spawned!")
	add_to_group("enemies")
	add_to_group("boss")
	
	health = max_health
	
	# Make boss DARK RED colored
	_set_boss_color()
	
	# Find player
	player = get_tree().get_first_node_in_group("player")
	
	# Start attack patterns
	_start_attacks()
	
	# Boss entrance animation
	_entrance_animation()

func _physics_process(delta):
	if not player or not is_instance_valid(player):
		return
	
	# Boss movement patterns based on phase
	match current_phase:
		1:
			_movement_pattern_1()
		2:
			_movement_pattern_2()
		3:
			_movement_pattern_3()
	
	move_and_slide()

# Set boss visual to dark red
func _set_boss_color():
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = Color(0.8, 0.1, 0.1)  # Dark red
		sprite.scale = Vector2(3, 3)  # Make boss bigger
		return
	
	# Create large boss visual
	var rect = ColorRect.new()
	rect.size = Vector2(96, 96)
	rect.position = Vector2(-48, -48)
	rect.color = Color(0.8, 0.1, 0.1)
	add_child(rect)

# Entrance animation
func _entrance_animation():
	position.y = -200
	var tween = create_tween()
	tween.tween_property(self, "position:y", 0, 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)

# Movement pattern 1 (Phase 1) - Side to side
func _movement_pattern_1():
	var target_x = sin(Time.get_ticks_msec() / 1000.0) * 300
	velocity.x = (target_x - position.x) * 2

# Movement pattern 2 (Phase 2) - Circle
func _movement_pattern_2():
	var angle = Time.get_ticks_msec() / 1000.0
	var radius = 200
	var target = Vector2(cos(angle) * radius, sin(angle) * radius * 0.5)
	velocity = (target - position) * 2

# Movement pattern 3 (Phase 3) - Aggressive tracking
func _movement_pattern_3():
	if player and is_instance_valid(player):
		var direction = (player.position - position).normalized()
		velocity = direction * speed * 2

# Start attack routines
func _start_attacks():
	_attack_loop()

# Main attack loop
func _attack_loop():
	while is_instance_valid(self) and health > 0:
		await get_tree().create_timer(shoot_interval).timeout
		
		if can_shoot and player and is_instance_valid(player):
			match current_pattern:
				AttackPattern.SPREAD_SHOT:
					_spread_shot()
				AttackPattern.CIRCLE_SHOT:
					_circle_shot()
				AttackPattern.LASER_BEAM:
					_laser_beam()
				AttackPattern.MISSILE_BARRAGE:
					_missile_barrage()

# Spread shot attack
func _spread_shot():
	var bullet_count = 5 + (current_phase * 2)
	var spread_angle = PI / 3
	
	for i in range(bullet_count):
		var angle = -spread_angle / 2 + (spread_angle / bullet_count) * i
		_shoot_bullet(angle)

# Circle shot attack
func _circle_shot():
	var bullet_count = 12 + (current_phase * 4)
	
	for i in range(bullet_count):
		var angle = (TAU / bullet_count) * i
		_shoot_bullet(angle)

# Laser beam attack
func _laser_beam():
	if not player or not is_instance_valid(player):
		return
	
	# Aim at player
	var direction = (player.position - position).normalized()
	
	# Shoot multiple bullets in line
	for i in range(10):
		_shoot_bullet(direction.angle())
		await get_tree().create_timer(0.05).timeout

# Missile barrage attack
func _missile_barrage():
	for i in range(5 + current_phase):
		if player and is_instance_valid(player):
			var direction = (player.position - position).normalized()
			_shoot_bullet(direction.angle())
		await get_tree().create_timer(0.2).timeout

# Shoot a single bullet at angle
func _shoot_bullet(angle: float):
	if not boss_bullet_scene:
		return
	
	var bullet = boss_bullet_scene.instantiate()
	bullet.position = position
	bullet.direction = Vector2(cos(angle), sin(angle))
	
	# Boss bullets are stronger
	if bullet.has("damage"):
		bullet.damage = damage
	if bullet.has("is_player_bullet"):
		bullet.is_player_bullet = false
	
	get_parent().add_child(bullet)

# Take damage
func take_damage(amount: int):
	health -= amount
	print("Boss health: ", health, "/", max_health)
	
	# Flash effect
	_flash_damage()
	
	# Check phase transitions
	var health_percent = float(health) / float(max_health)
	
	if health_percent <= 0.66 and current_phase == 1:
		_change_phase(2)
	elif health_percent <= 0.33 and current_phase == 2:
		_change_phase(3)
	
	if health <= 0:
		die()

# Flash effect when damaged
func _flash_damage():
	var sprite = get_node_or_null("Sprite2D")
	var color_rect = get_node_or_null("ColorRect")
	
	if sprite:
		sprite.modulate = Color.WHITE
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(sprite):
			sprite.modulate = Color(0.8, 0.1, 0.1)
	elif color_rect:
		color_rect.color = Color.WHITE
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(color_rect):
			color_rect.color = Color(0.8, 0.1, 0.1)

# Change boss phase
func _change_phase(new_phase: int):
	current_phase = new_phase
	print("Boss entered phase ", new_phase)
	phase_changed.emit(new_phase)
	
	# Change attack pattern
	match new_phase:
		2:
			current_pattern = AttackPattern.CIRCLE_SHOT
			shoot_interval = 0.8
		3:
			current_pattern = AttackPattern.MISSILE_BARRAGE
			shoot_interval = 0.5
			speed *= 1.5
	
	attack_pattern_changed.emit(current_pattern)
	
	# Visual feedback
	_phase_transition_effect()

# Phase transition effect
func _phase_transition_effect():
	# Screen shake
	var particle_manager = get_tree().get_first_node_in_group("particle_manager")
	if particle_manager and particle_manager.has_method("screen_shake"):
		particle_manager.screen_shake(15.0, 0.5)
	
	# Flash effect
	if particle_manager and particle_manager.has_method("screen_flash"):
		particle_manager.screen_flash(Color.RED, 0.3)

# Boss death
func die():
	print("Boss defeated!")
	boss_died.emit()
	
	# Massive explosion effect
	var particle_manager = get_tree().get_first_node_in_group("particle_manager")
	if particle_manager:
		if particle_manager.has_method("create_explosion"):
			particle_manager.create_explosion(position, 5.0, Color.RED)
		if particle_manager.has_method("screen_shake"):
			particle_manager.screen_shake(20.0, 1.0)
	
	# Award massive score
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager and game_manager.has_method("add_score"):
		game_manager.add_score(10000)
	
	# Update stats
	if AccountManager.is_logged_in:
		AccountManager.add_to_stat("bosses_defeated", 1)
	
	queue_free()

# Attack player on collision
func _on_area_entered(area):
	if area.is_in_group("player"):
		if area.has_method("take_damage"):
			area.take_damage(damage)

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
