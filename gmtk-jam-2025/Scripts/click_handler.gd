extends Area3D
class_name ClickHandler

signal start_camera_move()
signal stop_camera_move()

func _on_input_event(camera, event, event_position, normal, shape_idx):
	if(not event is InputEventMouseButton):
		return
	
	if(event.pressed):
		if(event.button_index == MOUSE_BUTTON_LEFT):
			print("pressed")
		elif(event.button_index == MOUSE_BUTTON_RIGHT):
			start_camera_move.emit()
	
	elif(event.is_released()):
		if(event.button_index == MOUSE_BUTTON_RIGHT):
			stop_camera_move.emit()
