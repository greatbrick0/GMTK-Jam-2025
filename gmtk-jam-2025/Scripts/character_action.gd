extends Node
class_name CharacterAction

@export var actionTags: Array[String] = []
@export var actionIcon: Texture
@export var canTargetSelf: bool = false

var actionOwner: GridCharacter

func _ready() -> void:
	actionOwner = get_parent().get_parent()

func GetTileOptions(tilesDict: Dictionary) -> Array[Vector2i]:
	var output: Array[Vector2i] = []
	if(canTargetSelf): output.append(actionOwner.gridPos)
	return output

func AttemptUseAction(actionPos: Vector2i) -> bool:
	if(CanBeUsed()):
		print(actionOwner.usedActions)
		actionOwner.AppendUsedActions(actionTags)
		UseAction(actionPos)
		return true
	else:
		return false

func UseAction(actionPos: Vector2i) -> void:
	pass

func CanBeUsed() -> bool:
	var output: bool = true
	for ii in actionTags:
		output = output and (not ii in actionOwner.usedActions)
	return output
