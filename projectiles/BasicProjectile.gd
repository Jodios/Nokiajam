extends Node2D

@export var Speed : int = 50
@export var Damage : float = 20
@export var Piercing : float = 20

var direction : Vector2 = Vector2.ZERO

var hitbox : Area2D

var parent : Player

func _ready():
	hitbox = get_node("hitbox")
	hitbox.body_entered.connect(hitbox_collision_handler)
	StatsUtils.add_shot_fired()

func _process(delta: float) -> void:
	modulate = Global.theme.secondary
	position += Speed * direction * delta
	if StatsUtils.currentStats.health <= 0:
		queue_free()

func start(startPosition: Vector2, dir: Vector2, p: Player) -> void:
	position = startPosition
	direction = dir
	parent = p

func hitbox_collision_handler(body: Node) -> void:
	if body.is_in_group(Global.Border):
		queue_free()
		return

	if not body.is_in_group(Global.EnemyGroup):
		return

	if body is Enemy:
		StatsUtils.add_shot_landed()
		var enemy = body as Enemy
		enemy.damage(Damage)
	
	queue_free()
