extends CanvasLayer

# UI Elements
@onready var score_label = $ScoreLabel
@onready var health_label = $HealthLabel
@onready var game_over_panel = $GameOverPanel
@onready var final_score_label = $GameOverPanel/FinalScoreLabel
@onready var restart_label = $GameOverPanel/RestartLabel

func _ready():
	game_over_panel.visible = false

func update_score(new_score: int):
	score_label.text = "Score: " + str(new_score)

func update_health(new_health: int):
	health_label.text = "Health: " + str(new_health)

func show_game_over(final_score: int):
	game_over_panel.visible = true
	final_score_label.text = "Final Score: " + str(final_score)
