extends Node2D

@export var turtle_scene: PackedScene = preload("res://Turtle.tscn")
@onready var addTurtle: Button = $addTurtle
@onready var turtle_pen: Sprite2D = $TurtlePen
@onready var turtleCoinsLabel: Label = $turtleCoins
@onready var turtleCostLabel: Label = $addTurtle/turtleCost
@onready var turtleCountLabel: Label = $turtleCount

var turtleCoins: int = 999
var turtleCost: int = 1
var turtleCount: int = 0
var turtleMax: int = 5

func _ready() -> void:
	pass

# scroll to get to different scenes
func _unhandled_input(event: InputEvent) -> void:
	var screen_height: float = get_viewport_rect().size.y
	if event is InputEventMouseButton:
		# Detect scroll wheel moving up
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_pressed():
			# Subtract the screen height to move up by one full screen
			position.y += screen_height
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_pressed():

			# Subtract the screen height to move up by one full screen
			position.y -= screen_height
			
func get_pen_bounds() -> Rect2:
	if not turtle_pen or not turtle_pen.texture:
		return Rect2()

	# Get the texture's pixel size scaled by the sprite's scale
	var pen_size: Vector2 = turtle_pen.texture.get_size() * turtle_pen.global_scale
	
	# Determine top-left corner depending on whether the sprite is centered
	var top_left: Vector2
	if turtle_pen.centered:
		top_left = turtle_pen.global_position - (pen_size / 2.0)
	else:
		top_left = turtle_pen.global_position
		
	return Rect2(top_left, pen_size)

func _on_addTurtle_pressed() -> void:
	print("aksdafhnjs")
	if turtle_scene:
		if turtleCoins > turtleCost:
			turtleCoins -= turtleCost
			turtleCost += 1
			turtleCount += 1
			var bounds = get_pen_bounds()
			var new_turtle = turtle_scene.instantiate()
			
			
			# Pass the dynamic boundaries to the turtle
			new_turtle.bounds = bounds
			
			# Spawn at a random position inside TurtlePen
			new_turtle.global_position = Vector2(
				randf_range(bounds.position.x, bounds.end.x),
				randf_range(bounds.position.y, bounds.end.y)
			)
			
			add_child(new_turtle)

func _process(delta: float) -> void:
	turtleCoinsLabel.text = "Turtle Coins: %d" %turtleCoins
	turtleCostLabel.text = "Turtle Cost: %d" %turtleCost
	turtleCountLabel.text = "%d/%d" % [turtleCount, turtleMax]
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	#
