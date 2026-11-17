extends "res://code/turtleBase.gd"

@export var turtle_icon: Texture2D = preload("res://assets/turtleNoBG.png")
@export var turtle_scene: PackedScene = preload("res://scenes/seaTurtle.tscn")

@export var speed: float = 120
## Steepest angle (degrees from horizontal) the turtle will swim at.
@export var max_swim_angle: float = 50.0
## Most the body will visibly tilt up or down (degrees).
@export var max_tilt: float = 20.0
## How fast the body turns toward its new angle. Higher = snappier.
@export var turn_speed: float = 6.0

var half_size: Vector2 = Vector2(16, 16)
## Fine-tune how close the turtle gets to the walls. Negative = can overlap a bit.
@export var edge_padding: Vector2 = Vector2.ZERO

var facing_right: bool = false

@onready var body: Node2D = $body

func _ready() -> void:
	sprite = $body/seaTurtle
	turtleHat = $body/turtleHat
	collision_shape = $turtleHitbox
	super()
	if hats.size() > 0:
		if random_hat < 0 or random_hat >= hats.size():
			random_hat = randi_range(0, hats.size() - 1)
		turtleHat.texture = hats[random_hat]
		turtleHat.visible = true
	else:
		turtleHat.visible = false
	calculateTurtleSize()
	pickRandomDirection()
	sprite.play("default")

func calculateTurtleSize() -> void:
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

	updateBody(delta)

## Flips the body to face the swim direction and tilts it up/down (capped).
func updateBody(delta: float) -> void:
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

## Faces left or right and levels out (used at job spots).
func setFacing(flip: bool) -> void:
	facing_right = flip
	body.scale.x = -abs(body.scale.x) if flip else abs(body.scale.x)
	body.rotation = 0.0

## Picks a new swim direction, never steeper than max_swim_angle.
func pickRandomDirection() -> void:
	var angle: float = deg_to_rad(randf_range(-max_swim_angle, max_swim_angle))
	direction = Vector2.RIGHT.rotated(angle)
	if randf() < 0.5:
		direction.x = -direction.x
