extends Node

signal hats_changed

var turtle_coins: int = 1000
var hat_coins: int = 0
var customer_speed_multiplier: float = 1.0
var spawn_timer_multiplier: float = 1.0
var owned_hats: Array[int] = []

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
	preload("res://assets/hatCowboy.png"),
	preload("res://assets/hatBeard.png"),
	preload("res://assets/hatChristmas.png"),
	preload("res://assets/hatMagicChristmas.png"),
	preload("res://assets/hatSandBucket.png"),
	preload("res://assets/hatJackOlantern.png"),]
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
	preload("res://assets/hatCenteredCowboy.png"),
	preload("res://assets/hatCenteredBeard.png"),
	preload("res://assets/hatCenteredChristmas.png"),
	preload("res://assets/hatCenteredMagicChristmas.png"),
	preload("res://assets/hatCenteredSandBucket.png"),
	preload("res://assets/hatCenteredJackOlantern.png"),]
@export var hatNames: Array[String] = [
	"Chef Hat",
	"Dunce Hat",
	"Nest Hat",
	"Fishbowl Hat",
	"Fishing Rod Hat",
	"Joyful Hat",
	"Eyes Hat",
	"King Crown",
	"Leaf Hat",
	"Plunger Hat",
	"Queen Crown",
	"Sombrero Hat",
	"Top Hat",
	"Traffic Cone Hat",
	"Cowboy Hat",
	"Beard Hat",
	"Christmas Tree Hat",
	"Special Christmas Hat",
	"Sand Bucket Hat",
	"Jack O Lantern",]
		
@export var numHats = hats.size()
signal coins_changed(new_amount: int)
signal coins_spent(amount: int)
		
func add_coins(amount: int) -> void:
	turtle_coins += amount
	coins_changed.emit(turtle_coins)

func spend_coins(amount: int) -> bool:
	if turtle_coins >= amount:
		turtle_coins -= amount
		coins_spent.emit(amount)
		coins_changed.emit(turtle_coins)
		
		return true
	return false

func spend_hat_coins(amount: int) -> bool:
	if hat_coins >= amount:
		hat_coins -= amount
		return true
	return false
	

func add_hat(hat_id: int) -> void:
	owned_hats.append(hat_id)
	hats_changed.emit()

func set_owned_hats(list: Array) -> void:
	owned_hats.clear()
	for h in list:
		owned_hats.append(int(h))  # JSON loads numbers as floats
	hats_changed.emit()
	
func remove_hat(hat_id: int) -> bool:
	var idx: int = owned_hats.find(hat_id)
	if idx == -1:
		return false
	owned_hats.remove_at(idx)
	hats_changed.emit()
	return true
