extends Control

@onready var spinner: TextureButton = $spinner
@onready var prizeBall: TextureButton = $HatMachinePrizeBall
@onready var hatCoinLabel: Label = $TheHatMachineCoins
var pressedAmount = 0
var isHolding: bool = false
var prize: bool = false
var prizeNo: int = -1
@export var hatCost = 1


@onready var balls: Array[Sprite2D] = [
	$HatMachineBall,
	$HatMachineBall2,
	$HatMachineBall3,
	$HatMachineBall4,
	$HatMachineBall5,
	$HatMachineBall6,
	$HatMachineBall7
]
@onready var grid: GridContainer = %hatGrid

var hats = GameManager.hats
var hatsCentered = GameManager.hatsCentered
var numHats = GameManager.numHats

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for ball in balls:
		ball.rotation_degrees = randi_range(1, 360)
	spinner.rotation_degrees = 0
	GameManager.hats_changed.connect(_rebuild_hat_grid)
	_rebuild_hat_grid()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	hatCoinLabel.text = "Hat Coins: %d" % GameManager.hat_coins
	if isHolding and not prize:
		spinner.rotation_degrees += 1
		for ball in balls:
			ball.rotation_degrees +=1
		if spinner.rotation_degrees > 355 and GameManager.spend_hat_coins(hatCost):
			spinner.rotation_degrees = 0
			prizeBall.visible = true
			prizeNo = randi_range(0, numHats - 1)
			$HatMachinePrizeBall/HatPrize.texture = hatsCentered[prizeNo]			
			prize = true
		
func _on_spinner_button_down() -> void:
	if GameManager.hat_coins > 0:
		isHolding = true
func _on_spinner_button_up() -> void:
	isHolding = false
		
func _on_hat_machine_prize_ball_pressed() -> void:
	prizeBall.visible = false
	prize = false
	if prizeNo >= 0:
		GameManager.add_hat(prizeNo)
	
func add_hat_icon_to_grid(hatTexture) -> void:
	var item_container: VBoxContainer = VBoxContainer.new()
	item_container.alignment = BoxContainer.ALIGNMENT_CENTER

	var button: TextureButton = TextureButton.new()
	button.texture_normal = hatTexture
	button.custom_minimum_size = Vector2(96, 96)
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED

	var status_label: Label = Label.new()
	status_label.text = "hat"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_color_override("font_color", Color.BLACK)

	item_container.add_child(button)
	item_container.add_child(status_label)
	grid.add_child(item_container)
	
func _rebuild_hat_grid() -> void:
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
	for hat_id in GameManager.owned_hats:
		if hat_id >= 0 and hat_id < hatsCentered.size():
			add_hat_icon_to_grid(hatsCentered[hat_id])
	
