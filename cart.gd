extends Area2D

@export var speed: float
@export var coins_reward: int = 4
@export var location = get_parent()

@export var speedMultiplier: float = 1.0
@export var feedWorkersMultiplier: float = 1.0
@export var jackpotMultiplier: float = 1.0
@export var gemMultiplier: float = 1.0
@export var cartMultiplier: int = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fallingOre: AnimatedSprite2D = $fallingOre

@export var gems: Array[Sprite2D] = []

var target_x: float = 0.0
var earned_money: bool = false
var baseSpeed: float = 200.0
var fallingOreSpeed: float = 0
var jackpotMulti = 1
var jackpot = false

@onready var parent: Sprite2D

func _ready() -> void:
	speed = baseSpeed * speedMultiplier
	sprite.play("empty")
	target_x = get_viewport_rect().size.x * 0.5
	
	parent = get_parent()
	parent.hasCart = true
	
func _physics_process(delta: float) -> void:
	# Walk left toward the first quarter of the screen.
	global_position.x -= speed * delta
	fallingOre.global_position.y += fallingOreSpeed*speedMultiplier

	if global_position.x <= target_x:
		global_position.x = target_x
		_on_target_reached()

	if global_position.x < -200:
		await get_tree().create_timer(1.0).timeout
		parent.hasCart = false
		queue_free()

func _on_target_reached() -> void:
	fallingOreSpeed = 2
	fallingOre.visible = true
	if fallingOre.global_position.y > sprite.global_position.y - 30 and not earned_money:
		fallingOre.visible = false
		sprite.play("full")
		earned_money = true
		var jackpotRandom = randi_range(1, 100)
		if jackpotRandom <= jackpotMultiplier:
			jackpotMulti = 100
			jackpot = true
		spawn_coin_label(coins_reward*gemMultiplier*cartMultiplier*jackpotMulti)
		target_x = -1000

func spawn_coin_label(amount: int) -> void:
	var label: Label = Label.new()
	label.text = "+%d coins" % amount
	if jackpot:
		label.text = "+%d JACKPOT" % amount
	GameManager.add_coins(amount)
	label.top_level = true
	label.global_position = global_position + Vector2(40, -80)
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
