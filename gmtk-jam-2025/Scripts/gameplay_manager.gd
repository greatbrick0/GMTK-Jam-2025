extends Node
class_name GameplayManager

@export var cam: CameraMovement
@export var clickHandler: ClickHandler
@export var gameHud: GameHud
@export var mapHolder: Node3D
@export var levelMaps: Array[PackedScene]
@export var mapTransfers: Array[PackedScene]
@export var tileHighlightObj: PackedScene
var tileHighlightRefs: Array[Node3D]

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
var playerInputBlockers: int = 0
var selectedCharacter: GridCharacter
var selectedAction: CharacterAction
var actionTargetTiles: Array[Vector2i] = []

func _ready() -> void:
	currentLevel = LevelSelector.selectedLevel
	clickHandler.click_signal.connect(RecieveClick)
	clickHandler.start_camera_move.connect(cam.OnStartCameraMove)
	clickHandler.stop_camera_move.connect(cam.OnStopCameraMove)
	EventBus.adjust_player_blockers.connect(AdjustPlayerInputBlockers)
	EventBus.grid_dict_move_item.connect(MoveItemOnGrid)
	EventBus.grid_dict_remove_item.connect(RemoveItemFromGrid)
	
	LoadNextLevelMap()
	prevTransferRef = mapTransfers[0].instantiate() as LevelMap
	mapHolder.add_child(prevTransferRef)
	allActiveTiles.merge(prevTransferRef.SetUpTiles())

func _process(delta):
	if(Input.is_action_just_pressed("ui_up")):
		currentLevel += 1
		LoadNextLevelMap()
	if(playerInputBlockers > 0): return
	for ii in range(0, 9):
		if(Input.is_action_just_pressed("UseAction"+str(ii))):
			StartUsingAction(ii)

func CheckForLevelVictory() -> bool:
	var output: bool = false
	for ii in successTiles:
		if(allActiveTiles[ii] is GridCharacter):
			if(allActiveTiles[ii].team == Enums.Teams.PLAYER and allActiveTiles[ii].characterClass == Enums.CharacterClasses.ROYALTY):
				output = true
	return output

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
	
	currentLevelMapRef = levelMaps[currentLevel].instantiate() as LevelMap
	mapHolder.add_child(currentLevelMapRef)
	currentLevelMapRef.global_position = Vector3(connectPoint.x, 0, connectPoint.y)
	currentLevelMapRef.get_node("FallAnims").play("FallEnter")
	allActiveTiles.merge(currentLevelMapRef.SetUpTiles(connectPoint))
	prevConnectPoint = connectPoint
	connectPoint = currentLevelMapRef.GetConnectPoint()
	
	currentTransferRef = mapTransfers[currentLevel + 1].instantiate() as LevelMap
	mapHolder.add_child(currentTransferRef)
	currentTransferRef.global_position = Vector3(connectPoint.x, 0, connectPoint.y)
	currentTransferRef.get_node("FallAnims").play("FallEnter")
	allActiveTiles.merge(currentTransferRef.SetUpTiles(connectPoint))
	successTiles = currentTransferRef.GetTileArray(connectPoint)

func MoveItemOnGrid(oldPos: Vector2i, newPos: Vector2i, item: GridItem) -> void:
	if(oldPos == newPos): return
	allActiveTiles[newPos] = item
	if(allActiveTiles.has(oldPos)):
		allActiveTiles[oldPos] = null
	print(allActiveTiles[newPos].name)

func RemoveItemFromGrid(oldPos: Vector2i, item: GridItem) -> void:
	if(allActiveTiles.has(oldPos)):
		allActiveTiles[oldPos] = null

func AdjustPlayerInputBlockers(adjust: int) -> void:
	playerInputBlockers += adjust
	print("blockers ", playerInputBlockers)

func RecieveClick(clickPos: Vector3) -> void:
	if(playerInputBlockers > 0): return
	
	var roundedClickPos: Vector2i = Vector2i(round(clickPos.x), round(clickPos.z))
	match(clickMode):
		ClickModes.STANDARD:
			if(allActiveTiles.has(roundedClickPos)):
				UnselectCharacter()
				print("standard pressed ", roundedClickPos)
				if(allActiveTiles[roundedClickPos] is GridItem):
					allActiveTiles[roundedClickPos].StandardClickAction(self)
			else:
				UnselectCharacter()
		ClickModes.ACTION_TARGET:
			if(allActiveTiles.has(roundedClickPos)):
				if(roundedClickPos in actionTargetTiles):
					FinishUsingAction(roundedClickPos)
				else:
					MusicManager.PlayGeneral(2)
			else:
				UnselectCharacter()

func UnselectAction() -> void:
	if(selectedAction == null): return
	
	print("unselected action")
	selectedAction = null
	actionTargetTiles.clear()
	for ii in tileHighlightRefs:
		ii.call_deferred("queue_free")
	tileHighlightRefs.clear()
	
	clickMode = ClickModes.STANDARD

func UnselectCharacter(_val1 = null, _val2 = null) -> void:
	if(selectedCharacter == null): return
	
	selectedCharacter.character_died.disconnect(UnselectCharacter)
	gameHud.RemoveActionButtons()
	selectedCharacter = null
	UnselectAction()

func StartUsingAction(index: int) -> void:
	UnselectAction()
	if(selectedCharacter == null): return
	selectedAction = selectedCharacter.AttemptGetAction(index)
	if(selectedAction == null): return
	if(not selectedAction.CanBeUsed()): return
	
	clickMode = ClickModes.ACTION_TARGET
	actionTargetTiles = selectedAction.GetTileOptions(allActiveTiles)
	for ii in range(len(actionTargetTiles)):
		tileHighlightRefs.append(tileHighlightObj.instantiate() as Node3D)
		mapHolder.add_child(tileHighlightRefs[-1])
		tileHighlightRefs[-1].global_position = Vector3(actionTargetTiles[ii].x, 0, actionTargetTiles[ii].y)

func FinishUsingAction(actionPos: Vector2i) -> void:
	selectedAction.AttemptUseAction(actionPos, self)
	UnselectAction()
