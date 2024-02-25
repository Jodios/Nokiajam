extends Node2D

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var background = $background
var startable: bool = false

func _ready():
	SoundUtils.play_music()
	background.color = Global.theme.primary
	animationPlayer.play("introPart1")
	animationPlayer.animation_finished.connect(func(_name):
		animationPlayer.play("introPart2")
		startable = true
	)

func _process(_delta):
	if Input.is_action_just_pressed("shoot"):
		if !startable:
			animationPlayer.play("introPart2")
			startable = true
		else:
			SoundUtils.stop_music()
			get_tree().change_scene_to_file("res://levels/Main.tscn")
