extends Control

@onready var player_list = $VBoxContainer/PlayerList/ScrollContainer/PlayerContainer
@onready var chat_box = $VBoxContainer/ChatPanel/ChatBox
@onready var chat_input = $VBoxContainer/ChatPanel/HBoxContainer/ChatInput
@onready var map_container = $VBoxContainer/MapSelection/MapGrid
@onready var start_button = $VBoxContainer/Controls/StartButton
@onready var ready_button = $VBoxContainer/Controls/ReadyButton
@onready var leave_button = $VBoxContainer/Controls/LeaveButton

var player_ready_states = {}
var current_selected_map = "nebula"

func _ready():
	# Connect NetworkManager signals
	NetworkManager.player_connected.connect(_on_player_connected)
	NetworkManager.player_disconnected.connect(_on_player_disconnected)
	NetworkManager.connection_succeeded.connect(_on_connection_succeeded)
	NetworkManager.server_disconnected.connect(_on_server_disconnected)
	
	# Connect ChatManager signals - Disabled until ChatManager is properly implemented
	# ChatManager.message_received.connect(_on_message_received)
	
	# Setup UI
	start_button.pressed.connect(_on_start_pressed)
	ready_button.pressed.connect(_on_ready_pressed)
	leave_button.pressed.connect(_on_leave_pressed)
	chat_input.text_submitted.connect(_on_chat_submitted)
	
	# Initialize map selection
	_setup_map_selection()
	
	# Update player list
	_update_player_list()
	
	# Only host can start game
	start_button.visible = multiplayer.is_server()

func _setup_map_selection():
	# Clear existing map buttons
	for child in map_container.get_children():
		child.queue_free()
	
	# Create button for each map
	var maps = MapSystem.get_all_maps()
	for map_id in maps.keys():
		var map_data = maps[map_id]
		var map_button = Button.new()
		map_button.text = map_data["name"]
		map_button.custom_minimum_size = Vector2(150, 100)
		map_button.pressed.connect(_on_map_selected.bind(map_id))
		
		# Add description as tooltip
		map_button.tooltip_text = map_data["description"] + "\nMax Players: " + str(map_data["max_players"])
		
		map_container.add_child(map_button)

func _on_map_selected(map_id: String):
	if not multiplayer.is_server():
		_add_chat_message("System", "Only the host can select maps", "")
		return
	
	current_selected_map = map_id
	MapSystem.set_current_map(map_id)
	_sync_map_selection.rpc(map_id)
	
	var map_data = MapSystem.get_map(map_id)
	_add_chat_message("System", "Map changed to: " + map_data["name"], "")

@rpc("authority", "call_local", "reliable")
func _sync_map_selection(map_id: String):
	current_selected_map = map_id
	MapSystem.set_current_map(map_id)

func _update_player_list():
	# Clear existing players
	for child in player_list.get_children():
		child.queue_free()
	
	# Add each player
	for peer_id in NetworkManager.players.keys():
		var player_info = NetworkManager.players[peer_id]
		var player_label = Label.new()
		
		var ready_status = "✓" if player_ready_states.get(peer_id, false) else "○"
		var host_marker = " [HOST]" if peer_id == 1 else ""
		player_label.text = ready_status + " " + player_info.get("name", "Player") + host_marker
		
		player_list.add_child(player_label)

func _on_ready_pressed():
	var my_id = multiplayer.get_unique_id()
	var is_ready = not player_ready_states.get(my_id, false)
	player_ready_states[my_id] = is_ready
	
	_sync_ready_state.rpc(my_id, is_ready)
	ready_button.text = "Unready" if is_ready else "Ready"
	_update_player_list()

@rpc("any_peer", "call_local", "reliable")
func _sync_ready_state(peer_id: int, is_ready: bool):
	player_ready_states[peer_id] = is_ready
	_update_player_list()

func _on_start_pressed():
	if not multiplayer.is_server():
		return
	
	# Check if all players are ready
	var all_ready = true
	for peer_id in NetworkManager.players.keys():
		if peer_id == 1:  # Skip host
			continue
		if not player_ready_states.get(peer_id, false):
			all_ready = false
			break
	
	if not all_ready:
		_add_chat_message("System", "Not all players are ready!", "")
		return
	
	# Start game
	_start_game.rpc()

@rpc("authority", "call_local", "reliable")
func _start_game():
	MapSystem.load_current_map()

func _on_leave_pressed():
	NetworkManager.disconnect_from_server()
	get_tree().change_scene_to_file("res://MainMenu.tscn")

func _on_chat_submitted(text: String):
	if text.strip_edges().is_empty():
		return
	
	# ChatManager.send_message(text) - Disabled until implemented
	_add_chat_message("You", text, "")
	chat_input.clear()

func _on_message_received(sender_name: String, message: String, timestamp: String):
	_add_chat_message(sender_name, message, timestamp)

func _add_chat_message(sender: String, message: String, timestamp: String):
	var time_str = timestamp if timestamp else Time.get_time_string_from_system()
	chat_box.text += "[" + time_str + "] " + sender + ": " + message + "\n"
	
	# Auto-scroll to bottom
	await get_tree().process_frame
	chat_box.scroll_vertical = chat_box.get_v_scroll_bar().max_value

func _on_player_connected(peer_id: int, player_info: Dictionary):
	_add_chat_message("System", player_info.get("name", "Player") + " joined the lobby", "")
	_update_player_list()

func _on_player_disconnected(peer_id: int):
	player_ready_states.erase(peer_id)
	_add_chat_message("System", "A player left the lobby", "")
	_update_player_list()

func _on_connection_succeeded():
	_add_chat_message("System", "Connected to server!", "")

func _on_server_disconnected():
	_add_chat_message("System", "Disconnected from server", "")
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://MainMenu.tscn")
