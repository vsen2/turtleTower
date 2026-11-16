extends "res://code/floor.gd"

@onready var officeUI: Control = $OfficeUI

@onready var upgrade1: TextureButton = $OfficeUI/upgrade1
@onready var upgrade2: TextureButton = $OfficeUI/upgrade1
@onready var upgrade3: TextureButton = $OfficeUI/upgrade1
@onready var upgrade4: TextureButton = $OfficeUI/upgrade1
@onready var upgrade5: TextureButton = $OfficeUI/upgrade1

@onready var upgrade1CostLabel: Label = $OfficeUI/upgrade1Cost
@onready var upgrade2CostLabel: Label = $OfficeUI/upgrade2Cost
@onready var upgrade3CostLabel: Label = $OfficeUI/upgrade3Cost
@onready var upgrade4CostLabel: Label = $OfficeUI/upgrade4Cost
@onready var upgrade5CostLabel: Label = $OfficeUI/upgrade5Cost

@onready var upgrade1ValueLabel: Label = $OfficeUI/upgrade1Value
@onready var upgrade2ValueLabel: Label = $OfficeUI/upgrade2Value
@onready var upgrade3ValueLabel: Label = $OfficeUI/upgrade3Value
@onready var upgrade4ValueLabel: Label = $OfficeUI/upgrade4Value
@onready var upgrade5ValueLabel: Label = $OfficeUI/upgrade5Value

var upgrade1Cost = 5
var upgrade2Cost = 5
var upgrade3Cost = 5
var upgrade4Cost = 5
var upgrade5Cost = 100

@export var upgrade1Multiplier: int = 1
@export var upgrade2Multiplier: int = 1
@export var upgrade3Multiplier: float = 1.0
@export var upgrade4Multiplier: float = 1.0
@export var upgrade5Multiplier: int = 0

@export var eelScene: PackedScene = preload("res://scenes/eel.tscn")
@onready var tank: Sprite2D = $tank
## Thickness of the tank's black outline in the tank image's pixels.
## Eels stay inside this border.
@export var tank_wall: float = 45.0
@onready var water: AnimatedSprite2D = $tank/water
@onready var power: ProgressBar = $power
@onready var server: AnimatedSprite2D = $server
@onready var codeCooldownLabel: Label = $codeCDDisplay
@export var codeCooldown: float = 10
@export var amountEarned: int = 0

func _ready() -> void:
	super()
	update_labels()
	water.play("default")
	server.play("default")
	var bounds: Rect2 = get_pen_bounds()
	var pad: float = 24.0
	var min_x: float = bounds.position.x + pad
	var max_x: float = max(min_x, bounds.end.x - pad)
	var min_y: float = bounds.position.y + pad
	var max_y: float = max(min_y, bounds.end.y - pad)
	var spawn_pos := Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y))
	_addEel(spawn_pos)
	_request_save()

func update_labels() -> void:
	upgrade1CostLabel.text = "Cost: $%d" % upgrade1Cost
	upgrade2CostLabel.text = "Cost: $%d" % upgrade2Cost
	upgrade3CostLabel.text = "Cost: $%d" % upgrade3Cost
	upgrade4CostLabel.text = "Cost: $%d" % upgrade4Cost
	upgrade5CostLabel.text = "Cost: $%d" % upgrade5Cost
	upgrade1ValueLabel.text = "current power: %d/10" % upgrade1Multiplier
	upgrade2ValueLabel.text = "current multiplier: %.2fx" % upgrade2Multiplier
	upgrade3ValueLabel.text = "current multiplier: %.2fx" % upgrade3Multiplier
	upgrade4ValueLabel.text = "current multiplier: %dx" % upgrade4Multiplier
	upgrade5ValueLabel.text = "current multiplier: %dx" % upgrade5Multiplier
	power.max_value = 100
	power.value = upgrade1Multiplier*10  
	codeCooldown = 10 / ((upgrade1Multiplier + upgrade3Multiplier)/2)
	amountEarned = 2 * upgrade4Multiplier * (upgrade5Multiplier+1)
	codeCooldownLabel.text = "coding cooldown: %.2fx" % codeCooldown
	

func _on_upgrades_office_pressed() -> void:
	officeUI.visible = not officeUI.visible

func _on_upgrade1_pressed() -> void:
	if GameManager.spend_coins(upgrade1Cost):
		upgrade1Cost = upgrade1Cost * 10
		upgrade1Multiplier += 1
		var bounds: Rect2 = get_pen_bounds()
		var pad: float = 24.0
		var min_x: float = bounds.position.x + pad
		var max_x: float = max(min_x, bounds.end.x - pad)
		var min_y: float = bounds.position.y + pad
		var max_y: float = max(min_y, bounds.end.y - pad)
		var spawn_pos := Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y))
		_addEel(spawn_pos)
		_request_save()
	else:
		GameManager.spawnNopeLabel("Not enough coins! (brokie haha)")
	#change label
	update_labels()
	_request_save()
		
