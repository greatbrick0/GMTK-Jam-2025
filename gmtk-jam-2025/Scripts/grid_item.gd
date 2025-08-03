extends Node3D
class_name GridItem

var gridPos: Vector2i = Vector2i.ZERO

func _ready() -> void:
	await get_tree().process_frame
	gridPos = Vector2i(round(global_position.x), round(global_position.z))
	print(gridPos)
	EventBus.grid_dict_add_item.emit(gridPos, self)

func MoveOnGrid(newPos: Vector2i) -> void:
	EventBus.grid_dict_move_item.emit(gridPos, newPos, self)
	gridPos = newPos
	global_position = Vector3(newPos.x, 0, newPos.y)

func StandardClickAction(manager: GameplayManager) -> void:
	pass
