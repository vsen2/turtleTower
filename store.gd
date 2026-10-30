extends "res://floor.gd"

@onready var storeUI: Control = $StoreUI

@onready var fasterCustomers: TextureButton = $StoreUI/fasterCustomers
@onready var feedWorkers: TextureButton = $StoreUI/feedWorkers
@onready var betterApples: TextureButton = $StoreUI/betterApples
@onready var timer: TextureButton = $StoreUI/timer
@onready var extraApples: TextureButton = $StoreUI/extraApples

@onready var customerSpeedCostLabel: Label = $StoreUI/customerSpeedCost
@onready var feedWorkersCostLabel: Label = $StoreUI/feedWorkersCost
@onready var betterFruitCostLabel: Label = $StoreUI/betterFruitCost
@onready var timerCostLabel: Label = $StoreUI/timerCost
@onready var extraAppleCostLabel: Label = $StoreUI/extraAppleCost

@onready var customerSpeedValueLabel: Label = $StoreUI/customerSpeedValue
@onready var feedWorkersValueLabel: Label = $StoreUI/feedWorkersValue
@onready var betterFruitValueLabel: Label = $StoreUI/betterFruitValue
@onready var timerValueLabel: Label = $StoreUI/timerValue
@onready var extraAppleValueLabel: Label = $StoreUI/extraAppleValue

var customerSpeedCost = 5
var feedWorkersCost = 5
var betterFruitCost = 5
var timerCost = 5
var extraAppleCost = 100

@export var customerSpeedMultiplier = 1.0
@export var feedWorkersMultiplier = 1.0
@export var betterFruitMultiplier = 1.0
@export var timerMultiplier = 1.0
@export var appleMultiplier = 1

func _ready() -> void:
	super()
	update_labels()

func update_labels() -> void:
	customerSpeedCostLabel.text = "Cost: $%d" % customerSpeedCost
	customerSpeedValueLabel.text = "current multiplier: %.2fx" % customerSpeedMultiplier
	feedWorkersCostLabel.text = "Cost: $%d" % feedWorkersCost
	feedWorkersValueLabel.text = "current multiplier: %.2fx" % feedWorkersMultiplier
	betterFruitCostLabel.text = "Cost: $%d" % betterFruitCost
	betterFruitValueLabel.text = "current multiplier: %.2fx" % betterFruitMultiplier
	timerCostLabel.text = "Cost: $%d" % timerCost
	timerValueLabel.text = "current multiplier: %.2fx" % timerMultiplier
	extraAppleCostLabel.text = "Cost: $%d" % extraAppleCost
	extraAppleValueLabel.text = "current multiplier: %dx" % appleMultiplier

func _on_upgrades_store_pressed() -> void:
	storeUI.visible = not storeUI.visible

func _on_faster_customers_pressed() -> void:
	if GameManager.spend_coins(customerSpeedCost):
		customerSpeedCost = customerSpeedCost * 2
		customerSpeedMultiplier += 0.25
		GameManager.customer_speed_multiplier = customerSpeedMultiplier
		update_labels()
		_request_save()

func _on_feed_workers_pressed() -> void:
	if GameManager.spend_coins(feedWorkersCost):
		feedWorkersCost = feedWorkersCost * 2
		feedWorkersMultiplier += 0.25
		update_labels()
		_request_save()

func _on_better_apples_pressed() -> void:
	if GameManager.spend_coins(betterFruitCost):
		betterFruitCost = betterFruitCost * 2
		betterFruitMultiplier += 0.25
		update_labels()
		_request_save()

func _on_timer_pressed() -> void:
	if GameManager.spend_coins(timerCost):
		timerCost = timerCost * 2
		timerMultiplier += 0.25
		update_labels()
		_request_save()

func _on_extra_apples_pressed() -> void:
	if GameManager.spend_coins(extraAppleCost):
		extraAppleCost = extraAppleCost * 10
		appleMultiplier += 1
		update_labels()
		_request_save()

func _request_save() -> void:
	var main_node = get_tree().current_scene
	if main_node and main_node.has_method("save_game"):
		main_node.save_game()

func get_upgrades_data() -> Dictionary:
	return {
		"customerSpeedCost": customerSpeedCost,
		"feedWorkersCost": feedWorkersCost,
		"betterFruitCost": betterFruitCost,
		"timerCost": timerCost,
		"extraAppleCost": extraAppleCost,
		"customerSpeedMultiplier": customerSpeedMultiplier,
		"feedWorkersMultiplier": feedWorkersMultiplier,
		"betterFruitMultiplier": betterFruitMultiplier,
		"timerMultiplier": timerMultiplier,
		"appleMultiplier": appleMultiplier
	}

func load_upgrades_data(data: Dictionary) -> void:
	if data.has("customerSpeedCost"): customerSpeedCost = int(data["customerSpeedCost"])
	if data.has("feedWorkersCost"): feedWorkersCost = int(data["feedWorkersCost"])
	if data.has("betterFruitCost"): betterFruitCost = int(data["betterFruitCost"])
	if data.has("timerCost"): timerCost = int(data["timerCost"])
	if data.has("extraAppleCost"): extraAppleCost = int(data["extraAppleCost"])
	if data.has("customerSpeedMultiplier"): customerSpeedMultiplier = float(data["customerSpeedMultiplier"])
	if data.has("feedWorkersMultiplier"): feedWorkersMultiplier = float(data["feedWorkersMultiplier"])
	if data.has("betterFruitMultiplier"): betterFruitMultiplier = float(data["betterFruitMultiplier"])
	if data.has("timerMultiplier"): timerMultiplier = float(data["timerMultiplier"])
	if data.has("appleMultiplier"): appleMultiplier = int(data["appleMultiplier"])
	update_labels()
