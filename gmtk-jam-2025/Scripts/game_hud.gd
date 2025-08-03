extends CanvasLayer
class_name GameHud

@export var gameplayManager: GameplayManager
@export var actionButtonObj: PackedScene
var actionButtonsRefs: Array[TextureButton]
@export var actionButtonSprites: Array[Texture]

@export var descriptionLabel: Label
@export var playerScrapCount: int = 0
@export var scrapCountLabel: Label

@export var remainingTurns: int = 10
@export var remainingTurnsLabel: Label

var playerInputBlockers: int = 0

func _ready() -> void:
	EventBus.adjust_player_blockers.connect(AdjustPlayerInputBlockers)
	EventBus.add_scrap.connect(AddScrap)
	EventBus.mouse_message.connect(DisplayDescription)
	EventBus.end_turn.connect(SubtractRemainingTurns)
	EventBus.end_turn.connect(func(team: Enums.Teams): DisplayDescription(0, ""))

func AdjustPlayerInputBlockers(adjust: int) -> void:
	playerInputBlockers += adjust

func SetRemainingTurns(newTurns: int) -> void:
	remainingTurns -= 1
	remainingTurnsLabel.text = "Remaining Turns: " + str(remainingTurns)

func SubtractRemainingTurns(team: Enums.Teams) -> void:
	if(team == Enums.Teams.PLAYER):
		remainingTurns -= 1
		remainingTurnsLabel.text = "Remaining Turns: " + str(remainingTurns)
		await get_tree().create_timer(1.0).timeout
		if(remainingTurns < 0):
			print("you lose to no remaining turns")
			get_tree().change_scene_to_file("res://Scenes/Lose_Screen.tscn")

func DisplayDescription(channel: int, message: String) -> void:
	if(channel == 0):
		descriptionLabel.visible = message != ""
		descriptionLabel.text = message

func AddScrap(amount: int) -> void:
	playerScrapCount += amount
	scrapCountLabel.text = str(playerScrapCount)

func EndTurnButtonPressed() -> void:
	if(gameplayManager.currentTeam == Enums.Teams.PLAYER):
		if(playerInputBlockers > 0): return
		gameplayManager.AttemptToEndTurn()

func GenerateActionButtons(characterRef: GridCharacter):
	RemoveActionButtons()
	if(characterRef.GetActionCount() == 0): return
	
	for ii in range(characterRef.GetActionCount()):
		actionButtonsRefs.append(actionButtonObj.instantiate() as TextureButton)
		$Control/ActionButtonHolder.add_child(actionButtonsRefs[-1])
		if(characterRef.GetActionCount() == 1):
			SetSprite(actionButtonsRefs[-1], actionButtonSprites[1])
		else:
			if(ii == 0):
				SetSprite(actionButtonsRefs[-1], actionButtonSprites[2])
			elif(ii == characterRef.GetActionCount() - 1):
				SetSprite(actionButtonsRefs[-1], actionButtonSprites[3])
		actionButtonsRefs[-1].pressed.connect(gameplayManager.StartUsingAction.bind(ii))
		actionButtonsRefs[-1].get_node("MaskingTexture/TextureRect").texture = characterRef.AttemptGetAction(ii).actionIcon

func RemoveActionButtons():
	for ii in actionButtonsRefs:
		ii.call_deferred("queue_free")
	actionButtonsRefs.clear()

func SetSprite(textureButton: TextureButton, sprite: Texture):
	textureButton.texture_normal = sprite
	textureButton.texture_pressed = sprite
	textureButton.texture_hover = sprite
	textureButton.texture_disabled = sprite
	textureButton.texture_focused = sprite
