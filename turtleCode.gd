extends Area2D

@export var speed: float = 80.0
var bounds: Rect2

var direction: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_pick_random_direction()
	input_event.connect(_on_input_event)

func _process(delta: float) -> void:
	# Calculate margin so the turtle sprite stays fully inside the pen
	var half_size: Vector2 = Vector2.ZERO
	if sprite and sprite.texture:
		half_size = (sprite.texture.get_size() * sprite.global_scale) / 2.0

	var min_x = bounds.position.x + half_size.x
	var max_x = bounds.end.x - half_size.x
	var min_y = bounds.position.y + half_size.y
	var max_y = bounds.end.y - half_size.y

	if is_dragging:
		global_position = get_global_mouse_position() + drag_offset
		global_position.x = clamp(global_position.x, min_x, max_x)
		global_position.y = clamp(global_position.y, min_y, max_y)
	else:
		global_position += direction * speed * delta
		
		# Bounce off inner walls of TurtlePen
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
		
		# rotation = direction.angle()

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
