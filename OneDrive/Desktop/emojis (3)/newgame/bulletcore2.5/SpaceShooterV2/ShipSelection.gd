extends Control

@onready var ship_container = $ShipContainer
@onready var ship_name_label = $ShipInfoPanel/ShipNameLabel
@onready var ship_desc_label = $ShipInfoPanel/DescriptionLabel
@onready var ship_stats_label = $ShipInfoPanel/StatsLabel
@onready var select_button = $ShipInfoPanel/SelectButton
@onready var back_button = $BackButton

var current_ship_id = "starter"

func _ready():
	populate_ship_list()
	update_ship_info(current_ship_id)

func populate_ship_list():
	# Create buttons for each ship
	var ship_index = 0
	for ship_id in ShipData.SHIPS.keys():
		var ship_button = Button.new()
		var ship_config = ShipData.SHIPS[ship_id]
		
		# Set button properties
		ship_button.custom_minimum_size = Vector2(200, 80)
		ship_button.text = ship_config["name"]
		
		# Style based on unlock status
		if ShipData.is_ship_unlocked(ship_id):
			if ship_id == ShipData.selected_ship:
				ship_button.modulate = Color(0.3, 1, 0.3)  # Green for selected
			else:
				ship_button.modulate = Color.WHITE
		else:
			ship_button.modulate = Color(0.5, 0.5, 0.5)  # Gray for locked
			ship_button.text += "\n🔒 LOCKED"
		
		# Connect signal
		ship_button.pressed.connect(_on_ship_button_pressed.bind(ship_id))
		
		ship_container.add_child(ship_button)

func _on_ship_button_pressed(ship_id: String):
	current_ship_id = ship_id
	update_ship_info(ship_id)

func update_ship_info(ship_id: String):
	var ship_config = ShipData.SHIPS[ship_id]
	
	# Update labels
	ship_name_label.text = ship_config["name"]
	ship_desc_label.text = ship_config["description"]
	
	# Display stats
	var stats_text = "Stats:\n"
	stats_text += "Speed: " + str(ship_config["speed"]) + "\n"
	stats_text += "Fire Rate: " + str(ship_config["fire_rate"]) + "s\n"
	stats_text += "Health: " + str(ship_config["health"])
	ship_stats_label.text = stats_text
	
	# Update select button
	if ShipData.is_ship_unlocked(ship_id):
		if ship_id == ShipData.selected_ship:
			select_button.text = "✓ SELECTED"
			select_button.disabled = true
		else:
			select_button.text = "SELECT"
			select_button.disabled = false
	else:
		var requirement = ship_config["unlock_requirement"]
		select_button.text = "Unlock at " + str(requirement) + " score"
		select_button.disabled = true

func _on_select_button_pressed():
	if ShipData.select_ship(current_ship_id):
		# Refresh the ship list to show new selection
		for child in ship_container.get_children():
			child.queue_free()
		populate_ship_list()
		update_ship_info(current_ship_id)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")
