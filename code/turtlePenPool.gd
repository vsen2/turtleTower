extends "res://code/turtlePenBase.gd"

@export var waterSpeeds: Array[float] = [1.7, 2.5, 2.3, 2.7]
@onready var waterLines: Array[AnimatedSprite2D] = [$decor/waterLine1, $decor/waterLine2, $decor/waterLine3, $decor/waterLine4]

@onready var kelp1: AnimatedSprite2D = $decor/Kelp1
@onready var kelp2: AnimatedSprite2D = $decor/Kelp2
@onready var kelp3: AnimatedSprite2D = $decor/Kelp3
@onready var kelp4: AnimatedSprite2D = $decor/Kelp4

var directions: Array[int] = []


func _ready() -> void:
	super()

	kelp1.play("default")
	kelp2.play("default")
	kelp3.play("default")
	kelp4.play("default")
	
	for i in waterLines.size():
		directions.append(1 if i % 2 == 0 else -1)
		waterLines[i].play("default")
		
	for line in waterLines:
		print(line.name, " width: ", _get_half_width(line) * 2.0)

func _process(delta: float) -> void:
	if turtlePen == null or turtlePen.texture == null:
		return
	var pen_rect: Rect2 = _get_pen_rect()

	for i in waterLines.size():
		var line: AnimatedSprite2D = waterLines[i]
		var speed: float = waterSpeeds[i] if i < waterSpeeds.size() else 2.0
		var half_w: float = _get_half_width(line)

		# Keep the whole sprite inside the pen, not just its center.
		var min_x: float = pen_rect.position.x + half_w
		var max_x: float = pen_rect.end.x - half_w
		if min_x > max_x:  # line is wider than the pen
			min_x = pen_rect.get_center().x
			max_x = min_x

		line.global_position.x += speed * directions[i] * 60.0 * delta

		if line.global_position.x >= max_x:
			line.global_position.x = max_x
			directions[i] = -1
		elif line.global_position.x <= min_x:
			line.global_position.x = min_x
			directions[i] = 1


	
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
	#button.pressed.connect(get_parent()._on_turtle_icon_selected.bind(turtle))

	item_container.add_child(button)
	item_container.add_child(status_label)
	grid.add_child(item_container)
	
#func assign_turtle_to_spot(turtle: Node, spot: Node) -> void:
	#var floor_node: Node = get_floor_of(spot)
	#if floor_node == null:
		#return
	#var index: int = get_spot_index(spot)
	#var target: Vector2 = get_worker_position(spot)
	#turtle.send_to_station(target, String(floor_node.floor_id), index, spot, get_worker_flip(spot))
	#spot.hasWorker = true

#func assign_turtle_to_floor(turtle: Node, floor_node: Node) -> void:
	#var free: Array = floor_node.get_free_spots()
	#if free.is_empty():
		#print("No free spots on ", floor_node.floor_id)
		#return
	#assign_turtle_to_spot(turtle, free[0])
	
func _get_half_width(line: AnimatedSprite2D) -> float:
	if line.sprite_frames == null:
		return 0.0
	var tex: Texture2D = line.sprite_frames.get_frame_texture(line.animation, line.frame)
	if tex == null:
		return 0.0
	return tex.get_size().x * abs(line.global_scale.x) / 2.0
