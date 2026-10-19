extends Area2D

@export var speed: float = 300.0
@export var coins_reward: int = 10

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var target_x: float = 0.0
var has_reached_target: bool = false
var turtle_radius: float = 16.0
var earnedMoney = false

func _ready() -> void:
	sprite.play("default")
	var screen_width = get_viewport_rect().size.x
	target_x = screen_width * 0.25
	
	# Face left since it spawns on the right and walks left
	if sprite:
		sprite.flip_h = false
		
func _physics_process(delta: float) -> void:
	# Move left toward the target
	global_position.x -= speed * delta

	# Check if it has arrived at or passed the first quarter mark
	if global_position.x <= target_x:
		global_position.x = target_x
		_on_target_reached()
		
	if global_position.x < -100:
		queue_free()

func _on_target_reached() -> void:
	await get_tree().create_timer(2.0).timeout
	if !earnedMoney:
		earnedMoney = true
		spawn_coin_label(coins_reward)
	target_x = -1000
	
	
func spawn_coin_label(amount: int) -> void:
	var label = Label.new()
	label.text = "+%d coins" % amount
	
	# Set position: turtle's position + 50x, -50y
	label.global_position = global_position + Vector2(50, -75)
	
	# Style the label (Gold color with a dark outline)
	label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0)) # Gold
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_font_size_override("font_size", 25)
	label.z_index = 30  # Render on top of turtles and buildings
	
	# Add to the parent scene so it doesn't move with the turtle when it walks away
	get_parent().add_child(label)
	
	# Float upward and fade out over 1.2 seconds, then delete itself
	var tween = create_tween().set_parallel(true)
	tween.tween_property(label, "global_position:y", label.global_position.y - 25.0, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.chain().tween_callback(label.queue_free)
