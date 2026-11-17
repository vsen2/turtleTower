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
		onTargetReached()

	if global_position.x < -100:
		await get_tree().create_timer(1.0).timeout
		queue_free()

func onTargetReached() -> void:
	await get_tree().create_timer(3.0 / feedWorkersMultiplier).timeout
	if not earned_money:
		earned_money = true
		for apple in apples:
			apple.queue_free()
		spawnCoinLabel(coins_reward*fruitMultiplier*appleMultiplier)
	target_x = -1000

func spawnCoinLabel(amount: int) -> void:
	GameManager.addCoins(amount)
	# Added to the parent so the label stays put when the turtle walks away.
	GameManager.spawnFloatingLabel(get_parent(), "+%d coins" % amount, global_position + Vector2(50, -75),
		Color.BLACK, 25, "", true, 25.0, 0.8, 0.8)
