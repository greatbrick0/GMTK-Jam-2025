extends Node

var gameManager: GameplayManager

func _ready():
	gameManager = get_parent()
	EventBus.start_turn.connect(TurnStarted)

func TurnStarted(team: Enums.Teams) -> void:
	if(team == Enums.Teams.ENEMY):
		StartUsingCharacters()

func StartUsingCharacters() -> void:
	gameManager.AttemptToEndTurn()
