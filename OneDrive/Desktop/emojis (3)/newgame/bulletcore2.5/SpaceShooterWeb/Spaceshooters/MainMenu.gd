extends Control

@onready var title_label = $VBoxContainer/TitleLabel if has_node("VBoxContainer/TitleLabel") else null
@onready var play_button = $VBoxContainer/PlayButton if has_node("VBoxContainer/PlayButton") else null
@onready var online_button = $VBoxContainer/OnlineButton if has_node("VBoxContainer/OnlineButton") else null
@onready var settings_button = $VBoxContainer/SettingsButton if has_node("VBoxContainer/SettingsButton") else null
@onready var maps_button = $VBoxContainer/MapsButton if has_node("VBoxContainer/MapsButton") else null
@onready var quit_button = $VBoxContainer/QuitButton if has_node("VBoxContainer/QuitButton") else null

# Background music only
var background_music: AudioStreamPlayer

func _ready():
	# Setup music
	_setup_music()
	
	# Buttons are already connected in the .tscn scene file
	# Only add hover/unhover effects if not already connected
	if play_button:
		if not play_button.mouse_entered.is_connected(_on_button_hover):
			play_button.mouse_entered.connect(_on_button_hover.bind(play_button))
		if not play_button.mouse_exited.is_connected(_on_button_unhover):
			play_button.mouse_exited.connect(_on_button_unhover.bind(play_button))
	
	if online_button:
		if not online_button.mouse_entered.is_connected(_on_button_hover):
			online_button.mouse_entered.connect(_on_button_hover.bind(online_button))
		if not online_button.mouse_exited.is_connected(_on_button_unhover):
			online_button.mouse_exited.connect(_on_button_unhover.bind(online_button))
	
	if settings_button:
		if not settings_button.mouse_entered.is_connected(_on_button_hover):
			settings_button.mouse_entered.connect(_on_button_hover.bind(settings_button))
		if not settings_button.mouse_exited.is_connected(_on_button_unhover):
			settings_button.mouse_exited.connect(_on_button_unhover.bind(settings_button))
	
	if maps_button:
		if not maps_button.mouse_entered.is_connected(_on_button_hover):
			maps_button.mouse_entered.connect(_on_button_hover.bind(maps_button))
		if not maps_button.mouse_exited.is_connected(_on_button_unhover):
			maps_button.mouse_exited.connect(_on_button_unhover.bind(maps_button))
	
	if quit_button:
		if not quit_button.mouse_entered.is_connected(_on_button_hover):
			quit_button.mouse_entered.connect(_on_button_hover.bind(quit_button))
		if not quit_button.mouse_exited.is_connected(_on_button_unhover):
			quit_button.mouse_exited.connect(_on_button_unhover.bind(quit_button))
	
	# Animate title on start
	if title_label:
		_animate_title()

func _setup_music():
	# Create background music player
	background_music = AudioStreamPlayer.new()
	background_music.name = "BackgroundMusic"
	
	# Try to load ambient space music (you'll need to add your music file)
	# For now, using a looping engine sound as ambient atmosphere
	var music_stream = load("res://kenney_sci-fi-sounds/Audio/spaceEngine_003.ogg")
	if music_stream:
		background_music.stream = music_stream
		background_music.volume_db = -15  # Quieter for background
		background_music.autoplay = false  # We'll start it manually
		background_music.bus = "Master"
		add_child(background_music)
		
		# Start music with fade-in effect
		background_music.volume_db = -80
		background_music.play()
		
		# Fade in music over 2 seconds
		var tween = create_tween()
		tween.tween_property(background_music, "volume_db", -15, 2.0)
	
	print("Menu music initialized - Add your own music file to: res://music/menu_theme.ogg")

func _animate_title():
	# Start invisible and small
	title_label.modulate.a = 0
	title_label.scale = Vector2(0.5, 0.5)
	
	# Fade in and scale up animation
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(title_label, "modulate:a", 1.0, 1.0)
	tween.tween_property(title_label, "scale", Vector2(1.0, 1.0), 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Add continuous pulse effect
	tween.chain()
	var pulse = create_tween().set_loops()
	pulse.tween_property(title_label, "scale", Vector2(1.05, 1.05), 1.5)
	pulse.tween_property(title_label, "scale", Vector2(1.0, 1.0), 1.5)

func _on_button_hover(button: Button):
	# Animate button scale and glow
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "modulate", Color(1.3, 1.3, 1.3), 0.2)

func _on_button_unhover(button: Button):
	# Animate button back to normal
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)
	tween.tween_property(button, "modulate", Color(1.0, 1.0, 1.0), 0.2)

func _on_play_button_pressed():
	# Start solo play
	get_tree().change_scene_to_file("res://Main.tscn")

func _on_online_button_pressed():
	# Open LoginScreen for authentication first
	# Note: Make sure LoginScreen.tscn exists (not LoginScreen.tscn.tscn!)
	get_tree().change_scene_to_file("res://LoginScreen.tscn")

func _on_settings_button_pressed():
	# Open settings screen
	if ResourceLoader.exists("res://Settings.tscn"):
		get_tree().change_scene_to_file("res://Settings.tscn")
	else:
		print("Settings.tscn not found - check if file exists")

func _on_maps_button_pressed():
	# Open map selection screen
	get_tree().change_scene_to_file("res://MapSelection.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
