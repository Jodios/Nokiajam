extends Node2D

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var background = $background

func _ready():
	SoundUtils.play_music()
	background.color = Global.theme.primary
	animationPlayer.play("introPart1")
	animationPlayer.animation_finished.connect(func(_name):
		animationPlayer.play("introPart2")
	)

func _process(_delta):
	if Input.is_action_just_pressed("shoot"):
		SoundUtils.stop_music()
		get_tree().change_scene_to_file("res://levels/Main.tscn")
