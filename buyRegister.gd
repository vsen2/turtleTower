extends TextureButton
@export var targetNode: CanvasItem
@export var turtleUI: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_pressed() -> void:
	if true:
		targetNode.modulate = "ffffff"
		if turtleUI:
			turtleUI.visible = true
		targetNode.set("unlocked", true)
		visible = false
