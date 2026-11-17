extends "res://code/turtleBase.gd"

@export var speed: float = 80.0

var turtle_radius: float = 16.0

func _ready() -> void:
	sprite = $timmyTheTurtle
	turtleHat = $timmyTheTurtle/turtleHat
	collision_shape = $turtleHitbox
	super()
	if hats.size() > 0:
		if random_hat < 0 or random_hat >= hats.size():
			random_hat = randi_range(-10, hats.size() - 1)
		if random_hat > 0:
			turtleHat.texture = hats[random_hat]
			turtleHat.visible = true
	else:
		turtleHat.visible = false
	# Calculate turtle size BEFORE any positioning,
	# so _process can clamp correctly on save/load.
	calculateTurtleSize()
	pickRandomDirection()
	sprite.play("default")

func calculateTurtleSize() -> void:
	var shape: Shape2D = collision_shape.shape
	if shape is CircleShape2D:
		turtle_radius = shape.radius * collision_shape.global_scale.x
		return
	elif shape is RectangleShape2D:
		turtle_radius = max(shape.size.x, shape.size.y) * 0.5 * collision_shape.global_scale.x
		return
	if sprite.texture:
		var scaled_size: Vector2 = sprite.texture.get_size() * sprite.global_scale
		turtle_radius = max(scaled_size.x, scaled_size.y) / 2.0
		print("calculateTurtleSize: sprite.texture=", sprite.texture, "radius=", turtle_radius)
	else:
		print("calculateTurtleSize: sprite.texture is NULL - radius stays", turtle_radius)

func _process(delta: float) -> void:
	if is_assigned_to_store or bounds == Rect2():
		return
	var min_x: float = bounds.position.x + turtle_radius
	var max_x: float = bounds.end.x - turtle_radius
	var min_y: float = bounds.position.y + turtle_radius
	var max_y: float = bounds.end.y - turtle_radius
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
	if direction.x > 0:
		sprite.flip_h = true
		turtleHat.flip_h = true
		turtleHat.global_position.x = sprite.global_position.x + 57
	elif direction.x < 0:
		sprite.flip_h = false
		turtleHat.flip_h = false
		turtleHat.global_position.x = sprite.global_position.x - 59

func setFacing(flip: bool) -> void:
	sprite.flip_h = flip
	turtleHat.flip_h = flip
	if flip:
		turtleHat.global_position.x = sprite.global_position.x + 57
	else:
		turtleHat.global_position.x = sprite.global_position.x - 59
		
func pickRandomDirection() -> void:
	direction = Vector2.RIGHT.rotated(randf_range(0.0, TAU)).normalized()
