extends Control

@onready var fps_option = $Panel/FPSOption
@onready var vsync_check = $Panel/VSyncCheck
@onready var graphics_option = $Panel/GraphicsOption
@onready var music_slider = $Panel/MusicSlider
@onready var sfx_slider = $Panel/SFXSlider
@onready var fullscreen_check = $Panel/FullscreenCheck
@onready var back_button = $BackButton

func _ready():
	load_current_settings()

func load_current_settings():
	# Load FPS option
	var fps = SettingsManager.settings["fps_limit"]
	var fps_index = 0
	match fps:
		0: fps_index = 0  # Unlimited
		60: fps_index = 1
		120: fps_index = 2
		144: fps_index = 3
	fps_option.selected = fps_index
	
	# Load VSync
	vsync_check.button_pressed = SettingsManager.settings["vsync_enabled"]
	
	# Load graphics preset
	var preset = SettingsManager.settings["graphics_preset"]
	match preset:
		"low": graphics_option.selected = 0
		"medium": graphics_option.selected = 1
		"high": graphics_option.selected = 2
		"ultra": graphics_option.selected = 3
	
	# Load audio
	music_slider.value = SettingsManager.settings["music_volume"] * 100
	sfx_slider.value = SettingsManager.settings["sfx_volume"] * 100
	
	# Load fullscreen
	fullscreen_check.button_pressed = SettingsManager.settings["fullscreen"]

func _on_fps_option_item_selected(index):
	var fps_limits = [0, 60, 120, 144]
	SettingsManager.set_fps_limit(fps_limits[index])

func _on_vsync_check_toggled(toggled_on):
	SettingsManager.set_vsync(toggled_on)

func _on_graphics_option_item_selected(index):
	var presets = ["low", "medium", "high", "ultra"]
	SettingsManager.set_graphics_preset(presets[index])

func _on_music_slider_value_changed(value):
	SettingsManager.set_music_volume(value / 100.0)

func _on_sfx_slider_value_changed(value):
	SettingsManager.set_sfx_volume(value / 100.0)

func _on_fullscreen_check_toggled(toggled_on):
	SettingsManager.set_fullscreen(toggled_on)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")
