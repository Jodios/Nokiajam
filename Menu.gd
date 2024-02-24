extends Node2D

@onready
var background: ColorRect = $background
@onready
var label: Label = $Label

func _ready():
	SoundUtils.play_music()
	label.add_theme_color_override("font_color", Global.theme.secondary)

func _process(_delta):
	modulate = Global.theme.primary
	if Input.is_action_just_pressed("shoot"):
		SoundUtils.stop_music()
		get_tree().change_scene_to_file("res://levels/Main.tscn")
