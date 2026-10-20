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
