class_name Player
extends CharacterBody2D

@export var MaxHealth : int = 3
@export var MaxStuns : int = 3
@export var Speed : float = 900
@export var ProjectileType : ProjectileTypes.Type = ProjectileTypes.Type.Multiply

var PlayerHealth : int = 0
var Stuns : int = 0

signal PlayerPerished

var previousDirection : Vector2
var coolingDown : bool = false
var circleCoolingDown : bool = false
var multipleCoolingDown : bool = false
var stunCoolingDown : bool = false

@onready var cooldownTimer : Timer = $cooldown
@onready var multipleTimer : Timer = $multipleTimer
@onready var circleTimer : Timer = $circleTimer
@onready var stunTimer : Timer = $stunTimer
@onready var animationPlayer: AnimationPlayer = $playerAnimationPlayer
var lastPressedDirection = "right"

func _ready():
	PlayerHealth = MaxHealth
	Stuns = MaxStuns
	Global.playerHealth = PlayerHealth
	Global.playerStuns = Stuns
	previousDirection = Vector2.RIGHT
	add_to_group(Global.PlayerGroup)
	cooldownTimer.timeout.connect(_on_cooldown_timeout)
	multipleTimer.timeout.connect(func ():
		multipleCoolingDown = false
	)
	circleTimer.timeout.connect(func ():
		circleCoolingDown = false
	)
	stunTimer.timeout.connect(func ():
		stunCoolingDown = false
	)

func _process(_delta: float) -> void:
	if velocity != Vector2.ZERO:
		_animate_run()
	else:
		_animate_idle()
	Global.setStats(PlayerHealth, Stuns)
	_handle_shooting_action()
	_handle_stun_action()

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	move_and_slide()

func _on_cooldown_timeout() -> void:
	coolingDown = false

func damage(damageTaken: int) -> void:
	PlayerHealth -= damageTaken
	if PlayerHealth <= 0:
		die()

func die() -> void:
	Speed = 0
	queue_free()
	emit_signal("PlayerPerished")

func _handle_stun_action() -> void:
	if Input.is_action_just_pressed("freeze") && Stuns > 0 && !stunCoolingDown:
		Stuns -= 1
		StatsUtils.add_stun_used()
		SoundUtils.play_freeze_action_sound()
		var enemies = get_tree().get_nodes_in_group(Global.EnemyGroup)
		for enemy in enemies:
			enemy.stun()

func _handle_shooting_action() -> void:
	if !coolingDown && Input.is_action_just_pressed("shoot"):
		SoundUtils.play_shooting_sound()
		coolingDown = true
		cooldownTimer.start()
		_spawn_projectile("res://projectiles/BasicProjectile.tscn")
	if !multipleCoolingDown && Input.is_action_just_pressed("shootmultiple"):
		SoundUtils.play_shooting_sound()
		multipleCoolingDown = true
		multipleTimer.start()
		_multiply_projectile(6, "res://projectiles/BasicProjectile.tscn")
	if !circleCoolingDown && Input.is_action_just_pressed("shootcircle"):
		SoundUtils.play_shooting_sound()
		circleCoolingDown = true
		circleTimer.start()
		_multiply_projectile(60, "res://projectiles/BasicProjectile.tscn")

func _spawn_projectile(path: String) -> void:
	var projectileScene = load(path)
	var projectile = projectileScene.instantiate()
	projectile.start(global_position + Vector2(0, 0), previousDirection, self)
	get_tree().root.add_child(projectile)

func _multiply_projectile(amount: int, path: String) -> void:
	var projectileScene = load(path)
	for i in range(amount):
		var multiplier = 1 if i % 2 == 0 else -1
		var projectile = projectileScene.instantiate()
		projectile.start(
			global_position + Vector2(0, 0),
			previousDirection.rotated(deg_to_rad(i * 6 * multiplier)).normalized(),
			self
		)
		get_tree().root.add_child(projectile)

func _handle_movement(delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")
	if direction != Vector2.ZERO:
		previousDirection = direction
	velocity = direction * Speed * delta
	
func _animate_run():
	var left = Input.is_action_pressed("left")
	var right = Input.is_action_pressed("right")
	var up = Input.is_action_pressed("up")
	var down = Input.is_action_pressed("down")
	if right && up:
		lastPressedDirection="rightup"
		animationPlayer.play("northEastRun")
	elif right && down:
		lastPressedDirection="rightdown"
		animationPlayer.play("southEastRun")
	elif left && up:
		lastPressedDirection="leftup"
		animationPlayer.play("northWestRun")
	elif left && down:
		lastPressedDirection="leftdown"
		animationPlayer.play("southWestRun")
	elif right:
		lastPressedDirection="right"
		animationPlayer.play("eastRun")
	elif down:
		lastPressedDirection="down"
		animationPlayer.play("southRun")
	elif left:
		lastPressedDirection="left"
		animationPlayer.play("westRun")
	elif up:
		lastPressedDirection="up"
		animationPlayer.play("northRun")
	
func _animate_idle():
	if lastPressedDirection == "rightup":
		animationPlayer.play("northEastIdle")
	elif lastPressedDirection == "rightdown":
		animationPlayer.play("southEastIdle")
	elif lastPressedDirection == "leftup":
		animationPlayer.play("northWestIdle")
	elif lastPressedDirection == "leftdown":
		animationPlayer.play("southWestIdle")
	elif lastPressedDirection == "right":
		animationPlayer.play("eastIdle")
	elif lastPressedDirection == "down":
		animationPlayer.play("southIdle")
	elif lastPressedDirection == "left":
		animationPlayer.play("westIdle")
	elif lastPressedDirection == "up":
		animationPlayer.play("northIdle")
