extends Node2D

@export var newScene: PackedScene

func Transition() -> void:
	get_tree().change_scene_to_packed(newScene)
