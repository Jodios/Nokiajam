extends Node2D

const HEALTH_ICON_PATH: String = "res://assets/heartIconV1.png"
const FREEZE_ICON_PATH: String = "res://assets/freezeIconV1.png"

enum Icon {
	HEALTH,
	FREEZE
}

var e_mask : ColorRect
var e_reveal_timer : Timer

func _ready():
	create_background()
	generateIcons(Icon.HEALTH)
	generateIcons(Icon.FREEZE)
	set_up_circle_cooldown_connections()
	create_e_label()
	create_e_mask()
	create_e_reveal_timer()
	stop_e_cooldown()
	
func create_e_reveal_timer():
	e_reveal_timer = Timer.new()
	e_reveal_timer.timeout.connect(func():
		e_mask.position.y -= 1
	)
	e_reveal_timer.wait_time = 1
	add_child(e_reveal_timer)
	
func create_e_mask():
	e_mask = ColorRect.new()
	e_mask.color = Global.theme.primary
	e_mask.size.x = 5
	e_mask.size.y = 5
	e_mask.position.x = (get_viewport_rect().size.x / 2) - 2
	e_mask.z_index = 15
	add_child(e_mask)
	
func create_e_label():
	var font = load("res://assets/fonts/Pixeled.ttf")
	var e_label = Label.new()
	e_label.add_theme_color_override("font_color", Global.theme.secondary)
	e_label.text = "e"
	e_label.position.y = -4
	e_label.position.x = (get_viewport_rect().size.x / 2) - 2
	e_label.add_theme_font_override("font", font)
	e_label.add_theme_font_size_override("font_size", 5)
	add_child(e_label)
	
func set_up_circle_cooldown_connections():
	var circleTimerNode = get_node("/root/Main/Player/circleTimer")
	circleTimerNode.connect("timeout", Callable(self, "present_circle_shot_ready"))
	var playerNode = get_node("/root/Main/Player")
	playerNode.connect("circle_shot_fired", Callable(self, "start_e_cooldown"))
		
func _process(_delta: float) -> void:
	update_icons(Icon.FREEZE)
	update_icons(Icon.HEALTH)
	
func start_e_cooldown():
	e_mask.position.y = 2
	e_reveal_timer.start()
	
func stop_e_cooldown():
	e_reveal_timer.stop()
	e_mask.position.y = -6

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
			visible = false
		else:
			visible = true
		
			
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
