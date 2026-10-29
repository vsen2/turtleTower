extends Control

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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_labels()
	
func update_labels() -> void:
	customerSpeedCostLabel.text = "Cost: $%d" % cartSpeedMultiplier
	customerSpeedValueLabel.text = "current multiplier: %.2fx" % cartSpeedMultiplier
	
	feedWorkersCostLabel.text = "Cost: $%d" % feedWorkersCost
	feedWorkersValueLabel.text = "current multiplier: %.2fx" % 1
	
	betterFruitCostLabel.text = "Cost: $%d" % moreOreCost
	betterFruitValueLabel.text = "current multiplier: %.2fx" % moreOreMultiplier
	
	timerCostLabel.text = "Cost: $%d" % gemCost
	timerValueLabel.text = "current multiplier: %.2fx" % gemMultiplier
	
	extraAppleCostLabel.text = "Cost: $%d" % extraCartCost
	extraAppleValueLabel.text = "current multiplier: %dx" % extraCartMultiplier

# Called every frame. 'delta' is the elapsed time since the previous frame.    s
func _process(delta: float) -> void:
	pass
		
func _on_upgrades_mine_pressed() -> void:
	mineUI.visible = not mineUI.visible

func _on_faster_customers_pressed() -> void:
	if GameManager.spend_coins(cartSpeedCost):
		cartSpeedCost = cartSpeedCost*2
		cartSpeedMultiplier += 0.25
		GameManager.cartSpeedMultiplier = cartSpeedMultiplier
		update_labels()
		_request_save()
		
func _on_feed_workers_pressed() -> void:
	if GameManager.spend_coins(feedWorkersCost):
		feedWorkersCost = feedWorkersCost*2
		feedWorkersMultiplier += 0.25
		update_labels()
		_request_save()

func _on_better_apples_pressed() -> void:
	if GameManager.spend_coins(moreOreCost):
		moreOreCost = moreOreCost*2
		moreOreMultiplier += 0.25
		update_labels()
		_request_save()

func _on_timer_pressed() -> void:
	if GameManager.spend_coins(gemCost):
		gemCost = gemCost*2
		gemMultiplier += 0.25
		update_labels()
		_request_save()
		
func _on_extra_apples_pressed() -> void:
	if GameManager.spend_coins(extraCartCost):
		extraCartCost = extraCartCost*10
		extraCartMultiplier += 1
		update_labels()
		_request_save()

	
func _request_save() -> void:
	# Calls save_game() on main if present
	var main_node = get_tree().current_scene
	if main_node and main_node.has_method("save_game"):
		main_node.save_game()
		print("saving")

# --- Save & Load helpers ---
