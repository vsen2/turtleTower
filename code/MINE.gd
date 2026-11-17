extends "res://code/floor.gd"

@onready var mineUI: Control = $mineUI

@onready var fasterCustomers: TextureButton = $mineUI/fasterCustomers
@onready var feedWorkers: TextureButton = $mineUI/feedWorkers
@onready var gems: TextureButton = $mineUI/gems
@onready var jackpot: TextureButton = $mineUI/jackpot
@onready var extraApples: TextureButton = $mineUI/extraCart

@onready var customerSpeedCostLabel: Label = $mineUI/cartSpeedCost
@onready var feedWorkersCostLabel: Label = $mineUI/feedWorkersCost
@onready var gemsCostLabel: Label = $mineUI/gemsCost
@onready var jackpotCostLabel: Label = $mineUI/jackpotCost
@onready var extraAppleCostLabel: Label = $mineUI/extraCartCost

@onready var customerSpeedValueLabel: Label = $mineUI/cartSpeedValue
@onready var feedWorkersValueLabel: Label = $mineUI/feedWorkersValue
@onready var gemsValueLabel: Label = $mineUI/gemsValue
@onready var jackpotValueLabel: Label = $mineUI/jackpotValue
@onready var extraAppleValueLabel: Label = $mineUI/extraCartValue
	
var cartSpeedCost = 5
var feedWorkersCost = 5
var gemsCost = 5
var jackpotCost = 5
var extraCartCost = 100
	
@export var cartSpeedMultiplier: float = 1.0
@export var feedWorkersMultiplier: float = 1.0
@export var gemsMultiplier: float = 1.0
@export var jackpotMultiplier: int = 1
@export var extraCartMultiplier: int = 1
	
func _ready() -> void:
	super()
	updateLabels()

func updateLabels() -> void:
	customerSpeedCostLabel.text = "Cost: $%d" % cartSpeedCost
	customerSpeedValueLabel.text = "current multiplier: %.2fx" % cartSpeedMultiplier
	feedWorkersCostLabel.text = "Cost: $%d" % feedWorkersCost
	feedWorkersValueLabel.text = "current multiplier: %.2fx" % feedWorkersMultiplier
	gemsCostLabel.text = "Cost: $%d" % gemsCost
	gemsValueLabel.text = "current multiplier: %.2fx" % gemsMultiplier
	jackpotCostLabel.text = "Cost: $%d" % jackpotCost
	jackpotValueLabel.text = "chance of jackpot: %d%%" % jackpotMultiplier
	extraAppleCostLabel.text = "Cost: $%d" % extraCartCost
	extraAppleValueLabel.text = "current multiplier: %dx" % extraCartMultiplier

func onUpgradesMinePressed() -> void:
	mineUI.visible = not mineUI.visible

func onFasterCustomersPressed() -> void:
	if GameManager.spendCoins(cartSpeedCost):
		cartSpeedCost = cartSpeedCost * 2
		cartSpeedMultiplier += 0.25
		updateLabels()
		requestSave()

func onFeedWorkersPressed() -> void:
	if GameManager.spendCoins(feedWorkersCost):
		feedWorkersCost = feedWorkersCost * 2
		feedWorkersMultiplier += 0.25
		updateLabels()
		requestSave() 
		
func onGemsPressed() -> void:
	if GameManager.spendCoins(gemsCost):
		gemsCost = gemsCost * 2
		gemsMultiplier += 0.25
		updateLabels()
		requestSave()

func onJackpotPressed() -> void:
	if GameManager.spendCoins(jackpotCost):
		jackpotCost = jackpotCost * 2
		jackpotMultiplier += 1
		updateLabels()
		requestSave()

func onExtraCartPressed() -> void:
	if GameManager.spendCoins(extraCartCost):
		extraCartCost = extraCartCost * 10
		extraCartMultiplier += 1
		updateLabels()
		requestSave()

func getUpgradesData() -> Dictionary:
	return {
		"cartSpeedCost": cartSpeedCost,
		"feedWorkersCost": feedWorkersCost,
		"gemsCost": gemsCost,
		"jackpotCost": jackpotCost,
		"extraCartCost": extraCartCost,
		"cartSpeedMultiplier": cartSpeedMultiplier,
		"feedWorkersMultiplier": feedWorkersMultiplier,
		"gemsMultiplier": gemsMultiplier,
		"jackpotMultiplier": jackpotMultiplier,
		"extraCartMultiplier": extraCartMultiplier
	}

func loadUpgradesData(data: Dictionary) -> void:
	if data.has("cartSpeedCost"): cartSpeedCost = int(data["cartSpeedCost"])
	if data.has("feedWorkersCost"): feedWorkersCost = int(data["feedWorkersCost"])
	if data.has("gemsCost"): gemsCost = int(data["gemsCost"])
	if data.has("jackpotCost"): jackpotCost = int(data["jackpotCost"])
	if data.has("extraCartCost"): extraCartCost = int(data["extraCartCost"])
	if data.has("cartSpeedMultiplier"): cartSpeedMultiplier = float(data["cartSpeedMultiplier"])
	if data.has("feedWorkersMultiplier"): feedWorkersMultiplier = float(data["feedWorkersMultiplier"])
	if data.has("gemsMultiplier"): gemsMultiplier = float(data["gemsMultiplier"])
	if data.has("jackpotMultiplier"): jackpotMultiplier = float(data["jackpotMultiplier"])
	if data.has("extraCartMultiplier"): extraCartMultiplier = int(data["extraCartMultiplier"])
	updateLabels()
