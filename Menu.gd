extends Node2D

@onready
var background: ColorRect = $background

func _process(_delta):
    modulate = Global.theme.primary
