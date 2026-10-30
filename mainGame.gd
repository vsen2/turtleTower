extends Node2D

# Saved under user:// so it also works in an exported build (res:// is read-only).
const SAVE_PATH: String = "user://savegame.json"

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

var turtleCost: int = 1
var turtleCount: int = 0
var turtleMax: int = 50
var penSpaceCost: int = 1
var floorLevel: int = 0

# Set when a spot's plus button is pressed; the next turtle picked is sent there.
var pending_spot: Node = null
var floor_chooser: PopupMenu = null

func _ready() -> void:
	print("starting main game...")
	load_game()

func _notification(what: int) -> void:
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

# --------------------------------------------------------------- floors

func get_floors() -> Array[Node]:
	var out: Array[Node] = []
	for f in get_tree().get_nodes_in_group("floors"):
		out.append(f)
	return out

func get_floor_by_id(id: String) -> Node:
	for f in get_floors():
		if String(f.floor_id) == id:
			return f
	return null

func get_floor_of(node: Node) -> Node:
	var n: Node = node
	while n != null:
		if n.is_in_group("floors"):
			return n
		n = n.get_parent()
	return null

func get_spot_index(spot: Node) -> int:
	var floor_node: Node = get_floor_of(spot)
	if floor_node == null:
		return -1
	return floor_node.get_spots().find(spot)

# --------------------------------------------------------------- turtles

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
		var spawn_pos := Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y))
		_instantiate_turtle(spawn_pos, -1, "", -1)
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

func _instantiate_turtle(pos: Vector2, hat_id: int, assigned_floor: String, assigned_spot: int) -> Node2D:
	var new_turtle: Node2D = turtle_scene.instantiate()
	new_turtle.bounds = get_pen_bounds()
	new_turtle.global_position = pos
	if hat_id != -1:
		new_turtle.random_hat = hat_id
	add_child(new_turtle)
	add_turtle_icon_to_grid(new_turtle)

	if assigned_floor != "" and assigned_spot >= 0:
		var floor_node: Node = get_floor_by_id(assigned_floor)
		if floor_node != null:
			var spots: Array = floor_node.get_spots()
			if assigned_spot < spots.size():
				var spot: Node = spots[assigned_spot]
				var target: Vector2 = spot.global_position + Vector2(-200, -60)
				new_turtle.send_to_station(target, assigned_floor, assigned_spot, spot)
				spot.hasWorker = true
	return new_turtle

func add_turtle_icon_to_grid(turtle: Node) -> void:
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

	turtle.status_label = status_label
	button.pressed.connect(_on_turtle_icon_selected.bind(turtle))

	item_container.add_child(button)
	item_container.add_child(status_label)
	grid.add_child(item_container)

# ------------------------------------------------------- job assignment

## Called by a spot's plus button: remember the target and open the turtle list.
func begin_spot_assignment(spot: Node) -> void:
	pending_spot = spot
	turtleUI.visible = true

func _on_turtle_icon_selected(turtle: Node) -> void:
	if not is_instance_valid(turtle):
		return
	turtleUI.visible = false

	if is_instance_valid(pending_spot) and not pending_spot.hasWorker:
		assign_turtle_to_spot(turtle, pending_spot)
		pending_spot = null
	elif turtle.is_assigned_to_store:
		turtle.return_to_pen(get_pen_bounds())
	else:
		_show_floor_chooser(turtle)
	save_game()

func assign_turtle_to_spot(turtle: Node, spot: Node) -> void:
	var floor_node: Node = get_floor_of(spot)
	if floor_node == null:
		return
	var index: int = get_spot_index(spot)
	var target: Vector2 = spot.global_position + Vector2(-200, -60)
	turtle.send_to_station(target, String(floor_node.floor_id), index, spot)
	spot.hasWorker = true

func assign_turtle_to_floor(turtle: Node, floor_node: Node) -> void:
	var free: Array = floor_node.get_free_spots()
	if free.is_empty():
		print("No free spots on ", floor_node.floor_id)
		return
	assign_turtle_to_spot(turtle, free[0])

func _show_floor_chooser(turtle: Node) -> void:
	if floor_chooser == null:
		floor_chooser = PopupMenu.new()
		add_child(floor_chooser)
		floor_chooser.id_pressed.connect(_on_floor_chosen)
	floor_chooser.clear()
	var idx: int = 0
	for floor_node in get_floors():
		var free: Array = floor_node.get_free_spots()
		if free.is_empty():
			continue
		floor_chooser.add_item("%s (%d free)" % [String(floor_node.floor_id).capitalize(), free.size()], idx)
		floor_chooser.set_item_metadata(idx, floor_node)
		idx += 1
	if idx == 0:
		print("No floors have free spots")
		return
	floor_chooser.set_meta("turtle", turtle)
	floor_chooser.position = Vector2i(get_viewport().get_mouse_position())
	floor_chooser.popup()

func _on_floor_chosen(id: int) -> void:
	var turtle = floor_chooser.get_meta("turtle")
	var floor_node = floor_chooser.get_item_metadata(id)
	if is_instance_valid(turtle) and floor_node != null:
		assign_turtle_to_floor(turtle, floor_node)
		save_game()

# --------------------------------------------------------------- save

func save_game() -> void:
	var turtles_data: Array = []
	for turtle in get_tree().get_nodes_in_group("turtles"):
		if is_instance_valid(turtle) and turtle.has_method("save_data"):
			turtles_data.append(turtle.save_data())

	var floors_data: Dictionary = {}
	for floor_node in get_floors():
		floors_data[String(floor_node.floor_id)] = floor_node.get_save_data()

	var data: Dictionary = {
		"turtle_coins": GameManager.turtle_coins,
		"turtleCost": turtleCost,
		"turtleCount": turtleCount,
		"turtleMax": turtleMax,
		"penSpaceCost": penSpaceCost,
		"floors": floors_data,
		"turtles": turtles_data,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "	"))
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

	if data.has("turtle_coins"):
		GameManager.turtle_coins = int(data["turtle_coins"])
	if data.has("turtleCost"):
		turtleCost = int(data["turtleCost"])
	if data.has("turtleMax"):
		turtleMax = int(data["turtleMax"])
	if data.has("penSpaceCost"):
		penSpaceCost = int(data["penSpaceCost"])

	# Restore each floor's own slice, then clear its spot staffing so the
	# turtles we rebuild below are the single source of truth.
	var floors_data: Dictionary = data.get("floors", {})
	for floor_node in get_floors():
		var key := String(floor_node.floor_id)
		if floors_data.has(key):
			floor_node.load_save_data(floors_data[key])
		for spot in floor_node.get_spots():
			spot.hasWorker = false

	# Restore turtles (and re-staff the spots they were working).
	turtleCount = 0
	var turtles_data: Array = data.get("turtles", [])
	for t_data in turtles_data:
		var pos := Vector2(float(t_data.get("pos_x", 0.0)), float(t_data.get("pos_y", 0.0)))
		var hat: int = int(t_data.get("random_hat", -1))
		var assigned_floor: String = String(t_data.get("assigned_floor_id", ""))
		var assigned_spot: int = int(t_data.get("assigned_spot_index", -1))
		_instantiate_turtle(pos, hat, assigned_floor, assigned_spot)
		turtleCount += 1
