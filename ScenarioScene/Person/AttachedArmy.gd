class_name AttachedArmy

var id: int setget forbidden

var scenario

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
	officer_ids = Util.to_int_list(json["OfficerIds"])

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

func update_from_creating_troop(scen, creating_troop):
	scenario = scen
	
	var new_id = scen.attached_armies.keys().max()
	if new_id == null:
		new_id = 1
	else:
		new_id = new_id + 1
	
	id = new_id
	military_kind = creating_troop.military_kind
	naval_military_kind = creating_troop.naval_military_kind
	quantity = creating_troop.quantity
	morale = creating_troop.morale
	combativity = creating_troop.combativity
	officer_ids = Util.id_list(creating_troop.persons)

func get_creating_troop(scen):
	var result = CreatingTroop.new()
	result.military_kind = military_kind
	result.naval_military_kind = naval_military_kind
	result.quantity = quantity
	result.morale = morale
	result.combativity = combativity
	result.persons = [scen.persons[officer_ids[0]]]

	return result
	

func get_officers_list():
	return scenario.get_persons_from_ids(officer_ids)

func get_officers_name_list():
	var result = ""
	for p in get_officers_list():
		result += p.get_name() + "‧"
	return result

func get_cost():
	return quantity * (military_kind.equipment_cost + naval_military_kind.equipment_cost)
	
func add_experience(delta):
	experience += delta
	
func add_quantity(delta):
	quantity += delta

func set_morale(v):
	morale = v
