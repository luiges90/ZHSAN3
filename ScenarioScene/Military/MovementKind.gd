extends Node
class_name MovementKind

var id: int setget forbidden
var scenario

var movement_cost = {} setget forbidden
var effectiveness = {} setget forbidden

func forbidden(x):
	assert(false)

func load_data(json: Dictionary):
	id = json["_Id"]
	movement_cost = json["MovementCosts"]
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"MovementCosts": movement_cost
	}
