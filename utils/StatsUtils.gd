extends Node

var _data = []
const SAVE_PATH: String = "user://stats.save"
const STATS: String = "stats"

var startTime = Time.get_ticks_msec()
var timeElapsed = 0
var currentStats = {}

func _ready():
	load_stats_from_file()

func get_latest_stat():
	if _data.size() == 0:
		return null
	var lastIndex = _data.size() - 1
	return _data[lastIndex]

func start_game() -> void:
	startTime = Time.get_ticks_msec()
	currentStats = {
		"ID": 0,
		"timePlayed": 0.0,
		"enemiesKilled": 0,
		"shotsFired": 0,
		"shotsLanded": 0,
		"accuracy": 0.0,
		"dateSaved": "",
		"stunsUsed": 0,
		"enemiesStunned": 0,
		"health": 3,
		"stuns": 3
	}

func stop_game(saveStats: bool = true) -> void:
	currentStats.dateSaved = Time.get_datetime_string_from_system()
	if saveStats:
		save_stats()

func remove_stun() -> void:
	if currentStats.stuns == 0:
		return
	currentStats.stuns -= 1
	
func remove_health() -> void:
	if currentStats.health == 0:
		return
	currentStats.health -= 1

func add_enemy_death() -> void:
	currentStats.enemiesKilled += 1

func add_stun_used() -> void:
	currentStats.stunsUsed += 1
	
func add_enemy_stunned() -> void:
	currentStats.enemiesStunned += 1

func add_shot_landed() -> void:
	currentStats.shotsLanded += 1

func add_shot_fired() -> void:
	currentStats.shotsFired += 1
	
func delete_saved_data():
	_data = []
	DirAccess.remove_absolute(SAVE_PATH)

func save_stats() -> void:
	if currentStats.shotsFired > 0:
		currentStats.accuracy = float(currentStats.shotsLanded) / currentStats.shotsFired * 100.0
	currentStats.ID = _data.size() + 1
	var elapsedTime = Time.get_ticks_msec() - startTime
	currentStats.timePlayed = float(elapsedTime / 1000.0)
	save_stats_to_file()

func save_stats_to_file() -> void:
	var saveGame = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	_data.append(currentStats)
	var jsonString = JSON.stringify(_data)
	saveGame.store_string(jsonString)
	saveGame.close()

func load_stats_from_file() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_data = []
		return
	var saveGame = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var jsonString = saveGame.get_as_text()
	var json = JSON.new()
	var error = json.parse(jsonString)
	if error != OK:
		print(
			"JSON Parse Error: ",
			json.get_error_message(),
			" in ",
			jsonString,
			" at line ",
			json.get_error_line()
		)
		_data = []
		return
	_data = json.get_data()
