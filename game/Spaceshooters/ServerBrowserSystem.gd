extends Node

# Server Browser System - Manage multiple game servers with player limits

signal server_list_updated(servers)
signal server_joined(server_data)
signal server_full(server_name)
signal server_disconnected()

# Server configuration
const MAX_PLAYERS_PER_SERVER = 32
const SERVER_REFRESH_INTERVAL = 5.0

# Server regions
enum ServerRegion {
	NORTH_AMERICA_EAST,
	NORTH_AMERICA_WEST,
	EUROPE_WEST,
	EUROPE_EAST,
	ASIA_PACIFIC,
	SOUTH_AMERICA,
	OCEANIA,
	MIDDLE_EAST
}

# Available servers (would be fetched from backend)
var available_servers: Array = []
var current_server: Dictionary = {}
var refresh_timer: float = 0.0

# Default server list configuration
const DEFAULT_SERVERS = [
	{
		"id": "na-east-1",
		"name": "NA East 1",
		"region": ServerRegion.NORTH_AMERICA_EAST,
		"location": "New York",
		"max_players": 32,
		"current_players": 0,
		"ping": 20,
		"status": "online"
	},
	{
		"id": "na-east-2",
		"name": "NA East 2",
		"region": ServerRegion.NORTH_AMERICA_EAST,
		"location": "Virginia",
		"max_players": 32,
		"current_players": 0,
		"ping": 25,
		"status": "online"
	},
	{
		"id": "na-west-1",
		"name": "NA West 1",
		"region": ServerRegion.NORTH_AMERICA_WEST,
		"location": "California",
		"max_players": 32,
		"current_players": 0,
		"ping": 45,
		"status": "online"
	},
	{
		"id": "eu-west-1",
		"name": "EU West 1",
		"region": ServerRegion.EUROPE_WEST,
		"location": "London",
		"max_players": 32,
		"current_players": 0,
		"ping": 85,
		"status": "online"
	},
	{
		"id": "eu-central-1",
		"name": "EU Central 1",
		"region": ServerRegion.EUROPE_WEST,
		"location": "Frankfurt",
		"max_players": 32,
		"current_players": 0,
		"ping": 90,
		"status": "online"
	},
	{
		"id": "asia-1",
		"name": "Asia 1",
		"region": ServerRegion.ASIA_PACIFIC,
		"location": "Tokyo",
		"max_players": 32,
		"current_players": 0,
		"ping": 150,
		"status": "online"
	},
	{
		"id": "asia-2",
		"name": "Asia 2",
		"region": ServerRegion.ASIA_PACIFIC,
		"location": "Singapore",
		"max_players": 32,
		"current_players": 0,
		"ping": 160,
		"status": "online"
	},
	{
		"id": "oceania-1",
		"name": "Oceania 1",
		"region": ServerRegion.OCEANIA,
		"location": "Sydney",
		"max_players": 32,
		"current_players": 0,
		"ping": 180,
		"status": "online"
	},
	{
		"id": "sa-1",
		"name": "South America 1",
		"region": ServerRegion.SOUTH_AMERICA,
		"location": "São Paulo",
		"max_players": 32,
		"current_players": 0,
		"ping": 120,
		"status": "online"
	}
]

func _ready():
	available_servers = DEFAULT_SERVERS.duplicate(true)
	refresh_server_list()

func _process(delta):
	refresh_timer += delta
	if refresh_timer >= SERVER_REFRESH_INTERVAL:
		refresh_timer = 0.0
		refresh_server_list()

func refresh_server_list():
	"""Refresh server list (would query backend in production)"""
	# In production, this would make an HTTP request to your backend
	# For now, simulate with local data
	
	# Sort by ping (lowest first)
	available_servers.sort_custom(func(a, b): return a.ping < b.ping)
	
	server_list_updated.emit(available_servers)

func get_servers_by_region(region: ServerRegion) -> Array:
	"""Get all servers in a specific region"""
	var filtered = []
	for server in available_servers:
		if server.region == region:
			filtered.append(server)
	return filtered

func get_recommended_server() -> Dictionary:
	"""Get best server based on ping and player count"""
	var best_server = {}
	var best_score = -999999
	
	for server in available_servers:
		if server.status != "online":
			continue
		
		if server.current_players >= server.max_players:
			continue
		
		# Score based on low ping and not too empty/full
		var ping_score = 200 - server.ping
		var player_ratio = float(server.current_players) / float(server.max_players)
		var population_score = 50 if (player_ratio > 0.3 and player_ratio < 0.8) else 0
		
		var total_score = ping_score + population_score
		
		if total_score > best_score:
			best_score = total_score
			best_server = server
	
	return best_server

func join_server(server_id: String) -> bool:
	"""Attempt to join a server"""
	var server = get_server_by_id(server_id)
	
	if server.is_empty():
		print("Server not found: ", server_id)
		return false
	
	if server.status != "online":
		print("Server offline: ", server_id)
		return false
	
	if server.current_players >= server.max_players:
		server_full.emit(server.name)
		print("Server full: ", server.name)
		return false
	
	# Join server
	current_server = server
	server_joined.emit(server)
	
	print("Joined server: ", server.name)
	print("Players: ", server.current_players, "/", server.max_players)
	
	return true

func leave_server():
	"""Leave current server"""
	if not current_server.is_empty():
		print("Left server: ", current_server.name)
		current_server = {}
		server_disconnected.emit()

func get_server_by_id(server_id: String) -> Dictionary:
	"""Get server data by ID"""
	for server in available_servers:
		if server.id == server_id:
			return server
	return {}

func get_all_servers() -> Array:
	"""Get all available servers"""
	return available_servers

func get_current_server() -> Dictionary:
	"""Get currently connected server"""
	return current_server

func is_connected_to_server() -> bool:
	"""Check if connected to a server"""
	return not current_server.is_empty()

func get_server_status_color(server: Dictionary) -> Color:
	"""Get color for server status indicator"""
	if server.status != "online":
		return Color.GRAY
	
	var player_ratio = float(server.current_players) / float(server.max_players)
	
	if player_ratio >= 0.9:
		return Color.RED  # Almost full
	elif player_ratio >= 0.6:
		return Color.YELLOW  # Medium population
	else:
		return Color.GREEN  # Low population

func get_server_display_text(server: Dictionary) -> String:
	"""Get formatted display text for server"""
	return "%s | %s | %d/%d | %dms" % [
		server.name,
		server.location,
		server.current_players,
		server.max_players,
		server.ping
	]

func estimate_ping_to_region(region: ServerRegion) -> int:
	"""Estimate ping based on user location (simplified)"""
	# In production, you would actually ping the servers
	# This is a simplified estimate
	var servers = get_servers_by_region(region)
	if servers.size() > 0:
		return servers[0].ping
	return 100

func auto_select_best_server() -> Dictionary:
	"""Automatically select the best available server"""
	return get_recommended_server()
