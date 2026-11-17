extends Node

signal hats_changed

var turtle_coins: int = 100000
var hat_coins: int = 0
var owned_hats: Array[int] = []

@export var hats: Array[Texture2D] = [
	preload("res://assets/hat-Chef.png"),
	preload("res://assets/hat-Dunce.png"),
	preload("res://assets/hat-Egg.png"),
	preload("res://assets/hat-Fishbowl.png"),
	preload("res://assets/hat-FishingRod.png"),
	preload("res://assets/hat-FunnyPropellor.png"),
	preload("res://assets/hat-GooglyEyes.png"),
	preload("res://assets/hat-KingCrown.png"),
	preload("res://assets/hat-Leaf.png"),
	preload("res://assets/hat-Plunger.png"),
	preload("res://assets/hat-QueenCrown.png"),
	preload("res://assets/hat-Sombrero.png"),
	preload("res://assets/hat-Tophat.png"),
	preload("res://assets/hat-TrafficCone.png"),
	preload("res://assets/hat-Cowboy.png"),
	preload("res://assets/hat-Beard.png"),
	preload("res://assets/hat-Christmas.png"),
	preload("res://assets/hat-MagicChristmas.png"),
	preload("res://assets/hat-SandBucket.png"),
	preload("res://assets/hat-JackOlantern.png"),
	preload("res://assets/hat-Halo.png"),
	preload("res://assets/hat-Dino.png"),
	preload("res://assets/hat-IceCream.png"),
	preload("res://assets/hat-Beanie.png"),
	preload("res://assets/hat-Banana.png"),
	preload("res://assets/hat-Batman.png"),
	preload("res://assets/hat-Drinks.png"),
	preload("res://assets/hat-Skull.png"),
	preload("res://assets/hat-Steampunk.png"),
	preload("res://assets/hat-MagicSteampunk.png")]
	
	
@export var hatsCentered: Array[Texture2D] = [
	preload("res://assets/hatCentered-Chef.png"),
	preload("res://assets/hatCentered-Dunce.png"),
	preload("res://assets/hatCentered-Egg.png"),
	preload("res://assets/hatCentered-Fishbowl.png"),
	preload("res://assets/hatCentered-FishingRod.png"),
	preload("res://assets/hatCentered-FunnyPropellor.png"),
	preload("res://assets/hatCentered-GooglyEyes.png"),
	preload("res://assets/hatCentered-KingCrown.png"),
	preload("res://assets/hatCentered-Leaf.png"),
	preload("res://assets/hatCentered-Plunger.png"),
	preload("res://assets/hatCentered-QueenCrown.png"),
	preload("res://assets/hatCentered-Sombrero.png"),
	preload("res://assets/hatCentered-Tophat.png"),
	preload("res://assets/hatCentered-TrafficCone.png"),
	preload("res://assets/hatCentered-Cowboy.png"),
	preload("res://assets/hatCentered-Beard.png"),
	preload("res://assets/hatCentered-Christmas.png"),
	preload("res://assets/hatCentered-MagicChristmas.png"),
	preload("res://assets/hatCentered-SandBucket.png"),
	preload("res://assets/hatCentered-jackOLantern.png"),
	preload("res://assets/hatCentered-Halo.png"),
	preload("res://assets/hatCentered-Dino.png"),
	preload("res://assets/hatCentered-IceCream.png"),
	preload("res://assets/hatCentered-Beanie.png"),
	preload("res://assets/hatCentered-Banana.png"),
	preload("res://assets/hatCentered-Batman.png"),
	preload("res://assets/hatCentered-Drinks.png"),
	preload("res://assets/hatCentered-Skull.png"),
	preload("res://assets/hatCentered-Steampunk.png"),
	preload("res://assets/hatCentered-MagicSteampunk.png")]
@export var hatNames: Array[String] = [
	"Chef Hat","Dunce Hat","Nest Hat","Fishbowl Hat","Fishing Rod Hat","Joyful Hat","Eyes Hat","King Crown","Leaf Hat","Plunger Hat",
	"Queen Crown","Sombrero Hat","Top Hat","Traffic Cone Hat","Cowboy Hat","Beard Hat","Christmas Tree Hat","Special Christmas Hat",
	"Sand Bucket Hat","Jack O Lantern","Halo","Dino", "Ice Cream", "Beanie", "Banana", "Bat", "Drink Hat", "Steampunk", "Steampunk rare"
	]
		
@export var numHats = hats.size()
signal coins_changed(new_amount: int)
signal coins_spent(amount: int)
		
func addCoins(amount: int) -> void:
	turtle_coins += amount
	coins_changed.emit(turtle_coins)

func spendCoins(amount: int) -> bool:
	if turtle_coins >= amount:
		turtle_coins -= amount
		coins_spent.emit(amount)
		coins_changed.emit(turtle_coins)
		
		return true
	return false

func spendHatCoins(amount: int) -> bool:
	if hat_coins >= amount:
		hat_coins -= amount
		return true
	return false
	

func addHat(hat_id: int) -> void:
	owned_hats.append(hat_id)
	hats_changed.emit()

func setOwnedHats(list: Array) -> void:
	owned_hats.clear()
	for h in list:
		owned_hats.append(int(h))  # JSON loads numbers as floats
	hats_changed.emit()
	
func removeHat(hat_id: int) -> bool:
	var idx: int = owned_hats.find(hat_id)
	if idx == -1:
		return false
	owned_hats.remove_at(idx)
	hats_changed.emit()
	return true

func spawnNopeLabel(words: String) -> void:
	if has_node("cantBuyLabel"):
		return  # don't stack the same warning
	spawnFloatingLabel(self, words, get_viewport().get_mouse_position(), Color.BLACK, 25, "cantBuyLabel")

## Shared helper for every "+5 coins" / warning style popup text.
## Creates a label at globalPos, floats it up and fades it out, then deletes it.
func spawnFloatingLabel(parent: Node, text: String, globalPos: Vector2,
		color: Color = Color.BLACK, fontSize: int = 25, labelName: String = "",
		outline: bool = false, rise: float = 20.0, riseTime: float = 0.5, fadeTime: float = 0.8) -> Label:
	var label: Label = Label.new()
	if labelName != "":
		label.name = labelName
	label.text = text
	label.top_level = true
	label.z_index = 30
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", fontSize)
	if outline:
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 4)
	parent.add_child(label)
	label.global_position = globalPos

	# The tween belongs to the label, so it keeps going even if the node
	# that spawned it gets deleted.
	var tween: Tween = label.create_tween().set_parallel(true)
	tween.tween_property(label, "global_position:y", label.global_position.y - rise, riseTime)
	tween.tween_property(label, "modulate:a", 0.0, fadeTime)
	tween.chain().tween_callback(label.queue_free)
	return label
