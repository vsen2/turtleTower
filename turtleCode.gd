extends Area2D

@export var speed: float = 80.0
var bounds: Rect2

var current_job: String = "Idle"          # Descriptive name of the job
var assigned_station: Node2D = null 

var direction: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var is_assigned_to_store: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var status_label: Label = null

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Cache the radius/extent so it's calculated reliably
var turtle_radius: float = 16.0

func _ready() -> void:
	_pick_random_direction()
	input_event.connect(_on_input_event)
	_calculate_turtle_size()
	sprite.play("default")
	z_index = 5

func _calculate_turtle_size() -> void:
	# Priority 1: Use CollisionShape2D if present (most accurate)
	if collision_shape and collision_shape.shape:
		var shape = collision_shape.shape
		if shape is CircleShape2D:
			turtle_radius = shape.radius * collision_shape.global_scale.x
			return
		elif shape is RectangleShape2D:
			turtle_radius = max(shape.size.x, shape.size.y) * 0.5 * collision_shape.global_scale.x
			return

	# Priority 2: Fallback to Sprite dimensions
	if sprite and sprite.texture:
		var scaled_size: Vector2 = sprite.texture.get_size() * sprite.global_scale
		# Using the larger dimension prevents corners poking out during rotation
		turtle_radius = max(scaled_size.x, scaled_size.y) / 2.0

func _process(delta: float) -> void:
	if is_assigned_to_store:
		return
		
	if !is_assigned_to_store:
		if bounds == Rect2():
			return

	# Pad inner bounds using the calculated turtle radius
	var min_x = bounds.position.x + turtle_radius
	var max_x = bounds.end.x - turtle_radius
	var min_y = bounds.position.y + turtle_radius
	var max_y = bounds.end.y - turtle_radius

	# Prevent inversions if pen is smaller than the turtle
	if min_x > max_x:
		min_x = bounds.get_center().x
		max_x = min_x
	if min_y > max_y:
		min_y = bounds.get_center().y
		max_y = min_y

	if is_dragging:
		global_position = get_global_mouse_position() + drag_offset
		global_position.x = clamp(global_position.x, min_x, max_x)
		global_position.y = clamp(global_position.y, min_y, max_y)
	else:
		global_position += direction * speed * delta

		# Bounce using outer radius rather than center point
		if global_position.x <= min_x:
			direction.x = abs(direction.x)
		elif global_position.x >= max_x:
			direction.x = -abs(direction.x)

		if global_position.y <= min_y:
			direction.y = abs(direction.y)
		elif global_position.y >= max_y:
			direction.y = -abs(direction.y)
		
		global_position.x = clamp(global_position.x, min_x, max_x)
		global_position.y = clamp(global_position.y, min_y, max_y)
		
		if sprite:
			if direction.x > 0:
				sprite.flip_h = true
			elif direction.x < 0:
				sprite.flip_h = false
				
func send_to_station(target_pos: Vector2, registerNum: int = 1, register_node: Node2D = null) -> void:
	if is_instance_valid(assigned_station):
		assigned_station.hasWorker = false
	print("Inside turtle send_to_station, setting pos from ", global_position, " to ", target_pos)
	current_job = "Register %d" % registerNum
	assigned_station = register_node
	is_assigned_to_store = true
	global_position = target_pos
	print(global_position)
	if status_label:
		status_label.text = "Working at:\nRegister %d" % registerNum

func return_to_pen(new_bounds: Rect2) -> void:
	if is_instance_valid(assigned_station):
		assigned_station.hasWorker = false
		
	current_job = "Idle"
	assigned_station = null
	is_assigned_to_store = false
		
	bounds = new_bounds
	is_assigned_to_store = false
	_pick_random_direction()
	
	if status_label:
		status_label.text = "Idle"
	
func _pick_random_direction() -> void:
	direction = Vector2.RIGHT.rotated(randf_range(0.0, TAU)).normalized()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			is_dragging = true
			drag_offset = global_position - get_global_mouse_position()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.is_pressed() and is_dragging:
			is_dragging = false
			_pick_random_direction()
