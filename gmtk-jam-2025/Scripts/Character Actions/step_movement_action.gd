extends CharacterAction
class_name StepMovementAction

@export var directions: Array[Vector2i]
@export var stepRange: int
var chainsOfMovement: Dictionary[Vector2i, Vector2i]

func GetTileOptions(tilesDict: Dictionary) -> Array[Vector2i]:
	chainsOfMovement.clear()
	var output: Array[Vector2i] = []
	if(canTargetSelf): output.append(actionOwner.gridPos)
	
	var tile: Vector2i
	var outerTiles: Array[Vector2i] = [actionOwner.gridPos]
	
	for ii in range(stepRange):
		var newOuterTiles: Array[Vector2i] = []
		for jj in outerTiles:
			for kk in directions:
				tile = jj + kk
				if(tilesDict.has(tile) and tilesDict[tile] == null and not output.has(tile) and not newOuterTiles.has(tile)):
					newOuterTiles.append(tile)
					chainsOfMovement[tile] = jj
					output.append(tile)
		outerTiles = newOuterTiles
	
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
