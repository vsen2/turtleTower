extends Node2D

const SAVE_PATH: String = "user://savegame.json"

@onready var camera: Camera2D = $Camera2D
@onready var turtleUI: Control = $CanvasLayer/TurtleUI
@onready var shopUI: Control = $CanvasLayer/ShopUI
@onready var turtleCoinsLabel: Label = $CanvasLayer/turtleCoins

@onready var turtleFile1: Sprite2D = $CanvasLayer/TurtleUI/File1
@onready var turtleFile2: Sprite2D = $CanvasLayer/TurtleUI/File2
@onready var turtleFile3: Sprite2D = $CanvasLayer/TurtleUI/File3

var floorLimits = Vector2(4,-2)

var floorLevel: int = 0

# menu for changing turtles
var pending_spot: Node = null
var turtle_menu: PopupMenu = null
var hat_menu: PopupMenu = null
var floor_chooser: PopupMenu = null
var menu_turtle: Node = null
enum TurtleAction { JOB, PEN, HAT }

var cameraStartY: float = 0.0

func _ready() -> void:
	print("mainGame _ready...")
	cameraStartY = camera.position.y
	load_game()
	GameManager.hats_changed.connect(save_game)
	GameManager.coins_spent.connect(spawnSpentCoinsLabel)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()

func _process(_delta: float) -> void:
	turtleCoinsLabel.text = "Turtle Coins: %d" % GameManager.turtle_coins

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.is_pressed()):
		return
	var wheel: InputEventMouseButton = event
	if wheel.button_index == MOUSE_BUTTON_WHEEL_UP:
		floorLevel += 1
	elif wheel.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		floorLevel -= 1
	else:
		return
	floorLevel = clampi(floorLevel, int(floorLimits.y), int(floorLimits.x))
	var screen_height: float = get_viewport_rect().size.y
	camera.position.y = cameraStartY + floorLevel * screen_height * -1
	print(floorLevel)
	
func spawnSpentCoinsLabel(coins: int) -> void:
	var label: Label = Label.new()
	label.name = "SpentMoney"
	label.text = "-%d Coins" % coins
	label.z_index = 30
	label.add_theme_color_override("font_color", Color(1.0, 0.26, 0.201, 1.0))
	label.add_theme_font_size_override("font_size", 15)

	# Put it in the same CanvasLayer as the coin counter so it stays on screen.
	turtleCoinsLabel.get_parent().add_child(label)
	label.position = turtleCoinsLabel.position + Vector2(turtleCoinsLabel.size.x + 5, 0)

	# Float upward and fade out, then delete itself.
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 20.0, 0.5)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.chain().tween_callback(label.queue_free)

func get_floors() -> Array[Node]:
	var out: Array[Node] = []
	for f in get_tree().get_nodes_in_group("floors"):
		out.append(f)
	return out

func getTurtlePens() -> Array[Node]:
	var out: Array[Node] = []
	for f in get_tree().get_nodes_in_group("turtlePens"):
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


func begin_spot_assignment(spot: Node) -> void:
	pending_spot = spot
	
func _on_turtle_icon_selected(turtle: Node) -> void:
	if not is_instance_valid(turtle):
		return
	# Came here from a spot's + button: send this turtle straight there.
	if is_instance_valid(pending_spot) and not pending_spot.hasWorker:
		assign_turtle_to_spot(turtle, pending_spot)
		pending_spot = null
		save_game()
		return
	_show_turtle_menu(turtle)

func _show_turtle_menu(turtle: Node) -> void:
	if turtle_menu == null:
		turtle_menu = PopupMenu.new()
		add_child(turtle_menu)
		turtle_menu.id_pressed.connect(_on_turtle_menu_chosen)
	turtle_menu.clear()
	menu_turtle = turtle
	if turtle.is_assigned_to_store:
		turtle_menu.add_item("Switch job", TurtleAction.JOB)
		turtle_menu.add_item("Send back to pen", TurtleAction.PEN)
	else:
		turtle_menu.add_item("Give a job", TurtleAction.JOB)
	turtle_menu.add_item("Give a hat", TurtleAction.HAT)
	_popup_at_mouse(turtle_menu)

func _on_turtle_menu_chosen(id: int) -> void:
	var turtle: Node = menu_turtle
	if not is_instance_valid(turtle):
		return
	match id:
		TurtleAction.JOB:
			_show_floor_chooser.call_deferred(turtle)
		TurtleAction.PEN:
			#turtle.return_to_pen(get_pen_bounds())
			save_game()
		TurtleAction.HAT:
			_show_hat_menu.call_deferred(turtle)

