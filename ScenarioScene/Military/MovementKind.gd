extends Node
class_name MovementKind

var id: int :
	get:
		return id # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var scenario
var naval: bool :
	get:
		return naval # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var movement_cost = {} :
	get:
		return movement_cost # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

func forbidden(x):
	assert(false)

func load_data(json: Dictionary, objects):
	id = json["_Id"]
	movement_cost = Util.convert_dict_to_int_key(json["MovementCosts"])
	naval = json["Naval"]
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"MovementCosts": movement_cost,
		"Naval": naval
	}
