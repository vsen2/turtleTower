extends Sprite2D

@export var customer_turtle_scene: PackedScene = preload("res://customerTurtle.tscn")
@export var spot_id: String = ""

const BUTTON_NORMAL_TEXTURE = preload("res://assets/plusButtonWhite.png")
const BUTTON_HOVER_TEXTURE = preload("res://assets/plusButtonGrey.png")

@export var location = get_parent()
@export var wait_time: float = 10.0

var unlocked: bool = false
var hasWorker: bool = false

var customer_timer: Timer
var timer_label: Label
var unlock_button: TextureButton

func _ready() -> void:
	add_to_group("job_spots")
	z_index = 10
	if not unlocked:
		create_unlock_button()

	customer_timer = Timer.new()
	customer_timer.wait_time = wait_time
	customer_timer.one_shot = false
	customer_timer.autostart = false
	customer_timer.timeout.connect(_on_customer_timer_timeout)
	add_child(customer_timer)

	timer_label = Label.new()
	timer_label.text = ""
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	timer_label.size = Vector2(120, 24)
	timer_label.position = Vector2(-timer_label.size.x / 2.0, -45)
	timer_label.add_theme_color_override("font_color", Color.BLACK)
	timer_label.add_theme_constant_override("outline_size", 4)
	timer_label.visible = false
	add_child(timer_label)

func create_unlock_button() -> void:
	unlock_button = TextureButton.new()
	unlock_button.texture_normal = BUTTON_NORMAL_TEXTURE
	unlock_button.texture_hover = BUTTON_HOVER_TEXTURE
	unlock_button.texture_pressed = BUTTON_HOVER_TEXTURE
	unlock_button.z_index = 19
	unlock_button.top_level = true
	unlock_button.ignore_texture_size = true
	unlock_button.stretch_mode = TextureButton.STRETCH_SCALE
	unlock_button.custom_minimum_size = Vector2(100, 100)
	unlock_button.size = Vector2(100, 100)
	add_child(unlock_button)
	unlock_button.global_position = global_position - Vector2(310, 50)
	unlock_button.pressed.connect(_on_spot_plus_pressed)

func _on_spot_plus_pressed() -> void:
	unlocked = true
	modulate = Color.WHITE
	if is_instance_valid(unlock_button):
		unlock_button.queue_free()
		unlock_button = null
	var main: Node = get_tree().current_scene
	if main and main.has_method("begin_spot_assignment"):
		main.begin_spot_assignment(self)

func _process(_delta: float) -> void:
	if not (unlocked and hasWorker):
		customer_timer.wait_time = wait_time
		return
	var timer_mult: float = 1.0
	if location != null and location.get("timerMultiplier") != null:
		timer_mult = float(location.get("timerMultiplier"))
	customer_timer.wait_time = wait_time / timer_mult
	timer_label.z_index = 13
	timer_label.top_level = true
	timer_label.visible = true
	timer_label.text = "%.1fs" % customer_timer.time_left
	timer_label.add_theme_font_size_override("font_size", 25)
	timer_label.global_position = global_position + Vector2(250, -166)
	if customer_timer.is_stopped():
		customer_timer.start()

func _on_customer_timer_timeout() -> void:
	spawn_customer_turtle()

func spawn_customer_turtle() -> void:
	if not customer_turtle_scene:
		return
	var customer: Node2D = customer_turtle_scene.instantiate()
	var spawn_x: float = get_viewport_rect().size.x
	var spawn_y: float = global_position.y + 15
	customer.speedMultiplier = get_parent().customerSpeedMultiplier
	customer.global_position = Vector2(spawn_x, spawn_y)
	get_parent().add_child(customer)

func get_spot_save_data() -> Dictionary:
	return {"spot_id": spot_id, "unlocked": unlocked, "has_worker": hasWorker}

func load_spot_save_data(data: Dictionary) -> void:
	unlocked = bool(data.get("unlocked", false))
	hasWorker = bool(data.get("has_worker", false))
	if unlocked:
		modulate = Color.WHITE
		if is_instance_valid(unlock_button):
			unlock_button.queue_free()
			unlock_button = null
	elif not is_instance_valid(unlock_button):
		create_unlock_button()
