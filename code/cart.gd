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
		onTargetReached()

	if global_position.x < -200:
		await get_tree().create_timer(1.0).timeout
		parent.hasCart = false
		queue_free()

func onTargetReached() -> void:
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
		spawnCoinLabel(coins_reward*gemMultiplier*cartMultiplier*jackpotMulti)
		target_x = -1000

func spawnCoinLabel(amount: int) -> void:
	GameManager.addCoins(amount)
	var text: String = ("+%d JACKPOT" if jackpot else "+%d coins") % amount
	# Added to the parent so the label stays put when the cart moves away.
	GameManager.spawnFloatingLabel(get_parent(), text, global_position + Vector2(40, -80),
		Color.BLACK, 25, "", true, 25.0, 0.8, 0.8)