func _on_upgrade2_pressed() -> void:
	if GameManager.spend_coins(upgrade2Cost):
		upgrade2Cost = upgrade2Cost * 2
		upgrade2Multiplier += 1
		update_labels()
		_request_save()
		
func _on_upgrade3_pressed() -> void:
	if GameManager.spend_coins(upgrade3Cost):
		upgrade3Cost = upgrade3Cost * 2
		upgrade3Multiplier += 0.25
		update_labels()
		_request_save()
		
func _on_upgrade4_pressed() -> void:
	if GameManager.spend_coins(upgrade4Cost):
		upgrade4Cost = upgrade4Cost * 2
		upgrade4Multiplier += 0.25
		update_labels()
		_request_save()
		
func _on_upgrade5_pressed() -> void:
	if upgrade5Multiplier >= 6:
		GameManager.spawnNopeLabel("Desk is full of coffee!")
		return
	if GameManager.spend_coins(upgrade5Cost):
		upgrade5Cost = upgrade5Cost * 2
		upgrade5Multiplier += 1  # one more coffee on the desk
		update_labels()
		$officeDesk.refresh()
		_request_save()
	
func _addEel(pos: Vector2) -> Node2D:
	var newEel: Node2D = eelScene.instantiate()
	newEel.bounds = get_pen_bounds()
	newEel.add_to_group(floor_id)
	add_child(newEel)
	newEel.global_position = pos
	return newEel
	
func get_pen_bounds() -> Rect2:
	if not tank or not tank.texture:
		print("get_pen_bounds: pen missing or no texture!")
		return Rect2(Vector2(), Vector2(100, 100))
	var pen_size: Vector2 = tank.texture.get_size() * tank.global_scale
	var top_left: Vector2 = tank.global_position
	if tank.centered:
		top_left -= pen_size / 2.0
	# Shrink by the outline so eels swim inside the glass, not over it
	var wall: Vector2 = Vector2(tank_wall, tank_wall) * tank.global_scale.abs()
	return Rect2(top_left + wall, pen_size - wall * 2.0)
	

	
func get_eels_data() -> Array:
	var eels: Array = []
	for eel in get_tree().get_nodes_in_group(floor_id):
		if eel.get_parent() == self:
			eels.append({
				"x": eel.global_position.x,
				"y": eel.global_position.y,
			})
	return eels

func load_eels_data(eels: Array) -> void:
	# remove any eels that already exist so you don't get duplicates
	for eel in get_tree().get_nodes_in_group(floor_id):
		if eel.get_parent() == self:
			eel.queue_free()
	for e in eels:
		_addEel(Vector2(float(e["x"]), float(e["y"])))
	
func _request_save() -> void:
	var main_node = get_tree().current_scene
	if main_node and main_node.has_method("save_game"):
		main_node.save_game()

func get_upgrades_data() -> Dictionary:
	return {
		"upgrade1Cost": upgrade1Cost,
		"upgrade2Cost": upgrade2Cost,
		"upgrade3Cost": upgrade3Cost,
		"upgrade4Cost": upgrade4Cost,
		"upgrade5Cost": upgrade5Cost,
		"upgrade1Multiplier": upgrade1Multiplier,
		"upgrade2Multiplier": upgrade2Multiplier,
		"upgrade3Multiplier": upgrade3Multiplier,
		"upgrade4Multiplier": upgrade4Multiplier,
		"upgrade5Multiplier": upgrade5Multiplier,
		"eels": get_eels_data(),
	}

func load_upgrades_data(data: Dictionary) -> void:
	if data.has("upgrade1Cost"): upgrade1Cost = int(data["upgrade1Cost"])
	if data.has("upgrade2Cost"): upgrade2Cost = int(data["upgrade2Cost"])
	if data.has("upgrade3Cost"): upgrade3Cost = int(data["upgrade3Cost"])
	if data.has("upgrade4Cost"): upgrade4Cost = int(data["upgrade4Cost"])
	if data.has("upgrade5Cost"): upgrade5Cost = int(data["upgrade5Cost"])
	if data.has("upgrade1Multiplier"): upgrade1Multiplier = float(data["upgrade1Multiplier"])
	if data.has("upgrade2Multiplier"): upgrade2Multiplier = float(data["upgrade2Multiplier"])
	if data.has("upgrade3Multiplier"): upgrade3Multiplier = float(data["upgrade3Multiplier"])
	if data.has("upgrade4Multiplier"): upgrade4Multiplier = float(data["upgrade4Multiplier"])
	if data.has("upgrade5Multiplier"): upgrade5Multiplier = int(data["upgrade5Multiplier"])
	$officeDesk.refresh()
	$officeDesk2.refresh()
	$officeDesk3.refresh()
	$officeDesk4.refresh()
	$officeDesk5.refresh()
	$officeDesk6.refresh()
	if data.has("eels"): load_eels_data(data["eels"])
	update_labels()
