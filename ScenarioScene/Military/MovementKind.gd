extends Node
class_name MovementKind

var id: int setget forbidden
var scenario
var naval: bool setget forbidden

var movement_cost = {} setget forbidden

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
