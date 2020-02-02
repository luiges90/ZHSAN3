extends Node
class_name ArchitectureKind

var _id: int
var scenario

var gname
var image

func load_data(json: Dictionary):
	_id = json["_Id"]
	gname = json["Name"]
	image = json["Image"]
	
func get_id() -> int:
	return _id
