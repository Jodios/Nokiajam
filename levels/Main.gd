extends Node2D

@export var EnemySpawnInterval : float = 2
@export var MaxEnemySpawns : float = 10.0
@onready var background : ColorRect = $background

var enemySpawnTimer : Timer
var gameOver = false

func _ready():
	background.color = Global.theme.primary
	enemySpawnTimer = Timer.new()
	add_child(enemySpawnTimer)
	enemySpawnTimer.wait_time = EnemySpawnInterval
	enemySpawnTimer.timeout.connect(_on_enemy_spawn_timeout)
	start_game()
	
func _process(_delta: float) -> void:
	StatsUtils.timeElapsed = (Time.get_ticks_msec() - StatsUtils.startTime) / 1000
	if StatsUtils.timeElapsed >= 1:
		enemySpawnTimer.wait_time = EnemySpawnInterval  * (pow(.95, StatsUtils.timeElapsed)) 
		MaxEnemySpawns = MaxEnemySpawns  * (pow(1.000001, StatsUtils.timeElapsed))
	if gameOver and Input.is_action_just_pressed("shoot"):
		start_game()
	elif !gameOver and StatsUtils.currentStats.health <= 0:
		end_game()
		
func end_game():
	gameOver = true
	enemySpawnTimer.stop()
	StatsUtils.stop_game()
	
func start_game():
	gameOver = false
	remove_all_enemies()
	enemySpawnTimer.start()
	reset_player_position()
	StatsUtils.start_game()
	
func reset_player_position():
	var player_node = get_node("Player")
	if player_node != null:
		player_node.position.x = 42
		player_node.position.y = 24

func _on_enemy_spawn_timeout() -> void:
	if get_enemy_count() < MaxEnemySpawns:
		spawn_enemy(EnemyTypes.Type.NORMAL)

func get_enemy_count() -> int:
	return get_tree().get_nodes_in_group(Global.EnemyGroup).size()

func spawn_enemy(type: int) -> void:
	var enemyScene = load("res://enemies/basic/Enemy.tscn")
	var enemy = enemyScene.instantiate()
	enemy.EnemyType = type
	enemy.position = random_spawn_position()
	enemy.set_z_index(0)
	add_child(enemy)

func remove_all_enemies() -> void:
	for child in get_tree().get_nodes_in_group(Global.EnemyGroup):
		child.queue_free()

func random_spawn_position() -> Vector2:
	var edge = randi() % 4
	var spawnPosition : Vector2
	match edge:
		0:
			spawnPosition = Vector2(randi_range(0,84), 0)
		1:
			spawnPosition = Vector2(84, randi_range(0,48))
		2:
			spawnPosition = Vector2(randi_range(0,84), 48)
		3:
			spawnPosition = Vector2(0, randi_range(0,48))
		_:
			spawnPosition = Vector2.ZERO
	return spawnPosition
