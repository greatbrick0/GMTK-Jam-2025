extends RefCounted
class_name TeamData

var team: Enums.Teams
var teamMembers: Array[GridCharacter] = []
var classCounts: Dictionary[Enums.CharacterClasses, int]

func _init(newTeam: Enums.Teams):
	team = newTeam

func CheckForRoyalty() -> bool:
	var output: bool = false
	for ii in teamMembers:
		output = output or ii.characterClass == Enums.CharacterClasses.ROYALTY
	return output

func GetClassCount(characterClass: Enums.CharacterClasses) -> int:
	if(classCounts.has(characterClass)): return classCounts[characterClass]
	else: return 0

func AddTeamMember(newMember: GridCharacter) -> void:
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
