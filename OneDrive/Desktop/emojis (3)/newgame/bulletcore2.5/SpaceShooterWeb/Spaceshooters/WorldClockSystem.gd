extends Node

# World Clock System - Displays time for different cities/timezones

signal time_updated(city_name, time_string, timezone)

# Time configuration
var update_interval: float = 1.0
var time_elapsed: float = 0.0

# Timezone offsets from UTC (in hours)
const TIMEZONES = {
	"New York": -4,      # EDT
	"Los Angeles": -7,   # PDT
	"London": 1,         # BST
	"Paris": 2,          # CEST
	"Tokyo": 9,          # JST
	"Sydney": 10,        # AEST
	"Dubai": 4,          # GST
	"Moscow": 3,         # MSK
	"Beijing": 8,        # CST
	"Mumbai": 5.5,       # IST
	"São Paulo": -3,     # BRT
	"Mexico City": -5,   # CDT
	"Berlin": 2,         # CEST
	"Seoul": 9,          # KST
	"Singapore": 8,      # SGT
	"Toronto": -4,       # EDT
	"Hong Kong": 8,      # HKT
	"Cairo": 2,          # EET
	"Buenos Aires": -3,  # ART
	"Lagos": 1           # WAT
}

# Current selected cities (can be changed)
var active_cities: Array = ["New York", "London", "Tokyo", "Sydney"]
var detected_timezone: String = ""

func _ready():
	detect_user_timezone()

func _process(delta):
	time_elapsed += delta
	if time_elapsed >= update_interval:
		time_elapsed = 0.0
		update_all_clocks()

func detect_user_timezone():
	"""Detect user's timezone based on system time"""
	var system_time = Time.get_datetime_dict_from_system()
	var utc_time = Time.get_datetime_dict_from_system(true)
	
	# Calculate offset
	var system_hour = system_time.hour
	var utc_hour = utc_time.hour
	var offset = system_hour - utc_hour
	
	# Handle day wraparound
	if offset > 12:
		offset -= 24
	elif offset < -12:
		offset += 24
	
	# Find matching city
	detected_timezone = get_closest_city(offset)
	var sign = "+" if offset >= 0 else ""
	print("Detected timezone: ", detected_timezone, " (UTC", sign, offset, ")")

func get_closest_city(offset: float) -> String:
	"""Find city with closest timezone offset"""
	var closest_city = "London"
	var closest_diff = 999.0
	
	for city in TIMEZONES:
		var diff = abs(TIMEZONES[city] - offset)
		if diff < closest_diff:
			closest_diff = diff
			closest_city = city
	
	return closest_city

func update_all_clocks():
	"""Update time for all active cities"""
	for city in active_cities:
		var time_data = get_time_for_city(city)
		time_updated.emit(city, time_data.time_string, time_data.timezone_string)

func get_time_for_city(city_name: String) -> Dictionary:
	"""Get current time for specified city"""
	if not TIMEZONES.has(city_name):
		return {"time_string": "N/A", "timezone_string": "N/A"}
	
	var offset = TIMEZONES[city_name]
	var utc_time = Time.get_datetime_dict_from_system(true)
	
	# Calculate local hour
	var local_hour = utc_time.hour + int(offset)
	var local_minute = utc_time.minute + int((offset - int(offset)) * 60)
	
	# Handle minute overflow
	if local_minute >= 60:
		local_hour += 1
		local_minute -= 60
	elif local_minute < 0:
		local_hour -= 1
		local_minute += 60
	
	# Handle hour wraparound
	if local_hour >= 24:
		local_hour -= 24
	elif local_hour < 0:
		local_hour += 24
	
	# Format time string (12-hour with AM/PM)
	var is_pm = local_hour >= 12
	var display_hour = local_hour
	if display_hour == 0:
		display_hour = 12
	elif display_hour > 12:
		display_hour -= 12
	
	var time_string = "%02d:%02d %s" % [display_hour, local_minute, "PM" if is_pm else "AM"]
	
	# Format timezone string
	var tz_sign = "+" if offset >= 0 else ""
	var timezone_string = "UTC%s%d" % [tz_sign, int(offset)]
	if offset != int(offset):
		timezone_string += ":30"
	
	return {
		"time_string": time_string,
		"timezone_string": timezone_string,
		"hour_24": local_hour,
		"minute": local_minute,
		"offset": offset
	}

func get_time_for_timezone_offset(offset: float) -> Dictionary:
	"""Get time for any timezone offset"""
	var utc_time = Time.get_datetime_dict_from_system(true)
	
	var local_hour = utc_time.hour + int(offset)
	var local_minute = utc_time.minute + int((offset - int(offset)) * 60)
	
	# Handle wraparound
	if local_minute >= 60:
		local_hour += 1
		local_minute -= 60
	if local_hour >= 24:
		local_hour -= 24
	elif local_hour < 0:
		local_hour += 24
	
	return {
		"hour": local_hour,
		"minute": local_minute,
		"second": utc_time.second
	}

func set_active_cities(cities: Array):
	"""Change which cities to display"""
	active_cities = cities
	update_all_clocks()

func get_available_cities() -> Array:
	"""Get list of all available cities"""
	var cities = []
	for city in TIMEZONES:
		cities.append(city)
	cities.sort()
	return cities

func get_user_local_time() -> String:
	"""Get formatted time in user's detected timezone"""
	if detected_timezone:
		var time_data = get_time_for_city(detected_timezone)
		return time_data.time_string
	else:
		var system_time = Time.get_datetime_dict_from_system()
		var hour = system_time.hour
		var minute = system_time.minute
		var is_pm = hour >= 12
		var display_hour = hour if hour <= 12 else hour - 12
		if display_hour == 0:
			display_hour = 12
		return "%02d:%02d %s" % [display_hour, minute, "PM" if is_pm else "AM"]

func format_time_24hr(hour: int, minute: int, second: int = 0) -> String:
	"""Format time in 24-hour format"""
	return "%02d:%02d:%02d" % [hour, minute, second]

func format_time_12hr(hour: int, minute: int) -> String:
	"""Format time in 12-hour format with AM/PM"""
	var is_pm = hour >= 12
	var display_hour = hour
	if display_hour == 0:
		display_hour = 12
	elif display_hour > 12:
		display_hour -= 12
	return "%02d:%02d %s" % [display_hour, minute, "PM" if is_pm else "AM"]
