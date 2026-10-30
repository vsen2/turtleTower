extends Sprite2D

@export var cart: PackedScene = preload("res://cart.tscn")
@export var spot_id: String = ""

const BUTTON_NORMAL_TEXTURE = preload("res://assets/plusButtonWhite.png")
const BUTTON_HOVER_TEXTURE = preload("res://assets/plusButtonGrey.png")

@export var location = get_parent()
@export var wait_time: float = 10.0

@export var unlocked: bool = false
var hasWorker: bool = false
var hasCart: bool = false

var unlock_button: TextureButton

func _ready() -> void:
	add_to_group("job_spots")
	z_index = 10
	if not unlocked:
		create_unlock_button()

func _process(_delta: float) -> void:
	if not hasWorker:
		return
	if hasCart:
		return
	spawn_new_cart()

func create_unlock_button() -> void:
	unlock_button = TextureButton.new()
	unlock_button.texture_normal = BUTTON_NORMAL_TEXTURE
	unlock_button.texture_hover = BUTTON_HOVER_TEXTURE
	unlock_button.z_index = 19
	unlock_button.top_level = true
	unlock_button.ignore_texture_size = true
	unlock_button.stretch_mode = TextureButton.STRETCH_SCALE
	unlock_button.custom_minimum_size = Vector2(100, 100)
	unlock_button.size = Vector2(100, 100)
	add_child(unlock_button)
	unlock_button.global_position = global_position - Vector2(310, 50)
	unlock_button.pressed.connect(_on_spot_plus_pressed)

func _on_spot_plus_pressed() -> void:
	unlocked = true
	modulate = Color.WHITE
	if is_instance_valid(unlock_button):
		unlock_button.queue_free()
		unlock_button = null
	var main: Node = get_tree().current_scene
	if main and main.has_method("begin_spot_assignment"):
		main.begin_spot_assignment(self)

func spawn_new_cart() -> void:
	if not cart:
		return
	var newCart: Node2D = cart.instantiate()
	var spawn_x: float = get_viewport_rect().size.x
	var spawn_y: float = global_position.y + 15
	newCart.top_level = true
	newCart.scale = Vector2(0.4, 0.4)
	newCart.global_position = Vector2(spawn_x, spawn_y)
	add_child(newCart)

func get_spot_save_data() -> Dictionary:
	return {"spot_id": spot_id, "unlocked": unlocked, "has_worker": hasWorker}

func load_spot_save_data(data: Dictionary) -> void:
	unlocked = bool(data.get("unlocked", false))
	hasWorker = bool(data.get("has_worker", false))
	if unlocked:
		modulate = Color.WHITE
		if is_instance_valid(unlock_button):
			unlock_button.queue_free()
			unlock_button = null
	elif not is_instance_valid(unlock_button):
		create_unlock_button()
