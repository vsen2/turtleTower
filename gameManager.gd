extends Node

var turtle_coins: int = 1000
var customer_speed_multiplier: float = 1.0
var spawn_timer_multiplier: float = 1.0

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
