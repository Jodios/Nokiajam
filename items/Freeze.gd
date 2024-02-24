class_name Freeze
extends Node2D

# Exports
@export var Strength : int = 1

# Variables
@onready var pickupArea : Area2D = $pickupArea
@onready var meshInstance2D : MeshInstance2D = $MeshInstance2D

func _ready():
	add_to_group("item")
	pickupArea.body_entered.connect(pickup)

func _process(_delta: float) -> void:
	# Update GUI changes
	modulate = Global.theme.secondary

func pickup(body: Node) -> void:
	if not body.is_in_group(Global.PlayerGroup):
		return
	SoundUtils.play_pickup_health_item_sound()
	var player = body as Player
	var possibleVal = player.Stuns + Strength
	if possibleVal <= player.MaxStuns:
		player.Stuns = possibleVal
	else:
		player.Stuns = player.MaxStuns
	queue_free()
