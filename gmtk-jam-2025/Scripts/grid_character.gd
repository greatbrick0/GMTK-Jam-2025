extends GridItem
class_name GridCharacter

@export var team: Enums.Teams = Enums.Teams.PLAYER
@export var maxHealth: int = 3
@export var health: int = 3
@export var droppedScrapCount: int = 1
var usedActions: Array = []

func _ready():
	EventBus.start_turn.connect(ResetForTurn)

func ResetForTurn(turnTeam: Enums.Teams) -> void:
	if(turnTeam == team):
		usedActions.clear()
