extends GridItem
class_name GridCharacter

@export var maxHealth: int = 3
@export var health: int = 3
@export var droppedScrapCount: int = 1
var usedActions: Array = []

func _ready():
	pass

func ResetForTurn() -> void:
	usedActions.clear()
