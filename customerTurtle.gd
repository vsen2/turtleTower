extends Area2D

@export var speed: float = 80.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var target_x: float = 0.0
var has_reached_target: bool = false
var turtle_radius: float = 16.0

func _ready() -> void:
	sprite.play("default")
	var screen_width = get_viewport_rect().size.x
	target_x = screen_width * 0.25
	
	# Face left since it spawns on the right and walks left
	if sprite:
		sprite.flip_h = false
		
func _physics_process(delta: float) -> void:
	if has_reached_target:
		return

	# Move left toward the target
	global_position.x -= speed * delta

	# Check if it has arrived at or passed the first quarter mark
	if global_position.x <= target_x:
		global_position.x = target_x
		has_reached_target = true
		_on_target_reached()

func _on_target_reached() -> void:
	pass
