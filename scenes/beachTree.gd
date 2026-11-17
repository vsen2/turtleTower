extends "res://code/workstation.gd"

@export var wait_time: float = 2

@onready var testerTurtle: Sprite2D = $testerTurtle
@onready var tTgarbage: Sprite2D = $testerTurtle/garbage

var cleanupSpeed = 2
var moveSpeed = 2
var beachCenter = 400
func _ready() -> void:
	super()
	add_to_group("job_spots")
	z_index = 10

	refresh()

func refresh() -> void:
	if not is_node_ready():
		return  # _ready() calls this once the child nodes exist
	if unlocked:
		self_modulate = Color.WHITE
	else:
		self_modulate = Color.GRAY

func _process(_delta: float) -> void:
	# (unlocked and hasWorker):
	testerTurtle.global_position.x -= moveSpeed
	if testerTurtle.global_position.x <= beachCenter:
		moveSpeed = 0
		tTgarbage.visible = true
		await get_tree().create_timer(1.0).timeout
		moveSpeed = cleanupSpeed
	elif testerTurtle.global_position.x < -100:
		return
