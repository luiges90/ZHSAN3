extends Node
class_name Skill

var id: int setget forbidden
var scenario

var gname: String setget forbidden
var color: Color setget forbidden
var description: String setget forbidden

var operation: String setget forbidden
var value: float setget forbidden

func forbidden(x):
	assert(false)

func load_data(json: Dictionary, objects):
	id = json["_Id"]
	gname = json["Name"]
	description = json["Description"]
	color = Util.load_color(json["Color"])
	operation = json["Operation"]
	value = json["Value"]
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Name": gname,
		"Description": description,
		"Color": Util.save_color(color),
		"Operation": operation,
		"Value": value
	}

func get_name() -> String:
	return gname

func apply_influence(in_operation, objects):
	if objects.has("value"):
		if in_operation == operation:
			return objects["value"] * value
		return objects["value"]
