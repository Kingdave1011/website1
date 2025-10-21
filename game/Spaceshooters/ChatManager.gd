extends Node

signal message_received(sender_name: String, message: String, timestamp: String)

const MAX_MESSAGES = 100
var chat_history = []
var muted_players = []
var blocked_players = []

func send_message(message: String):
	if message.strip_edges().is_empty():
		return
	
	var player_name = NetworkManager.player_info.get("name", "Player")
	var timestamp = Time.get_time_string_from_system()
	
	# Sanitize message
	message = sanitize_message(message)
	
	_send_message_to_server.rpc(player_name, message, timestamp)

@rpc("any_peer", "reliable")
func _send_message_to_server(sender_name: String, message: String, timestamp: String):
	var sender_id = multiplayer.get_remote_sender_id()
	
	# Check if sender is blocked or muted
	if sender_id in blocked_players or sender_id in muted_players:
		return
	
	# Broadcast to all clients
	_broadcast_message.rpc(sender_name, message, timestamp)

@rpc("authority", "call_local", "reliable")
func _broadcast_message(sender_name: String, message: String, timestamp: String):
	chat_history.append({
		"sender": sender_name,
		"message": message,
		"timestamp": timestamp
	})
	
	if chat_history.size() > MAX_MESSAGES:
		chat_history.pop_front()
	
	message_received.emit(sender_name, message, timestamp)

func mute_player(peer_id: int):
	if peer_id not in muted_players:
		muted_players.append(peer_id)

func unmute_player(peer_id: int):
	muted_players.erase(peer_id)

func block_player(peer_id: int):
	if peer_id not in blocked_players:
		blocked_players.append(peer_id)

func unblock_player(peer_id: int):
	blocked_players.erase(peer_id)

func sanitize_message(message: String) -> String:
	message = message.strip_edges()
	
	# Limit length
	if message.length() > 200:
		message = message.substr(0, 200)
	
	# Block URLs/links (http, https, www, .com, .net, etc.)
	message = block_urls(message)
	
	# Block email addresses
	message = block_emails(message)
	
	# Block phone numbers
	message = block_phone_numbers(message)
	
	# Block profanity and offensive words
	message = block_profanity(message)
	
	# Block IP addresses
	message = block_ip_addresses(message)
	
	# Remove excessive special characters
	message = remove_spam_patterns(message)
	
	return message

# Block URLs and links
func block_urls(text: String) -> String:
	var url_patterns = [
		"http://", "https://", "www.", ".com", ".net", ".org", 
		".io", ".gg", ".tv", ".me", ".co", ".info", ".biz",
		".edu", ".gov", ".mil", ".xyz", ".app", ".dev"
	]
	
	var lower_text = text.to_lower()
	for pattern in url_patterns:
		if pattern in lower_text:
			return "[LINK BLOCKED]"
	
	# Check for domain patterns (word.word)
	var regex = RegEx.new()
	regex.compile("[a-zA-Z0-9-]+\\.[a-zA-Z]{2,}")
	if regex.search(text):
		return "[LINK BLOCKED]"
	
	return text

# Block email addresses
func block_emails(text: String) -> String:
	var regex = RegEx.new()
	regex.compile("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}")
	if regex.search(text):
		return "[EMAIL BLOCKED]"
	return text

# Block phone numbers
func block_phone_numbers(text: String) -> String:
	# Remove spaces and common separators for checking
	var check_text = text.replace(" ", "").replace("-", "").replace("(", "").replace(")", "").replace(".", "")
	
	# Check for sequences of 7+ digits (likely a phone number)
	var regex = RegEx.new()
	regex.compile("\\d{7,}")
	if regex.search(check_text):
		return "[PHONE NUMBER BLOCKED]"
	
	return text

# Block IP addresses
func block_ip_addresses(text: String) -> String:
	var regex = RegEx.new()
	regex.compile("\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}")
	if regex.search(text):
		return "[IP ADDRESS BLOCKED]"
	return text

# Block profanity and offensive content
func block_profanity(text: String) -> String:
	# Comprehensive profanity list (censored/partial for demonstration)
	var blocked_words = [
		# Offensive language (partial list - add more as needed)
		"fuck", "fuk", "fck", "shit", "shit", "bitch", "btch", 
		"ass", "asshole", "damn", "hell", "crap", "bastard",
		"dick", "cock", "pussy", "cunt", "whore", "slut",
		# Slurs and hate speech (always block these)
		"nigger", "nigga", "fag", "faggot", "retard", "retarded",
		# Variations and leetspeak
		"f u c k", "f*ck", "fu<k", "sh1t", "b1tch", "a$$",
		# Other offensive terms
		"kys", "kill yourself", "cancer", "nazi", "hitler"
	]
	
	var lower_text = text.to_lower()
	var modified_text = text
	
	for word in blocked_words:
		# Check for exact word match or word with spaces
		var spaced_word = " " + word + " "
		var spaced_text = " " + lower_text + " "
		
		if word in lower_text or spaced_word in spaced_text:
			# Replace with asterisks
			var replacement = "*" * word.length()
			modified_text = replace_word_case_insensitive(modified_text, word, replacement)
	
	return modified_text

# Helper function to replace words case-insensitively
func replace_word_case_insensitive(text: String, word: String, replacement: String) -> String:
	var lower_text = text.to_lower()
	var lower_word = word.to_lower()
	var pos = lower_text.find(lower_word)
	
	while pos != -1:
		text = text.substr(0, pos) + replacement + text.substr(pos + word.length())
		lower_text = text.to_lower()
		pos = lower_text.find(lower_word, pos + replacement.length())
	
	return text

# Remove spam patterns (excessive repeated characters)
func remove_spam_patterns(text: String) -> String:
	# Remove excessive repeated characters (more than 3 of same character)
	var regex = RegEx.new()
	regex.compile("(.)\\1{3,}")
	var result = regex.sub(text, "$1$1$1", true)
	
	# Remove excessive special characters
	if result.count("!") > 5 or result.count("?") > 5 or result.count(".") > 5:
		result = "[SPAM BLOCKED]"
	
	return result

func get_chat_history() -> Array:
	return chat_history
