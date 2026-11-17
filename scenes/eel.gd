extends Area2D

@export var speed: float = 120
@export var max_swim_angle: float = 50.0
@export var max_tilt: float = 20.0
@export var turn_speed: float = 6.0

var bounds: Rect2
var direction: Vector2 = Vector2.ZERO

var facing_right: bool = false

@onready var sprite: AnimatedSprite2D = $electricEel
@onready var electricity: AnimatedSprite2D = $electricEel/electricity
@onready var collision_shape: CollisionShape2D = $eelHitbox

func _ready() -> void:
	pickRandomDirection()
	sprite.play("default")
	electricity.play("default")
	z_index = 5

func _process(delta: float) -> void:
	# How far the eel's body reaches from its origin, so the whole eel
	# (not just its center point) stays inside the tank.
	var body: Rect2 = bodyRect()
	var min_x: float = bounds.position.x - body.position.x
	var max_x: float = bounds.end.x - body.end.x
	var min_y: float = bounds.position.y - body.position.y
	var max_y: float = bounds.end.y - body.end.y
	if min_x > max_x:
		min_x = bounds.get_center().x
		max_x = min_x
	if min_y > max_y:
		min_y = bounds.get_center().y
		max_y = min_y

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

	updateSprite(delta)

## The eel's body box relative to its origin, based on the hitbox.
## Mirrors with the sprite and grows a bit when the eel tilts.
func bodyRect() -> Rect2:
	var shape := collision_shape.shape as RectangleShape2D
	if shape == null:
		return Rect2(-Vector2(16, 16), Vector2(32, 32))
	var center: Vector2 = collision_shape.position
	if facing_right:
		center.x = -center.x
	var half: Vector2 = shape.size / 2.0
	# Tilting raises/lowers the nose and tail
	half.y += half.x * abs(sin(sprite.rotation))
	return Rect2(center - half, half * 2.0)

## Flips the sprite to face the swim direction and tilts it up/down (capped).
func updateSprite(delta: float) -> void:
	if direction.x > 0:
		facing_right = true
	elif direction.x < 0:
		facing_right = false
	# The sprite faces left by default, so facing right = mirror it.
	sprite.scale.x = -abs(sprite.scale.x) if facing_right else abs(sprite.scale.x)

	# Angle above/below horizontal: positive = swimming down.
	var pitch: float = atan2(direction.y, abs(direction.x))
	var limit: float = deg_to_rad(max_tilt)
	pitch = clamp(pitch, -limit, limit)
	# Nose-down is clockwise when facing right, counter-clockwise when facing left.
	var target: float = pitch if facing_right else -pitch
	sprite.rotation = lerp_angle(sprite.rotation, target, clamp(turn_speed * delta, 0.0, 1.0))

## Faces left or right and levels out (used at job spots).
func setFacing(flip: bool) -> void:
	facing_right = flip
	sprite.scale.x = -abs(sprite.scale.x) if flip else abs(sprite.scale.x)
	sprite.rotation = 0.0
	
## Picks a new swim direction, never steeper than max_swim_angle.
func pickRandomDirection() -> void:
	var angle: float = deg_to_rad(randf_range(-max_swim_angle, max_swim_angle))
	direction = Vector2.RIGHT.rotated(angle)
	if randf() < 0.5:
		direction.x = -direction.x
