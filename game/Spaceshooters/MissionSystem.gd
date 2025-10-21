extends Node

# Mission System - Handles mission objectives, tracking, and rewards

signal mission_started(mission_data)
signal mission_completed(mission_data, rewards)
signal mission_failed(mission_data)
signal objective_updated(objective_text, progress, total)

# Mission types
enum MissionType {
	DESTROY_ENEMIES,
	SURVIVE_TIME,
	COLLECT_POWERUPS,
	REACH_SCORE,
	PROTECT_AREA,
	BOSS_BATTLE,
	EXPLORATION,
	ESCORT
}

# Current mission data
var current_mission: Dictionary = {}
var mission_active: bool = false
var mission_progress: Dictionary = {}

# Available missions database
const MISSIONS = {
	"rookie_destroyer": {
		"id": "rookie_destroyer",
		"name": "Rookie Destroyer",
		"description": "Destroy 20 enemy ships",
		"type": MissionType.DESTROY_ENEMIES,
		"objectives": {
			"enemies_destroyed": 20
		},
		"rewards": {
			"boosters": 100,
			"xp": 50
		},
		"difficulty": "Easy",
		"time_limit": 180  # 3 minutes
	},
	"survival_expert": {
		"id": "survival_expert",
		"name": "Survival Expert",
		"description": "Survive for 5 minutes without dying",
		"type": MissionType.SURVIVE_TIME,
		"objectives": {
			"survive_seconds": 300
		},
		"rewards": {
			"boosters": 200,
			"xp": 100
		},
		"difficulty": "Medium",
		"time_limit": 300
	},
	"power_collector": {
		"id": "power_collector",
		"name": "Power Collector",
		"description": "Collect 15 power-ups",
		"type": MissionType.COLLECT_POWERUPS,
		"objectives": {
			"powerups_collected": 15
		},
		"rewards": {
			"boosters": 150,
			"xp": 75
		},
		"difficulty": "Easy",
		"time_limit": 240
	},
	"score_master": {
		"id": "score_master",
		"name": "Score Master",
		"description": "Reach a score of 5000 points",
		"type": MissionType.REACH_SCORE,
		"objectives": {
			"score_reached": 5000
		},
		"rewards": {
			"boosters": 300,
			"xp": 150
		},
		"difficulty": "Hard",
		"time_limit": 300
	},
	"asteroid_annihilator": {
		"id": "asteroid_annihilator",
		"name": "Asteroid Annihilator",
		"description": "Clear Asteroid Belt map with 100% accuracy",
		"type": MissionType.DESTROY_ENEMIES,
		"objectives": {
			"enemies_destroyed": 30,
			"accuracy": 100
		},
		"rewards": {
			"boosters": 500,
			"xp": 250,
			"unlock": "elite_ship"
		},
		"difficulty": "Hard",
		"required_map": "asteroid_belt",
		"time_limit": 240
	},
	"ice_breaker": {
		"id": "ice_breaker",
		"name": "Ice Breaker",
		"description": "Complete Ice Field without taking damage",
		"type": MissionType.SURVIVE_TIME,
		"objectives": {
			"survive_seconds": 180,
			"damage_taken": 0
		},
		"rewards": {
			"boosters": 400,
			"xp": 200,
			"unlock": "ice_shield"
		},
		"difficulty": "Hard",
		"required_map": "ice_field",
		"time_limit": 180
	},
	"boss_hunter": {
		"id": "boss_hunter",
		"name": "Boss Hunter",
		"description": "Defeat the Space Station Boss",
		"type": MissionType.BOSS_BATTLE,
		"objectives": {
			"boss_defeated": 1
		},
		"rewards": {
			"boosters": 1000,
			"xp": 500,
			"unlock": "legendary_weapon"
		},
		"difficulty": "Extreme",
		"required_map": "space_station",
		"time_limit": 600
	}
}

func _ready():
	# Initialize mission system
	pass

func start_mission(mission_id: String) -> bool:
	if not MISSIONS.has(mission_id):
		print("Mission not found: ", mission_id)
		return false
	
	if mission_active:
		print("Mission already active")
		return false
	
	current_mission = MISSIONS[mission_id].duplicate(true)
	mission_active = true
	mission_progress = {}
	
	# Initialize progress tracking
	for objective in current_mission.objectives:
		mission_progress[objective] = 0
	
	mission_started.emit(current_mission)
	print("Mission started: ", current_mission.name)
	return true

func update_objective(objective_key: String, value: int):
	if not mission_active:
		return
	
	if not mission_progress.has(objective_key):
		return
	
	mission_progress[objective_key] = value
	
	# Emit progress update
	var required = current_mission.objectives[objective_key]
	objective_updated.emit(objective_key, value, required)
	
	# Check if objective completed
	check_mission_completion()

func increment_objective(objective_key: String, amount: int = 1):
	if not mission_active:
		return
	
	if not mission_progress.has(objective_key):
		return
	
	mission_progress[objective_key] += amount
	
	# Emit progress update
	var required = current_mission.objectives[objective_key]
	var current = mission_progress[objective_key]
	objective_updated.emit(objective_key, current, required)
	
	# Check if objective completed
	check_mission_completion()

func check_mission_completion():
	if not mission_active:
		return
	
	# Check if all objectives met
	for objective_key in current_mission.objectives:
		var required = current_mission.objectives[objective_key]
		var current = mission_progress[objective_key]
		
		if current < required:
			return  # Not all objectives complete
	
	# All objectives complete!
	complete_mission()

func complete_mission():
	if not mission_active:
		return
	
	mission_active = false
	mission_completed.emit(current_mission, current_mission.rewards)
	print("Mission completed: ", current_mission.name)
	print("Rewards: ", current_mission.rewards)

func fail_mission():
	if not mission_active:
		return
	
	mission_active = false
	mission_failed.emit(current_mission)
	print("Mission failed: ", current_mission.name)

func get_mission_progress_text() -> String:
	if not mission_active:
		return "No active mission"
	
	var text = current_mission.name + "\n"
	
	for objective_key in current_mission.objectives:
		var required = current_mission.objectives[objective_key]
		var current = mission_progress[objective_key]
		var objective_name = objective_key.replace("_", " ").capitalize()
		text += "%s: %d/%d\n" % [objective_name, current, required]
	
	return text

func get_all_missions() -> Dictionary:
	return MISSIONS

func get_mission_by_difficulty(difficulty: String) -> Array:
	var missions = []
	for mission_id in MISSIONS:
		var mission = MISSIONS[mission_id]
		if mission.difficulty == difficulty:
			missions.append(mission)
	return missions

func is_mission_available(mission_id: String, player_data: Dictionary) -> bool:
	if not MISSIONS.has(mission_id):
		return false
	
	var mission = MISSIONS[mission_id]
	
	# Check if required map is unlocked (if specified)
	if mission.has("required_map"):
		if not player_data.get("unlocked_maps", []).has(mission.required_map):
			return false
	
	# Check if player meets level requirements (if any)
	if mission.has("required_level"):
		if player_data.get("level", 1) < mission.required_level:
			return false
	
	return true
