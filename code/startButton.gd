extends TextureButton

func onButtonPressed() -> void:
	var error = get_tree().change_scene_to_file("res://scenes/main.tscn")
	if error != OK:
		print("Failed to load scene: ", error)
	
	
