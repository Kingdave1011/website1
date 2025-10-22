extends Node

# Chat Moderation System - Profanity filter, link blocking, auto-translation

signal message_blocked(reason, original_message)
signal message_translated(original, translated, from_lang, to_lang)
signal player_warned(player_name, reason)
signal player_muted(player_name, duration)

# Moderation settings
var enable_profanity_filter: bool = true
var enable_link_blocking: bool = true
var enable_auto_translation: bool = true
var max_warnings: int = 3

# Player warnings tracker
var player_warnings: Dictionary = {}
var muted_players: Dictionary = {}

# Profanity filter word list (basic - expand as needed)
const BLOCKED_WORDS = [
	# Add profanity here - keeping list minimal for example
	"spam", "hack", "cheat", "scam"
]

# URL/Link patterns
const LINK_PATTERNS = [
	"http://",
	"https://",
	"www.",
	".com",
	".net",
	".org",
	".io",
	".gg",
	".me"
]

# Translation API configuration (would use real API in production)
var translation_cache: Dictionary = {}

func filter_message(message: String, player_name: String, player_language: String = "en") -> Dictionary:
	"""
	Filter and process chat message
	Returns: {
		"allowed": bool,
		"filtered_message": String,
		"reason": String (if blocked),
		"translated": bool
	}
	"""
	var result = {
		"allowed": true,
		"filtered_message": message,
		"reason": "",
		"translated": false
	}
	
	# Check if player is muted
	if is_player_muted(player_name):
		result.allowed = false
		result.reason = "Player is muted"
		return result
	
	# Check for profanity
	if enable_profanity_filter:
		var profanity_check = check_profanity(message)
		if not profanity_check.clean:
			result.filtered_message = profanity_check.filtered
			warn_player(player_name, "Profanity detected")
			# Still allow but filter the words
	
	# Check for links
	if enable_link_blocking:
		if contains_link(message):
			result.allowed = false
			result.reason = "Links not allowed"
			message_blocked.emit("Link detected", message)
			warn_player(player_name, "Attempted to post link")
			return result
	
	# Check for spam (repeated characters)
	if is_spam(message):
		result.allowed = false
		result.reason = "Spam detected"
		message_blocked.emit("Spam", message)
		warn_player(player_name, "Spam detected")
		return result
	
	return result

func check_profanity(message: String) -> Dictionary:
	"""Check message for profanity and filter it"""
	var clean = true
	var filtered = message
	
	for word in BLOCKED_WORDS:
		var regex = RegEx.new()
		regex.compile("(?i)\\b" + word + "\\b")  # Case insensitive word boundary
		
		if regex.search(filtered):
			clean = false
			# Replace with asterisks
			var replacement = ""
			for i in range(word.length()):
				replacement += "*"
			filtered = regex.sub(filtered, replacement, true)
	
	return {"clean": clean, "filtered": filtered}

func contains_link(message: String) -> bool:
	"""Check if message contains URLs or links"""
	var lower_message = message.to_lower()
	
	for pattern in LINK_PATTERNS:
		if lower_message.contains(pattern):
			return true
	
	return false

func is_spam(message: String) -> bool:
	"""Check if message is spam (repeated characters, etc.)"""
	# Check for excessive repeated characters
	var repeat_count = 0
	var last_char = ""
	
	for c in message:
		if c == last_char:
			repeat_count += 1
			if repeat_count >= 5:  # 5+ repeated characters = spam
				return true
		else:
			repeat_count = 0
			last_char = c
	
	# Check for all caps (if message is long enough)
	if message.length() > 10:
		if message == message.to_upper() and message.strip_edges().length() > 0:
			# Check if contains letters
			var has_letter = false
			for c in message:
				if c.to_lower() != c.to_upper():
					has_letter = true
					break
			if has_letter:
				return true  # All caps spam
	
	return false

func translate_message(message: String, from_lang: String, to_lang: String) -> String:
	"""
	Translate message (would use real translation API in production)
	For now, returns original with [TRANSLATED] tag
	"""
	if from_lang == to_lang:
		return message
	
	# Check cache first
	var cache_key = message + from_lang + to_lang
	if translation_cache.has(cache_key):
		return translation_cache[cache_key]
	
	# In production, call translation API here
	# For example: Google Translate API, DeepL API, etc.
	var translated = "[TRANSLATED from %s] %s" % [from_lang.to_upper(), message]
	
	# Cache the translation
	translation_cache[cache_key] = translated
	
	message_translated.emit(message, translated, from_lang, to_lang)
	
	return translated

func warn_player(player_name: String, reason: String):
	"""Issue warning to player"""
	if not player_warnings.has(player_name):
		player_warnings[player_name] = 0
	
	player_warnings[player_name] += 1
	player_warned.emit(player_name, reason)
	
	print("Player warned: ", player_name, " (", reason, ")")
	print("Warnings: ", player_warnings[player_name], "/", max_warnings)
	
	# Auto-mute if too many warnings
	if player_warnings[player_name] >= max_warnings:
		mute_player(player_name, 600)  # 10 minute mute

func mute_player(player_name: String, duration: int):
	"""Mute player for specified duration (seconds)"""
	var mute_until = Time.get_unix_time_from_system() + duration
	muted_players[player_name] = mute_until
	
	player_muted.emit(player_name, duration)
	print("Player muted: ", player_name, " for ", duration, " seconds")

func unmute_player(player_name: String):
	"""Remove mute from player"""
	if muted_players.has(player_name):
		muted_players.erase(player_name)
		print("Player unmuted: ", player_name)

func is_player_muted(player_name: String) -> bool:
	"""Check if player is currently muted"""
	if not muted_players.has(player_name):
		return false
	
	var mute_until = muted_players[player_name]
	var current_time = Time.get_unix_time_from_system()
	
	if current_time >= mute_until:
		# Mute expired
		unmute_player(player_name)
		return false
	
	return true

func get_mute_time_remaining(player_name: String) -> int:
	"""Get seconds remaining on mute"""
	if not is_player_muted(player_name):
		return 0
	
	var mute_until = muted_players[player_name]
	var current_time = Time.get_unix_time_from_system()
	return max(0, mute_until - current_time)

func reset_player_warnings(player_name: String):
	"""Reset warning count for player"""
	if player_warnings.has(player_name):
		player_warnings.erase(player_name)

func get_player_warnings(player_name: String) -> int:
	"""Get warning count for player"""
	return player_warnings.get(player_name, 0)

func add_blocked_word(word: String):
	"""Add word to profanity filter (admin function)"""
	if not word in BLOCKED_WORDS:
		BLOCKED_WORDS.append(word.to_lower())
		print("Added blocked word: ", word)

func remove_blocked_word(word: String):
	"""Remove word from filter (admin function)"""
	var index = BLOCKED_WORDS.find(word.to_lower())
	if index >= 0:
		BLOCKED_WORDS.remove_at(index)
		print("Removed blocked word: ", word)
