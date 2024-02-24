class_name Enemy
extends CharacterBody2D

var EnemyType : EnemyTypes.Type = EnemyTypes.Type.NORMAL
var speed : float
var health : float
var stunDuration : float
var isStunned : bool = false
var player : Player
var stunTimer : Timer
var cooldown: bool = false
var damageAmount
var bugCooldown = false
var direction: Vector2 = Vector2.ZERO
@onready var cooldownTimer: Timer = $cooldown
@onready var bugCooldownTimer: Timer = $bugCooldown
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var animationTree: AnimationTree = $AnimationTree
var player_contact = false

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
	modulate = Global.theme.secondary
	
func _on_Player_body_entered():
	player_contact = true

func _on_Player_body_exited():
	player_contact = false
		
func _process(_delta):
	animationTree["parameters/run/blend_position"] = direction
	if player_contact:
		player.damage()

func _physics_process(_delta: float) -> void:
	if StatsUtils.currentStats.health <= 0:
		return
	_handle_movement()
	move_and_slide()

func deal_damage(body: Node2D):
	if !body.is_in_group(Global.PlayerGroup) && !cooldown:
		return
	cooldown = true
	cooldownTimer.start()
	(body as Player).damage(damageAmount)

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
	if isStunned || player == null:
		velocity = Vector2.ZERO
		return
	var playerPosition : Vector2 = player.position
	direction = (playerPosition - position).normalized()
	if position.distance_to(playerPosition) > 2:
		velocity = direction * speed

func _on_stun_timer_timeout() -> void:
	isStunned = false

