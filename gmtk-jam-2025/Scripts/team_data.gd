extends RefCounted
class_name TeamData

var team: Enums.Teams
var teamMembers: Array[GridCharacter] = []
var classCounts: Dictionary[Enums.CharacterClasses, int]

func _init(newTeam: Enums.Teams):
	team = newTeam
	EventBus.grid_dict_add_item.connect(CheckForAddedMember)

func CheckForRoyalty() -> bool:
	return classCounts[Enums.CharacterClasses.ROYALTY] > 0

func GetClassCount(characterClass: Enums.CharacterClasses) -> int:
	if(classCounts.has(characterClass)): return classCounts[characterClass]
	else: return 0

func CheckForAddedMember(newPos: Vector2i, item: GridItem) -> void:
	if(not item is GridCharacter): return
	if(item.team == team):
		AddTeamMember(item)

func AddTeamMember(newMember: GridCharacter) -> void:
	print(newMember.name + " added to team")
	teamMembers.append(newMember)
	if(classCounts.has(newMember.characterClass)):
		classCounts[newMember.characterClass] += 1
	else:
		classCounts[newMember.characterClass] = 1
	newMember.character_died.connect(RemoveTeamMember)

func RemoveTeamMember(oldPos: Vector2i, item: GridItem) -> void:
	item = item as GridCharacter
	classCounts[item.characterClass] -= 1
	teamMembers.erase(item)
	item.character_died.disconnect(RemoveTeamMember)
