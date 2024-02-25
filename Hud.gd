extends Node2D

const HEALTH_ICON_PATH: String = "res://assets/heartIconV1.png"
const FREEZE_ICON_PATH: String = "res://assets/freezeIconV1.png"

enum Icon {
	HEALTH,
	FREEZE
}

func _ready():
	create_background()
	generateIcons(Icon.HEALTH)
	generateIcons(Icon.FREEZE)
		
func _process(_delta: float) -> void:
	update_icons(Icon.FREEZE)
	update_icons(Icon.HEALTH)

func update_icons(icon: Icon):
	var icons = get_sprites(icon)
	var accountedFor = 0
	if icon == Icon.HEALTH:
		accountedFor = StatsUtils.currentStats.health
	else:
		accountedFor = StatsUtils.currentStats.stuns
	for sprite in icons:
		if accountedFor > 0:
			sprite.visible = true
			accountedFor -= 1
		else:
			sprite.visible = false
		if StatsUtils.currentStats.health == 0:
			sprite.visible = false
		
			
func generateIcons(icon: Icon):
	for i in range(3):
		var sprite = get_sprite(icon)
		match icon:
			Icon.HEALTH:
				sprite.position.x = 4 + (i) * 10
			_:
				sprite.position.x = get_viewport_rect().size.x - (4 + (i) * 10)
		sprite.position.y = 4
		add_child(sprite)
		
func get_sprites(icon: Icon) -> Array[Sprite2D]:
	var icons: Array[Sprite2D] = []
	for child in get_children():
		if StatsUtils.currentStats.health == 0 and child is ColorRect:
			child.visible = false
		elif StatsUtils.currentStats.health != 0 and child is ColorRect:
			child.visible = true
		if child is Sprite2D:
			var icon_path = ""
			if icon == Icon.HEALTH:
				icon_path = HEALTH_ICON_PATH
			else:
				icon_path = FREEZE_ICON_PATH
			if child.texture.get_path() == icon_path:
				icons.append(child)
	return icons
	
func create_background():
	var color_rect = ColorRect.new()
	color_rect.size.x = get_viewport_rect().size.x
	color_rect.size.y = 8
	color_rect.color = Global.theme.primary
	add_child(color_rect)
	
func get_sprite(icon: Icon) -> Sprite2D:
	var sprite = Sprite2D.new()
	sprite.set("icon_type", icon)
	match icon:
		Icon.HEALTH:
			var texture = preload(HEALTH_ICON_PATH)
			sprite.texture = texture
		_:
			var texture = preload(FREEZE_ICON_PATH)
			sprite.texture = texture
	return sprite
