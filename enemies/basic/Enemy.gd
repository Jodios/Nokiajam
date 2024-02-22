class_name Enemy
extends CharacterBody2D

var EnemyType : EnemyTypes.Type = EnemyTypes.Type.NORMAL
var speed : float
var health : float
var stunDuration : float
var isStunned : bool = false
var player : Node2D
var stunTimer : Timer

func _ready():
	add_to_group(Global.EnemyGroup)
	player = get_tree().root.get_node("Main/Player")
	var properties = EnemyTypes.EnemyTypeProperties[EnemyType]
	health = properties.health
	speed = properties.speed
	stunDuration = properties.stun_duration
	stunTimer = Timer.new()
	add_child(stunTimer)
	stunTimer.one_shot = true
	stunTimer.wait_time = stunDuration
	stunTimer.timeout.connect(_on_stun_timer_timeout)

func _process(_delta: float) -> void:
	modulate = Global.theme.secondary

func _physics_process(_delta: float) -> void:
	_handle_movement()

func stun() -> void:
	StatsUtils.add_enemy_stunned()
	if not isStunned:
		isStunned = true
		stunTimer.wait_time = stunDuration
		stunTimer.start()
	else:
		stunTimer.wait_time = stunDuration

func damage(damageTaken: float) -> void:
	SoundUtils.play_enemy_hit_sound()
	health -= damageTaken
	if health <= 0:
		die()

func die() -> void:
	speed = 0
	StatsUtils.add_enemy_death()
	queue_free()

func _handle_movement() -> void:
	if isStunned:
		return
	var playerPosition : Vector2 = player.position
	var targetPosition : Vector2 = (playerPosition - position).normalized()
	if position.distance_to(playerPosition) > 2:
		velocity = targetPosition * speed
		move_and_slide()
		look_at(playerPosition)

func _on_stun_timer_timeout() -> void:
	isStunned = false
