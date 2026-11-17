extends "res://code/floor.gd"

#base node for turtle storage levels

@export var turtle_icon: Texture2D = null
@export var turtle_scene: PackedScene = null
@export var grid: GridContainer = null

@onready var addTurtle: TextureButton = $addTurtle
@onready var addPenSpace: TextureButton = $addPenSpace
@onready var turtlePen: Sprite2D = $TurtlePen
@onready var turtleCostLabel: Label = $addTurtle/turtleCost
@onready var turtleCountLabel: Label = $turtleCount
@onready var penSpaceLabel: Label = $addPenSpace/penSpaceLabel
@export var penID: int = 0 

var turtleCost: int = 1
var turtleCount: int = 0
var turtleMax: int = 20
var penSpaceCost: int = 1
var hats = GameManager.hats

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_to_group("turtlePens")
	addTurtle.pressed.connect(onAddTurtlePressed)
	addPenSpace.pressed.connect(onAddPenSpacePressed)
	updateLabels()
	
func updateLabels() -> void:
	turtleCostLabel.text = "Cost: %d" % turtleCost
	turtleCountLabel.text = "%d/%d" % [turtleCount, turtleMax]
	penSpaceLabel.text = "Cost: %d" % penSpaceCost
	
func getPenTurtles() -> Array[Node]:
	return get_tree().get_nodes_in_group(floor_id)
	
func addTurtleIconToGrid(turtle: Node, hatID: int) -> void:
	print("hatID: " + str(hatID))
	var item_container: VBoxContainer = VBoxContainer.new()
	item_container.alignment = BoxContainer.ALIGNMENT_CENTER

	var button: TextureButton = TextureButton.new()
	button.texture_normal = turtle_icon
	button.custom_minimum_size = Vector2(96, 96)
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	
	if hatID > 0:
		var hat := TextureRect.new()
		hat.texture = hats[hatID]
		hat.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		hat.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hat.size = Vector2(120, 120)
		hat.position = Vector2(-40, -36)
		hat.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(hat)
	
	var status_label: Label = Label.new()
	status_label.text = "Idle"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_color_override("font_color", Color.BLACK)

	turtle.status_label = status_label
	button.pressed.connect(get_parent().onTurtleIconSelected.bind(turtle))

	
	item_container.add_child(button)
	item_container.add_child(status_label)
	grid.add_child(item_container)
	
func instantiateTurtle(pos: Vector2, hat_id: int, assigned_floor: String, assigned_spot: int) -> Node2D:
	var new_turtle: Node2D = turtle_scene.instantiate()
	new_turtle.bounds = getPenBounds()
	new_turtle.home_pen_id = floor_id
	new_turtle.add_to_group(floor_id)
	if hat_id > 0:
		new_turtle.random_hat = hat_id
	add_child(new_turtle)
	new_turtle.global_position = pos
	addTurtleIconToGrid(new_turtle, hat_id)

	if assigned_floor != "" and assigned_spot >= 0:
		var main = get_tree().current_scene
		var floor_node: Node = main.getFloorById(assigned_floor)
		if floor_node != null:
			var spots: Array = floor_node.getSpots()
			if assigned_spot < spots.size():
				var spot: Node = spots[assigned_spot]
				var target: Vector2 = main.getWorkerPosition(spot)
				new_turtle.sendToStation(target, assigned_floor, assigned_spot, spot, main.getWorkerFlip(spot))
				spot.hasWorker = true
	return new_turtle
	
func onAddTurtlePressed() -> void:
	if turtleCount < turtleMax:
		if GameManager.spendCoins(turtleCost):
			turtleCost += 1
			turtleCount += 1
			instantiateTurtle(randomPointIn(getPenBounds()), -1, "", -1)
			requestSave()
		else:
			GameManager.spawnNopeLabel("Not enough coins! (brokie haha)")
		updateLabels()
	else:
		GameManager.spawnNopeLabel("Not enough pen space!")
		
	
func onAddPenSpacePressed() -> void:
	if GameManager.spendCoins(penSpaceCost):
		penSpaceCost += 1
		turtleMax += 1
		requestSave()
	updateLabels()
		
func getPenBounds() -> Rect2:
	if not turtlePen or not turtlePen.texture:
		print("getPenBounds: turtle_pen missing or no texture!")
		return Rect2(Vector2(), Vector2(100, 100))
	var pen_size: Vector2 = turtlePen.texture.get_size() * turtlePen.global_scale.abs()
	var top_left: Vector2 = turtlePen.global_position
	if turtlePen.centered:
		top_left -= pen_size / 2.0
	return Rect2(top_left, pen_size)

func getUpgradesData() -> Dictionary:
	return {
		"turtleCost": turtleCost,
		"turtleMax": turtleMax,
		"penSpaceCost": penSpaceCost,
	}

func loadUpgradesData(data: Dictionary) -> void:
	if data.has("turtleCost"): turtleCost = int(data["turtleCost"])
	if data.has("turtleMax"): turtleMax = int(data["turtleMax"])
	if data.has("penSpaceCost"): penSpaceCost = int(data["penSpaceCost"])
	updateLabels()
	
