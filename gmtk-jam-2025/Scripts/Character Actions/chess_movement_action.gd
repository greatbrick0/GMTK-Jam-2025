extends CharacterAction
class_name ChessMovementAction

@export var directions: Array[Vector2i]
@export var ranges: Array[int]
var chainsOfMovement: Dictionary[Vector2i, Vector2i]

func GetTileOptions(tilesDict: Dictionary) -> Array[Vector2i]:
	chainsOfMovement.clear()
	var output: Array[Vector2i] = []
	if(canTargetSelf): output.append(actionOwner.gridPos)
	
	var tile: Vector2i
	for ii in range(len(directions)):
		for jj in range(1, ranges[ii] + 1):
			tile = actionOwner.gridPos + (directions[ii] * jj)
			if(tilesDict.has(tile) and tilesDict[tile] == null):
				chainsOfMovement[actionOwner.gridPos + (directions[ii] * jj)] = actionOwner.gridPos + (directions[ii] * (jj - 1))
				output.append(actionOwner.gridPos + (directions[ii] * jj))
			else:
				break
	return output

func UseAction(actionPos: Vector2i, gameplayManager: GameplayManager) -> void:
	action_use_success.emit()
	EventBus.adjust_player_blockers.emit(1)
	if(chainsOfMovement.has(actionPos)):
		await RepeatAcrossTiles(CreateChain(actionPos), 0.1, actionOwner.MoveOnGrid)
	actionOwner.MoveOnGrid(actionPos)
	await get_tree().create_timer(0.1).timeout
	EventBus.adjust_player_blockers.emit(-1)

func CreateChain(originPos: Vector2i) -> Array[Vector2i]:
	var chain: Array[Vector2i] = []
	var link: Vector2i = originPos
	var depth: int = 0
	while(depth < 20 and chainsOfMovement.has(link)):
		depth += 1
		chain.append(link)
		link = chainsOfMovement[link]
	chain.reverse()
	return chain
