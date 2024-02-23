class_name Player
extends CharacterBody2D

@export var MaxHealth : int = 3
@export var MaxStuns : int = 3
@export var Speed : float = 900
@export var ProjectileType : ProjectileTypes.Type = ProjectileTypes.Type.Multiply

@onready var player : MeshInstance2D = $player
@onready var animationPlayer: AnimationPlayer = $playerAnimationPlayer
var PlayerHealth : int = 0
var Stuns : int = 0

signal PlayerPerished

var previousDirection : Vector2
@onready var cooldownTimer : Timer = $cooldown
var coolingDown : bool = false
var direction = Vector2.ZERO
@onready var animationTree: AnimationTree = $AnimationTree
var lastPressedDirection = "right"

func _ready():
	previousDirection = Vector2.RIGHT
	add_to_group(Global.PlayerGroup)
	PlayerHealth = MaxHealth
	Stuns = MaxStuns
	cooldownTimer.timeout.connect(_on_cooldown_timeout)
	animationPlayer.play("southIdle")
	animationTree["parameters/idle/blend_position"] = direction
	animationTree["parameters/running/blend_position"] = direction
	animationTree.active = false

func _process(_delta: float) -> void:
	modulate = Global.theme.secondary
	var x: AnimationNodeStateMachinePlayback = animationTree["parameters/playback"]
	if direction != Vector2.ZERO:
		animationTree["parameters/idle/blend_position"] = direction
		animationTree["parameters/running/blend_position"] = direction
	if velocity != Vector2.ZERO:
		animationTree["parameters/conditions/idle"] = false
		animationTree["parameters/conditions/running"] = true
	else:
		animationTree["parameters/conditions/idle"] = true
		animationTree["parameters/conditions/running"] = false
		
		
		
		
	#if velocity != Vector2.ZERO:
		#_animate_run()
	#else:
		#_animate_idle()
		

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_shooting_action()
	_handle_stun_action()
	move_and_slide()
	
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
	if Input.is_action_just_pressed("freeze"):
		StatsUtils.add_stun_used()
		SoundUtils.play_freeze_action_sound()
		var enemies = get_tree().get_nodes_in_group(Global.EnemyGroup)
		for enemy in enemies:
			enemy.stun()

func _handle_shooting_action() -> void:
	if coolingDown:
		return
	if Input.is_action_just_pressed("shoot"):
		SoundUtils.play_shooting_sound()
		coolingDown = true
		cooldownTimer.start()
		if ProjectileType == ProjectileTypes.Type.Basic:
			_spawn_projectile("res://projectiles/BasicProjectile.tscn")
		if ProjectileType == ProjectileTypes.Type.Multiply:
			_multiply_projectile("res://projectiles/BasicProjectile.tscn")
		else:
			_spawn_projectile("res://projectiles/BasicProjectile.tscn")

func _spawn_projectile(path: String) -> void:
	var projectileScene = load(path)
	var projectile = projectileScene.instantiate()
	projectile.start(global_position + Vector2(0, 0), previousDirection, self)
	get_tree().root.add_child(projectile)

func _multiply_projectile(path: String) -> void:
	var projectileScene = load(path)
	for i in range(7):
		var multiplier = 1 if i % 2 == 0 else -1
		var projectile = projectileScene.instantiate()
		projectile.start(
			global_position + Vector2(0, 0),
			previousDirection.rotated(deg_to_rad(i * 6 * multiplier)).normalized(),
			self
		)
		get_tree().root.add_child(projectile)

func _handle_movement(delta: float) -> void:
	direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * Speed * delta
