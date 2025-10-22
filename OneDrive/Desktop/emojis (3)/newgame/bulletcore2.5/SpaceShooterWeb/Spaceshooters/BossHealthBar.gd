extends "res://HealthBar.gd"

# Boss Health Bar - Extended health bar for boss enemies with name display

@onready var boss_name_label = $BossName
@onready var phase_indicator = $PhaseIndicator

var boss_name: String = "BOSS"
var current_phase: int = 1
var total_phases: int = 1

func _ready():
	super._ready()
	# Boss bars always show numbers
	set_show_numbers(true)
	update_boss_display()

func set_boss_name(name: String):
	"""Set the displayed boss name"""
	boss_name = name
	update_boss_display()

func set_boss_phase(phase: int, total: int = 1):
	"""Update boss phase display"""
	current_phase = phase
	total_phases = total
	update_boss_display()

func update_boss_display():
	"""Update boss name and phase labels"""
	if boss_name_label:
		var display_text = boss_name
		if total_phases > 1:
			display_text += " - Phase %d/%d" % [current_phase, total_phases]
		boss_name_label.text = display_text

func set_health(health: int, max_hp: int = -1):
	"""Override to add boss-specific effects"""
	super.set_health(health, max_hp)
	
	# Add special effects for boss health changes
	if current_health < max_health * 0.25:
		add_critical_boss_effect()

func add_critical_boss_effect():
	"""Add red flashing border when boss is critical"""
	if border:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(border, "modulate", Color.RED, 0.3)
		tween.tween_property(border, "modulate", Color.WHITE, 0.3)

func phase_transition_effect():
	"""Visual effect when boss enters new phase"""
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Flash white
	tween.tween_property(fill, "modulate", Color.WHITE, 0.2)
	tween.tween_property(fill, "modulate", Color(0.2, 0.8, 0.2, 1.0), 0.3)
	
	# Scale pulse
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
	tween.tween_property(self, "scale", Vector2.ONE, 0.3)
	
	# Update phase display
	update_boss_display()

func show_boss_intro_animation():
	"""Dramatic entrance animation for boss health bar"""
	modulate.a = 0
	scale = Vector2(0.5, 0.5)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	tween.tween_property(self, "scale", Vector2.ONE, 0.5)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)
