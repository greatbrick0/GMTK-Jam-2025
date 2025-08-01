extends CharacterAction
class_name ChessMovementAction

@export var directions: Array[Vector2i]
@export var ranges: Array[int]

func GetTileOptions(tilesDict: Dictionary) -> Array[Vector2i]:
	var output: Array[Vector2i] = []
	if(canTargetSelf): output.append(actionOwner.gridPos)
	
	var tile: Vector2i
	for ii in range(len(directions)):
		for jj in range(1, ranges[ii] + 1):
			tile = actionOwner.gridPos + (directions[ii] * jj)
			if(tilesDict.has(tile) and tilesDict[tile] == null):
				output.append(actionOwner.gridPos + (directions[ii] * jj))
			else:
				break
	return output

func UseAction(actionPos: Vector2i) -> void:
	actionOwner.MoveOnGrid(actionPos)
	print("used action")
