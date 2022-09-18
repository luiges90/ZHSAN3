extends Node
class_name Stunt

enum TargetType { ALLIES, ENEMIES, ALL }
enum CompetitionAbility { NONE, COMMAND, STRENGTH, INTELLIGENCE }

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
var color: Color :
	get:
		return color # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var description: String :
	get:
		return description # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var target_range: int :
	get:
		return target_range # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var effect_range: int :
	get:
		return effect_range # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var tile_effect: String :
	get:
		return tile_effect # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var combativity_cost: int :
	get:
		return combativity_cost # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var duration: int :
	get:
		return duration # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var experience: int :
	get:
		return experience # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var influences :
	get:
		return influences # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var conditions :
	get:
		return conditions # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var ai_conditions :
	get:
		return ai_conditions # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var learn_conditions :
	get:
		return learn_conditions # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var max_level: int :
	get:
		return max_level # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var target_type :
	get:
		return target_type # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var success_chance: float :
	get:
		return success_chance # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var competition_ability :
	get:
		return competition_ability # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var ability_chance_rate: float :
	get:
		return ability_chance_rate # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

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
	success_chance = json["SuccessChance"]
	competition_ability = json["CompetitionAbility"]
	ability_chance_rate = json["AbilityChanceRate"]
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
		"SuccessChance": success_chance,
		"CompetitionAbility": competition_ability,
		"AbilityChanceRate": ability_chance_rate,
		"CombativityCost": combativity_cost,
		"Duration": duration,
		"MaxLevel": max_level,
		"LearnConditions": learn_conditions,
		"Conditions": conditions,
		"AIConditions": ai_conditions,
		"Influences": influences
	}

func get_name() -> StringName:
	return StringName(gname)

func get_color():
	return color

func get_name_with_level(level) -> String:
	return gname + str(level)

func apply_influences(in_operation, level: int, params: Dictionary):
	var all_params = params.duplicate()
	all_params['level'] = level
	return Influences.apply_influences(self, in_operation, all_params)

func check_conditions(troop):
	return Conditions.check_conditions_list(conditions, {"troop": troop})

func check_ai_conditions(troop):
	return Conditions.check_conditions_list(ai_conditions, {"troop": troop})

func get_valid_target_squares(troop) -> Array:
	if target_range <= 0:
		return [troop.map_position]
	
	var result = []
	var squares_in_range = Util.squares_in_range(troop.map_position, target_range)
	for s in squares_in_range:
		var target_troop = scenario.get_troop_at_position(s)
		if target_troop != null:
			if valid_target(troop, target_troop):
				result.append(s)
	return result
	
func valid_target(troop, other_troop) -> bool:
	if target_type == TargetType.ALL:
		return true
	elif target_type == TargetType.ALLIES: 
		return other_troop.get_belonged_faction().is_friend_to(troop.get_belonged_faction())
	elif target_type == TargetType.ENEMIES: 
		return other_troop.get_belonged_faction().is_enemy_to(troop.get_belonged_faction())
	else:
		return false
