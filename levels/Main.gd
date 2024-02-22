extends Node2D

@export var EnemySpawnInterval : float = 2
@export var MaxEnemySpawns : int = 10
@onready var background : ColorRect = $background

var enemySpawnTimer : Timer

func _ready():
	enemySpawnTimer = Timer.new()
	add_child(enemySpawnTimer)
	enemySpawnTimer.wait_time = EnemySpawnInterval
	enemySpawnTimer.timeout.connect(_on_enemy_spawn_timeout)
	enemySpawnTimer.start()
	StatsUtils.start_game()

func _process(_delta: float) -> void:
	modulate = Global.theme.primary

func _on_enemy_spawn_timeout() -> void:
	if get_enemy_count() < MaxEnemySpawns:
		spawn_enemy(EnemyTypes.Type.NORMAL)

func get_enemy_count() -> int:
	var enemyCount : int = 0
	for child in get_tree().root.get_children():
		if child is Enemy:
			enemyCount += 1
	return enemyCount

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
