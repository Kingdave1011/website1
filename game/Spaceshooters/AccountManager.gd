extends Node

# Account Management System
# Handles guest play and account creation/login

signal account_created(username: String)
signal login_successful(username: String, is_guest: bool)
signal login_failed(error: String)

# Current player data
var current_username: String = ""
var is_guest_mode: bool = false
var is_admin: bool = false
var player_stats: Dictionary = {
	"kills": 0,
	"deaths": 0,
	"games_played": 0,
	"high_score": 0,
	"level": 1,
	"xp": 0
}

# Admin system
const OWNER_USERNAME = "King_davez"
const OWNER_PASSWORD_HASH = "f5c7e9a8e7b9c6d4a3f2e1b0c9d8e7f6a5b4c3d2e1f0a9b8c7d6e5f4a3b2c1d0"  # SHA256 of "Peaguyxx300"
var admin_users = ["King_davez"]  # List of admin usernames

# Password recovery
var password_recovery_codes = {}  # username: recovery_code

# Guest name generator
var guest_adjectives = ["Quick", "Swift", "Brave", "Bold", "Stealth", "Shadow", "Dark", "Light", "Nova", "Star"]
var guest_nouns = ["Pilot", "Hunter", "Warrior", "Fighter", "Ace", "Phoenix", "Eagle", "Falcon", "Hawk", "Dragon"]

func _ready():
	# Load saved account if exists
	load_saved_account()

# Generate random guest name
func generate_guest_name() -> String:
	randomize()
	var adjective = guest_adjectives[randi() % guest_adjectives.size()]
	var noun = guest_nouns[randi() % guest_nouns.size()]
	var number = randi() % 1000
	return adjective + noun + str(number)

# Play as guest (no account creation)
func play_as_guest() -> void:
	current_username = generate_guest_name()
	is_guest_mode = true
	
	# Reset guest stats (not saved)
	player_stats = {
		"kills": 0,
		"deaths": 0,
		"games_played": 0,
		"high_score": 0,
		"level": 1,
		"xp": 0
	}
	
	print("Playing as guest: ", current_username)
	login_successful.emit(current_username, true)

# Create new account
func create_account(username: String, password: String) -> bool:
	# Validate username
	if username.length() < 3:
		login_failed.emit("Username must be at least 3 characters")
		return false
	
	if username.length() > 20:
		login_failed.emit("Username must be less than 20 characters")
		return false
	
	# Check if account already exists
	if account_exists(username):
		login_failed.emit("Username already taken")
		return false
	
	# Validate password
	if password.length() < 6:
		login_failed.emit("Password must be at least 6 characters")
		return false
	
	# Create account
	var account_data = {
		"username": username,
		"password_hash": hash_password(password),
		"created_date": Time.get_datetime_string_from_system(),
		"stats": {
			"kills": 0,
			"deaths": 0,
			"games_played": 0,
			"high_score": 0,
			"level": 1,
			"xp": 0
		}
	}
	
	# Save account
	save_account(account_data)
	
	# Set as current user
	current_username = username
	is_guest_mode = false
	player_stats = account_data["stats"]
	
	print("Account created: ", username)
	account_created.emit(username)
	login_successful.emit(username, false)
	
	return true

# Login to existing account
func login(username: String, password: String) -> bool:
	if not account_exists(username):
		login_failed.emit("Account not found")
		return false
	
	var account_data = load_account(username)
	
	if account_data["password_hash"] != hash_password(password):
		login_failed.emit("Incorrect password")
		return false
	
	# Set as current user
	current_username = username
	is_guest_mode = false
	player_stats = account_data["stats"]
	
	print("Logged in: ", username)
	login_successful.emit(username, false)
	
	return true

# Simple password hashing (use proper encryption in production)
func hash_password(password: String) -> String:
	return password.sha256_text()

# Check if account exists
func account_exists(username: String) -> bool:
	var save_path = "user://accounts/" + username + ".save"
	return FileAccess.file_exists(save_path)

# Save account to file
func save_account(account_data: Dictionary) -> void:
	var save_dir = "user://accounts/"
	DirAccess.make_dir_recursive_absolute(save_dir)
	
	var save_path = save_dir + account_data["username"] + ".save"
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	
	if file:
		file.store_string(JSON.stringify(account_data))
		file.close()
		print("Account saved: ", save_path)

# Load account from file
func load_account(username: String) -> Dictionary:
	var save_path = "user://accounts/" + username + ".save"
	
	if not FileAccess.file_exists(save_path):
		return {}
	
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			return json.data
	
	return {}

