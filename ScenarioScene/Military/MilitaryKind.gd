extends Node
class_name MilitaryKind

enum MilitaryType {
	INFANTRY, BOWMAN, CALVARY, SIEGE, NAVAL
}

var id: int setget forbidden
var scenario

var gname: String setget forbidden

var base_offence: int setget forbidden
var base_defence: int setget forbidden
var offence: float setget forbidden
var defence: float setget forbidden
var range_min: int setget forbidden
var range_max: int setget forbidden
var type setget forbidden
var type_offensive_effectiveness setget forbidden
var type_defensive_effectiveness setget forbidden

var speed: int setget forbidden
var initiative: int setget forbidden
var food_per_soldier: int setget forbidden
var movement_kind setget forbidden
var terrain_strength setget forbidden
var receive_counter_attacks: bool setget forbidden
var architecture_attack_factor: float setget forbidden

var max_quantity_multiplier: float setget forbidden
var equipment_cost: float setget forbidden

var influences: Array setget forbidden
var conditions: Array setget forbidden

var amount_to_troop_ratio: float setget forbidden

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

func get_speed():
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
