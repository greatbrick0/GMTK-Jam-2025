extends Node

var gameManager: GameplayManager
@export var myTeam: Enums.Teams = Enums.Teams.ENEMY

func _ready():
	gameManager = get_parent()
	EventBus.start_turn.connect(TurnStarted)

func TurnStarted(team: Enums.Teams) -> void:
	if(team == myTeam):
		StartUsingCharacters()

func StartUsingCharacters() -> void:
	await get_tree().create_timer(0.2).timeout
	if(len(gameManager.teamDatas[myTeam].teamMembers) == 0):
		print("no enemies")
		gameManager.AttemptToEndTurn()
		return
	for ii in gameManager.teamDatas[myTeam].teamMembers:
		while ii != null and ii.HasRemainingActions():
			var selectedAction: CharacterAction = ii.GetFirstRemainingAction()
			var targets: Array[Vector2i] = selectedAction.GetTileOptions(gameManager.allActiveTiles)
			var choice: Vector2i = ChoosePlayerTile(targets, gameManager.allActiveTiles)
			if(choice == Vector2i.MAX):
				choice = ChooseClosestTile(SelectRandomPlayerUnit(), targets)
				if(choice == Vector2i.MAX):
					choice = targets.pick_random()
			print(ii.name + " is using action " + selectedAction.name)
			await selectedAction.AttemptUseAction(choice, gameManager)
			await get_tree().create_timer(0.2).timeout
	gameManager.AttemptToEndTurn()

func ChoosePlayerTile(targets: Array[Vector2i], dict: Dictionary) -> Vector2i:
	for ii in targets:
		if(dict[ii] is GridCharacter):
			if(dict[ii].team != myTeam):
				return ii
	return Vector2i.MAX

func ChooseClosestTile(want: Vector2i, targets: Array[Vector2i]) -> Vector2i:
	var output: Vector2i = Vector2i.MAX
	var dist: float = INF
	for ii in targets:
		if(ii.distance_squared_to(want) < dist):
			dist = ii.distance_squared_to(want)
			output = ii
	return output

func SelectRandomPlayerUnit() -> Vector2i:
	var output: Vector2i
	var random: int = randi_range(0, len(gameManager.teamDatas[Enums.Teams.PLAYER].teamMembers) - 1)
	output = gameManager.teamDatas[Enums.Teams.PLAYER].teamMembers[random].gridPos
	return output
