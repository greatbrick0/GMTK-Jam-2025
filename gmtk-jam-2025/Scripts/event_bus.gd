extends Node

signal end_turn(team: Enums.Teams)
signal start_turn(team: Enums.Teams)

signal grid_dict_move_item(oldPos: Vector2i, newPos: Vector2i, item: GridItem)
signal grid_dict_remove_item(oldPos: Vector2i, item: GridItem)

func GridDictRemoveItem(oldPos: Vector2i, item: GridItem):
	grid_dict_remove_item.emit(oldPos, item)
