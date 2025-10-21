extends Node

# Anti-Cheat System
# Detects and prevents common cheating methods

signal cheat_detected(player_id: int, cheat_type: String, severity: String)
signal player_kicked(player_id: int, reason: String)

# Player tracking data
var player_data = {}

# Cheat detection thresholds
const MAX_SPEED = 600.0  # Maximum allowed player speed
const MAX_FIRE_RATE = 10.0  # Maximum shots per second
const MAX_SCORE_PER_SECOND = 1000  # Maximum score gain per second
const MAX_HEALTH = 100  # Maximum player health
const MAX_POSITION_DELTA = 500.0  # Maximum position change per frame (teleport detection)

# Tracking
var player_violations = {}
const MAX_VIOLATIONS = 3  # Kick after 3 violations

func _ready():
	# Initialize when multiplayer is active
	if multiplayer.has_multiplayer_peer():
		_initialize_tracking()

func _initialize_tracking():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)

func _on_player_connected(id: int):
	player_data[id] = {
		"last_position": Vector2.ZERO,
		"last_health": 100,
		"last_score": 0,
		"last_shot_time": 0.0,
		"shot_count": 0,
		"score_history": [],
		"speed_history": [],
		"last_update_time": Time.get_ticks_msec()
	}
	player_violations[id] = 0
	print("AntiCheat: Tracking player ", id)

func _on_player_disconnected(id: int):
	player_data.erase(id)
	player_violations.erase(id)

# Validate player movement
func validate_movement(player_id: int, position: Vector2, speed: float) -> bool:
	if not player_id in player_data:
		return true
	
	var data = player_data[player_id]
	var current_time = Time.get_ticks_msec()
	var delta_time = (current_time - data["last_update_time"]) / 1000.0
	
	if delta_time <= 0:
		return true
	
	# Check speed hacking
	if speed > MAX_SPEED:
		_report_violation(player_id, "SPEED_HACK", "HIGH")
		return false
	
	# Check teleport hacking (impossible position changes)
	if data["last_position"] != Vector2.ZERO:
		var position_delta = data["last_position"].distance_to(position)
		var max_allowed_delta = MAX_SPEED * delta_time
		
		if position_delta > max_allowed_delta and position_delta > MAX_POSITION_DELTA:
			_report_violation(player_id, "TELEPORT_HACK", "CRITICAL")
			return false
	
	# Update tracking
	data["last_position"] = position
	data["speed_history"].append(speed)
	if data["speed_history"].size() > 10:
		data["speed_history"].pop_front()
	data["last_update_time"] = current_time
	
	return true

# Validate player shooting
func validate_shooting(player_id: int) -> bool:
	if not player_id in player_data:
		return true
	
	var data = player_data[player_id]
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# Check fire rate hacking
	var time_since_last_shot = current_time - data["last_shot_time"]
	
	if time_since_last_shot < (1.0 / MAX_FIRE_RATE):
		data["shot_count"] += 1
		
		# If too many rapid shots, it's a hack
		if data["shot_count"] > 5:
			_report_violation(player_id, "FIRE_RATE_HACK", "HIGH")
			data["shot_count"] = 0
			return false
	else:
		data["shot_count"] = 0
	
	data["last_shot_time"] = current_time
	return true

# Validate score changes
func validate_score(player_id: int, new_score: int) -> bool:
	if not player_id in player_data:
		return true
	
	var data = player_data[player_id]
	var current_time = Time.get_ticks_msec()
	var delta_time = (current_time - data["last_update_time"]) / 1000.0
	
	if delta_time <= 0:
		return true
	
	# Check for impossible score gains
	var score_delta = new_score - data["last_score"]
	var max_allowed_score = MAX_SCORE_PER_SECOND * delta_time
	
	if score_delta > max_allowed_score and score_delta > 0:
		_report_violation(player_id, "SCORE_HACK", "CRITICAL")
		return false
	
	# Check for negative score manipulation
	if new_score < 0:
		_report_violation(player_id, "SCORE_MANIPULATION", "HIGH")
		return false
	
	data["last_score"] = new_score
	data["score_history"].append(new_score)
	if data["score_history"].size() > 10:
		data["score_history"].pop_front()
	
	return true

