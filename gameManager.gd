extends Node

var turtle_coins: int = 1000

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
