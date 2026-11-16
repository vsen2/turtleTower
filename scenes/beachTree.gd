extends "res://code/workstation.gd"

@export var wait_time: float = 2

var customer_timer: Timer
var timer_label: Label

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

func _on_spot_plus_pressed() -> void:
	var was_unlocked: bool = unlocked
	super()
	refresh()
	# Save right away so the unlock isn't lost if no turtle gets assigned
	if unlocked and not was_unlocked:
		var main: Node = get_tree().current_scene
		if main and main.has_method("save_game"):
			main.save_game()
		
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
	

func get_spot_save_data() -> Dictionary:
	return {"spot_id": spot_id, "unlocked": unlocked, "has_worker": hasWorker}

func load_spot_save_data(data: Dictionary) -> void:
	unlocked = bool(data.get("unlocked", false))
	hasWorker = bool(data.get("has_worker", false))
	if unlocked:
		modulate = Color.WHITE
		if is_instance_valid(unlock_button):
			unlock_button.queue_free()
			unlock_button = null
	elif not is_instance_valid(unlock_button):
		create_unlock_button()
