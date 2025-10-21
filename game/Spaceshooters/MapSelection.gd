extends Control

# Map Selection Screen
# Displays all available maps for player to choose

@onready var map_list_container = $VBoxContainer/ScrollContainer/MapList if has_node("VBoxContainer/ScrollContainer/MapList") else null
@onready var back_button = $VBoxContainer/BackButton if has_node("VBoxContainer/BackButton") else null
@onready var title_label = $VBoxContainer/TitleLabel if has_node("VBoxContainer/TitleLabel") else null

var selected_map_id: String = ""

func _ready():
	print("MapSelection screen ready!")
	
	# Populate map list
	_populate_map_list()
	
	# Connect back button if it exists
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

func _populate_map_list():
	if not map_list_container:
		# Create the container if it doesn't exist
		var vbox = VBoxContainer.new()
		vbox.name = "MapList"
		add_child(vbox)
		map_list_container = vbox
	
	# Clear existing buttons
	for child in map_list_container.get_children():
		child.queue_free()
	
	# Get all maps from MapSystem
	if has_node("/root/MapSystem"):
		var maps = MapSystem.get_all_maps()
		
		for map_id in maps:
			var map_data = MapSystem.get_map(map_id)
			
			# Create button for each map
			var map_button = Button.new()
			map_button.text = map_data["name"] + " - " + map_data["difficulty"]
			map_button.custom_minimum_size = Vector2(400, 60)
			
			# Add description as tooltip
			if "description" in map_data:
				map_button.tooltip_text = map_data["description"]
			
			# Connect button to select this map
			map_button.pressed.connect(_on_map_selected.bind(map_id, map_data))
			
			# Add visual style based on difficulty
			var style = StyleBoxFlat.new()
			match map_data["difficulty"]:
				"Easy":
					style.bg_color = Color(0.2, 0.8, 0.2, 0.3)  # Green
				"Normal":
					style.bg_color = Color(0.2, 0.5, 0.8, 0.3)  # Blue
				"Hard":
					style.bg_color = Color(0.8, 0.5, 0.2, 0.3)  # Orange
				"Extreme":
					style.bg_color = Color(0.8, 0.2, 0.2, 0.3)  # Red
				_:
					style.bg_color = Color(0.3, 0.3, 0.3, 0.3)  # Gray
			
			style.corner_radius_top_left = 5
			style.corner_radius_top_right = 5
			style.corner_radius_bottom_left = 5
			style.corner_radius_bottom_right = 5
			
			map_button.add_theme_stylebox_override("normal", style)
			map_button.add_theme_stylebox_override("hover", style)
			
			map_list_container.add_child(map_button)
			
			print("Added map button: ", map_data["name"])
	else:
		print("ERROR: MapSystem not found in Autoloads!")
		var error_label = Label.new()
		error_label.text = "ERROR: MapSystem not found!\nMake sure MapSystem.gd is added to Autoloads."
		error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		map_list_container.add_child(error_label)

func _on_map_selected(map_id: String, map_data: Dictionary):
	print("Map selected: ", map_data["name"])
	selected_map_id = map_id
	
	# Set the selected map in MapSystem
	if has_node("/root/MapSystem"):
		MapSystem.set_current_map(map_id)
		print("Map set to: ", map_id)
	
	# Start the game with selected map
	if ResourceLoader.exists("res://Main.tscn"):
		get_tree().change_scene_to_file("res://Main.tscn")
	else:
		print("ERROR: Main.tscn not found!")

func _on_back_pressed():
	# Return to main menu
	if ResourceLoader.exists("res://MainMenu.tscn"):
		get_tree().change_scene_to_file("res://MainMenu.tscn")
	else:
		print("ERROR: MainMenu.tscn not found!")
