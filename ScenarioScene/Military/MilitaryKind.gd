extends Node
class_name MilitaryKind

enum MilitaryType {
	INFANTRY, BOWMAN, CALVARY, SIEGE, NAVAL
}

var id: int :
	get:
		return id # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var scenario

var gname: String :
	get:
		return gname # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var base_offence: int :
	get:
		return base_offence # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var base_defence: int :
	get:
		return base_defence # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var offence: float :
	get:
		return offence # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var defence: float :
	get:
		return defence # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var range_min: int :
	get:
		return range_min # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var range_max: int :
	get:
		return range_max # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var type :
	get:
		return type # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var type_offensive_effectiveness :
	get:
		return type_offensive_effectiveness # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var type_defensive_effectiveness :
	get:
		return type_defensive_effectiveness # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var speed: int :
	get:
		return speed # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var initiative: int :
	get:
		return initiative # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var food_per_soldier: int :
	get:
		return food_per_soldier # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var movement_kind :
	get:
		return movement_kind # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var terrain_strength :
	get:
		return terrain_strength # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var receive_counter_attacks: bool :
	get:
		return receive_counter_attacks # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var architecture_attack_factor: float :
	get:
		return architecture_attack_factor # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var max_quantity_multiplier: float :
	get:
		return max_quantity_multiplier # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var equipment_cost: float :
	get:
		return equipment_cost # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var influences: Array :
	get:
		return influences # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var conditions: Array :
	get:
		return conditions # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var amount_to_troop_ratio: float :
	get:
		return amount_to_troop_ratio # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

func forbidden(x):
	assert(false)

func load_data(json: Dictionary, objects):
	id = json["_Id"]
	gname = json["Name"]
	type = json["Type"]
	base_offence = json["BaseOffence"]
	base_defence = json["BaseDefence"]
	offence = json["Offence"]
	defence = json["Defence"]
	range_min = json["RangeMin"]
	range_max = json["RangeMax"]
	max_quantity_multiplier = json["MaxQuantityMuiltipler"]
	speed = json["Speed"]
	initiative = json["Initiative"]
	food_per_soldier = json["FoodPerSoldier"]
	amount_to_troop_ratio = Util.dict_try_get(json, "AmountToTroopRatio", 1.0)
	equipment_cost = json["EquipmentCost"]
	movement_kind = scenario.movement_kinds[int(json["MovementKind"])]
	terrain_strength = Util.convert_dict_to_int_key(json["TerrainStrength"])
	receive_counter_attacks = json["ReceiveCounterAttacks"]
	architecture_attack_factor = json["ArchitectureAttackFactor"]
	type_offensive_effectiveness = Util.convert_dict_to_int_key(json["TypeOffensiveEffectiveness"])
	type_defensive_effectiveness = Util.convert_dict_to_int_key(json["TypeDefensiveEffectiveness"])
	influences = json["Influences"]
	conditions = json["Conditions"]
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Name": gname,
		"Type": type,
		"BaseOffence": base_offence,
		"BaseDefence": base_defence,
		"Offence": offence,
		"Defence": defence,
		"RangeMin": range_min,
		"RangeMax": range_max,
		"MaxQuantityMuiltipler": max_quantity_multiplier,
		"Speed": speed,
		"Initiative": initiative,
		"EquipmentCost": equipment_cost,
		"FoodPerSoldier": food_per_soldier,
		"AmountToTroopRatio": amount_to_troop_ratio,
		"MovementKind": movement_kind.id,
		"TerrainStrength": terrain_strength,
		"ReceiveCounterAttacks": receive_counter_attacks,
		"ArchitectureAttackFactor": architecture_attack_factor,
		"TypeOffensiveEffectiveness": type_offensive_effectiveness,
		"TypeDefensiveEffectiveness": type_defensive_effectiveness,
		"Influences": influences,
		"Conditions": conditions
	}
	
func get_name():
	return gname

func is_naval():
	return type == MilitaryType.NAVAL

func get_offence():
	return offence

func get_defence():
	return defence

func get_velocity():
	return speed

func get_initiative():
	return initiative


func get_terrain_strengths():
	return terrain_strength

func get_movement_costs():
	return movement_kind.movement_cost

func get_architecture_attack_factor():
	return architecture_attack_factor

func is_receive_counter_attacks():
	return receive_counter_attacks

func get_movement_kind_with_name():
	var result = {}
	var costs = movement_kind.movement_cost
	for i in costs:
		result[scenario.terrain_details[int(i)].get_name()] = costs[i]
	return result
	
func get_terrain_strength_with_name():
	var result = {}
	for i in terrain_strength:
		result[scenario.terrain_details[int(i)].get_name()] = terrain_strength[i]
	return result

func get_range_max():
	return range_max

func get_range_min():
	return range_min
	
func has_equipments():
	return equipment_cost > 0
	
func get_type_offensive_effectivenss(other_kind):
	var other_type = other_kind.type
	return Util.dict_try_get(type_offensive_effectiveness, other_type, 1)

func get_type_defensive_effectivenss(other_kind):
	var other_type = other_kind.type
	return Util.dict_try_get(type_defensive_effectiveness, other_type, 1)
	
func apply_influences(operation, params: Dictionary):
	return Influences.apply_influences(self, operation, params)
