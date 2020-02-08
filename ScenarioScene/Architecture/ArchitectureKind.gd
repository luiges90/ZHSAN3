extends Node
class_name ArchitectureKind

var _id: int setget forbidden, get_id
var scenario

var gname: String
var image: Texture

var agriculture: int
var commerce: int
var morale: int
var endurance: int
var population: int

func forbidden(x):
	assert(false)

func load_data(json: Dictionary):
	_id = json["_Id"]
	gname = json["Name"]
	image = load("res://Images/Architecture/" + json["Image"])
	agriculture = json["Agriculture"]
	commerce = json["Commerce"]
	morale = json["Morale"]
	endurance = json["Endurance"]
	population = json["Population"]
	
func get_id() -> int:
	return _id
