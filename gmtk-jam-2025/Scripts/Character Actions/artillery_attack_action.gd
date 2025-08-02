extends CharacterAction
class_name ArtilleryAttackAction

@export var damage: int = 1
@export var selfDamage: int = 0
@export var directions: Array[Vector2i]
@export var ranges: Array[Vector2i]

func GetTileOptions(tilesDict: Dictionary) -> Array[Vector2i]:
	var output: Array[Vector2i] = []
	if(canTargetSelf): output.append(actionOwner.gridPos)
	
	var tile: Vector2i
	for ii in range(len(directions)):
		for jj in range(ranges[ii].x, ranges[ii].y + 1):
			tile = actionOwner.gridPos + (directions[ii] * jj)
			if(tilesDict.has(tile) and (tilesDict[tile] == null or tilesDict[tile] is GridCharacter)):
				output.append(actionOwner.gridPos + (directions[ii] * jj))
	return output

func UseAction(actionPos: Vector2i, gameplayManager: GameplayManager) -> void:
	action_use_success.emit()
	actionOwner.RotateTowards(actionPos)
	actionOwner.TakeSelfDamage(selfDamage)
	if(gameplayManager.allActiveTiles[actionPos] is GridCharacter):
		gameplayManager.allActiveTiles[actionPos].TakeDamage(damage, 0.2)
