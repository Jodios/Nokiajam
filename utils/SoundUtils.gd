extends Node

@onready var HealthItem : AudioStreamPlayer = $HealthItem
@onready var FreezeItem : AudioStreamPlayer = $FreezeItem
@onready var FreezePlayer : AudioStreamPlayer = $Freeze
@onready var Perish : AudioStreamPlayer = $Perish
@onready var EnemyHit : AudioStreamPlayer = $EnemyHit
@onready var Shoot : AudioStreamPlayer = $Shoot
@onready var Music : AudioStreamPlayer = $Music
var playing : bool = false

func _ready():
	HealthItem.finished.connect(_on_finished)
	FreezeItem.finished.connect(_on_finished)
	FreezePlayer.finished.connect(_on_finished)
	Perish.finished.connect(_on_finished)
	EnemyHit.finished.connect(_on_finished)
	Shoot.finished.connect(_on_finished)

func play_music() -> void:
	Music.play(0)
	Music.finished.connect(func():
		Music.play(0)
	)
func stop_music() -> void:
	Music.stop()

func play_pickup_health_item_sound() -> void:
	_play_sound(HealthItem)

func play_pickup_freeze_item_sound() -> void:
	_play_sound(FreezeItem)

func play_freeze_action_sound() -> void:
	_play_sound(FreezePlayer)

func play_perish_sound() -> void:
	_play_sound(Perish)

func play_enemy_hit_sound() -> void:
	_play_sound(EnemyHit)

func play_shooting_sound() -> void:
	_play_sound(Shoot)

func _play_sound(player: AudioStreamPlayer) -> void:
	if playing:
		return
	playing = true
	player.play(0)

func _on_finished() -> void:
	playing = false
