extends Area2D

@export var speed: float = 80.0

var bounds: Rect2
var direction: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var is_assigned_to_store: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var current_job: String = "Idle"
var assigned_station: Node2D = null
var status_label: Label = null
var random_hat = randi_range(0, 13)

@onready var turtleHat: Node2D = $timmyTheTurtle/turtleHat
@onready var turtleHats: Array[Texture2D] = [
	preload("res://hatChef.png"),
	preload("res://hatDunce.png"),
	preload("res://hatEgg.png"),
	preload("res://hatFishbowl.png"),
	preload("res://hatFishingRod.png"),
	preload("res://hatFunnyPropellor.png"),
	preload("res://hatGooglyEyes.png"),
	preload("res://hatKingCrown.png"),
	preload("res://hatLeaf.png"),
	preload("res://hatPlunger.png"),
	preload("res://hatQueenCrown.png"),
	preload("res://hatSombrero.png"),
	preload("res://hatTophat.png"),
	preload("res://hatTophat.png"),
]


# Radius used to keep the turtle inside its pen; calculated in _ready().
var turtle_radius: float = 16.0

@onready var sprite: AnimatedSprite2D = $timmyTheTurtle
@onready var collision_shape: CollisionShape2D = $turtleHitbox

func _ready() -> void:
	
	_pick_random_direction()
	input_event.connect(_on_input_event)
	_calculate_turtle_size()
	sprite.play("default")
	z_index = 5
	turtleHat.texture = turtleHats[random_hat]
	turtleHat.visible = true
	
	print(turtleHat.global_position)
	print(global_position)

func _calculate_turtle_size() -> void:
	# Prefer the collision shape (most accurate), fall back to the sprite.
	var shape: Shape2D = collision_shape.shape
	if shape is CircleShape2D:
		turtle_radius = shape.radius * collision_shape.global_scale.x
		return
	elif shape is RectangleShape2D:
		turtle_radius = max(shape.size.x, shape.size.y) * 0.5 * collision_shape.global_scale.x
		return

	if sprite.texture:
		var scaled_size: Vector2 = sprite.texture.get_size() * sprite.global_scale
		# Use the larger dimension so corners don't poke out when the turtle rotates.
		turtle_radius = max(scaled_size.x, scaled_size.y) / 2.0

func _process(delta: float) -> void:
	if is_assigned_to_store or bounds == Rect2():
		return

	# Inset the pen bounds by the turtle radius.
	var min_x: float = bounds.position.x + turtle_radius
	var max_x: float = bounds.end.x - turtle_radius
	var min_y: float = bounds.position.y + turtle_radius
	var max_y: float = bounds.end.y - turtle_radius

	# Avoid inverted bounds if the pen is smaller than the turtle.
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
		return

	global_position += direction * speed * delta

	# Bounce off the pen walls.
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

	# Face the direction of travel.
	if direction.x > 0:
		sprite.flip_h = true
		turtleHat.flip_h = true
		turtleHat.global_position.x = sprite.global_position.x + 57
		
	elif direction.x < 0:
		sprite.flip_h = false
		turtleHat.flip_h = false
		turtleHat.global_position.x = sprite.global_position.x - 59

func send_to_station(target_pos: Vector2, register_number: int = 1, register_node: Node2D = null) -> void:
	if is_instance_valid(assigned_station):
		assigned_station.hasWorker = false
	sprite.flip_h = false
	current_job = "Register %d" % register_number
	assigned_station = register_node
	is_assigned_to_store = true
	global_position = target_pos

	if status_label:
		status_label.text = "Register %d" % register_number

func return_to_pen(new_bounds: Rect2) -> void:
	if is_instance_valid(assigned_station):
		assigned_station.hasWorker = false

	current_job = "Idle"
	assigned_station = null
	is_assigned_to_store = false
	bounds = new_bounds
	_pick_random_direction()

	if status_label:
		status_label.text = "Idle"

func _pick_random_direction() -> void:
	direction = Vector2.RIGHT.rotated(randf_range(0.0, TAU)).normalized()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		is_dragging = true
		drag_offset = global_position - get_global_mouse_position()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.is_pressed() and is_dragging:
			is_dragging = false
			_pick_random_direction()
			
func save_data() -> Dictionary:
	return {
		"pos_x": global_position.x,
		"pos_y": global_position.y,
		"random_hat": random_hat,
		"is_assigned_to_store": is_assigned_to_store,
		"assigned_station": assigned_station
	}
	
	
