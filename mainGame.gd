extends Node2D

# const SAVE_PATH: String = "res://savegame.json"
const SAVE_PATH: String = "res://savegame.json"

@export var turtle_icon: Texture2D = preload("res://assets/turtleNoBG.png")
@export var turtle_scene: PackedScene = preload("res://turtle.tscn")

@onready var turtle_pen: Sprite2D = $TurtlePen
@onready var camera: Camera2D = $Camera2D
@onready var towerUI: Control = $CanvasLayer/TowerUI
@onready var turtleUI: Control = $CanvasLayer/TurtleUI
@onready var grid: GridContainer = $CanvasLayer/TurtleUI/scrollContainer/turtleGrid
@onready var turtleCoinsLabel: Label = $CanvasLayer/turtleCoins
@onready var turtleCostLabel: Label = $CanvasLayer/TowerUI/addTurtle/turtleCost
@onready var turtleCountLabel: Label = $turtleCount
@onready var penSpaceLabel: Label = $CanvasLayer/TowerUI/addPenSpace/penSpaceLabel
@onready var registers: Array[Node2D] = [
	$STORE/CashRegister1,
	$STORE/CashRegister2,
	$STORE/CashRegister3,
	$STORE/CashRegister4,
]
@onready var register_buttons: Array[Node] = [
	$STORE/addRegister1,
	$STORE/addRegister2,
	$STORE/addRegister3,
	$STORE/addRegister4,
]
@onready var store_upgrades: Control = $STORE/StoreUI # Node holding the store upgrade script

var turtleCost: int = 1
var turtleCount: int = 0
var turtleMax: int = 50
var penSpaceCost: int = 1
var floorLevel: int = 0

func _ready() -> void:
	print("starting main game...")
	load_game()

func _notification(what: int) -> void:
	# Auto-save when the player closes or backgrounds the game window
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()
		
func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.is_pressed() and not turtleUI.visible):
		return

	var screen_height: float = get_viewport_rect().size.y
	var wheel: InputEventMouseButton = event
	if wheel.button_index == MOUSE_BUTTON_WHEEL_UP:
		floorLevel -= 1
		camera.position.y -= screen_height
	elif wheel.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		floorLevel += 1
		camera.position.y += screen_height

	towerUI.visible = floorLevel <= 0

func get_pen_bounds() -> Rect2:
	if not turtle_pen or not turtle_pen.texture:
		return Rect2()

	var pen_size: Vector2 = turtle_pen.texture.get_size() * turtle_pen.global_scale
	var top_left: Vector2 = turtle_pen.global_position
	if turtle_pen.centered:
		top_left -= pen_size / 2.0

	return Rect2(top_left, pen_size)

func _on_addTurtle_pressed() -> void:
	if not turtle_scene:
		return
	if turtleCount >= turtleMax:
		print("Pen is full!")
		return
	if GameManager.spend_coins(turtleCost):
		turtleCost += 1
		turtleCount += 1

		var bounds: Rect2 = get_pen_bounds()
		var pad: float = 24.0
		var min_x: float = bounds.position.x + pad
		var max_x: float = max(min_x, bounds.end.x - pad)
		var min_y: float = bounds.position.y + pad
		var max_y: float = max(min_y, bounds.end.y - pad)
		
		var spawn_pos := Vector2(
			randf_range(min_x, max_x),
			randf_range(min_y, max_y)
		)
		
		_instantiate_turtle(spawn_pos, -1, false, -1)
		save_game()

func _on_addPenSpace_pressed() -> void:
	if GameManager.spend_coins(penSpaceCost):
		penSpaceCost += 1
		turtleMax += 1
		save_game()

func _process(_delta: float) -> void:
	turtleCoinsLabel.text = "Turtle Coins: %d" % GameManager.turtle_coins
	turtleCostLabel.text = "Cost: %d" % turtleCost
	turtleCountLabel.text = "%d/%d" % [turtleCount, turtleMax]
	penSpaceLabel.text = "Cost: %d" % penSpaceCost

func _on_changeTurtles_pressed() -> void:
	turtleUI.visible = not turtleUI.visible
	
func _instantiate_turtle(pos: Vector2, hat_id: int, assigned: bool, reg_idx: int) -> Node2D:
	var new_turtle: Node2D = turtle_scene.instantiate()
	new_turtle.bounds = get_pen_bounds()
	new_turtle.global_position = pos
	
	if hat_id != -1:
		new_turtle.random_hat = hat_id

	add_child(new_turtle)
	add_turtle_icon_to_grid(new_turtle)

	# If restoring to a station
	if assigned and reg_idx >= 0 and reg_idx < registers.size():
		var reg: Node2D = registers[reg_idx]
		if is_instance_valid(reg):
			reg.hasWorker = true
			var target_spot: Vector2 = reg.global_position + Vector2(-200, -60)
			new_turtle.send_to_station(target_spot, reg_idx + 1, reg)

	return new_turtle

