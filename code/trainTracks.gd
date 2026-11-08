extends "res://code/workstation.gd"

@export var cart: PackedScene = preload("res://scenes/cart.tscn")

@onready var pickaxe: AnimatedSprite2D = $pickaxe
@onready var rock: AnimatedSprite2D = $rock

var hasCart: bool = false

func _ready() -> void:
	startingStuff()
	add_to_group("job_spots")
	z_index = 10
	
	var cartSpeedMultiplier = get_parent().cartSpeedMultiplier
	var gemsMultiplier = get_parent().gemsMultiplier
	var jacpotMultiplier = get_parent().jackpotMultiplier
	var extraCartMultiplier = get_parent().extraCartMultiplier

func _process(_delta: float) -> void:
	pickaxe.speed_scale = get_parent().feedWorkersMultiplier
	pickaxe.speed_scale = get_parent().feedWorkersMultiplier
	if hasWorker:
		pickaxe.visible = true
		pickaxe.play("DEFAULT")
		rock.play("mining")
	else:
		pickaxe.pause()
		pickaxe.visible = false
		rock.pause()
	if not hasWorker:
		return
	if hasCart:
		return
	spawn_new_cart()
			
func spawn_new_cart() -> void:
	if not cart:
		return
	var newCart: Node2D = cart.instantiate()
	var spawn_x: float = get_viewport_rect().size.x
	var spawn_y: float = global_position.y + 15
	newCart.speedMultiplier = get_parent().cartSpeedMultiplier
	newCart.gemMultiplier = get_parent().gemsMultiplier
	newCart.cartMultiplier = get_parent().extraCartMultiplier
	newCart.z_index = 20
	newCart.top_level = true
	newCart.scale = Vector2(0.4, 0.4)
	newCart.global_position = Vector2(spawn_x, spawn_y)
	add_child(newCart)
