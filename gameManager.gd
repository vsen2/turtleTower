extends Node

var turtle_coins: int = 1000
var customer_speed_multiplier: float = 1.0
var spawn_timer_multiplier: float = 1.0

@export var hats: Array[Texture2D] = [
	preload("res://assets/hatChef.png"),
	preload("res://assets/hatDunce.png"),
	preload("res://assets/hatEgg.png"),
	preload("res://assets/hatFishbowl.png"),
	preload("res://assets/hatFishingRod.png"),
	preload("res://assets/hatFunnyPropellor.png"),
	preload("res://assets/hatGooglyEyes.png"),
	preload("res://assets/hatKingCrown.png"),
	preload("res://assets/hatLeaf.png"),
	preload("res://assets/hatPlunger.png"),
	preload("res://assets/hatQueenCrown.png"),
	preload("res://assets/hatSombrero.png"),
	preload("res://assets/hatTophat.png"),
	preload("res://assets/hatTrafficCone.png"),
]

@export var hatsCentered: Array[Texture2D] = [
	preload("res://assets/hatCenteredChef.png"),
	preload("res://assets/hatCenteredDunce.png"),
	preload("res://assets/hatCenteredEgg.png"),
	preload("res://assets/hatCenteredFishbowl.png"),
	preload("res://assets/hatCenteredFishingRod.png"),
	preload("res://assets/hatCenteredFunnyPropellor.png"),
	preload("res://assets/hatCenteredGooglyEyes.png"),
	preload("res://assets/hatCenteredKingCrown.png"),
	preload("res://assets/hatCenteredLeaf.png"),
	preload("res://assets/hatCenteredPlunger.png"),
	preload("res://assets/hatCenteredQueenCrown.png"),
	preload("res://assets/hatCenteredSombrero.png"),
	preload("res://assets/hatCenteredTophat.png"),
	preload("res://assets/hatCenteredTrafficCone.png"),
]


@export var numHats = hats.size()
signal coins_changed(new_amount: int)

func add_coins(amount: int) -> void:
	turtle_coins += amount
	coins_changed.emit(turtle_coins)

func spend_coins(amount: int) -> bool:
	if turtle_coins >= amount:
		turtle_coins -= amount
		coins_changed.emit(turtle_coins)
		return true
	return false
