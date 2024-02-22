extends Node

# Define themes dictionary
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

var themeIdx : int = 0
var theme : Dictionary = themes.values()[themeIdx]

var EnemyGroup : String = "enemy"
var PlayerGroup : String = "player"
var Border : String = "border"

var testtesttest : String = "jest"
var CurrentScene : Node

func _ready():
	var root : Viewport = get_tree().root
	CurrentScene = root.get_child(root.get_child_count() - 1)

func _process(_delta: float) -> void:
	if Input.is_action_just_released("changeTheme"):
		themeIdx = (themeIdx + 1) % themes.size()
		theme = themes.values()[themeIdx]
