extends "res://code/workstation.gd"

@export var wait_time: float = 2

var customer_timer: Timer
var timer_label: Label

@onready var officeLaptop: Sprite2D = $OfficeLaptop
# Filled in _ready() from the coffee1..coffee6 child nodes
var coffees: Array[Sprite2D] = []

var coffeesUnlocked = 0
	
func _ready() -> void:
	super()
	add_to_group("job_spots")
	z_index = 10

	customer_timer = Timer.new()
	customer_timer.wait_time = wait_time
	customer_timer.one_shot = false
	customer_timer.autostart = false
	customer_timer.timeout.connect(_on_customer_timer_timeout)
	add_child(customer_timer)

	# Countdown label shown above the desk while a turtle works here
	timer_label = Label.new()
	timer_label.top_level = true
	timer_label.z_index = 13
	timer_label.visible = false
	timer_label.add_theme_font_size_override("font_size", 25)
	add_child(timer_label)

	coffees.clear()
	for i in range(1, 7):
		var c := get_node_or_null("coffee%d" % i) as Sprite2D
		if c:
			coffees.append(c)
	refresh()

## Updates the desk's look. Call it whenever unlocked or the coffee upgrade changes.
## Locked: grey desk, no laptop, no coffees. Unlocked: white desk + laptop.
func refresh() -> void:
	if not is_node_ready():
		return  # _ready() calls this once the child nodes exist
	if unlocked:
		self_modulate = Color.WHITE
		officeLaptop.visible = true
	else:
		self_modulate = Color.GRAY
		officeLaptop.visible = false

	coffeesUnlocked = int(get_parent().upgrade5Multiplier)
	for i in coffees.size():
		coffees[i].visible = unlocked and i < coffeesUnlocked

func _on_spot_plus_pressed() -> void:
	var was_unlocked: bool = unlocked
	super()
	refresh()
	# Save right away so the unlock isn't lost if no turtle gets assigned
	if unlocked and not was_unlocked:
		var main: Node = get_tree().current_scene
		if main and main.has_method("save_game"):
			main.save_game()

func update_ui_state() -> void:
	super()
	refresh()
		

func _process(_delta: float) -> void:
	if not (unlocked and hasWorker):
		customer_timer.wait_time = wait_time
		timer_label.visible = false
		return
	var timer_mult: float = 1.0
	customer_timer.wait_time = wait_time / timer_mult
	timer_label.visible = true
	timer_label.text = "%.1fs" % customer_timer.time_left
	timer_label.global_position = global_position + Vector2(250, -166)
	if customer_timer.is_stopped() and hasWorker:
		customer_timer.start()
		
	

func _on_customer_timer_timeout() -> void:
	spawn_code()
	
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
