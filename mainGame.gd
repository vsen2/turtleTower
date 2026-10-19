extends Node2D

@export var turtle_icon: Texture2D = preload("res://turtleNoBG.png")
@export var turtle_scene: PackedScene = preload("res://Turtle.tscn")
@export var customer_scene: PackedScene = preload("res://customerTurtle.tscn")
@export var customer_interval: float = 3.0


@onready var addTurtle: Button = $addTurtle
@onready var addPenSpace: Button = $addPenSpace
@onready var turtle_pen: Sprite2D = $TurtlePen
@onready var turtleCoinsLabel: Label = $CanvasLayer/turtleCoins
@onready var turtleCostLabel: Label = $CanvasLayer/TowerUI/addTurtle/turtleCost
@onready var turtleCountLabel: Label = $turtleCount
@onready var penSpaceLabel: Label = $CanvasLayer/TowerUI/addPenSpace/penSpaceLabel
@onready var camera: Camera2D = $Camera2D
@onready var towerUI: Control = $CanvasLayer/TowerUI
@onready var grid: GridContainer = $CanvasLayer/TurtleUI/scrollContainer/turtleGrid
@onready var turtleUI: Control = $CanvasLayer/TurtleUI
@onready var registers: Array[Node2D] = [$STORE/CashRegister1, $STORE/CashRegister2, $STORE/CashRegister3, $STORE/CashRegister4]

var turtleCoins: int = 99999999
var penSpaceCost: int = 1
var turtleCost: int = 1
var turtleCount: int = 0
var turtleMax: int = 50
var floorLevel: int = 0
var customer_timer: Timer


func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	var screen_height: float = get_viewport_rect().size.y
	if event is InputEventMouseButton and not turtleUI.visible and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			floorLevel -= 1
			camera.position.y -= screen_height
			print("floor: %s" % floorLevel)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			floorLevel += 1
			camera.position.y += screen_height
			print("floor: %s" % floorLevel)
			
		towerUI.visible = (floorLevel <= 0)

func get_pen_bounds() -> Rect2:
	if not turtle_pen or not turtle_pen.texture:
		return Rect2()

	var pen_size: Vector2 = turtle_pen.texture.get_size() * turtle_pen.global_scale
	var top_left: Vector2
	if turtle_pen.centered:
		top_left = turtle_pen.global_position - (pen_size / 2.0)
	else:
		top_left = turtle_pen.global_position
		
	return Rect2(top_left, pen_size)

func _on_addTurtle_pressed() -> void:
	if not turtle_scene:
		return

	if turtleCoins >= turtleCost and turtleCount < turtleMax:
		turtleCoins -= turtleCost
		turtleCost += 1
		turtleCount += 1

		var bounds: Rect2 = get_pen_bounds()
		var new_turtle = turtle_scene.instantiate()
		new_turtle.bounds = bounds
		
		# Give a 24px safety margin from the fence on initial spawn
		var pad: float = 24.0
		var spawn_min_x = bounds.position.x + pad
		var spawn_max_x = max(spawn_min_x, bounds.end.x - pad)
		var spawn_min_y = bounds.position.y + pad
		var spawn_max_y = max(spawn_min_y, bounds.end.y - pad)

		new_turtle.global_position = Vector2(
			randf_range(spawn_min_x, spawn_max_x),
			randf_range(spawn_min_y, spawn_max_y)
		)
		
		add_child(new_turtle)
		add_turtle_icon_to_grid(new_turtle)

func _on_addPenSpace_pressed() -> void:
	if turtleCoins >= penSpaceCost:
		turtleCoins -= penSpaceCost
		turtleMax += 1
		penSpaceCost += 1

func _process(_delta: float) -> void:
	turtleCoinsLabel.text = "Turtle Coins: %d" % turtleCoins
	turtleCostLabel.text = "Cost: %d" % turtleCost
	turtleCountLabel.text = "%d/%d" % [turtleCount, turtleMax]
	penSpaceLabel.text = "Cost: %d" % penSpaceCost

func _on_changeTurtles_pressed() -> void:
	turtleUI.visible = !turtleUI.visible

func add_turtle_icon_to_grid(turtle_ref: Node2D) -> void:
	# Container to stack the icon and label vertically
	var item_container = VBoxContainer.new()
	item_container.alignment = BoxContainer.ALIGNMENT_CENTER

	# Turtle Icon Button
	var btn = TextureButton.new()
	btn.texture_normal = turtle_icon
	btn.custom_minimum_size = Vector2(96, 96)
	btn.ignore_texture_size = true
	btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED

	# Label showing current assignment
	var status_label = Label.new()
	status_label.text = "Idle"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_color_override("font_color", Color.BLACK)
	
	# Give the turtle node a reference to its label so it can update it
	turtle_ref.status_label = status_label

	# Connect button press
	btn.pressed.connect(_on_turtle_icon_selected.bind(turtle_ref))

	# Assemble hierarchy
	item_container.add_child(btn)
	item_container.add_child(status_label)
	grid.add_child(item_container)
	
func _on_turtle_icon_selected(turtle: Node2D) -> void:
	if not is_instance_valid(turtle):
		return
	
	# Close the turtle menu
	turtleUI.visible = false
	
	# Move turtle to an available cash register or the store area
	if !turtle.current_job == null:
		turtle.return_to_pen(get_pen_bounds())
	else:
		assign_turtle_to_store(turtle)

func assign_turtle_to_store(turtle: Node2D) -> void:
	var target_spot: Vector2 = Vector2.ZERO
	var chosen_register: Node2D = null
	var register_number: int = -1

	for i in registers.size():
		print(registers[i].hasWorker)
		print(registers[i].unlocked)
		if is_instance_valid(registers[i]) and not registers[i].hasWorker and registers[i].unlocked:
			print("works")
			target_spot = registers[i].global_position
			chosen_register = registers[i]
			register_number = i + 1  # 1-based index (Register 1, Register 2, etc.)
			target_spot.x -= 200
			target_spot.y -= 60
			break
	if chosen_register != null:
		chosen_register.hasWorker = true
		turtle.send_to_station(target_spot, register_number, chosen_register)
	else:
		print("All registers are full!")
	

		
