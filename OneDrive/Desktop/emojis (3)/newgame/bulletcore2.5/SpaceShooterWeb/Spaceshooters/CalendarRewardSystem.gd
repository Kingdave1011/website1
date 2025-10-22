extends Node

# Calendar Reward System - 7-day rotating rewards calendar

signal day_reward_claimed(day, rewards)
signal calendar_reset(new_cycle_start)
signal streak_milestone(days)

# Calendar tracking
var current_cycle_start_day: int = 0
var days_claimed: Array = []
var current_streak: int = 0
var last_claim_day: int = -1

# 7-Day Reward Calendar (rotates every week)
const CALENDAR_REWARDS = {
	1: {
		"day": 1,
		"name": "Day 1: Welcome Bonus",
		"description": "Start your weekly journey",
		"rewards": {
			"boosters": 100,
			"xp": 50,
			"item": "basic_crate"
		},
		"icon": "res://icons/day1.png"
	},
	2: {
		"day": 2,
		"name": "Day 2: Combat Pack",
		"description": "Tools for battle",
		"rewards": {
			"boosters": 150,
			"xp": 75,
			"unlock": "rapid_fire_upgrade"
		},
		"icon": "res://icons/day2.png"
	},
	3: {
		"day": 3,
		"name": "Day 3: Shield Boost",
		"description": "Defensive bonus",
		"rewards": {
			"boosters": 200,
			"xp": 100,
			"unlock": "shield_generator",
			"powerup": "shield_x3"
		},
		"icon": "res://icons/day3.png"
	},
	4: {
		"day": 4,
		"name": "Day 4: Elite Package",
		"description": "Premium rewards",
		"rewards": {
			"boosters": 300,
			"xp": 150,
			"item": "elite_crate",
			"unlock": "elite_ship_skin"
		},
		"icon": "res://icons/day4.png"
	},
	5: {
		"day": 5,
		"name": "Day 5: Power Surge",
		"description": "Maximum firepower",
		"rewards": {
			"boosters": 400,
			"xp": 200,
			"unlock": "weapon_upgrade_tier2",
			"powerup": "invincibility"
		},
		"icon": "res://icons/day5.png"
	},
	6: {
		"day": 6,
		"name": "Day 6: Legendary Cache",
		"description": "Rare treasures await",
		"rewards": {
			"boosters": 500,
			"xp": 250,
			"item": "legendary_crate",
			"unlock": "legendary_weapon",
			"title": "Dedicated Player"
		},
		"icon": "res://icons/day6.png"
	},
	7: {
		"day": 7,
		"name": "Day 7: Grand Prize",
		"description": "Weekly grand finale!",
		"rewards": {
			"boosters": 1000,
			"xp": 500,
			"item": "grand_crate",
			"unlock": "exclusive_ship",
			"title": "Week Warrior",
			"special": "mystery_box"
		},
		"icon": "res://icons/day7.png",
		"special_effect": true
	}
}

func _ready():
	load_calendar_data()
	check_new_day()

func load_calendar_data():
	"""Load saved calendar progress"""
	var save_data = load_save_data()
	
	if save_data.has("cycle_start_day"):
		current_cycle_start_day = save_data.cycle_start_day
	else:
		# New player - start today
		current_cycle_start_day = get_current_day_number()
	
	days_claimed = save_data.get("days_claimed", [])
	current_streak = save_data.get("current_streak", 0)
	last_claim_day = save_data.get("last_claim_day", -1)
	
	print("Calendar loaded. Streak: ", current_streak, " days")

func check_new_day():
	"""Check if it's a new day and reset calendar if needed"""
	var current_day = get_current_day_number()
	var days_since_start = current_day - current_cycle_start_day
	
	# Reset calendar after 7 days
	if days_since_start >= 7:
		reset_calendar()
	
	# Check streak
	if last_claim_day >= 0:
		var days_since_last_claim = current_day - last_claim_day
		if days_since_last_claim > 1:
			# Streak broken
			current_streak = 0
			print("Streak broken! Days since last login: ", days_since_last_claim)

func reset_calendar():
	"""Reset calendar for new 7-day cycle"""
	var current_day = get_current_day_number()
	current_cycle_start_day = current_day
	days_claimed = []
	
	calendar_reset.emit(current_cycle_start_day)
	save_calendar_data()
	print("Calendar reset! New 7-day cycle started.")

