extends Node

# Daily Challenge System - Fresh challenges every day with bonus rewards

signal challenge_available(challenge_data)
signal challenge_completed(challenge_data, rewards)
signal challenge_expired()

# Challenge tracking
var current_challenge: Dictionary = {}
var challenge_start_time: int = 0
var challenge_completion_time: int = 0
var challenge_active: bool = false
var is_completed: bool = false

# Challenge types
enum ChallengeType {
	SPEED_RUN,
	NO_DAMAGE,
	PERFECT_ACCURACY,
	SPECIFIC_WEAPON,
	LIMITED_AMMO,
	TIME_ATTACK,
	BOSS_RUSH,
	SURVIVAL_GAUNTLET,
	COLLECT_ALL,
	COMBO_MASTER
}

# Challenge database (rotates based on day of year)
const CHALLENGE_POOL = [
	{
		"name": "Speed Demon",
		"description": "Complete any map in under 90 seconds",
		"type": ChallengeType.SPEED_RUN,
		"objectives": {"completion_time_under": 90},
		"rewards": {"boosters": 300, "xp": 150, "title": "Speed Demon"},
		"difficulty": "Hard"
	},
	{
		"name": "Untouchable",
		"description": "Complete a match without taking any damage",
		"type": ChallengeType.NO_DAMAGE,
		"objectives": {"damage_taken": 0, "match_completed": 1},
		"rewards": {"boosters": 400, "xp": 200, "unlock": "invincibility_boost"},
		"difficulty": "Extreme"
	},
	{
		"name": "Marksman",
		"description": "Achieve 95% accuracy or higher (min 30 shots)",
		"type": ChallengeType.PERFECT_ACCURACY,
		"objectives": {"accuracy": 95, "shots_fired": 30},
		"rewards": {"boosters": 350, "xp": 175},
		"difficulty": "Hard"
	},
	{
		"name": "Laser Master",
		"description": "Complete a match using only laser weapons",
		"type": ChallengeType.SPECIFIC_WEAPON,
		"objectives": {"weapon_used": "laser", "enemies_killed": 25},
		"rewards": {"boosters": 250, "xp": 125, "unlock": "laser_skin"},
		"difficulty": "Medium"
	},
	{
		"name": "Conservative",
		"description": "Win with less than 50 shots fired",
		"type": ChallengeType.LIMITED_AMMO,
		"objectives": {"shots_fired_max": 50, "victory": 1},
		"rewards": {"boosters": 400, "xp": 200},
		"difficulty": "Hard"
	},
	{
		"name": "3-Minute Madness",
		"description": "Survive 3 minutes in endless mode",
		"type": ChallengeType.TIME_ATTACK,
		"objectives": {"survival_time": 180, "mode": "endless"},
		"rewards": {"boosters": 300, "xp": 150},
		"difficulty": "Medium"
	},
	{
		"name": "Boss Marathon",
		"description": "Defeat 3 bosses in a single session",
		"type": ChallengeType.BOSS_RUSH,
		"objectives": {"bosses_defeated": 3},
		"rewards": {"boosters": 600, "xp": 300, "unlock": "boss_hunter_badge"},
		"difficulty": "Extreme"
	},
	{
		"name": "Gauntlet Survivor",
		"description": "Clear waves 1-5 without dying once",
		"type": ChallengeType.SURVIVAL_GAUNTLET,
		"objectives": {"waves_completed": 5, "deaths": 0},
		"rewards": {"boosters": 500, "xp": 250},
		"difficulty": "Hard"
	},
	{
		"name": "Power Hoarder",
		"description": "Collect all 10 types of power-ups in one match",
		"type": ChallengeType.COLLECT_ALL,
		"objectives": {"unique_powerups": 10},
		"rewards": {"boosters": 350, "xp": 175, "unlock": "power_magnet"},
		"difficulty": "Medium"
	},
	{
		"name": "Combo King",
		"description": "Achieve a 50-hit combo",
		"type": ChallengeType.COMBO_MASTER,
		"objectives": {"max_combo": 50},
		"rewards": {"boosters": 400, "xp": 200, "title": "Combo King"},
		"difficulty": "Hard"
	}
]

