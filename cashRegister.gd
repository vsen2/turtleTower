extends Sprite2D

@export var customer_turtle_scene: PackedScene = preload("res://customerTurtle.tscn")

@export var location = get_parent()
@export var wait_time: float = 10.0

var unlocked: bool = false
var hasWorker: bool = false

var customer_timer: Timer
var timer_label: Label

func _ready() -> void:
	z_index = 10

	customer_timer = Timer.new()
	customer_timer.wait_time = wait_time/location.timerMultiplier
	customer_timer.one_shot = false
	customer_timer.autostart = false
	customer_timer.timeout.connect(_on_customer_timer_timeout)
	add_child(customer_timer)

	# Countdown label shown above the register while it's staffed.
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
	# Only run the customer timer while this register is unlocked and staffed.
	if not (unlocked and hasWorker):
		customer_timer.wait_time = wait_time
		return
		
	customer_timer.wait_time = wait_time/location.timerMultiplier

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
	customer.speedMultiplier = location.customerSpeedMultiplier
	customer.feedWorkersMultiplier = location.feedWorkersMultiplier
	customer.fruitMultiplier = location.betterFruitMultiplier
	customer.appleMultiplier = location.appleMultiplier
	customer.global_position = Vector2(spawn_x, spawn_y)

	get_parent().add_child(customer)
