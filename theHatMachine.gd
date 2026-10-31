extends Control

@onready var spinner: TextureButton = $spinner
@onready var prizeBall: TextureButton = $HatMachinePrizeBall

var pressedAmount = 0
var isHolding: bool = false
var prize: bool = false

@onready var balls: Array[Sprite2D] = [
	$HatMachineBall,
	$HatMachineBall2,
	$HatMachineBall3,
	$HatMachineBall4,
	$HatMachineBall5,
	$HatMachineBall6,
	$HatMachineBall7
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for ball in balls:
		ball.rotation_degrees = randi_range(1, 360)
	spinner.rotation_degrees = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isHolding and not prize:
		spinner.rotation_degrees += 1
		for ball in balls:
			ball.rotation_degrees +=1
		if spinner.rotation_degrees > 355:
			spinner.rotation_degrees = 0
			prize = true
		print(spinner.rotation_degrees)
		
func _on_spinner_button_down() -> void:
	isHolding = true
func _on_spinner_button_up() -> void:
	isHolding = false
		
func _on_hat_machine_prize_ball_pressed() -> void:
	prizeBall.visible = false
	#add hat to thingy
