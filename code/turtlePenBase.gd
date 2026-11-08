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

signal updateLabelSignal(amount: int)

var turtleCost: int = 1
var turtleCount: int = 0
var turtleMax: int = 20
var penSpaceCost: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_to_group("turtlePens")
	addTurtle.pressed.connect(_on_addTurtle_pressed)
	addPenSpace.pressed.connect(_on_addPenSpace_pressed)
	updateLabelSignal.connect(updateLabels)
	updateLabelSignal.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func updateLabels() -> void:
	turtleCostLabel.text = "Cost: %d" % turtleCost
	turtleCountLabel.text = "%d/%d" % [turtleCount, turtleMax]
	penSpaceLabel.text = "Cost: %d" % penSpaceCost
	
func get_pen_turtles() -> Array[Node]:
	return get_tree().get_nodes_in_group(floor_id)
	
func _request_save() -> void:
	var main_node = get_tree().current_scene
	if main_node and main_node.has_method("save_game"):
		main_node.save_game()
	
func _get_pen_rect() -> Rect2:
	var pen_size: Vector2 = turtlePen.texture.get_size() * turtlePen.global_scale.abs()
	var top_left: Vector2 = turtlePen.global_position
	if turtlePen.centered:
		top_left -= pen_size / 2.0
	return Rect2(top_left, pen_size)
	
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
	button.pressed.connect(get_parent()._on_turtle_icon_selected.bind(turtle))

	item_container.add_child(button)
	item_container.add_child(status_label)
	grid.add_child(item_container)
	
func _instantiate_turtle(pos: Vector2, hat_id: int, assigned_floor: String, assigned_spot: int) -> Node2D:
	var new_turtle: Node2D = turtle_scene.instantiate()
	new_turtle.bounds = get_pen_bounds()
	new_turtle.home_pen_id = floor_id
	new_turtle.add_to_group(floor_id)
	if hat_id != -1:
		new_turtle.random_hat = hat_id
	add_child(new_turtle)
	new_turtle.global_position = pos
	add_turtle_icon_to_grid(new_turtle)

	if assigned_floor != "" and assigned_spot >= 0:
		var main = get_tree().current_scene
		var floor_node: Node = main.get_floor_by_id(assigned_floor)
		if floor_node != null:
			var spots: Array = floor_node.get_spots()
			if assigned_spot < spots.size():
				var spot: Node = spots[assigned_spot]
				var target: Vector2 = main.get_worker_position(spot)
				new_turtle.send_to_station(target, assigned_floor, assigned_spot, spot, main.get_worker_flip(spot))
				spot.hasWorker = true
	return new_turtle
	
func _on_addTurtle_pressed() -> void:
	if turtleCount < turtleMax:
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
			_request_save()
		else:
			spawnNopeLabel("Not enough coins! (brokie haha)")
			
		updateLabelSignal.emit()
	else:
		spawnNopeLabel("Not enough pen space!")
		
	
func spawnNopeLabel(words: String) -> void:
	if not has_node("cantBuyLabel"):
		var label: Label = Label.new()
		label.name = "cantBuyLabel"
		label.text = words
		label.top_level = true
		label.global_position = get_viewport().get_mouse_position()
		label.z_index = 30
		label.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0, 1.0)) # color
		label.add_theme_font_size_override("font_size", 25)
		add_child(label)
		# Float upward and fade out, then delete itself.
		var tween: Tween = create_tween().set_parallel(true)
		tween.tween_property(label, "global_position:y", label.global_position.y - 20.0, .5)
		tween.tween_property(label, "modulate:a", 0.0, 0.8)
		tween.chain().tween_callback(label.queue_free)
	
func _on_addPenSpace_pressed() -> void:
	if GameManager.spend_coins(penSpaceCost):
		penSpaceCost += 1
		turtleMax += 1
		_request_save()
	updateLabelSignal.emit()
		
func get_pen_bounds() -> Rect2:
	if not turtlePen or not turtlePen.texture:
		print("get_pen_bounds: turtle_pen missing or no texture!")
		return Rect2(Vector2(), Vector2(100, 100))
	var pen_size: Vector2 = turtlePen.texture.get_size() * turtlePen.global_scale
	var top_left: Vector2 = turtlePen.global_position
	if turtlePen.centered:
		top_left -= pen_size / 2.0
	return Rect2(top_left, pen_size)

func get_upgrades_data() -> Dictionary:
	return {
		"turtleCost": turtleCost,
		"turtleMax": turtleMax,
		"penSpaceCost": penSpaceCost,
	}

func load_upgrades_data(data: Dictionary) -> void:
	if data.has("turtleCost"): turtleCost = int(data["turtleCost"])
	if data.has("turtleMax"): turtleMax = int(data["turtleMax"])
	if data.has("penSpaceCost"): penSpaceCost = int(data["penSpaceCost"])
	updateLabels()
	
