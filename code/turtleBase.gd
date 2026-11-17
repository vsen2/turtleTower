extends Area2D

# Shared code for every turtle that lives in a pen (land, space and sea turtles).
# Each kind of turtle extends this and only adds how it moves and faces.

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

# Set by each turtle type in its _ready() before calling super().
var sprite: AnimatedSprite2D
var turtleHat: Sprite2D
var collision_shape: CollisionShape2D

func _ready() -> void:
	add_to_group("turtles")
	input_event.connect(onInputEvent)
	z_index = 5

func sendToStation(target_pos: Vector2, floor_id: String, spot_index: int, spot_node: Node2D = null, flip: bool = false) -> void:
	if is_instance_valid(assigned_station):
		assigned_station.hasWorker = false
	setFacing(flip)
	sprite.stop()
	assigned_station = spot_node
	assigned_floor_id = floor_id
	assigned_spot_index = spot_index
	is_assigned_to_store = true
	current_job = "%s #%d" % [floor_id.capitalize(), spot_index + 1]
	global_position = target_pos
	if status_label:
		status_label.text = current_job

func returnToPen(new_bounds: Rect2) -> void:
	if is_instance_valid(assigned_station):
		assigned_station.hasWorker = false
	current_job = "Idle"
	assigned_station = null
	assigned_floor_id = ""
	assigned_spot_index = -1
	is_assigned_to_store = false
	bounds = new_bounds
	sprite.play("default")
	pickRandomDirection()
	if status_label:
		status_label.text = "Idle"

func setHat(hat_id: int, from_inventory: bool) -> void:
	if hat_id < 0 or hat_id >= hats.size():
		return
	random_hat = hat_id
	hat_from_inventory = from_inventory
	turtleHat.texture = hats[hat_id]
	turtleHat.visible = true

# Override these in each turtle type.
func setFacing(_flip: bool) -> void:
	pass

func pickRandomDirection() -> void:
	pass

func onInputEvent(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		is_dragging = true
		drag_offset = global_position - get_global_mouse_position()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.is_pressed() and is_dragging:
			is_dragging = false
			pickRandomDirection()

func saveData() -> Dictionary:
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
