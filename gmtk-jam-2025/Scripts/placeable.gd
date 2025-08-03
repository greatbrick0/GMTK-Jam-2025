extends Node2D
class_name Placeable

@export var scrapCost: int = 0
@export var placedObj: PackedScene
@export_multiline var shortDescription: String = "Pawn"
@export_multiline var fullDescription: String = "Pawn"
var detailStage: int = 0
var currentlyMoving: bool = false
var purchasable: bool = false
var selected: bool = false
var hovered: bool = false
var timeHovered: float = 0.0
var animTime: float = 0.0
@export var animIntensity: float = 10
@export var animSpeed: float = 5
var playerInputBlockers: int = 0

func _process(delta) -> void:
	if(selected):
		animTime += 1.0 * delta
		$Visuals.position = Vector2(sin(animTime * animSpeed) * animIntensity, 0)
	else:
		if(hovered):
			timeHovered += 1.0 * delta
			if(detailStage == 0 and timeHovered > 0.3):
				detailStage = 1
				EventBus.mouse_message.emit(0, shortDescription)
			elif(detailStage == 1 and timeHovered > 1.0):
				detailStage = 2
				EventBus.mouse_message.emit(0, fullDescription)

func AdjustPlayerInputBlockers(adjust: int) -> void:
	playerInputBlockers += adjust

func _on_button_pressed() -> void:
	if(selected):
		selected = false
		EventBus.cancel_character_placing.emit(self)
		$Visuals.position = Vector2.ZERO
		animTime = 0
	else:
		if(playerInputBlockers > 0): return
		if(scrapCost <= 0):
			selected = true
			EventBus.start_character_placing.emit(self)
		else:
			MusicManager.PlayGeneral(2)

func _on_button_mouse_entered() -> void:
	hovered = true

func _on_button_mouse_exited() -> void:
	EventBus.mouse_message.emit(0, "")
	hovered = false
	timeHovered = 0.0
	detailStage = 0
