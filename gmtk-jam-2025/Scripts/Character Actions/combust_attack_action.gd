extends CharacterAction
class_name CombustAttackAction

@export var damage: int = 1
@export var selfDamage: int = 0
@export var directions: Array[Vector2i]

func UseAction(actionPos: Vector2i, gameplayManager: GameplayManager) -> void:
	action_use_success.emit()
	for ii in directions:
		if(gameplayManager.allActiveTiles.has(actionPos + ii)):
			if(gameplayManager.allActiveTiles[actionPos + ii] is GridCharacter):
				gameplayManager.allActiveTiles[actionPos + ii].TakeDamage(damage, 0.2)
	actionOwner.TakeSelfDamage(selfDamage)
	action_follow_up.emit(actionPos, gameplayManager)
