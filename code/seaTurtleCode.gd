extends Area2D

@export var turtle_icon: Texture2D = preload("res://assets/turtleNoBG.png")
@export var turtle_scene: PackedScene = preload("res://scenes/seaTurtle.tscn")

@export var speed: float = 120
## Steepest angle (degrees from horizontal) the turtle will swim at.
@export var max_swim_angle: float = 50.0
## Most the body will visibly tilt up or down (degrees).
@export var max_tilt: float = 20.0
## How fast the body turns toward its new angle. Higher = snappier.
@export var turn_speed: float = 6.0

var bounds: Rect2
var direction: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var is_assigned_to_store: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var current_job: String = "Idle"
var assigned_station: Node2D = null
var status_label: Label = null
var random_hat: int = -1
var assigned_floor_id: String = ""
var assigned_spot_index: int = -1
var hat_from_inventory: bool = false
var home_pen_id: String = "" 

var hats = GameManager.hats
var half_size: Vector2 = Vector2(16, 16)
## Fine-tune how close the turtle gets to the walls. Negative = can overlap a bit.
@export var edge_padding: Vector2 = Vector2.ZERO

var facing_right: bool = false

@onready var body: Node2D = $body
@onready var sprite: AnimatedSprite2D = $body/seaTurtle
@onready var turtleHat: Sprite2D = $body/turtleHat
@onready var collision_shape: CollisionShape2D = $turtleHitbox

func _ready() -> void:
	add_to_group("turtles")
	if hats.size() > 0:
		if random_hat < 0 or random_hat >= hats.size():
			random_hat = randi_range(0, hats.size() - 1)
		turtleHat.texture = hats[random_hat]
		turtleHat.visible = true
	else:
		turtleHat.visible = false
	_calculate_turtle_size()
	_pick_random_direction()
	input_event.connect(_on_input_event)
	sprite.play("default")
	z_index = 5

func _calculate_turtle_size() -> void:
	# Use the hitbox first, since it matches the visible turtle.
	var shape: Shape2D = collision_shape.shape
	if shape is RectangleShape2D:
		half_size = shape.size * collision_shape.global_scale.abs() / 2.0
		return
	if shape is CircleShape2D:
		var r: float = shape.radius * collision_shape.global_scale.x
		half_size = Vector2(r, r)
		return
	# Fallback: the sprite image.
	if sprite.sprite_frames:
		var tex: Texture2D = sprite.sprite_frames.get_frame_texture(sprite.animation, 0)
		if tex:
			half_size = tex.get_size() * sprite.global_scale.abs() / 2.0

func _process(delta: float) -> void:
	if is_assigned_to_store or bounds == Rect2():
		return
	var min_x: float = bounds.position.x + half_size.x + edge_padding.x
	var max_x: float = bounds.end.x - half_size.x - edge_padding.x
	var min_y: float = bounds.position.y + half_size.y + edge_padding.y
	var max_y: float = bounds.end.y - half_size.y - edge_padding.y
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

	# Bounce off the pen walls. Flipping x or y keeps the same shallow angle.
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

	_update_body(delta)

## Flips the body to face the swim direction and tilts it up/down (capped).
func _update_body(delta: float) -> void:
	if direction.x > 0:
		facing_right = true
	elif direction.x < 0:
		facing_right = false
	# The sprite faces left by default, so facing right = mirror it.
	body.scale.x = -abs(body.scale.x) if facing_right else abs(body.scale.x)

	# Angle above/below horizontal: positive = swimming down.
	var pitch: float = atan2(direction.y, abs(direction.x))
	var limit: float = deg_to_rad(max_tilt)
	pitch = clamp(pitch, -limit, limit)
	# Nose-down is clockwise when facing right, counter-clockwise when facing left.
	var target: float = pitch if facing_right else -pitch
	body.rotation = lerp_angle(body.rotation, target, clamp(turn_speed * delta, 0.0, 1.0))

func send_to_station(target_pos: Vector2, floor_id: String, spot_index: int, spot_node: Node2D = null, flip: bool = false) -> void:
	if is_instance_valid(assigned_station):
		assigned_station.hasWorker = false
	_set_facing(flip)
	sprite.stop()
	assigned_station = spot_node
	assigned_floor_id = floor_id
	assigned_spot_index = spot_index
	is_assigned_to_store = true
	current_job = "%s #%d" % [floor_id.capitalize(), spot_index + 1]
	global_position = target_pos
	if status_label:
		status_label.text = current_job

func return_to_pen(new_bounds: Rect2) -> void:
	if is_instance_valid(assigned_station):
		assigned_station.hasWorker = false
	current_job = "Idle"
	assigned_station = null
	assigned_floor_id = ""
	assigned_spot_index = -1
	is_assigned_to_store = false
	bounds = new_bounds
	sprite.play("default")
	_pick_random_direction()
	if status_label:
		status_label.text = "Idle"

## Faces left or right and levels out (used at job spots).
func _set_facing(flip: bool) -> void:
	facing_right = flip
	body.scale.x = -abs(body.scale.x) if flip else abs(body.scale.x)
	body.rotation = 0.0

func set_hat(hat_id: int, from_inventory: bool) -> void:
	if hat_id < 0 or hat_id >= hats.size():
		return
	random_hat = hat_id
	hat_from_inventory = from_inventory
	turtleHat.texture = hats[hat_id]
	turtleHat.visible = true

## Picks a new swim direction, never steeper than max_swim_angle.
func _pick_random_direction() -> void:
	var angle: float = deg_to_rad(randf_range(-max_swim_angle, max_swim_angle))
	direction = Vector2.RIGHT.rotated(angle)
	if randf() < 0.5:
		direction.x = -direction.x

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
		"hat_from_inventory": hat_from_inventory,
		"is_assigned_to_store": is_assigned_to_store,
		"assigned_floor_id": assigned_floor_id,
		"assigned_spot_index": assigned_spot_index,
		"home_pen_id": home_pen_id,
	}
