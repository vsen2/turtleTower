extends "res://floor.gd"

func _ready() -> void:
	super()

func _on_add_pen_button_pressed() -> void:
	$TurtlePen.visible = true
	$addNewPen2.queue_free()
