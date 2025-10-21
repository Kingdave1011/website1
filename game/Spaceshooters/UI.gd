extends CanvasLayer

# UI Elements
@onready var score_label = $ScoreLabel
@onready var health_label = $HealthLabel
@onready var time_label = $TimeLabel
@onready var wave_label = $WaveLabel if has_node("WaveLabel") else null
@onready var game_timer_label = $GameTimerLabel if has_node("GameTimerLabel") else null
@onready var game_over_panel = $GameOverPanel
@onready var final_score_label = $GameOverPanel/FinalScoreLabel
@onready var restart_label = $GameOverPanel/RestartLabel
@onready var pause_panel = $PausePanel if has_node("PausePanel") else null
@onready var wave_transition_label = $WaveTransitionLabel if has_node("WaveTransitionLabel") else null

func _ready():
	game_over_panel.visible = false
	if pause_panel:
		pause_panel.visible = false
	if wave_transition_label:
		wave_transition_label.visible = false
	update_time()

func _process(_delta):
	update_time()

func update_score(new_score: int):
	score_label.text = "Score: " + str(new_score)

func update_health(new_health: int):
	health_label.text = "Health: " + str(new_health)

func update_timer(elapsed_time: float):
	if game_timer_label:
		var minutes = int(elapsed_time) / 60
		var seconds = int(elapsed_time) % 60
		game_timer_label.text = "Time: %02d:%02d" % [minutes, seconds]

func update_time():
	if time_label:
		var time_dict = Time.get_datetime_dict_from_system()
		var hour = time_dict.hour
		var minute = time_dict.minute
		var second = time_dict.second
		
		# Format time as HH:MM:SS
		var time_string = "%02d:%02d:%02d" % [hour, minute, second]
		time_label.text = "Time: " + time_string

func show_pause_menu(is_paused: bool):
	if pause_panel:
		pause_panel.visible = is_paused

func show_wave_transition(wave_number: int):
	if wave_transition_label:
		wave_transition_label.text = "Wave " + str(wave_number) + " Starting!"
		wave_transition_label.visible = true
		await get_tree().create_timer(2.0).timeout
		wave_transition_label.visible = false
	
	if wave_label:
		wave_label.text = "Wave: " + str(wave_number)

func show_game_over(final_score: int):
	game_over_panel.visible = true
	final_score_label.text = "Final Score: " + str(final_score)