func _ready():
	load_daily_challenge()

func load_daily_challenge():
	"""Load today's challenge based on day of year"""
	var date = Time.get_datetime_dict_from_system()
	var day_of_year = get_day_of_year(date)
	
	# Rotate through challenges (10-day cycle)
	var challenge_index = day_of_year % CHALLENGE_POOL.size()
	current_challenge = CHALLENGE_POOL[challenge_index].duplicate(true)
	
	# Check if already completed today
	var save_data = load_save_data()
	if save_data.has("last_challenge_day"):
		if save_data.last_challenge_day == day_of_year:
			is_completed = save_data.get("challenge_completed", false)
	
	challenge_active = not is_completed
	challenge_start_time = Time.get_unix_time_from_system()
	
	if challenge_active:
		challenge_available.emit(current_challenge)
		print("Today's challenge: ", current_challenge.name)
	else:
		print("Daily challenge already completed!")

func get_day_of_year(date: Dictionary) -> int:
	"""Calculate day of year (1-365/366)"""
	var days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	
	# Check leap year
	var year = date.year
	if (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0):
		days_in_month[1] = 29
	
	var day_count = date.day
	for i in range(date.month - 1):
		day_count += days_in_month[i]
	
	return day_count

func check_challenge_objective(objective_key: String, value):
	"""Check if challenge objective is met"""
	if not challenge_active or is_completed:
		return
	
	if not current_challenge.objectives.has(objective_key):
		return
	
	var required = current_challenge.objectives[objective_key]
	
	# Check if met
	var is_met = false
	if objective_key.ends_with("_max"):
		is_met = value <= required
	elif objective_key.ends_with("_under"):
		is_met = value < required
	else:
		is_met = value >= required
	
	if is_met:
		# Check all other objectives
		# (In real implementation, track all objectives)
		complete_challenge()

func complete_challenge():
	"""Mark challenge as completed and give rewards"""
	if is_completed:
		return
	
	is_completed = true
	challenge_active = false
	challenge_completion_time = Time.get_unix_time_from_system()
	
	# Save completion
	save_challenge_completion()
	
	# Emit completion signal
	challenge_completed.emit(current_challenge, current_challenge.rewards)
	print("Daily challenge completed!")
	print("Rewards: ", current_challenge.rewards)

func get_time_remaining() -> int:
	"""Get seconds until next challenge (midnight)"""
	var current_time = Time.get_datetime_dict_from_system()
	var seconds_today = current_time.hour * 3600 + current_time.minute * 60 + current_time.second
	var seconds_in_day = 86400
	return seconds_in_day - seconds_today

func format_time_remaining() -> String:
	"""Format time remaining as HH:MM:SS"""
	var seconds = get_time_remaining()
	var hours = seconds / 3600
	var minutes = (seconds % 3600) / 60
	var secs = seconds % 60
	return "%02d:%02d:%02d" % [hours, minutes, secs]

func is_challenge_available() -> bool:
	"""Check if challenge is available (not completed today)"""
	return challenge_active and not is_completed

func get_current_challenge() -> Dictionary:
	"""Get today's challenge data"""
	return current_challenge

func get_challenge_progress_text() -> String:
	"""Get formatted progress string"""
	if is_completed:
		return "Completed! ✓"
	elif not challenge_active:
		return "Not available"
	else:
		return "In Progress..."

func save_challenge_completion():
	"""Save challenge completion status"""
	var date = Time.get_datetime_dict_from_system()
	var day_of_year = get_day_of_year(date)
	
	var save_data = {
		"last_challenge_day": day_of_year,
		"challenge_completed": true,
		"completion_time": challenge_completion_time
	}
	
	# TODO: Implement actual file save
	print("Challenge completion saved")

func load_save_data() -> Dictionary:
	"""Load save data"""
	# TODO: Implement actual file load
	return {}
