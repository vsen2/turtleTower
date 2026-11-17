extends Node2D

const SAVE_PATH: String = "user://savegame.json"

@onready var camera: Camera2D = $Camera2D
@onready var turtleUI: Control = $CanvasLayer/TurtleUI
@onready var shopUI: Control = $CanvasLayer/ShopUI
@onready var turtleCoinsLabel: Label = $CanvasLayer/turtleCoins

@onready var turtleFile1: Sprite2D = $CanvasLayer/TurtleUI/File1
@onready var turtleFile2: Sprite2D = $CanvasLayer/TurtleUI/File2
@onready var turtleFile3: Sprite2D = $CanvasLayer/TurtleUI/File3

@onready var floorSlider: VSlider = $CanvasLayer/floorSlider
@onready var floorLabel: Label = $CanvasLayer/floorLabel

var floorLimits = Vector2(4,-4)
var floorLevel: int = 0

# menu for changing turtles
var pending_spot: Node = null
var turtle_menu: PopupMenu = null
var hat_menu: PopupMenu = null
var floor_chooser: PopupMenu = null
var menu_turtle: Node = null
enum TurtleAction { JOB, PEN, HAT }

var cameraStartY: float = 0.0
var _camera_tween: Tween

# Stays false until loadGame() finishes, so nothing can overwrite the save
# file with a blank game while the scene is still starting up.
var _save_loaded: bool = false

func _ready() -> void:
	print("mainGame _ready...")
	cameraStartY = camera.position.y
	loadGame()
	_save_loaded = true
	GameManager.hats_changed.connect(saveGame)
	# Autosave every 5 seconds so earned coins aren't lost.
	var autosave := Timer.new()
	autosave.wait_time = 5.0
	autosave.autostart = true
	autosave.timeout.connect(saveGame)
	add_child(autosave)
	GameManager.coins_spent.connect(spawnSpentCoinsLabel)
	setupFloorSlider()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		saveGame()

func _process(_delta: float) -> void:
	turtleCoinsLabel.text = "Turtle Coins: %d" % GameManager.turtle_coins

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.is_pressed()):
		return
	var wheel: InputEventMouseButton = event
	if wheel.button_index == MOUSE_BUTTON_WHEEL_UP:
		goToFloor(floorLevel + 1)
	elif wheel.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		goToFloor(floorLevel - 1)
	
func spawnSpentCoinsLabel(coins: int) -> void:
	# Put it in the same CanvasLayer as the coin counter so it stays on screen.
	var pos: Vector2 = turtleCoinsLabel.position + Vector2(turtleCoinsLabel.size.x + 5, 0)
	GameManager.spawnFloatingLabel(turtleCoinsLabel.get_parent(), "-%d Coins" % coins, pos,
		Color(1.0, 0.26, 0.201, 1.0), 15, "SpentMoney")
	
func setupFloorSlider() -> void:
	floorSlider.min_value = floorLimits.y      # lowest floor (-2)
	floorSlider.max_value = floorLimits.x      # highest floor (4)
	floorSlider.step = 1
	floorSlider.value_changed.connect(func(v: float) -> void: goToFloor(int(v)))

	var track := StyleBoxFlat.new()
	track.bg_color = Color(0.96, 0.95, 0.9)   
	track.border_color = Color.BLACK
	track.set_border_width_all(4)
	track.set_corner_radius_all(14)
	track.content_margin_left = 14
	track.content_margin_right = 14
	floorSlider.add_theme_stylebox_override("slider", track)

	var empty := StyleBoxEmpty.new()
	floorSlider.add_theme_stylebox_override("grabber_area", empty)
	floorSlider.add_theme_stylebox_override("grabber_area_highlight", empty)

	# White circle with a black outline
	floorSlider.add_theme_icon_override("grabber", makeCircle(44, Color.WHITE))
	floorSlider.add_theme_icon_override("grabber_highlight", makeCircle(44, Color(1.0, 1.0, 1.0, 1.0)))
	floorSlider.tick_count = 0
	floorLabel.add_theme_font_size_override("font_size", 22)

	# Place the label once the slider has its real size
	updateFloorLabel.call_deferred()

func makeCircle(diameter: int, fill: Color) -> Texture2D:
	var grad := Gradient.new()
	grad.set_offset(0, 0.0)
	grad.set_color(0, fill)
	grad.set_offset(1, 1.0)
	grad.set_color(1, Color(0, 0, 0, 0))
	grad.add_point(0.74, fill)
	grad.add_point(0.78, Color.BLACK)
	grad.add_point(0.94, Color.BLACK)
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.width = diameter
	tex.height = diameter
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	return tex

