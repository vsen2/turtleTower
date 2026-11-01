extends Control

var hatCoinCost: int = 100

@onready var shopUI: Control = %ShopUI
@onready var hatCoin: Label = $Item1/hatCoin
@onready var hatCost: Label = $Item1/cost

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hatCoin.text = "Hat Coins: %d" % GameManager.hat_coins
	hatCost.text = "COST: %d" % hatCoinCost


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_x_button_pressed() -> void:
	shopUI.visible = false
	
func _on_buy_pressed() -> void:
	if GameManager.spend_coins(hatCoinCost):
		GameManager.hat_coins += 1
		print(GameManager.hat_coins)
		hatCoin.text = "Hat Coins: %d" % GameManager.hat_coins
		hatCost.text = "COST: %d" % hatCoinCost
		
