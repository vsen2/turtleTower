extends Control

# Base class for a tower "floor" (the mine, the store, a pen level, ...).
#
# A floor owns a set of *job spots* -- registers, train tracks, etc. -- that
# turtles can be assigned to, plus its own upgrade stats. Each floor saves and
# loads itself as one self-contained unit, so a floor can later become its own
# .tscn scene without changing the save format: on instantiation it just calls
# loadSaveData() with its slice of the save file.
	
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
	
## Ask the main scene to save the game (shared by every floor).
func requestSave() -> void:
	var main_node = get_tree().current_scene
	if main_node and main_node.has_method("saveGame"):
		main_node.saveGame()

## A random point inside bounds, kept pad pixels away from the edges.
func randomPointIn(bounds: Rect2, pad: float = 24.0) -> Vector2:
	var min_x: float = bounds.position.x + pad
	var max_x: float = max(min_x, bounds.end.x - pad)
	var min_y: float = bounds.position.y + pad
	var max_y: float = max(min_y, bounds.end.y - pad)
	return Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y))

## Every descendant node that belongs to the "job_spots" group, in scene order.
func getSpots() -> Array[Node]:
	var out: Array[Node] = []
	collectSpots(self, out)
	return out

func collectSpots(node: Node, out: Array[Node]) -> void:
	for child in node.get_children():
		if child.is_in_group("job_spots"):
			out.append(child)
		collectSpots(child, out)

## Unlocked spots that don't currently have a turtle working them.
func getFreeSpots() -> Array[Node]:
	var out: Array[Node] = []
	for spot in getSpots():
		if spot.unlocked and not spot.hasWorker:
			out.append(spot)
	return out

# ------------------------------------------------------------ save / load

## This floor's full state, keyed under floor_id by the game manager.
func getSaveData() -> Dictionary:
	var spots_data: Array = []
	for spot in getSpots():
		if spot.has_method("getSpotSaveData"):
			spots_data.append(spot.getSpotSaveData())
	return {
		"floor_id": floor_id,
		"spots": spots_data,
		"upgrades": getUpgradesData(),
	}

## Restore this floor from its slice of the save file.
func loadSaveData(data: Dictionary) -> void:
	var spots: Array[Node] = getSpots()
	var spots_data: Array = data.get("spots", [])
	for i in mini(spots.size(), spots_data.size()):
		var spot: Node = spots[i]
		if spot.has_method("loadSpotSaveData"):
			spot.loadSpotSaveData(spots_data[i])
	loadUpgradesData(data.get("upgrades", {}))

# Override these in floors that have upgrade stats.
func getUpgradesData() -> Dictionary:
	return {}

func loadUpgradesData(_data: Dictionary) -> void:
	pass