func goToFloor(level: int, instant: bool = false) -> void:
	var old_level: int = floorLevel
	floorLevel = clampi(level, int(floorLimits.y), int(floorLimits.x))
	var screen_height: float = get_viewport_rect().size.y
	var target_y: float = cameraStartY + floorLevel * screen_height * -1

	# Stop any slide already in progress so fast scrolling doesn't stack tweens
	if _camera_tween and _camera_tween.is_valid():
		_camera_tween.kill()

	if instant:
		camera.position.y = target_y
	else:
		# Longer slides take a bit longer, so crossing 4 floors isn't a blur
		var duration: float = 0.25 + 0.08 * abs(floorLevel - old_level)
		_camera_tween = create_tween()
		_camera_tween.tween_property(camera, "position:y", target_y, duration) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	floorSlider.set_value_no_signal(floorLevel)

	updateFloorLabel()
	
func updateFloorLabel() -> void:
	var i: int = floorLevel - int(floorLimits.y)
	floorLabel.text = "%d" % floorLevel

	# Where the circle is: 0 = lowest floor, 1 = highest floor
	var ratio: float = inverse_lerp(floorLimits.y, floorLimits.x, float(floorLevel))
	var grab_h: float = floorSlider.get_theme_icon("grabber").get_height()
	var travel: float = floorSlider.size.y - grab_h
	var handle_y: float = floorSlider.position.y + grab_h / 2.0 + travel * (1.0 - ratio)

	# Center the number inside the circle
	var grab_w: float = floorSlider.get_theme_icon("grabber").get_width()
	floorLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	floorLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	floorLabel.mouse_filter = Control.MOUSE_FILTER_IGNORE  # let clicks reach the slider
	floorLabel.size = Vector2(grab_w, grab_h)
	floorLabel.position = Vector2(
		floorSlider.position.x + floorSlider.size.x / 2.0 - grab_w / 2.0,
		handle_y - grab_h / 2.0)

func getFloors() -> Array[Node]:
	return get_tree().get_nodes_in_group("floors")

func getTurtlePens() -> Array[Node]:
	return get_tree().get_nodes_in_group("turtlePens")

func getFloorById(id: String) -> Node:
	for f in getFloors():
		if String(f.floor_id) == id:
			return f
	return null

func getFloorOf(node: Node) -> Node:
	var n: Node = node
	while n != null:
		if n.is_in_group("floors"):
			return n
		n = n.get_parent()
	return null

func getSpotIndex(spot: Node) -> int:
	var floor_node: Node = getFloorOf(spot)
	if floor_node == null:
		return -1
	return floor_node.getSpots().find(spot)


func beginSpotAssignment(spot: Node) -> void:
	pending_spot = spot
	showTurtleUi()
	
func onTurtleIconSelected(turtle: Node) -> void:
	if not is_instance_valid(turtle):
		return
	# Came here from a spot's + button: send this turtle straight there.
	if is_instance_valid(pending_spot) and not pending_spot.hasWorker:
		assignTurtleToSpot(turtle, pending_spot)
		pending_spot = null
		turtleUI.visible = false
		saveGame()
		return
	showTurtleMenu(turtle)

func showTurtleMenu(turtle: Node) -> void:
	if turtle_menu == null:
		turtle_menu = PopupMenu.new()
		add_child(turtle_menu)
		turtle_menu.id_pressed.connect(onTurtleMenuChosen)
	turtle_menu.clear()
	menu_turtle = turtle
	if turtle.is_assigned_to_store:
		turtle_menu.add_item("Switch job", TurtleAction.JOB)
		turtle_menu.add_item("Send back to pen", TurtleAction.PEN)
	else:
		turtle_menu.add_item("Give a job", TurtleAction.JOB)
	turtle_menu.add_item("Give a hat", TurtleAction.HAT)
	popupAtMouse(turtle_menu)

func onTurtleMenuChosen(id: int) -> void:
	var turtle: Node = menu_turtle
	if not is_instance_valid(turtle):
		return
	match id:
		TurtleAction.JOB:
			showFloorChooser.call_deferred(turtle)
		TurtleAction.PEN:
			#turtle.returnToPen(getPenBounds())
			saveGame()
		TurtleAction.HAT:
			showHatMenu.call_deferred(turtle)

