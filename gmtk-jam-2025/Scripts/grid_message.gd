extends GridItem

@export_multiline var message: String = "Did you know..."

func _ready():
	$AnimationPlayer.play("sway")
	super._ready()

func StandardClickAction(manager: GameplayManager) -> void:
	EventBus.mouse_message.emit(0, message)
