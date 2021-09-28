class_name AttachedArmy

var id: int setget forbidden

var military_kind setget forbidden
var naval_military_kind setget forbidden
var quantity: int setget forbidden
var morale: int setget forbidden
var combativity: int setget forbidden
var experience: int setget forbidden

func forbidden(x):
	assert(false)

####################################
#           Save / Load            #
####################################

func load_data(json: Dictionary, objects):
    id = json["_Id"]
    military_kind = scenario.military_kinds[int(json["MilitaryKind"])]
	naval_military_kind = scenario.military_kinds[int(json["NavalMilitaryKind"])]
    quantity = json["Quantity"]
	morale = json["Morale"]
	combativity = json["Combativity"]
    experience = json["Experience"]

func save_data() -> Dictionary:
	return {
        "_Id": id,
        "MilitaryKind": military_kind.id,
        "NavalMilitaryKind": naval_military_kind.id,
        "Quantity": quantity,
        "Morale": morale,
        "Combativity": combativity,
        "Experience": experience
    }