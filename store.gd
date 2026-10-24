extends Control

@onready var storeUI: Control = $StoreUI
@onready var fasterCustomers: TextureButton = $StoreUI/fasterCustomers
@onready var feedWorkers: TextureButton = $StoreUI/feedWorkers
@onready var betterApples: TextureButton = $StoreUI/betterApples
@onready var timer: TextureButton = $StoreUI/timer
@onready var customerSpeedCostLabel: Label = $StoreUI/customerSpeedCost
@onready var feedWorkersCostLabel: Label = $StoreUI/feedWorkersCost
@onready var betterFruitCostLabel: Label = $StoreUI/betterFruitCost
@onready var timerCostLabel: Label = $StoreUI/timerCost
@onready var customerSpeedValueLabel: Label = $StoreUI/customerSpeedValue
@onready var feedWorkersValueLabel: Label = $StoreUI/feedWorkersValue
@onready var betterFruitValueLabel: Label = $StoreUI/betterFruitValue
@onready var timerValueLabel: Label = $StoreUI/timerValue

var customerSpeedCost = 5
var feedWorkersCost = 5
var betterFruitCost = 5
var timerCost = 5

var customerSpeedMultiplier = 1.0
var feedWorkersMultiplier = 1.0
var betterFruitMultiplier = 1.0
var timerMultiplier = 1.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	customerSpeedCostLabel.text = "Cost: $%d" % customerSpeedCost
	customerSpeedValueLabel.text = "current multiplier: %dx" % customerSpeedMultiplier
	
	feedWorkersCostLabel.text = "Cost: $%d" % feedWorkersCost
	feedWorkersValueLabel.text = "current multiplier: %dx" % feedWorkersMultiplier
	
	betterFruitCostLabel.text = "Cost: $%d" % betterFruitCost
	betterFruitValueLabel.text = "current multiplier: %dx" % betterFruitMultiplier
	
	timerCostLabel.text = "Cost: $%d" % timerCost
	timerValueLabel.text = "current multiplier: %dx" % timerMultiplier

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_upgrades_store_pressed() -> void:
	storeUI.visible = not storeUI.visible

func _on_faster_customers_pressed() -> void:
	if GameManager.spend_coins(customerSpeedCost):
		print("yes")
		customerSpeedCost = customerSpeedCost*customerSpeedCost
		customerSpeedMultiplier += 0.25
		customerSpeedCostLabel.text = "Cost: $%d" % customerSpeedCost
		customerSpeedValueLabel.text = "current multiplier: %dx" % customerSpeedMultiplier
		
func _on_feed_workers_pressed() -> void:
	if GameManager.spend_coins(feedWorkersCost):
		feedWorkersCost = feedWorkersCost*feedWorkersCost
		feedWorkersMultiplier += 0.25
		feedWorkersCostLabel.text = "Cost: $%d" % feedWorkersCost
		feedWorkersValueLabel.text = "current multiplier: %dx" % feedWorkersMultiplier

func _on_better_apples_pressed() -> void:
	if GameManager.spend_coins(betterFruitCost):
		betterFruitCost = betterFruitCost*betterFruitCost
		betterFruitMultiplier += 0.25
		betterFruitCostLabel.text = "Cost: $%d" % betterFruitCost
		betterFruitValueLabel.text = "current multiplier: %dx" % betterFruitMultiplier

func _on_timer_pressed() -> void:
	if GameManager.spend_coins(timerCost):
		timerCost = timerCost*timerCost
		timerMultiplier += 0.25
		timerCostLabel.text = "Cost: $%d" % timerCost
		timerValueLabel.text = "current multiplier: %dx" % timerMultiplier
	
