extends GridItem
class_name Scrap

@export var scrapAmount: int = 1

func GetCollected() -> void:
	$AnimationPlayer.play("shrink")
	EventBus.add_scrap.emit(scrapAmount)
	EventBus.grid_dict_remove_item.emit(gridPos, self)