# Validate health changes
func validate_health(player_id: int, new_health: int) -> bool:
	if not player_id in player_data:
		return true
	
	var data = player_data[player_id]
	
	# Check for health hacking (over max)
	if new_health > MAX_HEALTH:
		_report_violation(player_id, "HEALTH_HACK", "CRITICAL")
		return false
	
	# Check for instant full heal (suspicious)
	if new_health > data["last_health"] + 50 and data["last_health"] < 50:
		_report_violation(player_id, "INSTANT_HEAL", "MEDIUM")
		# Don't return false, might be legitimate power-up
	
	# Check for negative health
	if new_health < 0:
		_report_violation(player_id, "HEALTH_MANIPULATION", "HIGH")
		return false
	
	data["last_health"] = new_health
	return true

# Validate game state
func validate_game_state(player_id: int, game_state: Dictionary) -> bool:
	# Check for impossible game states
	if "wave" in game_state and game_state["wave"] < 0:
		_report_violation(player_id, "WAVE_MANIPULATION", "HIGH")
		return false
	
	if "enemies_killed" in game_state and game_state["enemies_killed"] < 0:
		_report_violation(player_id, "STAT_MANIPULATION", "MEDIUM")
		return false
	
	# Check for impossible time values
	if "game_time" in game_state and game_state["game_time"] < 0:
		_report_violation(player_id, "TIME_MANIPULATION", "LOW")
		return false
	
	return true

# Server-side validation (call this from server)
@rpc("any_peer", "reliable")
func report_player_action(action_type: String, data: Dictionary):
	var player_id = multiplayer.get_remote_sender_id()
	
	match action_type:
		"move":
			if not validate_movement(player_id, data.get("position", Vector2.ZERO), data.get("speed", 0.0)):
				_kick_player(player_id, "Movement hacking detected")
		
		"shoot":
			if not validate_shooting(player_id):
				_kick_player(player_id, "Fire rate hacking detected")
		
		"score":
			if not validate_score(player_id, data.get("score", 0)):
				_kick_player(player_id, "Score manipulation detected")
		
		"health":
			if not validate_health(player_id, data.get("health", 0)):
				_kick_player(player_id, "Health hacking detected")
		
		"state":
			if not validate_game_state(player_id, data):
				_kick_player(player_id, "Game state manipulation detected")

# Report a violation
func _report_violation(player_id: int, cheat_type: String, severity: String):
	print("CHEAT DETECTED - Player: ", player_id, " Type: ", cheat_type, " Severity: ", severity)
	
	# Increment violation count
	if not player_id in player_violations:
		player_violations[player_id] = 0
	
	player_violations[player_id] += 1
	
	# Emit signal
	cheat_detected.emit(player_id, cheat_type, severity)
	
	# Auto-kick on critical violations or too many violations
	if severity == "CRITICAL" or player_violations[player_id] >= MAX_VIOLATIONS:
		_kick_player(player_id, "Anti-cheat violation: " + cheat_type)

# Kick player from game
func _kick_player(player_id: int, reason: String):
	print("KICKING PLAYER ", player_id, " - Reason: ", reason)
	
	# Emit signal
	player_kicked.emit(player_id, reason)
	
	# Disconnect player (server authority)
	if multiplayer.is_server():
		multiplayer.multiplayer_peer.disconnect_peer(player_id)
	
	# Clean up data
	player_data.erase(player_id)
	player_violations.erase(player_id)

# Server-side score verification
func verify_score_increase(player_id: int, score_increase: int, expected_max: int) -> bool:
	# Verify score increase is within reasonable bounds
	if score_increase > expected_max:
		_report_violation(player_id, "SCORE_HACK", "HIGH")
		return false
	return true

# Get player violation count
func get_violations(player_id: int) -> int:
	return player_violations.get(player_id, 0)

# Reset violations (admin command)
func reset_violations(player_id: int):
	player_violations[player_id] = 0

# Check if player is suspicious
func is_player_suspicious(player_id: int) -> bool:
	return player_violations.get(player_id, 0) > 0

# Get all suspicious players
func get_suspicious_players() -> Array:
	var suspicious = []
	for player_id in player_violations:
		if player_violations[player_id] > 0:
			suspicious.append(player_id)
	return suspicious

# Server timestamp verification (prevent time manipulation)
func get_server_timestamp() -> int:
	return Time.get_ticks_msec()

# Verify client timestamp is synchronized
func verify_timestamp(player_id: int, client_timestamp: int) -> bool:
	var server_time = get_server_timestamp()
	var time_diff = abs(server_time - client_timestamp)
	
	# Allow 5 second desync tolerance
	if time_diff > 5000:
		_report_violation(player_id, "TIME_DESYNC", "MEDIUM")
		return false
	
	return true
