extends Node2D

@export var EnemySpawnInterval : float = 2
@export var MaxEnemySpawns : int = 10
@export var MaxItemSpawns : int = 5
@onready var background : ColorRect = $background
@onready var hud = $Hud
var playing = false

var enemySpawnTimer : Timer
var itemSpawnTimer : Timer

func _ready():
	StatsUtils.startTime = Time.get_ticks_msec()
	enemySpawnTimer = Timer.new()
	add_child(enemySpawnTimer)
	itemSpawnTimer = Timer.new()
	add_child(itemSpawnTimer)
	enemySpawnTimer.wait_time = EnemySpawnInterval
	itemSpawnTimer.wait_time = randi_range(5,8)
	enemySpawnTimer.timeout.connect(_on_enemy_spawn_timeout)
	itemSpawnTimer.timeout.connect(_on_item_spawn_timeout)
	itemSpawnTimer.start()
	enemySpawnTimer.start()
	StatsUtils.start_game()

func _process(_delta: float) -> void:
	modulate = Global.theme.primary

func _on_enemy_spawn_timeout() -> void:
	if get_enemy_count() < MaxEnemySpawns:
		spawn_enemy(EnemyTypes.Type.NORMAL)
		
func _on_item_spawn_timeout() -> void:
	itemSpawnTimer.wait_time = randi_range(5,8)
	if get_tree().get_nodes_in_group("item").size() < MaxItemSpawns:
		spawn_item(randi_range(0,1))

func get_enemy_count() -> int:
	return get_tree().get_nodes_in_group(Global.EnemyGroup).size()
	
func spawn_item(type: int) -> void:
	var scene
	if type == 0:
		scene = load("res://items/Freeze.tscn").instantiate()
		pass
	else:
		scene = load("res://items/Health.tscn").instantiate()
	scene.position = Vector2(randi_range(0,84), randi_range(0,48))
	get_tree().root.add_child(scene)

func spawn_enemy(type: int) -> void:
	var enemyScene = load("res://enemies/basic/Enemy.tscn")
	var enemy = enemyScene.instantiate()
	enemy.EnemyType = type
	enemy.position = random_spawn_position()
	get_tree().root.add_child(enemy)

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

func random_spawn_position_for_items() -> Vector2:
	return Vector2(randi_range(0,84), randi_range(0,48))
