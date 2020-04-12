extends Node
class_name MilitaryKind

var id: int setget forbidden
var scenario

var gname: String setget forbidden

var base_offence: int setget forbidden
var base_defence: int setget forbidden
var offence: float setget forbidden
var defence: float setget forbidden
var range_min: int setget forbidden
var range_max: int setget forbidden

var speed: int setget forbidden
var initiative: int setget forbidden
var movement_kind setget forbidden
var terrain_strength setget forbidden

var max_quantity_multiplier: float setget forbidden
var equipment_cost: float setget forbidden

func forbidden(x):
	assert(false)

func load_data(json: Dictionary):
	id = json["_Id"]
	gname = json["Name"]
	base_offence = json["BaseOffence"]
	base_defence = json["BaseDefence"]
	offence = json["Offence"]
	defence = json["Defence"]
	range_min = json["RangeMin"]
	range_max = json["RangeMax"]
	max_quantity_multiplier = json["MaxQuantityMuiltipler"]
	speed = json["Speed"]
	initiative = json["Initiative"]
	equipment_cost = json["EquipmentCost"]
	movement_kind = scenario.movement_kinds[int(json["MovementKind"])]
	terrain_strength = json["TerrainStrength"]
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Name": gname,
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
		"MovementKind": movement_kind.id,
		"TerrainStrength": terrain_strength
	}
	
func get_name():
	return gname

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
	
func has_equipments():
	return equipment_cost > 0
