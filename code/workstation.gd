extends Sprite2D

@export var baseCost: int 
@onready var unlockCostMultiplier = get_parent().getDifficulty()
@onready var buttonOffset = get_parent().getButtonOffset()

@export var spot_id: String = ""
@export var unlocked: bool = false
@export var hasWorker: bool = false
	
var unlock_button: TextureButton
var unlockCost
var unlockCostLabel: Label
	
const BUTTON_NORMAL_TEXTURE = preload("res://assets/plusButtonWhite.png")
const BUTTON_HOVER_TEXTURE = preload("res://assets/plusButtonGrey.png")

# Called when the node enters the scene tree for the first time.
func startingStuff() -> void:
	unlockCost = (baseCost*unlockCostMultiplier)
	print("unlock cost multi" + str(unlockCostMultiplier))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_unlock_button() -> void:
	unlock_button = TextureButton.new()
	unlock_button.texture_normal = BUTTON_NORMAL_TEXTURE
	unlock_button.texture_hover = BUTTON_HOVER_TEXTURE
	unlock_button.z_index = 19
	unlock_button.top_level = true
	unlock_button.ignore_texture_size = true
	unlock_button.stretch_mode = TextureButton.STRETCH_SCALE
	unlock_button.custom_minimum_size = Vector2(100, 100)
	unlock_button.size = Vector2(100, 100)
	add_child(unlock_button)
	print(buttonOffset)
	unlock_button.global_position = (global_position + buttonOffset)
	#print("globalpos" + str(global_position) + " " + str(buttonOffset))
	
	unlock_button.pressed.connect(_on_spot_plus_pressed)
	
func _on_spot_plus_pressed() -> void:
	if is_instance_valid(unlock_button) and GameManager.spend_coins(unlockCost):
		unlock_button.queue_free()
		unlock_button = null
		unlockCostLabel.queue_free()
		unlockCostLabel = null
		unlocked = true
		modulate = Color.WHITE
		var main: Node = get_tree().current_scene
		if main and main.has_method("begin_spot_assignment"):
			main.begin_spot_assignment(self)
		
func initialize_from_save(data: Dictionary) -> void:
	load_spot_save_data(data)
	update_ui_state()
		
func update_ui_state() -> void:
	if unlocked:
		modulate = Color.WHITE
		if is_instance_valid(unlock_button):
			unlock_button.queue_free()
			unlock_button = null
		if is_instance_valid(unlockCostLabel):
			unlockCostLabel.queue_free()
			unlockCostLabel = null
	else:
		if not is_instance_valid(unlock_button):
			create_unlock_button()
		if not is_instance_valid(unlockCostLabel):
			createUnlockCostLabel()
			
func createUnlockCostLabel() -> void:
	unlockCostLabel = Label.new()
	unlockCostLabel.name = "unlockCostLabel"
	unlockCostLabel.text = "Cost: %d" % unlockCost
	unlockCostLabel.top_level = true
	unlockCostLabel.global_position.x = global_position.x + buttonOffset.x - 7
	unlockCostLabel.global_position.y = global_position.y + buttonOffset.y - 40
	unlockCostLabel.z_index = 100
	unlockCostLabel.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0, 1.0)) # color
	unlockCostLabel.add_theme_font_size_override("font_size", 25)

	unlock_button.add_child(unlockCostLabel)
	
func get_spot_save_data() -> Dictionary:
	return {"spot_id": spot_id, "unlocked": unlocked, "has_worker": hasWorker}

func load_spot_save_data(data: Dictionary) -> void:
	unlocked = bool(data.get("unlocked", false))
	hasWorker = bool(data.get("has_worker", false))
