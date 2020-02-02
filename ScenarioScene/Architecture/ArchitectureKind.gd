extends Node
class_name ArchitectureKind

var _id: int
var scenario

var gname: String
var image: Texture

func load_data(json: Dictionary):
	_id = json["_Id"]
	gname = json["Name"]
	image = load("res://Images/Architecture/" + json["Image"])
	
func get_id() -> int:
	return _id
