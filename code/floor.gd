extends Control

# Base class for a tower "floor" (the mine, the store, a pen level, ...).
#
# A floor owns a set of *job spots* -- registers, train tracks, etc. -- that
# turtles can be assigned to, plus its own upgrade stats. Each floor saves and
# loads itself as one self-contained unit, so a floor can later become its own
# .tscn scene without changing the save format: on instantiation it just calls
# load_save_data() with its slice of the save file.
	
## Stable id used as this floor's key in the save file. Defaults to the node
## name (snake_cased) if left blank, so it still works out of the box.
@export var floor_id: String = ""
@export var worker_offset: Vector2 = Vector2(-200, -60)
@export var worker_flip: bool = false

@export var buttonOffset: Vector2

##TEMPORARY
@export var floorDifficulty: int = 1 ## priceChanging 

func _ready() -> void:
	add_to_group("floors")
	if floor_id.is_empty():
		floor_id = String(name).to_snake_case()
		
func getDifficulty() -> int:
	return floorDifficulty
	
func getButtonOffset() -> Vector2:
	return buttonOffset
	
func new()-> void:
	return
	
	
func spawn_notEnoughCoins_label() -> void:
	var label: Label = Label.new()
	label.name = "NotEnoughCoinsLabel"
	label.text = "Not Enough Hat Coins"
	label.top_level = true
	label.global_position = Vector2(450, -450)
	label.z_index = 30
	label.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0, 1.0)) # color
	label.add_theme_font_size_override("font_size", 25)

	add_child(label)
	# Float upward and fade out, then delete itself.
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(label, "global_position:y", label.global_position.y - 20.0, .5)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.chain().tween_callback(label.queue_free)

## Every descendant node that belongs to the "job_spots" group, in scene order.
func get_spots() -> Array[Node]:
	var out: Array[Node] = []
	_collect_spots(self, out)
	return out

func _collect_spots(node: Node, out: Array[Node]) -> void:
	for child in node.get_children():
		if child.is_in_group("job_spots"):
			out.append(child)
		_collect_spots(child, out)

## Unlocked spots that don't currently have a turtle working them.
func get_free_spots() -> Array[Node]:
	var out: Array[Node] = []
	for spot in get_spots():
		if spot.unlocked and not spot.hasWorker:
			out.append(spot)
	return out

# ------------------------------------------------------------ save / load

## This floor's full state, keyed under floor_id by the game manager.
func get_save_data() -> Dictionary:
	var spots_data: Array = []
	for spot in get_spots():
		if spot.has_method("get_spot_save_data"):
			spots_data.append(spot.get_spot_save_data())
	return {
		"floor_id": floor_id,
		"spots": spots_data,
		"upgrades": get_upgrades_data(),
	}

## Restore this floor from its slice of the save file.
func load_save_data(data: Dictionary) -> void:
	var spots: Array[Node] = get_spots()
	var spots_data: Array = data.get("spots", [])
	for i in mini(spots.size(), spots_data.size()):
		var spot: Node = spots[i]
		if spot.has_method("load_spot_save_data"):
			spot.load_spot_save_data(spots_data[i])
	load_upgrades_data(data.get("upgrades", {}))

# Override these in floors that have upgrade stats.
func get_upgrades_data() -> Dictionary:
	return {}

func load_upgrades_data(_data: Dictionary) -> void:
	pass
