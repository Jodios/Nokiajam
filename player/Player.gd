class_name Player
extends CharacterBody2D

@export var Speed : float = 900
@export var ProjectileType : ProjectileTypes.Type = ProjectileTypes.Type.Multiply

signal PlayerPerished

var previousDirection : Vector2
var coolingDown : bool = false
var circleCoolingDown : bool = false
var multipleCoolingDown : bool = false
var stunCoolingDown : bool = false
var damageCoolingDown : bool = false

@onready var cooldownTimer : Timer = $cooldown
@onready var multipleTimer : Timer = $multipleTimer
@onready var circleTimer : Timer = $circleTimer
@onready var damageTimer : Timer = $damageTimer
@onready var stunTimer : Timer = $stunTimer
@onready var animationPlayer: AnimationPlayer = $playerAnimationPlayer
var lastPressedDirection = "right"

func _ready():
	previousDirection = Vector2.RIGHT
	add_to_group(Global.PlayerGroup)
	cooldownTimer.timeout.connect(_on_cooldown_timeout)
	$hitbox.connect("body_entered", Callable(self, "_on_body_entered"))
	$hitbox.connect("body_exited", Callable(self, "_on_body_exited"))
	multipleTimer.timeout.connect(func ():
		multipleCoolingDown = false
	)
	circleTimer.timeout.connect(func ():
		circleCoolingDown = false
	)
	stunTimer.timeout.connect(func ():
		stunCoolingDown = false
	)
	damageTimer.timeout.connect(func ():
		damageCoolingDown = false
	)

func _on_body_entered(body):
	if body.has_method("_on_Player_body_entered"):
		body._on_Player_body_entered()
	
func _on_body_exited(body):
	if body.has_method("_on_Player_body_exited"):
		body._on_Player_body_exited()

func _process(_delta: float) -> void:
	if StatsUtils.currentStats.health <= 0:
		return
	if velocity != Vector2.ZERO:
		_animate_run()
	else:
		_animate_idle()
	_handle_shooting_action()
	_handle_stun_action()

func _physics_process(delta: float) -> void:
	if StatsUtils.currentStats.health <= 0:
		return
	_handle_movement(delta)
	move_and_slide()

func _on_cooldown_timeout() -> void:
	coolingDown = false

func damage() -> void:
	if damageCoolingDown:
		return
	# Issue where player loses 1 life when the game just starts
	# this checks if game just started 1 sec ago
	if abs(StatsUtils.startTime - Time.get_ticks_msec()) <= 1000:
		return
	StatsUtils.remove_health()
	if StatsUtils.currentStats.health > 0:
		damageCoolingDown = true
		damageTimer.start()
	else:
		animationPlayer.play("northIdle")

func _handle_stun_action() -> void:
	if Input.is_action_just_pressed("freeze") && StatsUtils.currentStats.stuns > 0 && !stunCoolingDown:
		StatsUtils.remove_stun()
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
