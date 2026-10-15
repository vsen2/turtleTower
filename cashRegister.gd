extends Sprite2D

@export var customer_spawn_offset: Vector2 = Vector2(0, 32)
@export var customer_turtle_scene: PackedScene = preload("res://customerTurtle.tscn")

var unlocked: bool = false
var hasWorker: bool = true
var hasTurtle: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(can_accept_customer()):
		spawn_customer_turtle()
		hasTurtle = true
	
func can_accept_customer() -> bool:
	return unlocked and hasWorker and !hasTurtle

func spawn_customer_turtle() -> void:
	if not customer_turtle_scene:
		return
	
	# Instantiate the customer turtle
	var customer = customer_turtle_scene.instantiate()
	
	# Find the right edge of the screen using the viewport
	var viewport_rect = get_viewport_rect()
	var spawn_x = viewport_rect.size.x
	
	# Match the Y position of the object running this script
	var spawn_y = global_position.y + 15
	
	# Set the spawn position
	customer.global_position = Vector2(spawn_x, spawn_y)
	
	# Add it to the scene (typically added to the parent or a main manager node)
	get_parent().add_child(customer)
