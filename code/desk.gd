extends "res://code/workstation.gd"

@export var wait_time: float = 2

var customer_timer: Timer

@onready var officeLaptop: Sprite2D = $OfficeLaptop
# Filled in _ready() from the coffee1..coffee6 child nodes
var coffees: Array[Sprite2D] = []

var coffeesUnlocked = 0
var codedTimes = 0
	
func _ready() -> void:
	super()
	add_to_group("job_spots")
	z_index = 10

	customer_timer = Timer.new()
	customer_timer.wait_time = wait_time
	customer_timer.one_shot = false
	customer_timer.autostart = false
	customer_timer.timeout.connect(spawnCode)
	add_child(customer_timer)

	coffees.clear()
	for i in range(1, 7):
		var c := get_node_or_null("coffee%d" % i) as Sprite2D
		if c:
			coffees.append(c)
	refresh()

func refresh() -> void:
	if not is_node_ready():
		return  # _ready() calls this once the child nodes exist
	if unlocked:
		self_modulate = Color.WHITE
		officeLaptop.visible = true
	else:
		self_modulate = Color.GRAY
		officeLaptop.visible = false

	for i in get_parent().upgrade5Multiplier:
		coffees[i].visible = unlocked

func _process(_delta: float) -> void:
	if (unlocked and hasWorker):
		customer_timer.wait_time = get_parent().codeCooldown
		if customer_timer.is_stopped() and hasWorker:
			customer_timer.start()
	
func spawnCode() -> void:
	spawnCodeLabel("code code code! +$", Color(0.0, 0.439, 0.0, 1.0), -120)
	codedTimes += 1
	if codedTimes >= (24/get_parent().upgrade2Multiplier):
		codedTimes = 0
		spawnCodeLabel("CLawde code! +$", Color(1.0, 0.439, 0.0, 1.0), -108)

## Pays out the office's earnings and shows a floating label for it.
func spawnCodeLabel(text: String, color: Color, offsetY: float) -> void:
	var amount: int = get_parent().amountEarned
	GameManager.addCoins(amount)
	GameManager.spawnFloatingLabel(self, text + str(amount), global_position + Vector2(-130, offsetY), color, 15, "code")
