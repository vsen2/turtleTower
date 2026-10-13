extends Sprite2D

@export var customer_spawn_offset: Vector2 = Vector2(0, 32)

var unlocked: bool = false
var hasWorker: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func can_accept_customer() -> bool:
	return unlocked and hasWorker
