extends Node2D

@onready var shape: CollisionShape2D = $Hud/CollisionShape2D
@onready var area: Area2D = $Hud

var flip: bool = false

var healthPanels: Array[Panel] = []
var stunPanels: Array[Panel] = []

var previousHealth
var previousStuns

# Called when the node enters the scene tree for the first time.
func _ready():
	healthPanels.append($NinePatchRect/GridContainer/Panel1)
	healthPanels.append($NinePatchRect/GridContainer/Panel2)
	healthPanels.append($NinePatchRect/GridContainer/Panel3)
	stunPanels.append($NinePatchRect/GridContainer/Panel4)
	stunPanels.append($NinePatchRect/GridContainer/Panel5)
	stunPanels.append($NinePatchRect/GridContainer/Panel6)
	Global.StatsChanged.connect(update_hud)
	area.body_entered.connect(_on_body_enter)
	previousHealth = Global.playerHealth
	previousStuns = Global.playerStuns
	for i in range(healthPanels.size()):
		var healthScene = load("res://items/Health.tscn").instantiate()
		healthPanels[i].add_child(healthScene)
	for i in range(stunPanels.size()):
		var stunScene = load("res://items/Freeze.tscn").instantiate()
		stunPanels[i].add_child(stunScene)

func _process(_delta):
	if flip:
		position = Vector2(60, 3)
		shape.position = Vector2(5, 0)
	else:
		position = Vector2(3,3)
		shape.position = Vector2(15, 24)

func update_hud():
	if Global.playerHealth < previousHealth:
		for i in range(Global.playerHealth, healthPanels.size()):
			var healthNode = healthPanels[i].get_node("Health")
			if healthNode != null:
				healthNode.queue_free()
	else:
		for i in range(0, Global.playerHealth):
			var healthScene = load("res://items/Health.tscn").instantiate()
			healthPanels[i].add_child(healthScene)
			
	if Global.playerStuns < previousStuns:
		for i in range(Global.playerStuns, stunPanels.size()):
			var freezeNode = stunPanels[i].get_node("Freeze")
			if freezeNode != null:
				freezeNode.queue_free()
	else:
		for i in range(0, Global.playerStuns):
			var stunScene = load("res://items/Freeze.tscn").instantiate()
			stunPanels[i].add_child(stunScene)
			
	previousHealth = Global.playerHealth
	previousStuns = Global.playerStuns
		
func get_sprite(path) -> Sprite2D:
	var image = Image.load_from_file(path)
	var texture = ImageTexture.create_from_image(image)
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = texture
	return sprite
	
func _on_body_enter(body: Node2D):
	if !body.is_in_group(Global.PlayerGroup): return
	flip = !flip
