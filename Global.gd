extends Node

var themes = {
	"original": {
		"primary": Color("#c7f0d8"),
		"secondary": Color("#43523d")
	},
	"harsh": {
		"primary": Color("#9bc700"),
		"secondary": Color("#2b3f09")
	},
	"gray": {
		"primary": Color("#879188"),
		"secondary": Color("#1a1914")
	}
}

var themeIdx : int = 2
var theme : Dictionary = themes.values()[themeIdx]

var EnemyGroup : String = "enemy"
var PlayerGroup : String = "player"
var Border : String = "border"

var CurrentScene : Node

func _ready():
	var root : Viewport = get_tree().root
	CurrentScene = root.get_child(root.get_child_count() - 1)
