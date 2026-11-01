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
@onready var hat_scroll: Control = %hatGrid.get_parent()
@onready var grid: GridContainer = %hatGrid

var hats = GameManager.hats
var hatsCentered = GameManager.hatsCentered
var numHats = GameManager.numHats
var hatNames = GameManager.hatNames

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
	elif not has_node("NotEnoughCoinsLabel"):

		spawn_notEnoughCoins_label()
func _on_spinner_button_up() -> void:
	isHolding = false
		
func _on_hat_machine_prize_ball_pressed() -> void:
	prizeBall.visible = false
	prize = false
	if prizeNo >= 0:
		GameManager.add_hat(prizeNo)
	
func add_hat_icon_to_grid(hat_id: int) -> void:
	var item_container: VBoxContainer = VBoxContainer.new()
	item_container.alignment = BoxContainer.ALIGNMENT_CENTER

	var button: TextureButton = TextureButton.new()
	button.texture_normal = hatsCentered[hat_id]
	button.custom_minimum_size = Vector2(80, 80)
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED

	var status_label: Label = Label.new()
	status_label.text = _get_hat_name(hat_id)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_color_override("font_color", Color.BLACK)
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	var cell_w: float = _get_cell_width()
	button.custom_minimum_size = Vector2(cell_w * 0.75, cell_w * 0.75)
	status_label.custom_minimum_size = Vector2(cell_w, 0)
	item_container.custom_minimum_size = Vector2(cell_w, 0)
	
	item_container.add_child(button)
	item_container.add_child(status_label)
	grid.add_child(item_container)
	
func _get_cell_width() -> float:
	var sep: int = grid.get_theme_constant("h_separation")
	var available: float = hat_scroll.size.x - 20  # leave room for the vertical scrollbar
	return floor((available - sep * (grid.columns - 1)) / grid.columns)
	
func spawn_notEnoughCoins_label() -> void:
	print("happening")
	var label: Label = Label.new()
	label.name = "NotEnoughCoinsLabel"
	label.text = "Not Enough Hat Coins"
	label.top_level = true
	label.global_position = Vector2(450, -450)
	label.z_index = 30
	label.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0, 1.0)) # color
	label.add_theme_font_size_override("font_size", 25)

	add_child(label)
	# Float upward and fade out, then delete itself.
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(label, "global_position:y", label.global_position.y - 20.0, .5)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.chain().tween_callback(label.queue_free)

func _get_hat_name(hat_id: int) -> String:
	if hat_id < GameManager.hatNames.size():
		return GameManager.hatNames[hat_id]
	# Fallback: use the texture's file name, e.g. "res://hats/top_hat.png" -> "Top Hat"
	var tex: Texture2D = hatsCentered[hat_id]
	return tex.resource_path.get_file().get_basename().capitalize()

func _rebuild_hat_grid() -> void:
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
	for hat_id in GameManager.owned_hats:
		if hat_id >= 0 and hat_id < hatsCentered.size():
			add_hat_icon_to_grid(hat_id)

	
