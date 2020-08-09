extends Node
class_name Skill

var id: int setget forbidden
var scenario

var gname: String setget forbidden
var color: Color setget forbidden
var description: String setget forbidden

var influences setget forbidden

func forbidden(x):
	assert(false)

func load_data(json: Dictionary, objects):
	id = json["_Id"]
	gname = json["Name"]
	description = json["Description"]
	color = Util.load_color(json["Color"])
	influences = json["Influences"]
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Name": gname,
		"Description": description,
		"Color": Util.save_color(color),
		"Influences": influences
	}

func get_name() -> String:
	return gname

func apply_influences(in_operation, params):
	if params.has("value"):
		var value = params['value']
		for influence in influences:
			if in_operation == influence['Operation']:
				value = influence["Value"] * value
		return value
