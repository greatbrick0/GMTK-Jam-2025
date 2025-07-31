extends Node

@export var newScene: PackedScene
@export var doesSelectLevel: bool = false
@export var levelToSelect: int = 0

func Transition() -> void:
	if(doesSelectLevel):
		LevelSelector.selectedLevel = levelToSelect
	get_tree().change_scene_to_packed(newScene)
