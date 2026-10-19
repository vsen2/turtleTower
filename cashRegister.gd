extends Sprite2D

@export var customer_spawn_offset: Vector2 = Vector2(0, 32)
@export var customer_turtle_scene: PackedScene = preload("res://customerTurtle.tscn")



var unlocked: bool = false
var hasWorker: bool = false

signal worker_status_changed(hasWorker: bool)

var customer_timer: Timer
var timer_label: Label

@export var waitTime: = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	z_index = 10
	customer_timer = Timer.new()
	customer_timer.wait_time = waitTime   # delay
	customer_timer.one_shot = false   # Set to false so it repeats continuously
	customer_timer.autostart = false
	customer_timer.timeout.connect(_on_customer_timer_timeout)
	add_child(customer_timer)
	
	timer_label = Label.new()
	timer_label.text = ""
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Center the label above the register (adjust offset if needed)
	timer_label.size = Vector2(120, 24)
	timer_label.position = Vector2(-timer_label.size.x / 2.0, -45)
	
	# Give text an outline so it's easily readable against background sprites
	timer_label.add_theme_color_override("font_color", Color.BLACK)
	timer_label.add_theme_constant_override("outline_size", 4)
	timer_label.visible = false
	add_child(timer_label)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_run_timer():
		# Show the label
		if timer_label:
			timer_label.z_index = 13
			timer_label.top_level = true
			timer_label.visible = true
			timer_label.text = "%.1fs" % customer_timer.time_left
			timer_label.add_theme_font_size_override("font_size", 25)
			timer_label.global_position = global_position + Vector2(250, -166)

		# Start the timer only if it isn't already running
		if customer_timer.is_stopped():
			customer_timer.start()
	else:
		customer_timer.wait_time = waitTime
			
			
func can_accept_customer() -> bool:
	return unlocked and hasWorker
	
func can_run_timer():
	return unlocked and hasWorker
	
func _on_customer_timer_timeout() -> void:
	spawn_customer_turtle()
	
func spawn_customer_turtle() -> void:
	if not customer_turtle_scene: return
	var customer = customer_turtle_scene.instantiate()	
	
	# Find the right edge of the screen using the viewport
	var viewport_rect = get_viewport_rect()
	var spawn_x = viewport_rect.size.x
	
	# Match the Y position of the object running this script
	var spawn_y = global_position.y + 15
	
	# Set the spawn position
	customer.global_position = Vector2(spawn_x, spawn_y)
	
	# Add it to the scene (typically added to the parent or a main manager node)
	get_parent().add_child(customer)
