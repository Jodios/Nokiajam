extends Node2D

@export var EnemySpawnInterval : float = 4
@export var MaxEnemySpawns : float = 8.0

var enemySpawnTimer : Timer
var gameOver = false

func _ready():
	enemySpawnTimer = Timer.new()
	add_child(enemySpawnTimer)
	enemySpawnTimer.wait_time = EnemySpawnInterval
	enemySpawnTimer.timeout.connect(_on_enemy_spawn_timeout)
	start_game()
	
func _process(_delta: float) -> void:
	StatsUtils.timeElapsed = (Time.get_ticks_msec() - StatsUtils.startTime) / 1000.0
	if StatsUtils.timeElapsed >= 1:
		var newWaitTime = EnemySpawnInterval * pow(0.99, StatsUtils.timeElapsed)
		enemySpawnTimer.wait_time = max(1, newWaitTime)
	if gameOver and Input.is_action_just_pressed("shoot"):
		start_game()
	elif !gameOver and StatsUtils.currentStats.health <= 0:
		end_game()
		
func end_game():
	SoundUtils.play_perish_sound()
	gameOver = true
	enemySpawnTimer.stop()
	StatsUtils.stop_game()
	present_game_over()
	
func start_game():
	gameOver = false
	remove_game_over()
	remove_all_enemies()
	enemySpawnTimer.start()
	reset_player_position()
	StatsUtils.start_game()
	
func present_game_over():
	var font = load("res://assets/fonts/Pixeled.ttf")
	
	var color_rect = ColorRect.new()
	color_rect.size = get_viewport_rect().size
	color_rect.color = Global.theme.primary
	color_rect.offset_left = -7.0
	color_rect.offset_top = -10.0
	color_rect.offset_right = 92.0
	color_rect.offset_bottom = 58.0
	add_child(color_rect)
	
	var score_label = Label.new()
	score_label.add_theme_color_override("font_color", Global.theme.secondary)
	score_label.text = "Score: " + str(StatsUtils.get_latest_stat().score)
	score_label.offset_top = 11.0
	score_label.offset_right = 84.0
	score_label.offset_bottom = 25.0
	score_label.add_theme_font_override("font", font)
	score_label.add_theme_font_size_override("font_size", 5)
	score_label.horizontal_alignment = 1
	score_label.vertical_alignment = 1
	add_child(score_label)
	
	var highscore_label = Label.new()
	highscore_label.add_theme_color_override("font_color", Global.theme.secondary)
	highscore_label.text = "Best: " + str(StatsUtils.get_highscore().score)
	highscore_label.offset_top = 20.0
	highscore_label.offset_right = 84.0
	highscore_label.offset_bottom = 25.0
	highscore_label.add_theme_font_override("font", font)
	highscore_label.add_theme_font_size_override("font_size", 5)
	highscore_label.horizontal_alignment = 1
	highscore_label.vertical_alignment = 1
	add_child(highscore_label)

func remove_game_over():
	for child in get_children():
		if child is ColorRect or child is Label:
			child.queue_free()
	
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