func _show_hat_menu(turtle: Node) -> void:
	if hat_menu == null:
		hat_menu = PopupMenu.new()
		hat_menu.add_theme_constant_override("icon_max_width", 40)
		add_child(hat_menu)
		hat_menu.id_pressed.connect(_on_hat_chosen)
	hat_menu.clear()
	menu_turtle = turtle

	# Count how many of each hat you own.
	var counts: Dictionary = {}
	for hat_id in GameManager.owned_hats:
		counts[hat_id] = counts.get(hat_id, 0) + 1

	if counts.is_empty():
		hat_menu.add_item("No hats yet - try the Hat Machine!", 9999)
		hat_menu.set_item_disabled(0, true)
	else:
		var ids: Array = counts.keys()
		ids.sort()
		for hat_id in ids:
			var label: String = "Hat %d" % hat_id
			if hat_id < GameManager.hatNames.size():
				label = GameManager.hatNames[hat_id]
			if counts[hat_id] > 1:
				label += " (x%d)" % counts[hat_id]
			hat_menu.add_icon_item(GameManager.hatsCentered[hat_id], label, hat_id)
	_popup_at_mouse(hat_menu)

func _on_hat_chosen(hat_id: int) -> void:
	var turtle: Node = menu_turtle
	if not is_instance_valid(turtle):
		return
	if hat_id == turtle.random_hat and turtle.hat_from_inventory:
		return  # already wearing that exact hat
	var old_hat: int = turtle.random_hat
	var old_was_owned: bool = turtle.hat_from_inventory
	if not GameManager.remove_hat(hat_id):
		return
	turtle.set_hat(hat_id, true)
	if old_was_owned:
		GameManager.add_hat(old_hat)  # give the old one back
	save_game()

func _popup_at_mouse(menu: PopupMenu) -> void:
	menu.reset_size()
	menu.position = Vector2i(get_viewport().get_mouse_position())
	menu.popup()

func assign_turtle_to_spot(turtle: Node, spot: Node) -> void:
	var floor_node: Node = get_floor_of(spot)
	if floor_node == null:
		return
	var index: int = get_spot_index(spot)
	var target: Vector2 = get_worker_position(spot)
	turtle.send_to_station(target, String(floor_node.floor_id), index, spot, get_worker_flip(spot))
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
			floor_chooser.add_item("No free spots - unlock one first!", 9999)
			floor_chooser.set_item_disabled(0, true)
		floor_chooser.set_meta("turtle", turtle)
		_popup_at_mouse(floor_chooser)

func _on_floor_chosen(id: int) -> void:
	var turtle = floor_chooser.get_meta("turtle")
	var floor_node = floor_chooser.get_item_metadata(id)
	if is_instance_valid(turtle) and floor_node != null:
		assign_turtle_to_floor(turtle, floor_node)
		save_game()
		
func get_worker_position(spot: Node) -> Vector2:
	var floor_node: Node = get_floor_of(spot)
	var offset: Vector2 = Vector2(-200, -60)
	if floor_node != null and "worker_offset" in floor_node:
		offset = floor_node.worker_offset
	return spot.global_position + offset
	
func get_worker_flip(spot: Node) -> bool:
	var floor_node: Node = get_floor_of(spot)
	if floor_node != null and "worker_flip" in floor_node:
		return floor_node.worker_flip
	return false

func save_game() -> void:
	var allTurtlesData: Dictionary = {}
	for turtlePen in getTurtlePens():
		var turtleData: Array = []
		for turtle in turtlePen.get_pen_turtles():
			if is_instance_valid(turtle) and turtle.has_method("save_data"):
				turtleData.append(turtle.save_data())
		allTurtlesData[turtlePen.floor_id] = turtleData
			
	var floors_data: Dictionary = {}
	for floor_node in get_floors():
		floors_data[String(floor_node.floor_id)] = floor_node.get_save_data()

	var data: Dictionary = {
		"turtle_coins": GameManager.turtle_coins,
		"hat_coins": GameManager.hat_coins,
		"owned_hats": GameManager.owned_hats,
		"floors": floors_data,
		"allTurtleData": allTurtlesData,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "	"))
		file.close()

