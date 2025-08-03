extends Node

signal end_turn(team: Enums.Teams)
signal start_turn(team: Enums.Teams)
signal adjust_player_blockers(adjust: int)

signal grid_dict_add_item(newPos: Vector2i, item: GridItem)
signal grid_dict_move_item(oldPos: Vector2i, newPos: Vector2i, item: GridItem)
signal grid_dict_remove_item(oldPos: Vector2i, item: GridItem)

signal start_character_placing(placeable: Placeable)
signal cancel_character_placing(placeable: Placeable)

signal mouse_message(channel: int, message: String)

func GridDictRemoveItem(oldPos: Vector2i, item: GridItem):
	grid_dict_remove_item.emit(oldPos, item)
