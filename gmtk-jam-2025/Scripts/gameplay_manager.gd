extends Node

@export var cam: CameraMovement
@export var clickHandler: ClickHandler

func _ready():
	clickHandler.start_camera_move.connect(cam.OnStartCameraMove)
	clickHandler.stop_camera_move.connect(cam.OnStopCameraMove)