func showHatMenu(turtle: Node) -> void:
	if hat_menu == null:
		hat_menu = PopupMenu.new()
		hat_menu.add_theme_constant_override("icon_max_width", 40)
		add_child(hat_menu)
		hat_menu.id_pressed.connect(onHatChosen)
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
	popupAtMouse(hat_menu)

func onHatChosen(hat_id: int) -> void:
	var turtle: Node = menu_turtle
	if not is_instance_valid(turtle):
		return
	if hat_id == turtle.random_hat and turtle.hat_from_inventory:
		return  # already wearing that exact hat
	var old_hat: int = turtle.random_hat
	var old_was_owned: bool = turtle.hat_from_inventory
	if not GameManager.removeHat(hat_id):
		return
	turtle.setHat(hat_id, true)
	if old_was_owned:
		GameManager.addHat(old_hat)  # give the old one back
	saveGame()

func popupAtMouse(menu: PopupMenu) -> void:
	menu.reset_size()
	menu.position = Vector2i(get_viewport().get_mouse_position())
	menu.popup()

func assignTurtleToSpot(turtle: Node, spot: Node) -> void:
	var floor_node: Node = getFloorOf(spot)
	if floor_node == null:
		return
	var index: int = getSpotIndex(spot)
	var target: Vector2 = getWorkerPosition(spot)
	turtle.sendToStation(target, String(floor_node.floor_id), index, spot, getWorkerFlip(spot))
	spot.hasWorker = true

func assignTurtleToFloor(turtle: Node, floor_node: Node) -> void:
	var free: Array = floor_node.getFreeSpots()
	if free.is_empty():
		print("No free spots on ", floor_node.floor_id)
		return
	assignTurtleToSpot(turtle, free[0])

func showFloorChooser(turtle: Node) -> void:
	if floor_chooser == null:
		floor_chooser = PopupMenu.new()
		add_child(floor_chooser)
		floor_chooser.id_pressed.connect(onFloorChosen)
	floor_chooser.clear()
	var idx: int = 0
	for floor_node in getFloors():
		var free: Array = floor_node.getFreeSpots()
		if free.is_empty():
			continue
		floor_chooser.add_item("%s (%d free)" % [String(floor_node.floor_id).capitalize(), free.size()], idx)
		floor_chooser.set_item_metadata(idx, floor_node)
		idx += 1
		if idx == 0:
			floor_chooser.add_item("No free spots - unlock one first!", 9999)
			floor_chooser.set_item_disabled(0, true)
		floor_chooser.set_meta("turtle", turtle)
		popupAtMouse(floor_chooser)

func onFloorChosen(id: int) -> void:
	var turtle = floor_chooser.get_meta("turtle")
	var floor_node = floor_chooser.get_item_metadata(id)
	if is_instance_valid(turtle) and floor_node != null:
		assignTurtleToFloor(turtle, floor_node)
		saveGame()
		
func getWorkerPosition(spot: Node) -> Vector2:
	var floor_node: Node = getFloorOf(spot)
	var offset: Vector2 = Vector2(-200, -60)
	if floor_node != null and "worker_offset" in floor_node:
		offset = floor_node.worker_offset
	return spot.global_position + offset
	
func getWorkerFlip(spot: Node) -> bool:
	var floor_node: Node = getFloorOf(spot)
	if floor_node != null and "worker_flip" in floor_node:
		return floor_node.worker_flip
	return false

func saveGame() -> void:
	if not _save_loaded:
		return
	print("saved game")
	var allTurtlesData: Dictionary = {}
	var penData: Dictionary = {}
	for turtlePen in getTurtlePens():
		var turtleData: Array = []
		for turtle in turtlePen.getPenTurtles():
			if is_instance_valid(turtle) and turtle.has_method("saveData"):
				turtleData.append(turtle.saveData())
		allTurtlesData[turtlePen.floor_id] = turtleData
		penData[String(turtlePen.floor_id)] = turtlePen.getSaveData()
		
	var floors_data: Dictionary = {}
	for floor_node in getFloors():
		floors_data[String(floor_node.floor_id)] = floor_node.getSaveData()

	var data: Dictionary = {
		"turtle_coins": GameManager.turtle_coins,
		"hat_coins": GameManager.hat_coins,
		"owned_hats": GameManager.owned_hats,
		"pens": penData,
		"floors": floors_data,
		"allTurtleData": allTurtlesData,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "	"))
		file.close()