func load_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	var json := JSON.new()
	json.parse(text)
	var data: Dictionary = json.data
	
	if data.has("turtle_coins"):
		GameManager.turtle_coins = int(data["turtle_coins"])
	if data.has("hat_coins"):
		GameManager.hat_coins = int(data["hat_coins"])
		
	GameManager.set_owned_hats(data.get("owned_hats", []))
	
	var floors_data: Dictionary = data.get("floors", {})
	for floor_node in get_floors():
		var key := String(floor_node.floor_id)
		if floors_data.has(key):
			floor_node.load_save_data(floors_data[key])
		for spot in floor_node.get_spots():
			spot.hasWorker = false
			if spot.has_method("update_ui_state"):
				spot.update_ui_state()

	# Restore each floor's own slice, then clear its spot staffing so the
	# turtles we rebuild below are the single source of truth.
	var allTurtles_data: Dictionary = data.get("allTurtleData", {})
	for pen in getTurtlePens():
		var list: Array = allTurtles_data.get(pen.floor_id, [])
		for t_data in list:
			var pos := Vector2(float(t_data.get("pos_x", 0.0)), float(t_data.get("pos_y", 0.0)))
			var hat: int = int(t_data.get("random_hat", -1))
			var assigned_floor: String = String(t_data.get("assigned_floor_id", ""))
			var assigned_spot: int = int(t_data.get("assigned_spot_index", -1))
			var t: Node2D = pen._instantiate_turtle(pos, hat, assigned_floor, assigned_spot)
			if t != null:
				t.hat_from_inventory = bool(t_data.get("hat_from_inventory", false))
		pen.turtleCount = list.size()
		pen.updateLabels()

func _on_changeTurtles_pressed() -> void:
	turtleUI.visible = not turtleUI.visible
	shopUI.visible = false
	turtleFile1.z_index = 50
	turtleFile2.z_index = 49
	turtleFile3.z_index = 49
	updatee_turtle_UI_pages()
	$CanvasLayer/TurtleUI/File1/scrollSeaTurtles.visible = false
	$CanvasLayer/TurtleUI/File1/scrollSpaceTurtles.visible = false
	$CanvasLayer/TurtleUI/File1/scrollTurtles.visible = true
	
func _on_shop_pressed() -> void:
	shopUI.visible = not shopUI.visible
	turtleUI.visible = false
	
func _on_file_button_1_pressed() -> void:
	turtleFile1.z_index = 50
	turtleFile2.z_index = 49
	turtleFile3.z_index = 49
	updatee_turtle_UI_pages()
	$CanvasLayer/TurtleUI/File1/scrollSeaTurtles.visible = false
	$CanvasLayer/TurtleUI/File1/scrollSpaceTurtles.visible = false
	$CanvasLayer/TurtleUI/File1/scrollTurtles.visible = true

func _on_file_button_2_pressed() -> void:
	turtleFile1.z_index = 49
	turtleFile2.z_index = 50
	turtleFile3.z_index = 49
	updatee_turtle_UI_pages()
	
func _on_file_button_3_pressed() -> void:
	turtleFile1.z_index = 49
	turtleFile2.z_index = 49
	turtleFile3.z_index = 49
	updatee_turtle_UI_pages()
	

func _on_turtle_scroll_pressed() -> void:
	$CanvasLayer/TurtleUI/File1/scrollSeaTurtles.visible = false
	$CanvasLayer/TurtleUI/File1/scrollSpaceTurtles.visible = false
	$CanvasLayer/TurtleUI/File1/scrollTurtles.visible = true
	
func _on_sea_turtle_scroll_pressed() -> void:
	$CanvasLayer/TurtleUI/File1/scrollSeaTurtles.visible = true
	$CanvasLayer/TurtleUI/File1/scrollSpaceTurtles.visible = false
	$CanvasLayer/TurtleUI/File1/scrollTurtles.visible = false

func _on_space_turtle_scroll_pressed() -> void:
	$CanvasLayer/TurtleUI/File1/scrollSeaTurtles.visible = false
	$CanvasLayer/TurtleUI/File1/scrollSpaceTurtles.visible = true
	$CanvasLayer/TurtleUI/File1/scrollTurtles.visible = false
	
func updatee_turtle_UI_pages() -> void:
	$CanvasLayer/TurtleUI/File1/scrollTurtles.visible = (turtleFile1.z_index == 50)
	$CanvasLayer/TurtleUI/File1/scrollSpaceTurtles.visible = (turtleFile1.z_index == 50)
	$CanvasLayer/TurtleUI/File1/scrollSeaTurtles.visible = (turtleFile1.z_index == 50)
	$CanvasLayer/TurtleUI/File1/textTurtles.visible = (turtleFile1.z_index == 50)
	
	$CanvasLayer/TurtleUI/File2/TextHats.visible = (turtleFile2.z_index == 50)
	$CanvasLayer/TurtleUI/File2/hatContainer.visible = (turtleFile2.z_index == 50)
