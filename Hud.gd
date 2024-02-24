extends Node2D

@onready var shape: CollisionShape2D = $Hud/CollisionShape2D
@onready var area: Area2D = $Hud

var flip: bool = false
var healthSprites: Array[Sprite2D] = []
var stunSprites: Array[Sprite2D] = []

var previousHealth
var previousStuns

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.StatsChanged.connect(update_hud)
	area.body_entered.connect(_on_body_enter)
	previousHealth = Global.playerHealth
	previousStuns = Global.playerStuns
	for i in range(Global.playerHealth):
		var healthSprite = get_sprite("res://assets/projectile.png")
		healthSprites.append(healthSprite)
		healthSprite.position = Vector2(2*i, 5)
		add_child(healthSprite)
	for i in range(Global.playerStuns):
		var stunSprite = get_sprite("res://assets/projectile.png")
		stunSprites.append(stunSprite)
		stunSprite.position = Vector2(2*i, 10)
		add_child(stunSprite)

func update_hud():
	if Global.playerHealth < previousHealth:
		for i in range(Global.playerHealth, healthSprites.size()):
			healthSprites[i].visible = false
	else:
		for i in range(0, Global.playerHealth):
			healthSprites[i].visible = true
			
			
	if Global.playerStuns < previousStuns:
		for i in range(Global.playerStuns, stunSprites.size()):
			stunSprites[i].visible = false
	else:
		for i in range(0, Global.playerStuns):
			stunSprites[i].visible = true
			
	previousHealth = Global.playerHealth
	previousStuns = Global.playerStuns

func _process(_delta):
	if flip:
		position = Vector2(50, 0)
	else:
		position = Vector2.ZERO
		
func get_sprite(path) -> Sprite2D:
	var image = Image.load_from_file(path)
	var texture = ImageTexture.create_from_image(image)
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = texture
	return sprite
	

func _on_body_enter(body: Node2D):
	if !body.is_in_group(Global.PlayerGroup): return
	flip = !flip
