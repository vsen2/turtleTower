extends Sprite2D

@export var cart: PackedScene = preload("res://cart.tscn")
@onready var turtleUI: Control = %TurtleUI

const BUTTON_NORMAL_TEXTURE = preload("res://assets/plusButtonWhite.png")
const BUTTON_HOVER_TEXTURE = preload("res://assets/plusButtonGrey.png")

@export var location = get_parent()
@export var wait_time: float = 10.0

@export var unlocked: bool = false
var hasWorker: bool = false
var hasCart: bool = false

var unlock_button: TextureButton

func _ready() -> void:
	z_index = 10
	create_unlock_button()

func _process(_delta: float) -> void:
	# Only run the customer timer while this register is unlocked and staffed.
	return
	if hasCart:
		return
		print("hasCart")
	else:
		print("new cart")
		spawn_new_cart()
		
func create_unlock_button() -> void:
	unlock_button = TextureButton.new()
	unlock_button.texture_normal = BUTTON_NORMAL_TEXTURE
	unlock_button.texture_hover = BUTTON_HOVER_TEXTURE       # Changes texture on hover
	unlock_button.texture_pressed = BUTTON_HOVER_TEXTURE     # Optional: keep texture when clicked
	unlock_button.z_index = 19
	
	unlock_button.top_level = true
	
	# Allow custom sizing
	unlock_button.ignore_texture_size = true
	unlock_button.stretch_mode = TextureButton.STRETCH_SCALE
	unlock_button.custom_minimum_size = Vector2(100, 100)
	unlock_button.size = Vector2(100, 100)
	
	# Add to tree BEFORE setting global coordinates
	add_child(unlock_button)
	
	# Set exact global position
	unlock_button.global_position = global_position - Vector2(310, 50)
	
	unlock_button.pressed.connect(_on_unlock_button_pressed)

func _on_unlock_button_pressed() -> void:
	unlocked = true
	turtleUI.visible = true
	modulate = Color.WHITE
	if is_instance_valid(unlock_button):
		unlock_button.queue_free()

func spawn_new_cart() -> void:
	if not cart:
		return
	print("cart!")
	var newCart: Node2D = cart.instantiate()
	var spawn_x: float = get_viewport_rect().size.x
	var spawn_y: float = global_position.y + 15
	#newCart.speedMultiplier = location.cartSpeedMultiplier
	#newCart.feedWorkersMultiplier = location.feedWorkersMultiplier
	#newCart.fruitMultiplier = location.betterFruitMultiplier
	#newCart.appleMultiplier = location.appleMultiplier
	newCart.global_position = Vector2(spawn_x, spawn_y)

	add_child(newCart)
