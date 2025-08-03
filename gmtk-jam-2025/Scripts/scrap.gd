extends GridItem
class_name Scrap

@export var scrapAmount: int = 1
var nearTiles: Array[Vector2i]

func _ready():
	await super._ready()
	for ii in range(3):
		for jj in range(3):
			nearTiles.append(gridPos + Vector2i(ii - 1, jj - 1))
	EventBus.grid_dict_move_item.connect(LookForRoyalty)

func LookForRoyalty(oldPos: Vector2i, newPos: Vector2i, item: GridItem) -> void:
	if(nearTiles.has(newPos)):
		if(item is GridCharacter):
			if(item.characterClass == Enums.CharacterClasses.ROYALTY):
				GetCollected()

func GetCollected() -> void:
	$AnimationPlayer.play("shrink")
	EventBus.add_scrap.emit(scrapAmount)
	EventBus.grid_dict_remove_item.emit(gridPos, self)
