extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal connection_failed
signal connection_succeeded

const DEFAULT_PORT = 7777
const MAX_CLIENTS = 16

var peer = null
var players = {}
var player_info = {"name": "Player", "ship_class": "medium"}

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func create_server(port: int = DEFAULT_PORT) -> bool:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, MAX_CLIENTS)
	if error != OK:
		push_error("Failed to create server: " + str(error))
		return false
	
	multiplayer.multiplayer_peer = peer
	players[1] = player_info.duplicate()
	print("Server created on port ", port)
	return true

func join_server(address: String, port: int = DEFAULT_PORT) -> bool:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error != OK:
		push_error("Failed to join server: " + str(error))
		return false
	
	multiplayer.multiplayer_peer = peer
	print("Attempting to connect to ", address, ":", port)
	return true

func disconnect_from_server():
	if peer:
		peer.close()
		peer = null
	multiplayer.multiplayer_peer = null
	players.clear()

func set_player_info(info: Dictionary):
	player_info = info

# RPC Functions
@rpc("any_peer", "reliable")
func register_player(info: Dictionary):
	var id = multiplayer.get_remote_sender_id()
	players[id] = info
	player_connected.emit(id, info)

@rpc("authority", "call_local", "reliable")
func update_player_list(player_list: Dictionary):
	players = player_list

# Callbacks
func _on_player_connected(id: int):
	if multiplayer.is_server():
		register_player.rpc_id(id, player_info)
		players[id] = {}
		update_player_list.rpc(players)

func _on_player_disconnected(id: int):
	players.erase(id)
	player_disconnected.emit(id)
	if multiplayer.is_server():
		update_player_list.rpc(players)

func _on_connected_to_server():
	var my_id = multiplayer.get_unique_id()
	players[my_id] = player_info.duplicate()
	register_player.rpc_id(1, player_info)
	connection_succeeded.emit()

func _on_connection_failed():
	multiplayer.multiplayer_peer = null
	connection_failed.emit()

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
