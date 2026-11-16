extends Node

signal hats_changed

var turtle_coins: int = 100000
var hat_coins: int = 0
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
	preload("res://assets/hatJackOlantern.png"),
	preload("res://assets/hatHalo.png"),
	preload("res://assets/hatDino.png"),
	preload("res://assets/hatIceCream.png"),
	preload("res://assets/hatBeanie.png"),
	preload("res://assets/hatBanana.png"),
	preload("res://assets/hatBatman.png"),
	preload("res://assets/hatDrinks.png"),
	preload("res://assets/hatSkull.png"),
	preload("res://assets/hatSteampunk.png"),
	preload("res://assets/hatMagicSteampunk.png")]
	
	
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
	preload("res://assets/hatCenteredJackOLantern.png"),
	preload("res://assets/hatCenteredHalo.png"),
	preload("res://assets/hatCenteredDino.png"),
	preload("res://assets/hatCenteredIceCream.png"),
	preload("res://assets/hatCenteredBeanie.png"),
	preload("res://assets/hatCenteredBanana.png"),
	preload("res://assets/hatCenteredBatman.png"),
	preload("res://assets/hatCenteredDrinks.png"),
	preload("res://assets/hatCenteredSkull.png"),
	preload("res://assets/hatCenteredSteampunk.png"),
	preload("res://assets/hatCenteredMagicSteampunk.png")]
@export var hatNames: Array[String] = [
	"Chef Hat","Dunce Hat","Nest Hat","Fishbowl Hat","Fishing Rod Hat","Joyful Hat","Eyes Hat","King Crown","Leaf Hat","Plunger Hat",
	"Queen Crown","Sombrero Hat","Top Hat","Traffic Cone Hat","Cowboy Hat","Beard Hat","Christmas Tree Hat","Special Christmas Hat",
	"Sand Bucket Hat","Jack O Lantern","Halo","Dino", "Ice Cream", "Beanie", "Banana", "Bat", "Drink Hat", "Steampunk", "Steampunk rare"
	]
		
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

func spawnNopeLabel(words: String) -> void:
	var label: Label = Label.new()
	label.name = "cantBuyLabel"
	label.text = words
	label.top_level = true
	label.global_position = get_viewport().get_mouse_position()
	label.z_index = 30
	label.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0, 1.0)) # color
	label.add_theme_font_size_override("font_size", 25)
	add_child(label)
	# Float upward and fade out, then delete itself.
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(label, "global_position:y", label.global_position.y - 20.0, .5)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.chain().tween_callback(label.queue_free)
