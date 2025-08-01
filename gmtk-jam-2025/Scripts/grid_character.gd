extends GridItem
class_name GridCharacter

@export var team: Enums.Teams = Enums.Teams.PLAYER
@export var characterClass: Enums.CharacterClasses = Enums.CharacterClasses.LOW_POWER
@export var maxHealth: int = 3
@export var health: int = 3
@export var droppedScrapCount: int = 1
var usedActions: Array = []

func _ready():
	EventBus.start_turn.connect(ResetForTurn)

func StandardClickAction(manager: GameplayManager) -> void:
	if(team == Enums.Teams.PLAYER):
		manager.selectedCharacter = self
		print($Actions.get_children())

func ResetForTurn(turnTeam: Enums.Teams) -> void:
	if(turnTeam == team):
		usedActions.clear()

func AttemptGetAction(index: int) -> CharacterAction:
	if($Actions.get_child_count() > index):
		print(index)
		return $Actions.get_child(index)
	else:
		return null

func HasRemainingActions() -> bool:
	var output: bool = false
	for ii in $Actions.get_children():
		output = output or ii.CanBeUsed()
	return output
