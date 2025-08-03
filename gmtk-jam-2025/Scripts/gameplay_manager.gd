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
var teamDatas: Dictionary[Enums.Teams, TeamData] = {
	Enums.Teams.PLAYER: TeamData.new(Enums.Teams.PLAYER),
	Enums.Teams.ENEMY: TeamData.new(Enums.Teams.ENEMY),
}

enum ClickModes {STANDARD, ACTION_TARGET, PLACING_TARGET}
var clickMode: ClickModes = ClickModes.STANDARD
var playerInputBlockers: int = 0
var selectedCharacter: GridCharacter
var selectedAction: CharacterAction
var actionTargetTiles: Array[Vector2i] = []
var selectedPlaceable: Placeable

func _ready() -> void:
	currentLevel = LevelSelector.selectedLevel
	clickHandler.click_signal.connect(RecieveClick)
	clickHandler.start_camera_move.connect(cam.OnStartCameraMove)
	clickHandler.stop_camera_move.connect(cam.OnStopCameraMove)
	EventBus.adjust_player_blockers.connect(AdjustPlayerInputBlockers)
	EventBus.grid_dict_add_item.connect(AddItemToGrid)
	EventBus.grid_dict_move_item.connect(MoveItemOnGrid)
	EventBus.grid_dict_remove_item.connect(RemoveItemFromGrid)
	EventBus.start_character_placing.connect(StartCharacterPlacing)
	EventBus.cancel_character_placing.connect(CancelCharacterPlacing)
	
	LoadNextLevelMap()
	prevTransferRef = mapTransfers[0].instantiate() as LevelMap
	mapHolder.add_child(prevTransferRef)
	allActiveTiles.merge(prevTransferRef.SetUpTiles())

func _process(delta):
	if(Input.is_action_just_pressed("ui_up")):
		currentLevel += 1
		TransferGridItems()
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

func TransferGridItems() -> void:
	for ii in successTiles:
		if(allActiveTiles[ii] is Node3D):
			allActiveTiles[ii].reparent(currentTransferRef.get_node("GridItemHolder"))

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

func AddItemToGrid(newPos: Vector2i, item: GridItem) -> void:
	print("added item " + item.name + " at " + str(newPos))
	allActiveTiles[newPos] = item

func MoveItemOnGrid(oldPos: Vector2i, newPos: Vector2i, item: GridItem) -> void:
	if(oldPos == newPos): return
	AddItemToGrid(newPos, item)
	RemoveItemFromGrid(oldPos, item)

func RemoveItemFromGrid(oldPos: Vector2i, item: GridItem) -> void:
	if(allActiveTiles.has(oldPos)):
		allActiveTiles[oldPos] = null

func AdjustPlayerInputBlockers(adjust: int) -> void:
	playerInputBlockers += adjust

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
		ClickModes.PLACING_TARGET:
			if(allActiveTiles.has(roundedClickPos)):
				if(roundedClickPos in actionTargetTiles):
					FinishCharacterPlacing(selectedPlaceable)
				else:
					MusicManager.PlayGeneral(2)

func GenerateTileHighlights(tiles: Array[Vector2i], colour: Color = Color.CYAN) -> void:
	actionTargetTiles = tiles
	for ii in range(len(actionTargetTiles)):
		tileHighlightRefs.append(tileHighlightObj.instantiate() as Node3D)
		mapHolder.add_child(tileHighlightRefs[-1])
		tileHighlightRefs[-1].global_position = Vector3(actionTargetTiles[ii].x, 0, actionTargetTiles[ii].y)
		tileHighlightRefs[-1].get_node("Tileindication").material_override.next_pass.set_shader_parameter("baseColor", colour)

func DeleteTileHighlights() -> void:
	actionTargetTiles.clear()
	for ii in tileHighlightRefs:
		ii.call_deferred("queue_free")
	tileHighlightRefs.clear()

func UnselectAction() -> void:
	if(selectedAction == null): return
	
	print("unselected action")
	selectedAction = null
	DeleteTileHighlights()
	
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
	if(not selectedAction.CanBeUsed()): 
		MusicManager.PlayGeneral(2)
		return
	else:
		MusicManager.PlayGeneral(3)
	
	clickMode = ClickModes.ACTION_TARGET
	GenerateTileHighlights(selectedAction.GetTileOptions(allActiveTiles), selectedAction.indicatorsColour)

func FinishUsingAction(actionPos: Vector2i) -> void:
	selectedAction.AttemptUseAction(actionPos, self)
	UnselectAction()

func StartCharacterPlacing(placeable: Placeable) -> void:
	UnselectCharacter()
	selectedPlaceable = placeable
	clickMode = ClickModes.PLACING_TARGET
	GenerateTileHighlights(GetValidPlaceableTiles(), Color.YELLOW)

func CancelCharacterPlacing(placeable: Placeable) -> void:
	selectedPlaceable = null
	clickMode = ClickModes.STANDARD
	DeleteTileHighlights()

func FinishCharacterPlacing(placeable: Placeable) -> void:
	MusicManager.PlayGeneral(4)
	CancelCharacterPlacing(placeable)

func GetValidPlaceableTiles() -> Array[Vector2i]:
	var output: Array[Vector2i]
	var directions: Array[Vector2i] = [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN]
	for ii in teamDatas[Enums.Teams.PLAYER].teamMembers:
		for jj in directions:
			if(output.has(ii.gridPos + jj)): continue
			if(allActiveTiles.has(ii.gridPos + jj)): 
				if(allActiveTiles[ii.gridPos + jj] == null):
					output.append(ii.gridPos + jj)
	return output
