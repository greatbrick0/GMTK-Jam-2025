extends Node3D
class_name LevelMap

@export var blockerIndexes: Array[int]

func SetUpTiles() -> Dictionary:
	var output: Dictionary
	for ii in $GridMap.get_used_cells():
		if($GridMap.get_cell_item(ii) in blockerIndexes):
			output[Vector2i(ii.x, ii.z)] = 1
		else:
			output[Vector2i(ii.x, ii.z)] = null
	return output

func GetTileArray() -> Array[Vector2i]:
	var output: Array[Vector2i]
	for ii in $GridMap.get_used_cells():
		output.append(Vector2i(ii.x, ii.z))
	return output

func RemoveFromPlay() -> void:
	pass
