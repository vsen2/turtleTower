extends TextureButton

@export var targetNode: CanvasItem
@export var turtleUI: Control

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	targetNode.modulate = Color.WHITE
	if turtleUI:
		turtleUI.visible = true
	targetNode.set("unlocked", true)
	visible = false

	# Persist the purchase so it survives a restart.
	var game_root: Node = get_tree().current_scene
	if game_root and game_root.has_method("save_game"):
		game_root.save_game()
