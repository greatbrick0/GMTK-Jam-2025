extends Node
class_name CharacterAction

@export var actionTags: Array[String] = []
@export var actionIcon: Texture
@export var canTargetSelf: bool = false

signal action_use_success()
var actionOwner: GridCharacter

func _ready() -> void:
	actionOwner = get_parent().get_parent()

func GetTileOptions(tilesDict: Dictionary) -> Array[Vector2i]:
	var output: Array[Vector2i] = []
	if(canTargetSelf): output.append(actionOwner.gridPos)
	return output

func AttemptUseAction(actionPos: Vector2i, gameplayManager: GameplayManager) -> bool:
	if(CanBeUsed()):
		actionOwner.AppendUsedActions(actionTags)
		UseAction(actionPos, gameplayManager)
		return true
	else:
		return false

func UseAction(actionPos: Vector2i, gameplayManager: GameplayManager) -> void:
	pass

func CanBeUsed() -> bool:
	var output: bool = true
	for ii in actionTags:
		output = output and (not ii in actionOwner.usedActions)
	return output

func RepeatAcrossTiles(tileArray: Array[Vector2i], spacing: float, function: Callable) -> void:
	EventBus.adjust_player_blockers.emit(1)
	for ii in tileArray:
		function.call(ii)
		await get_tree().create_timer(spacing).timeout
	EventBus.adjust_player_blockers.emit(-1)
