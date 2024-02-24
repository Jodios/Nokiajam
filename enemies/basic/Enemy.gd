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
@onready var cooldownTimer: Timer = $cooldown
@onready var bugCooldownTimer: Timer = $bugCooldown

func _ready():
	cooldownTimer.timeout.connect(func():
		cooldown = false
	)
	bugCooldownTimer.timeout.connect(func():
		bugCooldown = false
	)
	add_to_group(Global.EnemyGroup)
	player = get_tree().root.get_node("Main/Player")
	var properties = EnemyTypes.EnemyTypeProperties[EnemyType]
	health = properties.health
	damageAmount = properties.damage
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
	for i in range(get_slide_collision_count()-1):
		var c: KinematicCollision2D = get_slide_collision(i)
		var collider = c.get_collider()
		if collider is Player && !bugCooldown:
			bugCooldown = true
			bugCooldownTimer.start()
			deal_damage(c.get_collider())
			break
	_handle_movement()
	move_and_slide()

func deal_damage(body: Node2D):
	if !body.is_in_group(Global.PlayerGroup) && !cooldown:
		return
	print(body)
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
	var targetPosition : Vector2 = (playerPosition - position).normalized()
	if position.distance_to(playerPosition) > 2:
		velocity = targetPosition * speed
		look_at(playerPosition)

func _on_stun_timer_timeout() -> void:
	isStunned = false
