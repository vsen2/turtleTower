extends "res://code/floor.gd"

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
	updateLabels()

func updateLabels() -> void:
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

func onUpgradesStorePressed() -> void:
	storeUI.visible = not storeUI.visible

func onFasterCustomersPressed() -> void:
	if GameManager.spendCoins(customerSpeedCost):
		customerSpeedCost = customerSpeedCost * 2
		customerSpeedMultiplier += 0.25
		updateLabels()
		requestSave()

func onFeedWorkersPressed() -> void:
	if GameManager.spendCoins(feedWorkersCost):
		feedWorkersCost = feedWorkersCost * 2
		feedWorkersMultiplier += 0.25
		updateLabels()
		requestSave()

func onBetterApplesPressed() -> void:
	if GameManager.spendCoins(betterFruitCost):
		betterFruitCost = betterFruitCost * 2
		betterFruitMultiplier += 0.25
		updateLabels()
		requestSave()

func onTimerPressed() -> void:
	if GameManager.spendCoins(timerCost):
		timerCost = timerCost * 2
		timerMultiplier += 0.25
		updateLabels()
		requestSave()

func onExtraApplesPressed() -> void:
	if GameManager.spendCoins(extraAppleCost):
		extraAppleCost = extraAppleCost * 10
		appleMultiplier += 1
		updateLabels()
		requestSave()

func getUpgradesData() -> Dictionary:
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

func loadUpgradesData(data: Dictionary) -> void:
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
	updateLabels()
