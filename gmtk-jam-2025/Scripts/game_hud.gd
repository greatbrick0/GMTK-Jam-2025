extends CanvasLayer
class_name GameHud

@export var gameplayManager: GameplayManager
@export var actionButtonObj: PackedScene
var actionButtonsRefs: Array[TextureButton]
@export var actionButtonSprites: Array[Texture]

func EndTurnButtonPressed() -> void:
	print("trying to end turn")

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
