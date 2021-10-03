class_name AttachedArmy

var id: int setget forbidden

var military_kind setget forbidden
var naval_military_kind setget forbidden
var quantity: int setget forbidden
var morale: int setget forbidden
var combativity: int setget forbidden
var experience: int setget forbidden

var officer_ids setget forbidden

func forbidden(x):
	assert(false)

####################################
#           Save / Load            #
####################################

func load_data(json: Dictionary, objects):
	id = json["_Id"]
	military_kind = objects['military_kinds'][int(json["MilitaryKind"])]
	naval_military_kind = objects['military_kinds'][int(json["NavalMilitaryKind"])]
	quantity = json["Quantity"]
	morale = json["Morale"]
	combativity = json["Combativity"]
	experience = json["Experience"]
	officer_ids = json["OfficerIds"]

func save_data() -> Dictionary:
	return {
		"_Id": id,
		"MilitaryKind": military_kind.id,
		"NavalMilitaryKind": naval_military_kind.id,
		"Quantity": quantity,
		"Morale": morale,
		"Combativity": combativity,
		"Experience": experience,
		"OfficerIds": officer_ids
	}

func create_from_creating_troop(creating_troop):
	military_kind = creating_troop.military_kind
	naval_military_kind = creating_troop.naval_military_kind
	quantity = creating_troop.quantity
	morale = creating_troop.morale
	combativity = creating_troop.combativity
	officer_ids = Util.id_list(creating_troop.persons)
	

