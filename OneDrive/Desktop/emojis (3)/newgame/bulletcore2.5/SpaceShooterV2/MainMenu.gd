extends Control

func _ready():
	pass

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Main.tscn")

func _on_quit_button_pressed():
	get_tree().quit()

func _on_donate_button_pressed():
	OS.shell_open("https://paypal.me/Kinloch68")

func _on_ships_button_pressed():
	get_tree().change_scene_to_file("res://ShipSelection.tscn")

func _on_settings_button_pressed():
	get_tree().change_scene_to_file("res://Settings.tscn")
