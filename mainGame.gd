extends Node2D

@export var turtle_icon: Texture2D = preload("res://turtleIcon.png")
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
@onready var registers: Array[Node2D] = [$STORE/CashRegister1, $STORE/CashRegister2, $STORE/CashRegister3, $STORE/CashRegister4
]

var turtleCoins: int = 99999999
var penSpaceCost: int = 1
var turtleCost: int = 1
var turtleCount: int = 0
var turtleMax: int = 50
var floorLevel: int = 0
var customer_timer: Timer

func _ready() -> void:
	_setup_customer_timer()

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
		add_turtle_icon_to_grid()

func _on_addPenSpace_pressed() -> void:
	if turtleCoins >= penSpaceCost:
		turtleCoins -= penSpaceCost
		turtleMax += 1
		penSpaceCost += 1

func _process(_delta: float) -> void:
	turtleCoinsLabel.text = "Turtle Coins: %d" % turtleCoins
	turtleCostLabel.text = "Turtle Cost: %d" % turtleCost
	turtleCountLabel.text = "%d/%d" % [turtleCount, turtleMax]
	penSpaceLabel.text = "Upgrade Cost: %d" % penSpaceCost

func _on_changeTurtles_pressed() -> void:
	turtleUI.visible = !turtleUI.visible

func add_turtle_icon_to_grid() -> void:
	var icon = TextureRect.new()
	icon.texture = turtle_icon
	icon.custom_minimum_size = Vector2(96, 96)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	grid.add_child(icon)

func _setup_customer_timer() -> void:
	customer_timer = Timer.new()
	customer_timer.wait_time = customer_interval
	customer_timer.autostart = true
	customer_timer.one_shot = false
	customer_timer.timeout.connect(_on_customer_timer_timeout)
	add_child(customer_timer)

func _on_customer_timer_timeout() -> void:
	# 1. Gather all registers that meet both conditions
	var eligible_registers: Array[Node2D] = []
	for reg in registers:
		if reg.has_method("can_accept_customer") and reg.can_accept_customer():
			eligible_registers.append(reg)

	# 2. Stop here if no registers are ready
	if eligible_registers.is_empty():
		return

	# 3. Pick one eligible register
	var chosen_register: Node2D = eligible_registers.pick_random()

	# 4. Spawn the customer turtle
	_spawn_customer(chosen_register)

func _spawn_customer(register: Node2D) -> void:
	if not customer_scene:
		return

	var customer = customer_scene.instantiate()
	
	# Place the customer at the register's customer spot
	customer.global_position = register.get_customer_position()
	
	# Give coins when the purchase finishes
	customer.purchase_completed.connect(func(amount: int):
		turtleCoins += amount
		turtleCoinsLabel.text = "Turtle Coins: %d" % turtleCoins
	)

	add_child(customer)
		
