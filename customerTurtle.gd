extends Area2D

@export var speed: float
@export var coins_reward: int = 4

@export var speedMultiplier: float = 1.0
@export var feedWorkersMultiplier: float = 1.0
@export var fruitMultiplier: float = 1.0
@export var appleMultiplier: int = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var apples: Array[Sprite2D] = []

var target_x: float = 0.0
var earned_money: bool = false
var baseSpeed: float = 300.0

func _ready() -> void:
	speed = baseSpeed * speedMultiplier

	sprite.play("default")
	target_x = get_viewport_rect().size.x * 0.25
	
	for i in range(appleMultiplier):
		var newApple := Sprite2D.new()
		newApple.texture = load("res://assets/apple.png")
		newApple.position = Vector2(45*(i+1), -58)
		newApple.z_index = 10
		newApple.scale = Vector2(0.15, 0.15)
		add_child(newApple)
		apples.append(newApple)
		

func _physics_process(delta: float) -> void:
	# Walk left toward the first quarter of the screen.
	global_position.x -= speed * delta

	if global_position.x <= target_x:
		global_position.x = target_x
		_on_target_reached()

	if global_position.x < -100:
		await get_tree().create_timer(1.0).timeout
		queue_free()

func _on_target_reached() -> void:
	await get_tree().create_timer(4.0 / feedWorkersMultiplier).timeout
	if not earned_money:
		earned_money = true
		for apple in apples:
			apple.queue_free()
		spawn_coin_label(coins_reward*fruitMultiplier*appleMultiplier)
	target_x = -1000

func spawn_coin_label(amount: int) -> void:
	var label: Label = Label.new()
	label.text = "+%d coins" % amount
	GameManager.add_coins(amount)
	label.global_position = global_position + Vector2(50, -75)
	label.z_index = 30
	label.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0, 1.0)) # color
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_font_size_override("font_size", 25)

	# Add to the parent so the label stays put when the turtle walks away.
	get_parent().add_child(label)

	# Float upward and fade out, then delete itself.
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(label, "global_position:y", label.global_position.y - 25.0, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.chain().tween_callback(label.queue_free)
