extends GridItem
class_name GridCharacter

@export var team: Enums.Teams = Enums.Teams.PLAYER
@export var characterClass: Enums.CharacterClasses = Enums.CharacterClasses.LOW_POWER
@export var maxHealth: int = 3
@export var health: int = 3
@export var droppedScrapCount: int = 1
@export var deathExplosionObj: PackedScene
@export var deathScrapObj: PackedScene
signal character_died(oldPos: Vector2i, item: GridItem)
signal character_damaged(newHealth: int, oldHealth: int)

@export var actionAnimPrefix: String
@export var actionAnimPlayer: AnimationPlayer
signal actions_available_updated(available: bool)
var usedActions: Array = []

func _ready():
	super._ready()
	character_died.connect(EventBus.GridDictRemoveItem)
	EventBus.start_turn.connect(ResetForTurn)
	actionAnimPlayer.animation_finished.connect(func(animName: String): if(animName.begins_with(actionAnimPrefix+"Action")): actionAnimPlayer.play(actionAnimPrefix+"Idle"))
	$Visuals_Stationary/HealthVisual._setup(maxHealth)

func StandardClickAction(manager: GameplayManager) -> void:
	if(team == Enums.Teams.PLAYER):
		MusicManager.PlayGeneral(1)
		manager.selectedCharacter = self
		manager.gameHud.GenerateActionButtons(self)
		character_died.connect(manager.UnselectCharacter)

func RotateTowards(focusPos: Vector2i) -> void:
	$Visuals.look_at(Vector3(focusPos.x, 0, focusPos.y))
	$Visuals.rotate_y(PI)

func PlayActionAnimation(animIndex: int) -> void:
	actionAnimPlayer.stop()
	actionAnimPlayer.play(actionAnimPrefix+"Action"+str(animIndex))

func ResetForTurn(turnTeam: Enums.Teams) -> void:
	if(turnTeam == team):
		usedActions.clear()
		actions_available_updated.emit(true)

func GetActionCount() -> int:
	return $Actions.get_child_count()

func AttemptGetAction(index: int) -> CharacterAction:
	if($Actions.get_child_count() > index):
		return $Actions.get_child(index)
	else:
		return null

func HasRemainingActions() -> bool:
	var output: bool = false
	for ii in $Actions.get_children():
		output = output or ii.CanBeUsed()
	return output

func AppendUsedActions(appended: Array[String]) -> void:
	usedActions.append_array(appended)
	if(not HasRemainingActions()):
		actions_available_updated.emit(false)

func TakeSelfDamage(damageAmount: int) -> bool:
	if(damageAmount == 0): return false
	character_damaged.emit(health - damageAmount, health)
	health -= damageAmount
	if(health <= 0): Die()
	return health <= 0

func TakeDamage(damageAmount: int, delay: float = 0.0) -> bool:
	if(delay > 0):
		EventBus.adjust_player_blockers.emit(1)
		await get_tree().create_timer(delay).timeout
		EventBus.adjust_player_blockers.emit(-1)
	character_damaged.emit(health - damageAmount, health)
	health -= damageAmount
	if(health <= 0):
		Die()
		return true
	else:
		$Sounds/HurtSound.play()
		return false 

func Die() -> void:
	character_died.emit(gridPos, self)
	var deathExplosionRef: Node3D = deathExplosionObj.instantiate() as Node3D
	get_parent().add_child(deathExplosionRef)
	deathExplosionRef.global_position = global_position
	var deathScrapRef: GridItem = deathScrapObj.instantiate() as Scrap
	deathScrapRef.scrapAmount = droppedScrapCount
	get_parent().add_child(deathScrapRef)
	deathScrapRef.global_position = global_position
	queue_free()
