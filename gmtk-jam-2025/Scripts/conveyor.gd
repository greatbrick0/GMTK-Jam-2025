extends Node2D

@export var gameHud: GameHud
@export var stockHolder: Node2D
@export var placeableGroups: Dictionary[Enums.CharacterClasses, Vector2i]
@export var placeableOptions: Array[PackedScene]

var stockMoving: bool = false
@export var stockMoveValue: float = 0
var stock: Array[Placeable] = []

func _ready() -> void:
	EventBus.end_turn.connect(AutoRotateConveyor)

func _process(delta) -> void:
	if(stockMoving): MoveStock(stockMoveValue)

func AutoRotateConveyor(team: Enums.Teams) -> void:
	if(team == Enums.Teams.PLAYER):
		RotateConveyor()

func RotateConveyor() -> void:
	var newPlaceableRef: Placeable = placeableOptions[RandomlySelectPlaceable()].instantiate() as Placeable
	stockHolder.add_child(newPlaceableRef)
	print(newPlaceableRef.name)
	newPlaceableRef.got_purchased.connect(gameHud.AddScrap)
	newPlaceableRef.got_purchased.connect(UpdatePricesVisible)
	newPlaceableRef.scale = Vector2.ZERO
	stock.insert(0, newPlaceableRef)
	for ii in range(len(stock)):
		stock[ii].purchasable = ii == 4 or ii == 5 or ii == 7
	
	$AnimationPlayer.play("Rotate")

func MoveStock(value: float) -> void:
	for ii in range(len(stock)):
		if(stock != null):
			stock[ii].position = lerp($Positions.get_child(ii).position, $Positions.get_child(ii + 1).position, value)
			stock[ii].scale = lerp($Positions.get_child(ii).scale, $Positions.get_child(ii + 1).scale, value)

func RemoveFinalStock() -> void:
	if(len(stock) > 7):
		stock.erase(stock[-1])

func SetStockIsMoving(isMoving: bool) -> void:
	stockMoving = isMoving
	for ii in stock:
		if(stock != null):
			$Prices.visible = not isMoving
			ii.currentlyMoving = isMoving
	if(not isMoving):
		UpdatePricesVisible()

func UpdatePricesVisible(val = null) -> void:
	for ii in range(3):
		get_node("Prices/Price"+str(ii)).visible = len(stock) > (4 + ii) and not stock[4 + ii].alreadyPurchased
		if(get_node("Prices/Price"+str(ii)).visible):
			get_node("Prices/Price"+str(ii)+"/Label").text = str(stock[4 + ii].scrapCost)

func RandomlySelectPlaceable() -> int:
	return randi_range(0, len(placeableOptions) - 1)

func _on_pay_for_rotate_button_pressed():
	if($AnimationPlayer.is_playing()): return
	if(gameHud.playerScrapCount >= 1):
		gameHud.AddScrap(-1)
		RotateConveyor()
		for ii in stock:
			ii.Unselect()
	else:
		MusicManager.PlayGeneral(2)
