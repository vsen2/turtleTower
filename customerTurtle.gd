extends Area2D

signal purchase_completed(amount: int)

@export var payment_amount: int = 15
@export var browse_time: float = 2.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Wait for browse/checkout time, complete payment, then leave
	await get_tree().create_timer(browse_time).timeout
	purchase_completed.emit(payment_amount)
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