func get_current_calendar_day() -> int:
	"""Get current day in the 7-day cycle (1-7)"""
	var current_day = get_current_day_number()
	var days_since_start = current_day - current_cycle_start_day
	return clamp(days_since_start + 1, 1, 7)

func can_claim_today() -> bool:
	"""Check if today's reward can be claimed"""
	var current_day = get_current_day_number()
	var calendar_day = get_current_calendar_day()
	
	# Check if already claimed today
	if days_claimed.has(calendar_day):
		return false
	
	# Check if this is actually today (not future day)
	if calendar_day > (current_day - current_cycle_start_day + 1):
		return false
	
	return true

func claim_today_reward() -> Dictionary:
	"""Claim today's calendar reward"""
	if not can_claim_today():
		return {}
	
	var calendar_day = get_current_calendar_day()
	var reward_data = CALENDAR_REWARDS[calendar_day]
	
	# Mark as claimed
	days_claimed.append(calendar_day)
	last_claim_day = get_current_day_number()
	current_streak += 1
	
	# Check for streak milestones
	if current_streak % 7 == 0:
		streak_milestone.emit(current_streak)
	
	# Save progress
	save_calendar_data()
	
	# Emit reward claimed
	day_reward_claimed.emit(calendar_day, reward_data.rewards)
	
	print("Day ", calendar_day, " reward claimed!")
	print("Rewards: ", reward_data.rewards)
	print("Current streak: ", current_streak, " days")
	
	return reward_data

func get_reward_for_day(day: int) -> Dictionary:
	"""Get reward data for specific day"""
	if CALENDAR_REWARDS.has(day):
		return CALENDAR_REWARDS[day]
	return {}

func is_day_claimed(day: int) -> bool:
	"""Check if specific day has been claimed"""
	return days_claimed.has(day)

func get_days_claimed_this_cycle() -> int:
	"""Get number of days claimed in current cycle"""
	return days_claimed.size()

func get_completion_percentage() -> float:
	"""Get percentage of calendar completed"""
	return (float(days_claimed.size()) / 7.0) * 100.0

func get_current_day_number() -> int:
	"""Get current day as number (days since epoch)"""
	var unix_time = Time.get_unix_time_from_system()
	return int(unix_time / 86400)  # Days since Unix epoch

func get_time_until_reset() -> int:
	"""Get seconds until calendar resets (next midnight after day 7)"""
	var current_day = get_current_day_number()
	var days_since_start = current_day - current_cycle_start_day
	var days_until_reset = 7 - days_since_start
	
	if days_until_reset <= 0:
		days_until_reset = 1
	
	# Get seconds until next midnight
	var current_time = Time.get_datetime_dict_from_system()
	var seconds_today = current_time.hour * 3600 + current_time.minute * 60 + current_time.second
	var seconds_until_midnight = 86400 - seconds_today
	
	return (days_until_reset - 1) * 86400 + seconds_until_midnight

func format_time_until_reset() -> String:
	"""Format time until reset as readable string"""
	var seconds = get_time_until_reset()
	var days = seconds / 86400
	var hours = (seconds % 86400) / 3600
	var minutes = (seconds % 3600) / 60
	
	if days > 0:
		return "%dd %dh %dm" % [days, hours, minutes]
	elif hours > 0:
		return "%dh %dm" % [hours, minutes]
	else:
		return "%dm" % [minutes]

func get_calendar_status_text() -> String:
	"""Get formatted calendar status"""
	var calendar_day = get_current_calendar_day()
	var claimed_count = days_claimed.size()
	var can_claim = can_claim_today()
	
	var text = "Calendar Progress: %d/7 days\n" % claimed_count
	text += "Current Day: Day %d\n" % calendar_day
	text += "Streak: %d days\n" % current_streak
	
	if can_claim:
		text += "✅ Reward available!\n"
	else:
		text += "⏰ Come back tomorrow\n"
	
	text += "Reset in: %s" % format_time_until_reset()
	
	return text

func save_calendar_data():
	"""Save calendar progress"""
	var save_data = {
		"cycle_start_day": current_cycle_start_day,
		"days_claimed": days_claimed,
		"current_streak": current_streak,
		"last_claim_day": last_claim_day
	}
	
	# TODO: Implement actual file save
	print("Calendar data saved")

func load_save_data() -> Dictionary:
	"""Load save data"""
	# TODO: Implement actual file load
	return {}
