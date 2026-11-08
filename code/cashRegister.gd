extends "res://code/workstation.gd"

@export var customer_turtle_scene: PackedScene = preload("res://scenes/customerTurtle.tscn")

@export var wait_time: float = 10.0

var customer_timer: Timer
var timer_label: Label


func _ready() -> void:
	startingStuff()
	add_to_group("job_spots")
	z_index = 10

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

func _process(_delta: float) -> void:
	if not (unlocked and hasWorker):
		customer_timer.wait_time = wait_time
		return
	var timer_mult: float = 1.0
	customer_timer.wait_time = wait_time / timer_mult
	timer_label.z_index = 13
	timer_label.top_level = true
	timer_label.visible = true
	timer_label.text = "%.1fs" % customer_timer.time_left
	timer_label.add_theme_font_size_override("font_size", 25)
	timer_label.global_position = global_position + Vector2(250, -166)
	if customer_timer.is_stopped() and hasWorker:
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
	customer.feedWorkersMultiplier = get_parent().feedWorkersMultiplier
	customer.fruitMultiplier = get_parent().betterFruitMultiplier
	customer.appleMultiplier = get_parent().appleMultiplier
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
