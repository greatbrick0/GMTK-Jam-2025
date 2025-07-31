extends Node

@export var cam: CameraMovement
@export var clickHandler: ClickHandler
@export var MapHolder: Node3D
@export var levelMaps: Array[PackedScene]
@export var mapTransfers: Array[PackedScene]

var currentLevel: int = 0

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

func LoadNextLevelMap() -> void:
	if(prevTransferRef != null):
		prevTransferRef.RemoveFromPlay()
		prevTransferRef = currentTransferRef
	if(currentLevelMapRef != null):
		currentLevelMapRef.RemoveFromPlay()
	
	currentLevelMapRef = levelMaps[currentLevel].instantiate()
	MapHolder.add_child(currentLevelMapRef)
	currentTransferRef = mapTransfers[currentLevel + 1].instantiate()
	MapHolder.add_child(currentTransferRef)
	successTiles = currentTransferRef.GetTileArray()

func RecieveClick(clickPos: Vector3) -> void:
	var roundedClickPos: Vector2i = Vector2i(round(clickPos.x), round(clickPos.z))
	print("pressed ", roundedClickPos)