# Load last used account
func load_saved_account() -> void:
	var config_path = "user://last_account.cfg"
	
	if FileAccess.file_exists(config_path):
		var file = FileAccess.open(config_path, FileAccess.READ)
		if file:
			var last_username = file.get_line()
			file.close()
			
			if account_exists(last_username):
				print("Found saved account: ", last_username)
				# Don't auto-login, just remember the username

# Save last used account
func save_last_account() -> void:
	if is_guest_mode:
		return  # Don't save guest accounts
	
	var config_path = "user://last_account.cfg"
	var file = FileAccess.open(config_path, FileAccess.WRITE)
	
	if file:
		file.store_line(current_username)
		file.close()

# Update player stats
func update_stats(kills: int = 0, deaths: int = 0, score: int = 0) -> void:
	player_stats["kills"] += kills
	player_stats["deaths"] += deaths
	player_stats["games_played"] += 1
	
	if score > player_stats["high_score"]:
		player_stats["high_score"] = score
	
	# Calculate XP and level
	var xp_gain = kills * 10 + score / 10
	player_stats["xp"] += xp_gain
	
	# Level up every 1000 XP
	while player_stats["xp"] >= player_stats["level"] * 1000:
		player_stats["level"] += 1
		print("Level up! Now level ", player_stats["level"])
	
	# Save if not guest
	if not is_guest_mode:
		var account_data = load_account(current_username)
		account_data["stats"] = player_stats
		save_account(account_data)

# Get current username
func get_username() -> String:
	return current_username

# Get player stats
func get_stats() -> Dictionary:
	return player_stats

# Is playing as guest
func is_guest() -> bool:
	return is_guest_mode

# Logout
func logout() -> void:
	if not is_guest_mode:
		save_last_account()
	
	current_username = ""
	is_guest_mode = false
	is_admin = false
	player_stats = {
		"kills": 0,
		"deaths": 0,
		"games_played": 0,
		"high_score": 0,
		"level": 1,
		"xp": 0
	}

# Check if current user is admin
func check_admin() -> bool:
	return current_username in admin_users

# Generate password recovery code
func request_password_reset(username: String) -> String:
	if not account_exists(username):
		return ""
	
	# Generate 6-digit recovery code
	randomize()
	var code = ""
	for i in range(6):
		code += str(randi() % 10)
	
	password_recovery_codes[username] = {
		"code": code,
		"timestamp": Time.get_ticks_msec(),
		"expiry": 600000  # 10 minutes in milliseconds
	}
	
	print("Password recovery code for ", username, ": ", code)
	return code

# Reset password with recovery code
func reset_password(username: String, code: String, new_password: String) -> bool:
	if not username in password_recovery_codes:
		login_failed.emit("No recovery code found")
		return false
	
	var recovery_data = password_recovery_codes[username]
	var current_time = Time.get_ticks_msec()
	
	# Check if code expired
	if current_time - recovery_data["timestamp"] > recovery_data["expiry"]:
		password_recovery_codes.erase(username)
		login_failed.emit("Recovery code expired")
		return false
	
	# Verify code
	if recovery_data["code"] != code:
		login_failed.emit("Invalid recovery code")
		return false
	
	# Validate new password
	if new_password.length() < 6:
		login_failed.emit("Password must be at least 6 characters")
		return false
	
	# Load and update account
	var account_data = load_account(username)
	account_data["password_hash"] = hash_password(new_password)
	save_account(account_data)
	
	# Clear recovery code
	password_recovery_codes.erase(username)
	
	print("Password reset successful for: ", username)
	return true

# Admin functions
func is_user_admin() -> bool:
	return is_admin

func kick_player(player_id: int, reason: String) -> void:
	if not is_admin:
		print("Admin privileges required")
		return
	
	# Call NetworkManager or AntiCheatManager to kick
	if AntiCheatManager:
		AntiCheatManager._kick_player(player_id, "Kicked by admin: " + reason)

func ban_username(username: String) -> void:
	if not is_admin:
		print("Admin privileges required")
		return
	
	# Add to ban list file
	var ban_list_path = "user://banned_users.txt"
	var file = FileAccess.open(ban_list_path, FileAccess.READ_WRITE)
	
	if not file:
		file = FileAccess.open(ban_list_path, FileAccess.WRITE)
	
	if file:
		file.seek_end()
		file.store_line(username)
		file.close()
		print("Banned user: ", username)

func is_username_banned(username: String) -> bool:
	var ban_list_path = "user://banned_users.txt"
	
	if not FileAccess.file_exists(ban_list_path):
		return false
	
	var file = FileAccess.open(ban_list_path, FileAccess.READ)
	if file:
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			if line == username:
				file.close()
				return true
		file.close()
	
	return false
