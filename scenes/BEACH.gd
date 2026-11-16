extends "res://code/floor.gd"

@onready var officeUI: Control = $BeachUI

@onready var upgrade1: TextureButton = $BeachUI/upgrade1
@onready var upgrade2: TextureButton = $BeachUI/upgrade1
@onready var upgrade3: TextureButton = $BeachUI/upgrade1
@onready var upgrade4: TextureButton = $BeachUI/upgrade1
@onready var upgrade5: TextureButton = $BeachUI/upgrade1

@onready var upgrade1CostLabel: Label = $BeachUI/upgrade1Cost
@onready var upgrade2CostLabel: Label = $BeachUI/upgrade2Cost
@onready var upgrade3CostLabel: Label = $BeachUI/upgrade3Cost
@onready var upgrade4CostLabel: Label = $BeachUI/upgrade4Cost
@onready var upgrade5CostLabel: Label = $BeachUI/upgrade5Cost

@onready var upgrade1ValueLabel: Label = $BeachUI/upgrade1Value
@onready var upgrade2ValueLabel: Label = $BeachUI/upgrade2Value
@onready var upgrade3ValueLabel: Label = $BeachUI/upgrade3Value
@onready var upgrade4ValueLabel: Label = $BeachUI/upgrade4Value
@onready var upgrade5ValueLabel: Label = $BeachUI/upgrade5Value

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

@export var codeCooldown: float = 10
@export var amountEarned: int = 0

func _ready() -> void:
	super()
	update_labels()


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
	codeCooldown = 10 / ((upgrade1Multiplier + upgrade3Multiplier)/2)
	amountEarned = 2 * upgrade4Multiplier * (upgrade5Multiplier+1)
	

func _on_upgrades_office_pressed() -> void:
	officeUI.visible = not officeUI.visible

func _on_upgrade1_pressed() -> void:
	if GameManager.spend_coins(upgrade1Cost):
		upgrade1Cost = upgrade1Cost * 10
		upgrade1Multiplier += 1
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
		upgrade5Multiplier += 1 
		update_labels()
		_request_save()
	
	
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
	update_labels()
