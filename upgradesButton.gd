extends TextureButton
@export var targetNode: CanvasItem

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if not is_instance_valid(targetNode):
		push_warning("target_node is not assigned or has been freed.")
		return

	targetNode.visible = not targetNode.visible
	print("Toggled %s: visible=%s (visible in tree=%s)" % [
		targetNode.name,
		targetNode.visible,
		targetNode.is_visible_in_tree()
	])
