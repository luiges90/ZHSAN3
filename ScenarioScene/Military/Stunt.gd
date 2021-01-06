extends Node
class_name Stunt

enum TargetType { ALLIES, ENEMIES, ALL, POSITION }

var id: int setget forbidden
var scenario

var gname: String setget forbidden
var color: Color setget forbidden
var description: String setget forbidden

var target_range: int setget forbidden
var effect_range: int setget forbidden

var tile_effect: String setget forbidden

var combativity_cost: int setget forbidden
var duration: int setget forbidden

var experience: int setget forbidden

var influences setget forbidden
var conditions setget forbidden
var ai_conditions setget forbidden

var learn_conditions setget forbidden
var max_level: int setget forbidden

var target_type setget forbidden

func forbidden(x):
	assert(false)

func load_data(json: Dictionary, objects):
	id = json["_Id"]
	gname = json["Name"]
	description = json["Description"]
	color = Util.load_color(json["Color"])
	tile_effect = json["TileEffect"]
	target_range = json["TargetRange"]
	effect_range = json["EffectRange"]
	target_type = json["TargetType"]
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
		"TargetRange": target_range,
		"EffectRange": effect_range,
		"TargetType": target_type,
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

func get_valid_target_squares(troop: Troop) -> Array:
	if target_range <= 0:
		return [troop.map_position]
	
	var result = []
	var squares_in_range = Util.squares_in_range(troop.map_position, target_range)
	for s in squares_in_range:
		if target_type == TargetType.POSITION:
			result.append(s)
		else:
			var target_troop = scenario.get_troop_at_position(s)
			if target_troop != null:
				if valid_target(troop, target_troop):
					result.append(s)
	return result
	
func valid_target(troop: Troop, other_troop: Troop) -> bool:
	match target_type:
		TargetType.ALL: return true
		TargetType.ALLIES: return other_troop.get_belonged_faction().is_friend_to(troop.get_belonged_faction())
		TargetType.ENEMIES: return other_troop.get_belonged_faction().is_enemy_to(troop.get_belonged_faction())
	return false
