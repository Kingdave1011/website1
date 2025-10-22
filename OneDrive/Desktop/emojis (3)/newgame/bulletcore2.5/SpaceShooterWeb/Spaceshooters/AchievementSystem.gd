extends Node

# Achievement System - Tracks and rewards player accomplishments

signal achievement_unlocked(achievement_data)
signal achievement_progress_updated(achievement_id, progress, total)

# Achievement categories
enum AchievementCategory {
	COMBAT,
	SURVIVAL,
	COLLECTION,
	EXPLORATION,
	MASTERY,
	SECRET
}

# Player achievement data (would be saved/loaded)
var unlocked_achievements: Array = []
var achievement_progress: Dictionary = {}

# Achievement database
const ACHIEVEMENTS = {
	"first_blood": {
		"id": "first_blood",
		"name": "First Blood",
		"description": "Destroy your first enemy",
		"category": AchievementCategory.COMBAT,
		"requirement": {"enemies_killed": 1},
		"rewards": {"boosters": 50, "title": "Rookie Hunter"},
		"icon": "res://icons/achievement_first_blood.png",
		"secret": false
	},
	"ace_pilot": {
		"id": "ace_pilot",
		"name": "Ace Pilot",
		"description": "Destroy 100 enemies",
		"category": AchievementCategory.COMBAT,
		"requirement": {"enemies_killed": 100},
		"rewards": {"boosters": 500, "title": "Ace Pilot", "unlock": "ace_decal"},
		"icon": "res://icons/achievement_ace.png",
		"secret": false
	},
	"legendary_warrior": {
		"id": "legendary_warrior",
		"name": "Legendary Warrior",
		"description": "Destroy 1000 enemies",
		"category": AchievementCategory.COMBAT,
		"requirement": {"enemies_killed": 1000},
		"rewards": {"boosters": 5000, "title": "Legendary Warrior", "unlock": "legendary_ship"},
		"icon": "res://icons/achievement_legend.png",
		"secret": false
	},
	"untouchable": {
		"id": "untouchable",
		"name": "Untouchable",
		"description": "Complete a match without taking damage",
		"category": AchievementCategory.SURVIVAL,
		"requirement": {"match_no_damage": 1},
		"rewards": {"boosters": 300, "title": "Untouchable"},
		"icon": "res://icons/achievement_untouchable.png",
		"secret": false
	},
	"survivor": {
		"id": "survivor",
		"name": "Survivor",
		"description": "Survive for 10 minutes in endless mode",
		"category": AchievementCategory.SURVIVAL,
		"requirement": {"survival_time": 600},
		"rewards": {"boosters": 400, "title": "Survivor"},
		"icon": "res://icons/achievement_survivor.png",
		"secret": false
	},
	"collector": {
		"id": "collector",
		"name": "Power Collector",
		"description": "Collect 50 power-ups",
		"category": AchievementCategory.COLLECTION,
		"requirement": {"powerups_collected": 50},
		"rewards": {"boosters": 200, "unlock": "rare_powerup"},
		"icon": "res://icons/achievement_collector.png",
		"secret": false
	},
	"explorer": {
		"id": "explorer",
		"name": "Space Explorer",
		"description": "Visit all 7 maps",
		"category": AchievementCategory.EXPLORATION,
		"requirement": {"maps_visited": 7},
		"rewards": {"boosters": 300, "title": "Explorer"},
		"icon": "res://icons/achievement_explorer.png",
		"secret": false
	},
	"map_master": {
		"id": "map_master",
		"name": "Map Master",
		"description": "Complete all missions on all maps",
		"category": AchievementCategory.MASTERY,
		"requirement": {"missions_completed": 21},  # 3 missions per map × 7 maps
		"rewards": {"boosters": 2000, "title": "Map Master", "unlock": "master_emblem"},
		"icon": "res://icons/achievement_master.png",
		"secret": false
	},
	"perfect_accuracy": {
		"id": "perfect_accuracy",
		"name": "Sniper Elite",
		"description": "Achieve 100% accuracy in a match (min 20 shots)",
		"category": AchievementCategory.MASTERY,
		"requirement": {"perfect_accuracy": 1, "min_shots": 20},
		"rewards": {"boosters": 500, "title": "Sniper Elite"},
		"icon": "res://icons/achievement_sniper.png",
		"secret": false
	},
	"speed_demon": {
		"id": "speed_demon",
		"name": "Speed Demon",
		"description": "Complete a mission in under 60 seconds",
		"category": AchievementCategory.MASTERY,
		"requirement": {"mission_time_under": 60},
		"rewards": {"boosters": 400, "unlock": "speed_boost"},
		"icon": "res://icons/achievement_speed.png",
		"secret": false
	},
	"secret_hunter": {
		"id": "secret_hunter",
		"name": "Secret Hunter",
		"description": "Find the hidden ship in Debris Field",
		"category": AchievementCategory.SECRET,
		"requirement": {"secret_found": "hidden_ship"},
		"rewards": {"boosters": 1000, "unlock": "secret_ship"},
		"icon": "res://icons/achievement_secret.png",
		"secret": true
	},
	"pacifist": {
		"id": "pacifist",
		"name": "Pacifist",
		"description": "Complete a match without firing a single shot",
		"category": AchievementCategory.SECRET,
		"requirement": {"shots_fired": 0, "match_completed": 1},
		"rewards": {"boosters": 800, "title": "The Pacifist"},
		"icon": "res://icons/achievement_pacifist.png",
		"secret": true
	},
	"glass_cannon": {
		"id": "glass_cannon",
		"name": "Glass Cannon",
		"description": "Defeat a boss with only 1 HP remaining",
		"category": AchievementCategory.SECRET,
		"requirement": {"boss_kill_low_hp": 1},
		"rewards": {"boosters": 600, "title": "Glass Cannon"},
		"icon": "res://icons/achievement_glass.png",
		"secret": true
	}
}

