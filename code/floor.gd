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

func _ready() -> void:
	add_to_group("floors")
	if floor_id.is_empty():
		floor_id = String(name).to_snake_case()

# ------------------------------------------------------------------ spots

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