extends Control

var music_player: AudioStreamPlayer

func _ready():
	# Create and setup background music
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
	# Load the dreams.mp3 music
	var music = load("res://sounds/dreams.mp3")
	if music:
		music_player.stream = music
		music_player.volume_db = -10  # Adjust volume
		music_player.autoplay = true
		music_player.play()

func _on_play_button_pressed():
	# Fade out music before changing scene
	if music_player:
		music_player.stop()
	get_tree().change_scene_to_file("res://Main.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
