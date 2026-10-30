extends "res://floor.gd"

@onready var mineUI: Control = $mineUI

@onready var fasterCustomers: TextureButton = $mineUI/fasterCustomers
@onready var feedWorkers: TextureButton = $mineUI/feedWorkers
@onready var betterApples: TextureButton = $mineUI/betterApples
@onready var timer: TextureButton = $mineUI/timer
@onready var extraApples: TextureButton = $mineUI/extraApples

@onready var customerSpeedCostLabel: Label = $mineUI/cartSpeedCost
@onready var feedWorkersCostLabel: Label = $mineUI/feedWorkersCost
@onready var betterFruitCostLabel: Label = $mineUI/betterFruitCost
@onready var timerCostLabel: Label = $mineUI/timerCost
@onready var extraAppleCostLabel: Label = $mineUI/extraAppleCost

@onready var customerSpeedValueLabel: Label = $mineUI/cartSpeedValue
@onready var feedWorkersValueLabel: Label = $mineUI/feedWorkersValue
@onready var betterFruitValueLabel: Label = $mineUI/betterFruitValue
@onready var timerValueLabel: Label = $mineUI/timerValue
@onready var extraAppleValueLabel: Label = $mineUI/extraAppleValue

var cartSpeedCost = 5
var feedWorkersCost = 5
var moreOreCost = 5
var gemCost = 5
var extraCartCost = 100

@export var cartSpeedMultiplier = 1.0
@export var feedWorkersMultiplier = 1.0
@export var moreOreMultiplier = 1.0
@export var gemMultiplier = 1.0
@export var extraCartMultiplier = 1

func _ready() -> void:
	super()
	update_labels()

func update_labels() -> void:
	customerSpeedCostLabel.text = "Cost: $%d" % cartSpeedCost
	customerSpeedValueLabel.text = "current multiplier: %.2fx" % cartSpeedMultiplier
	feedWorkersCostLabel.text = "Cost: $%d" % feedWorkersCost
	feedWorkersValueLabel.text = "current multiplier: %.2fx" % feedWorkersMultiplier
	betterFruitCostLabel.text = "Cost: $%d" % moreOreCost
	betterFruitValueLabel.text = "current multiplier: %.2fx" % moreOreMultiplier
	timerCostLabel.text = "Cost: $%d" % gemCost
	timerValueLabel.text = "current multiplier: %.2fx" % gemMultiplier
	extraAppleCostLabel.text = "Cost: $%d" % extraCartCost
	extraAppleValueLabel.text = "current multiplier: %dx" % extraCartMultiplier

func _on_upgrades_mine_pressed() -> void:
	mineUI.visible = not mineUI.visible

func _on_faster_customers_pressed() -> void:
	if GameManager.spend_coins(cartSpeedCost):
		cartSpeedCost = cartSpeedCost * 2
		cartSpeedMultiplier += 0.25
		update_labels()
		_request_save()

func _on_feed_workers_pressed() -> void:
	if GameManager.spend_coins(feedWorkersCost):
		feedWorkersCost = feedWorkersCost * 2
		feedWorkersMultiplier += 0.25
		update_labels()
		_request_save()

func _on_better_apples_pressed() -> void:
	if GameManager.spend_coins(moreOreCost):
		moreOreCost = moreOreCost * 2
		moreOreMultiplier += 0.25
		update_labels()
		_request_save()

func _on_timer_pressed() -> void:
	if GameManager.spend_coins(gemCost):
		gemCost = gemCost * 2
		gemMultiplier += 0.25
		update_labels()
		_request_save()

func _on_extra_apples_pressed() -> void:
	if GameManager.spend_coins(extraCartCost):
		extraCartCost = extraCartCost * 10
		extraCartMultiplier += 1
		update_labels()
		_request_save()

func _request_save() -> void:
	var main_node = get_tree().current_scene
	if main_node and main_node.has_method("save_game"):
		main_node.save_game()

func get_upgrades_data() -> Dictionary:
	return {
		"cartSpeedCost": cartSpeedCost,
		"feedWorkersCost": feedWorkersCost,
		"moreOreCost": moreOreCost,
		"gemCost": gemCost,
		"extraCartCost": extraCartCost,
		"cartSpeedMultiplier": cartSpeedMultiplier,
		"feedWorkersMultiplier": feedWorkersMultiplier,
		"moreOreMultiplier": moreOreMultiplier,
		"gemMultiplier": gemMultiplier,
		"extraCartMultiplier": extraCartMultiplier
	}

func load_upgrades_data(data: Dictionary) -> void:
	if data.has("cartSpeedCost"): cartSpeedCost = int(data["cartSpeedCost"])
	if data.has("feedWorkersCost"): feedWorkersCost = int(data["feedWorkersCost"])
	if data.has("moreOreCost"): moreOreCost = int(data["moreOreCost"])
	if data.has("gemCost"): gemCost = int(data["gemCost"])
	if data.has("extraCartCost"): extraCartCost = int(data["extraCartCost"])
	if data.has("cartSpeedMultiplier"): cartSpeedMultiplier = float(data["cartSpeedMultiplier"])
	if data.has("feedWorkersMultiplier"): feedWorkersMultiplier = float(data["feedWorkersMultiplier"])
	if data.has("moreOreMultiplier"): moreOreMultiplier = float(data["moreOreMultiplier"])
	if data.has("gemMultiplier"): gemMultiplier = float(data["gemMultiplier"])
	if data.has("extraCartMultiplier"): extraCartMultiplier = int(data["extraCartMultiplier"])
	update_labels()
