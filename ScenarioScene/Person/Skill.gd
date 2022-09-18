extends Node
class_name Skill

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

func forbidden(x):
	assert(false)

func load_data(json: Dictionary, objects):
	id = json["_Id"]
	gname = json["Name"]
	description = json["Description"]
	color = Util.load_color(json["Color"])
	conditions = json["Conditions"]
	influences = json["Influences"]
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
		"MaxLevel": max_level,
		"LearnConditions": learn_conditions,
		"Conditions": conditions,
		"Influences": influences
	}

func get_name() -> String:
	return gname

func get_name_with_level(level) -> String:
	return gname + str(level)
	
func get_color() -> Color:
	return color

func apply_influences(in_operation, level: int, params: Dictionary):
	var all_params = params.duplicate()
	all_params['level'] = level
	return Influences.apply_influences(self, in_operation, all_params)