func _ready():
	# Load saved achievement data
	load_achievement_data()

func track_stat(stat_name: String, value: int):
	# Update achievement progress for relevant achievements
	for achievement_id in ACHIEVEMENTS:
		var achievement = ACHIEVEMENTS[achievement_id]
		
		# Skip if already unlocked
		if is_unlocked(achievement_id):
			continue
		
		# Check if this stat is tracked by this achievement
		if achievement.requirement.has(stat_name):
			# Initialize progress if needed
			if not achievement_progress.has(achievement_id):
				achievement_progress[achievement_id] = {}
			
			# Update progress
			achievement_progress[achievement_id][stat_name] = value
			
			# Emit progress update
			var required = achievement.requirement[stat_name]
			achievement_progress_updated.emit(achievement_id, value, required)
			
			# Check if unlocked
			check_achievement_unlock(achievement_id)

func check_achievement_unlock(achievement_id: String):
	if is_unlocked(achievement_id):
		return
	
	var achievement = ACHIEVEMENTS[achievement_id]
	var progress = achievement_progress.get(achievement_id, {})
	
	# Check all requirements
	for req_key in achievement.requirement:
		var required_value = achievement.requirement[req_key]
		var current_value = progress.get(req_key, 0)
		
		if current_value < required_value:
			return  # Requirement not met
	
	# All requirements met!
	unlock_achievement(achievement_id)

func unlock_achievement(achievement_id: String):
	if is_unlocked(achievement_id):
		return
	
	unlocked_achievements.append(achievement_id)
	var achievement = ACHIEVEMENTS[achievement_id]
	
	achievement_unlocked.emit(achievement)
	print("🏆 Achievement Unlocked: ", achievement.name)
	print("Rewards: ", achievement.rewards)
	
	# Save achievement data
	save_achievement_data()

func is_unlocked(achievement_id: String) -> bool:
	return unlocked_achievements.has(achievement_id)

func get_achievement_progress(achievement_id: String) -> Dictionary:
	return achievement_progress.get(achievement_id, {})

func get_all_achievements() -> Dictionary:
	return ACHIEVEMENTS

func get_achievements_by_category(category: AchievementCategory) -> Array:
	var results = []
	for achievement_id in ACHIEVEMENTS:
		var achievement = ACHIEVEMENTS[achievement_id]
		if achievement.category == category:
			results.append(achievement)
	return results

func get_unlocked_count() -> int:
	return unlocked_achievements.size()

func get_total_count() -> int:
	return ACHIEVEMENTS.size()

func get_completion_percentage() -> float:
	if ACHIEVEMENTS.size() == 0:
		return 0.0
	return (float(unlocked_achievements.size()) / float(ACHIEVEMENTS.size())) * 100.0

func save_achievement_data():
	# Save to file (implement based on your save system)
	var save_data = {
		"unlocked": unlocked_achievements,
		"progress": achievement_progress
	}
	# TODO: Implement actual save to file
	print("Achievements saved")

func load_achievement_data():
	# Load from file (implement based on your save system)
	# TODO: Implement actual load from file
	print("Achievements loaded")