func loadGame() -> void:
	var data: Dictionary = {}
	if FileAccess.file_exists(SAVE_PATH):
		var text := FileAccess.get_file_as_string(SAVE_PATH)
		if text.strip_edges() != "":
			var json := JSON.new()
			if json.parse(text) == OK and json.data is Dictionary:
				data = json.data
	
	if data.has("turtle_coins"):
		print("has tiurtlew coins")
		GameManager.turtle_coins = int(data["turtle_coins"])
	if data.has("hat_coins"):
		GameManager.hat_coins = int(data["hat_coins"])
		
	GameManager.setOwnedHats(data.get("owned_hats", []))
	
	var floors_data: Dictionary = data.get("floors", {})
	for floor_node in getFloors():
		var key := String(floor_node.floor_id)
		if floors_data.has(key):
			floor_node.loadSaveData(floors_data[key])
		for spot in floor_node.getSpots():
			spot.hasWorker = false
			if spot.has_method("updateUiState"):
				spot.updateUiState()
				
	var penData: Dictionary = data.get("pens", {})
	for turtlePen in getTurtlePens():
		var key := String(turtlePen.floor_id)
		if penData.has(key):
			turtlePen.loadSaveData(penData[key])

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
			var t: Node2D = pen.instantiateTurtle(pos, hat, assigned_floor, assigned_spot)
			if t != null:
				t.hat_from_inventory = bool(t_data.get("hat_from_inventory", false))
		pen.turtleCount = list.size()
		pen.updateLabels()

func onChangeTurtlesPressed() -> void:
	if turtleUI.visible:
		turtleUI.visible = false
	else:
		showTurtleUi()
		
func showTurtleUi() -> void:
	turtleUI.visible = true
	shopUI.visible = false
	onFileButton1Pressed()

func onShopPressed() -> void:
	shopUI.visible = not shopUI.visible
	turtleUI.visible = false

## Brings one turtle-menu tab (file) to the front. 0 = none on top.
func selectFile(fileNumber: int) -> void:
	turtleFile1.z_index = 50 if fileNumber == 1 else 49
	turtleFile2.z_index = 50 if fileNumber == 2 else 49
	turtleFile3.z_index = 50 if fileNumber == 3 else 49
	updateTurtleUiPages()

func onFileButton1Pressed() -> void:
	selectFile(1)
	onTurtleScrollPressed()

func onFileButton2Pressed() -> void:
	selectFile(2)

func onFileButton3Pressed() -> void:
	selectFile(0)  # file 3 has no page yet, so nothing comes to the front

## Shows one of the turtle lists (land, sea or space) on file 1.
func showTurtleScroll(scrollName: String) -> void:
	$CanvasLayer/TurtleUI/File1/scrollTurtles.visible = (scrollName == "scrollTurtles")
	$CanvasLayer/TurtleUI/File1/scrollSeaTurtles.visible = (scrollName == "scrollSeaTurtles")
	$CanvasLayer/TurtleUI/File1/scrollSpaceTurtles.visible = (scrollName == "scrollSpaceTurtles")

func onTurtleScrollPressed() -> void:
	showTurtleScroll("scrollTurtles")

func onSeaTurtleScrollPressed() -> void:
	showTurtleScroll("scrollSeaTurtles")

func onSpaceTurtleScrollPressed() -> void:
	showTurtleScroll("scrollSpaceTurtles")

func updateTurtleUiPages() -> void:
	var file1OnTop: bool = turtleFile1.z_index == 50
	$CanvasLayer/TurtleUI/File1/scrollTurtles.visible = file1OnTop
	$CanvasLayer/TurtleUI/File1/scrollSpaceTurtles.visible = file1OnTop
	$CanvasLayer/TurtleUI/File1/scrollSeaTurtles.visible = file1OnTop
	$CanvasLayer/TurtleUI/File1/textTurtles.visible = file1OnTop

	var file2OnTop: bool = turtleFile2.z_index == 50
	$CanvasLayer/TurtleUI/File2/TextHats.visible = file2OnTop
	$CanvasLayer/TurtleUI/File2/hatContainer.visible = file2OnTop

func onClearDataButtonPressed() -> void:
	GameManager.setOwnedHats([])
	
	GameManager.hat_coins = 0
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	
	get_tree().reload_current_scene()
	GameManager.turtle_coins = 999
