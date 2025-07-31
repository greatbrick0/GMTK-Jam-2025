extends Node

@export var cam: CameraMovement
@export var clickHandler: ClickHandler
@export var MapHolder: Node3D
@export var levelMaps: Array[PackedScene]
@export var mapTransfers: Array[PackedScene]

var currentLevel: int = 0

var connectPoint: Vector2i = Vector2i.ZERO
var currentLevelMapRef: LevelMap
var prevTransferRef: LevelMap
var currentTransferRef: LevelMap

var allActiveTiles: Dictionary
var successTiles: Array[Vector2i]

func _ready() -> void:
	currentLevel = LevelSelector.selectedLevel
	clickHandler.click_signal.connect(RecieveClick)
	clickHandler.start_camera_move.connect(cam.OnStartCameraMove)
	clickHandler.stop_camera_move.connect(cam.OnStopCameraMove)
	
	LoadNextLevelMap()
	prevTransferRef = mapTransfers[0].instantiate()
	MapHolder.add_child(prevTransferRef)

func _process(delta):
	if(Input.is_action_just_released("ui_up")):
		currentLevel += 1
		LoadNextLevelMap()

func LoadNextLevelMap() -> void:
	if(prevTransferRef != null):
		prevTransferRef.RemoveFromPlay()
		prevTransferRef = currentTransferRef
	if(currentLevelMapRef != null):
		currentLevelMapRef.RemoveFromPlay()
	
	currentLevelMapRef = levelMaps[currentLevel].instantiate()
	MapHolder.add_child(currentLevelMapRef)
	currentLevelMapRef.global_position = Vector3(connectPoint.x, 0, connectPoint.y)
	currentLevelMapRef.get_node("FallAnims").play("FallEnter")
	connectPoint = currentLevelMapRef.GetConnectPoint()
	
	currentTransferRef = mapTransfers[currentLevel + 1].instantiate()
	MapHolder.add_child(currentTransferRef)
	currentTransferRef.global_position = Vector3(connectPoint.x, 0, connectPoint.y)
	currentTransferRef.get_node("FallAnims").play("FallEnter")
	successTiles = currentTransferRef.GetTileArray(connectPoint)

func RecieveClick(clickPos: Vector3) -> void:
	var roundedClickPos: Vector2i = Vector2i(round(clickPos.x), round(clickPos.z))
	print("pressed ", roundedClickPos)
	if(roundedClickPos in successTiles):
		print("success tile")