func add_turtle_icon_to_grid(turtle: Node2D) -> void:
	# Stack the icon and its status label vertically.
	var item_container: VBoxContainer = VBoxContainer.new()
	item_container.alignment = BoxContainer.ALIGNMENT_CENTER

	var button: TextureButton = TextureButton.new()
	button.texture_normal = turtle_icon
	button.custom_minimum_size = Vector2(96, 96)
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED

	var status_label: Label = Label.new()
	status_label.text = "Idle"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_color_override("font_color", Color.BLACK)

	# Let the turtle update its own label when its job changes.
	turtle.status_label = status_label

	button.pressed.connect(_on_turtle_icon_selected.bind(turtle))

	item_container.add_child(button)
	item_container.add_child(status_label)
	grid.add_child(item_container)

func _on_turtle_icon_selected(turtle: Node2D) -> void:
	if not is_instance_valid(turtle):
		return

	turtleUI.visible = false

	# Send a working turtle back to the pen, otherwise staff a free register.
	if turtle.is_assigned_to_store:
		turtle.return_to_pen(get_pen_bounds())
	else:
		assign_turtle_to_store(turtle)
	save_game()

func assign_turtle_to_store(turtle: Node2D) -> void:
	for i in registers.size():
		var register: Node2D = registers[i]
		if is_instance_valid(register) and not register.hasWorker and register.unlocked:
			var target_spot: Vector2 = register.global_position + Vector2(-200, -60)
			register.hasWorker = true
			turtle.send_to_station(target_spot, i + 1, register)
			return

	print("All registers are full!")
	
func save_game() -> void:
	var turtles_data: Array[Dictionary] = []
	for turtle in get_tree().get_nodes_in_group("turtles"):
		if is_instance_valid(turtle) and turtle.has_method("save_data"):
			turtles_data.append(turtle.save_data())

	var registers_unlocked: Array = []
	for register in registers:
		registers_unlocked.append(bool(register.unlocked))
		
	var _upgrades_data: Dictionary = {}
	if is_instance_valid(store_upgrades) and store_upgrades.has_method("get_save_data"):
		_upgrades_data = store_upgrades.get_save_data()
		
	var data: Dictionary = {
		"turtle_coins": GameManager.turtle_coins,
		"turtleCost": turtleCost,
		"turtleCount": turtleCount,
		"turtleMax": turtleMax,
		"penSpaceCost": penSpaceCost,
		"registers_unlocked": registers_unlocked,
		"turtles": turtles_data,
		"upgrades": _upgrades_data
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return

	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		file.close()
		return
	file.close()

	var data: Dictionary = json.data

	# Restore upgrades and currencies (cast float to int where applicable)
	if data.has("turtle_coins"):
		GameManager.turtle_coins = int(data["turtle_coins"])
	if data.has("turtleCost"):
		turtleCost = int(data["turtleCost"])
	if data.has("turtleMax"):
		turtleMax = int(data["turtleMax"])
	if data.has("penSpaceCost"):
		penSpaceCost = int(data["penSpaceCost"])

	# Restore purchased (unlocked) registers.
	if data.has("registers_unlocked"):
		var unlocked_states: Array = data["registers_unlocked"]
		for i in mini(unlocked_states.size(), registers.size()):
			if bool(unlocked_states[i]):
				_set_register_unlocked(i)
		
	if data.has("upgrades") and is_instance_valid(store_upgrades):
		if store_upgrades.has_method("load_save_data"):
			store_upgrades.load_save_data(data["upgrades"])

	# Rebuild turtles. turtleCount is derived from how many actually load, so it
	# can't drift out of sync with an old save that has no turtle data.
	turtleCount = 0
	if data.has("turtles") and data["turtles"] is Array:
		for t_data in data["turtles"]:
			var pos := Vector2(t_data["pos_x"], t_data["pos_y"])
			var hat: int = int(t_data["random_hat"])
			var assigned: bool = bool(t_data["is_assigned_to_store"])
			var reg_idx: int = int(t_data.get("assigned_register_index", -1))
			_instantiate_turtle(pos, hat, assigned, reg_idx)
			turtleCount += 1

func _set_register_unlocked(index: int) -> void:
	registers[index].unlocked = true
	registers[index].modulate = Color.WHITE
	if is_instance_valid(register_buttons[index]):
		register_buttons[index].visible = false
