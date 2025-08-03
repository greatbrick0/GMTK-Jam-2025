extends GridItem

@export_multiline var message: String = "Did you know..."

func StandardClickAction(manager: GameplayManager) -> void:
	EventBus.mouse_message.emit(0, message)
