extends Node
class_name ArchitectureKind

var id: int setget forbidden
var scenario

var gname: String setget forbidden
var image: Texture setget forbidden

var agriculture: int setget forbidden
var commerce: int setget forbidden
var morale: int setget forbidden
var endurance: int setget forbidden
var population: int setget forbidden

func forbidden(x):
	assert(false)

func load_data(json: Dictionary):
	id = json["_Id"]
	gname = json["Name"]
	image = load("res://Images/Architecture/" + json["Image"])
	agriculture = json["Agriculture"]
	commerce = json["Commerce"]
	morale = json["Morale"]
	endurance = json["Endurance"]
	population = json["Population"]
	
