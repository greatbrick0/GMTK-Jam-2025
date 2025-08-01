extends GridItem
class_name GridCharacter

@export var team: Enums.Teams = Enums.Teams.PLAYER
@export var characterClass: Enums.CharacterClasses = Enums.CharacterClasses.LOW_POWER
@export var maxHealth: int = 3
@export var health: int = 3
@export var droppedScrapCount: int = 1

signal actions_available_updated(available: bool)
var usedActions: Array = []

func _ready():
	EventBus.start_turn.connect(ResetForTurn)

func StandardClickAction(manager: GameplayManager) -> void:
	if(team == Enums.Teams.PLAYER):
		manager.selectedCharacter = self
		manager.gameHud.GenerateActionButtons(self)

func ResetForTurn(turnTeam: Enums.Teams) -> void:
	if(turnTeam == team):
		usedActions.clear()
		actions_available_updated.emit(true)

func GetActionCount() -> int:
	return $Actions.get_child_count()

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

func AppendUsedActions(appended: Array[String]) -> void:
	usedActions.append_array(appended)
	if(not HasRemainingActions()):
		actions_available_updated.emit(false)
