extends Node
class_name Stunt

var id: int setget forbidden
var scenario

var gname: String setget forbidden
var color: Color setget forbidden
var description: String setget forbidden

var tile_effect: String setget forbidden

var combativity_cost: int setget forbidden
var duration: int setget forbidden

var experience: int setget forbidden

var influences setget forbidden
var conditions setget forbidden
var ai_conditions setget forbidden

var learn_conditions setget forbidden
var max_level: int setget forbidden

func forbidden(x):
	assert(false)

func load_data(json: Dictionary, objects):
	id = json["_Id"]
	gname = json["Name"]
	description = json["Description"]
	color = Util.load_color(json["Color"])
	tile_effect = json["TileEffect"]
	combativity_cost = json["CombativityCost"]
	duration = json["Duration"]
	conditions = json["Conditions"]
	influences = json["Influences"]
	ai_conditions = json["AIConditions"]
	max_level = Util.dict_try_get(json, "MaxLevel", -1)
	learn_conditions = Util.dict_try_get(json, "LearnConditions", [])
	
	if max_level <= 0:
		max_level = 32767
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Name": gname,
		"Description": description,
		"Color": Util.save_color(color),
		"TileEffect": tile_effect,
		"CombativityCost": combativity_cost,
		"Duration": duration,
		"MaxLevel": max_level,
		"LearnConditions": learn_conditions,
		"Conditions": conditions,
		"AIConditions": ai_conditions,
		"Influences": influences
	}

func get_name() -> String:
	return gname

func get_name_with_level(level) -> String:
	return gname + str(level)

func apply_influences(in_operation, level: int, params: Dictionary):
	var all_params = params.duplicate()
	all_params['level'] = level
	return Influences.apply_influences(self, in_operation, all_params)

func check_conditions(troop: Troop):
	return Conditions.check_conditions_list(conditions, {"troop": troop})

func check_ai_conditions(troop: Troop):
	return Conditions.check_conditions_list(ai_conditions, {"troop": troop})
