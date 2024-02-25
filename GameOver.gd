extends Node2D

@onready var background: ColorRect = $background
@onready var scoreLabel: Label = $scoreLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	background.color = Global.theme.primary
	scoreLabel.add_theme_color_override(
		"font_color", 
		Global.theme.secondary
	)
	scoreLabel.text = "Score: " + str(StatsUtils.timeElapsed * StatsUtils.currentStats.enemiesKilled)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
