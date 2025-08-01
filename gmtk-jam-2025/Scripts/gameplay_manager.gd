extends Node
class_name GameplayManager

@export var cam: CameraMovement
@export var clickHandler: ClickHandler
@export var MapHolder: Node3D
@export var levelMaps: Array[PackedScene]
@export var mapTransfers: Array[PackedScene]

var currentLevel: int = 0

var connectPoint: Vector2i = Vector2i.ZERO
var prevConnectPoint: Vector2i = Vector2i.ZERO
var currentLevelMapRef: LevelMap
var prevTransferRef: LevelMap
var currentTransferRef: LevelMap

var allActiveTiles: Dictionary
var successTiles: Array[Vector2i]

enum ClickModes {STANDARD, ACTION_TARGET}
var clickMode: ClickModes = ClickModes.STANDARD
var selectedCharacter: GridCharacter

func _ready() -> void:
	currentLevel = LevelSelector.selectedLevel
	clickHandler.click_signal.connect(RecieveClick)
	clickHandler.start_camera_move.connect(cam.OnStartCameraMove)
	clickHandler.stop_camera_move.connect(cam.OnStopCameraMove)
	
	LoadNextLevelMap()
	prevTransferRef = mapTransfers[0].instantiate()
	MapHolder.add_child(prevTransferRef)
	allActiveTiles.merge(prevTransferRef.SetUpTiles())

func _process(delta):
	if(Input.is_action_just_pressed("ui_up")):
		currentLevel += 1
		LoadNextLevelMap()
	for ii in range(0, 9):
		if(Input.is_action_just_pressed("UseAction"+str(ii))):
			StartUsingAction(ii)

func LoadNextLevelMap() -> void:
	if(prevTransferRef != null):
		for ii in prevTransferRef.GetTileArray(prevConnectPoint):
			allActiveTiles.erase(ii)
		prevTransferRef.RemoveFromPlay()
		prevTransferRef = currentTransferRef
	if(currentLevelMapRef != null):
		for ii in currentLevelMapRef.GetTileArray(prevConnectPoint):
			allActiveTiles.erase(ii)
		currentLevelMapRef.RemoveFromPlay()
	
	currentLevelMapRef = levelMaps[currentLevel].instantiate()
	MapHolder.add_child(currentLevelMapRef)
	currentLevelMapRef.global_position = Vector3(connectPoint.x, 0, connectPoint.y)
	currentLevelMapRef.get_node("FallAnims").play("FallEnter")
	allActiveTiles.merge(currentLevelMapRef.SetUpTiles(connectPoint))
	prevConnectPoint = connectPoint
	connectPoint = currentLevelMapRef.GetConnectPoint()
	
	currentTransferRef = mapTransfers[currentLevel + 1].instantiate()
	MapHolder.add_child(currentTransferRef)
	currentTransferRef.global_position = Vector3(connectPoint.x, 0, connectPoint.y)
	currentTransferRef.get_node("FallAnims").play("FallEnter")
	allActiveTiles.merge(currentTransferRef.SetUpTiles(connectPoint))
	successTiles = currentTransferRef.GetTileArray(connectPoint)

func RecieveClick(clickPos: Vector3) -> void:
	var roundedClickPos: Vector2i = Vector2i(round(clickPos.x), round(clickPos.z))
	match(clickMode):
		ClickModes.STANDARD:
			if(allActiveTiles.has(roundedClickPos)):
				print("pressed ", roundedClickPos)
				if(allActiveTiles[roundedClickPos] is GridItem):
					allActiveTiles[roundedClickPos].StandardClickAction(self)
				else:
					UnselectCharacter()
			else:
				UnselectCharacter()
		ClickModes.ACTION_TARGET:
			if(allActiveTiles.has(roundedClickPos)):
				pass
			else:
				UnselectCharacter()

func UnselectCharacter() -> void:
	if(selectedCharacter == null): return
	
	print("unselected character")
	selectedCharacter = null

func StartUsingAction(index: int) -> void:
	if(selectedCharacter == null): return
	var selectedAction: CharacterAction = selectedCharacter.AttemptUseAction(index)
	if(selectedAction == null): return
	
	clickMode = ClickModes.ACTION_TARGET
