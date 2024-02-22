extends Node

var _data = []
const SAVE_PATH: String = "user://stats.save"
const STATS: String = "stats"

var startTime = Time.get_ticks_msec()
var currentStats = {
	"ID": 0,
	"timePlayed": 0.0,
	"enemiesKilled": 0,
	"shotsFired": 0,
	"shotsLanded": 0,
	"accuracy": 0.0,
	"dateSaved": Time.get_ticks_msec(),
}


func _ready():
	load_stats_from_file()


func get_latest_stat():
	if _data.size() == 0:
		return null
	var lastIndex = _data.size() - 2
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
		"dateSaved": Time.get_ticks_msec(),
	}


func stop_game(saveStats: bool = true) -> void:
	currentStats.dateSaved = Time.get_ticks_msec()
	if saveStats:
		save_stats()


func add_enemy_death() -> void:
	currentStats.enemiesKilled += 1


func add_shot_landed() -> void:
	currentStats.shotsLanded += 1


func add_shot_fired() -> void:
	currentStats.shotsFired += 1


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
	var jsonData = json.result
	_data = jsonData.data
	print("Loading from file")
	print(jsonData)
