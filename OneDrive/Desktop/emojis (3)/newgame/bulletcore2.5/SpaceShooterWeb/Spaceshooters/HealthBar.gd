extends Control

# Health Bar - Visual health display with color transitions

@onready var background = $Background
@onready var fill = $Fill
@onready var label = $Label
@onready var border = $Border

var max_health: int = 100
var current_health: int = 100
var show_numbers: bool = true
var animate_changes: bool = true

func _ready():
	update_display()

func set_health(health: int, max_hp: int = -1):
	"""Update health bar with new values"""
	if max_hp > 0:
		max_health = max_hp
	
	var old_health = current_health
	current_health = clamp(health, 0, max_health)
	
	if animate_changes:
		animate_health_change(old_health, current_health)
	else:
		update_display()

func animate_health_change(from: int, to: int):
	"""Smoothly animate health bar changes"""
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Animate the fill width
	var health_percent_from = float(from) / float(max_health)
	var health_percent_to = float(to) / float(max_health)
	var width = size.x
	
	tween.tween_property(fill, "size:x", width * health_percent_to, 0.3)\
		.from(width * health_percent_from)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	
	# Update color during animation
	tween.tween_callback(update_color).set_delay(0.15)
	
	# Update label
	if show_numbers:
		tween.tween_method(update_label_animated, from, to, 0.3)

func update_display():
	"""Update all visual elements"""
	if not is_node_ready():
		return
	
	var health_percent = float(current_health) / float(max_health)
	
	# Update fill width
	if fill:
		fill.size.x = size.x * health_percent
	
	# Update color
	update_color()
	
	# Update label
	if label and show_numbers:
		label.text = "%d / %d" % [current_health, max_health]

func update_color():
	"""Update fill color based on health percentage"""
	if not fill:
		return
	
	var health_percent = float(current_health) / float(max_health)
	
	if health_percent > 0.6:
		# Green (healthy)
		fill.color = Color(0.2, 0.8, 0.2, 1.0)
	elif health_percent > 0.3:
		# Yellow (warning)
		fill.color = Color(0.9, 0.9, 0.2, 1.0)
	elif health_percent > 0.15:
		# Orange (danger)
		fill.color = Color(1.0, 0.5, 0.0, 1.0)
	else:
		# Red (critical)
		fill.color = Color(1.0, 0.2, 0.2, 1.0)
		
		# Pulse effect when critical
		if health_percent > 0:
			pulse_critical()

func pulse_critical():
	"""Pulse effect for critical health"""
	var tween = create_tween()
	tween.tween_property(fill, "modulate:a", 0.5, 0.3)
	tween.tween_property(fill, "modulate:a", 1.0, 0.3)

func update_label_animated(value: float):
	"""Update label during animation"""
	if label and show_numbers:
		label.text = "%d / %d" % [int(value), max_health]

func set_show_numbers(show: bool):
	"""Toggle number display"""
	show_numbers = show
	if label:
		label.visible = show

func set_animate_changes(animate: bool):
	"""Toggle smooth animations"""
	animate_changes = animate

func _on_health_changed(new_health: int):
	"""Callback for health changed signal"""
	set_health(new_health)
