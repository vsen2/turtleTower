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
	customer.speedMultiplier = get_parent().customerSpeedMultiplier
	customer.feedWorkersMultiplier = get_parent().feedWorkersMultiplier
	customer.fruitMultiplier = get_parent().betterFruitMultiplier
	customer.appleMultiplier = get_parent().appleMultiplier
	get_parent().add_child(customer)
	customer.global_position = Vector2(get_viewport_rect().size.x, global_position.y)
	
func spawn_code() -> void:
	var label: Label = Label.new()
	label.name = "code"
	label.text = "code code code!"
	label.top_level = true
	label.global_position = Vector2(450, -450)
	label.z_index = 30
	label.add_theme_color_override("font_color", Color(0.0, 0.439, 0.0, 1.0)) # color
	label.add_theme_font_size_override("font_size", 25)

	add_child(label)
	# Float upward and fade out, then delete itself.
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(label, "global_position:y", label.global_position.y - 20.0, .5)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.chain().tween_callback(label.queue_free)

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
