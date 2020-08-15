extends Node
class_name Skill

var id: int setget forbidden
var scenario

var gname: String setget forbidden
var color: Color setget forbidden
var description: String setget forbidden

var influences setget forbidden
var conditions setget forbidden

func forbidden(x):
	assert(false)

func load_data(json: Dictionary, objects):
	id = json["_Id"]
	gname = json["Name"]
	description = json["Description"]
	color = Util.load_color(json["Color"])
	conditions = json["Conditions"]
	influences = json["Influences"]
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Name": gname,
		"Description": description,
		"Color": Util.save_color(color),
		"Conditions": conditions,
		"Influences": influences
	}

func get_name() -> String:
	return gname
	
func get_color() -> Color:
	return color

func apply_influences(in_operation, params: Dictionary):
	return ScenarioUtil.apply_influences(self, in_operation, params)
