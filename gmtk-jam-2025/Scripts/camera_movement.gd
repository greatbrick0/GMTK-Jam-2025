extends Node3D
class_name CameraMovement

var cameraMoving: bool = false
var prevMousePos: Vector2
var prevCameraPos: Vector3

@export var speedMult: Vector2 = Vector2.ONE
@export var angle: float = 20.0

func OnStartCameraMove():
	cameraMoving = true
	prevMousePos = get_viewport().get_mouse_position()
	prevCameraPos = global_position

func OnStopCameraMove():
	cameraMoving = false

func _process(delta):
	if(cameraMoving):
		var mouseDifference: Vector2 = prevMousePos - get_viewport().get_mouse_position()
		var modifiedDisplacement: Vector3 = Vector3(
			mouseDifference.x * speedMult.x, 
			0, 
			mouseDifference.y * speedMult.y
			).rotated(Vector3.UP, deg_to_rad(angle))
		
		global_position = prevCameraPos + modifiedDisplacement
