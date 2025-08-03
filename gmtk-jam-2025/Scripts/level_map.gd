extends Node3D
class_name LevelMap

@export var blockerIndexes: Array[int]

func SetUpTiles(offset: Vector2i = Vector2i.ZERO) -> Dictionary:
	var output: Dictionary
	for ii in $GridMap.get_used_cells():
		if($GridMap.get_cell_item(ii) in blockerIndexes):
			output[Vector2i(ii.x, ii.z) + offset] = 1
		else:
			output[Vector2i(ii.x, ii.z) + offset] = null
	return output

func GetTileArray(offset: Vector2i = Vector2i.ZERO) -> Array[Vector2i]:
	var output: Array[Vector2i]
	for ii in $GridMap.get_used_cells():
		output.append(Vector2i(ii.x, ii.z) + offset)
	return output

func GetConnectPoint() -> Vector2i:
	return Vector2i(round($ConnectPoint.global_position.x), round($ConnectPoint.global_position.z))

func RemoveFromPlay() -> void:
	for ii in $GridItemHolder.get_children():
		if(ii is GridCharacter):
			if(ii.team == Enums.Teams.PLAYER):
				EventBus.add_scrap.emit(ii.droppedScrapCount)
		ii.RemoveFromPlay()
	$FallAnims.play("FallExit")
