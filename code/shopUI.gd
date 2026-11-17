extends CanvasLayer

var hatCoinCost: int = 100

@onready var shopUI: Control = $ShopUI
@onready var turtleUI: Control = $TurtleUI
@onready var hatCoin: Label = $ShopUI/Item1/hatCoin
@onready var hatCost: Label = $ShopUI/Item1/cost

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hatCoin.text = "Hat Coins: %d" % GameManager.hat_coins
	hatCost.text = "COST: %d" % hatCoinCost


func onXButtonPressed() -> void:
	shopUI.visible = false
	turtleUI.visible = false
	
func onBuyPressed() -> void:
	if GameManager.spendCoins(hatCoinCost):
		GameManager.hat_coins += 1
		print(GameManager.hat_coins)
		hatCoin.text = "Hat Coins: %d" % GameManager.hat_coins
		hatCost.text = "COST: %d" % hatCoinCost
		
