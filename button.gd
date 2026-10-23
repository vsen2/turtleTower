extends Button

func _on_button_pressed() -> void:
	var error = get_tree().change_scene_to_file("res://main.tscn")
	if error != OK:
		print("Failed to load scene: ", error)
	
	
