extends Node
class_name MilitaryKind

var id: int setget forbidden
var scenario

var gname: String

var offence: int
var defence: int
var range_min: int
var range_max: int

var speed: int
var initiative: int
var movement_kind
var terrain_strength

func forbidden(x):
	assert(false)

func load_data(json: Dictionary):
	id = json["_Id"]
	gname = json["Name"]
	offence = json["Offence"]
	defence = json["Defence"]
	range_min = json["RangeMin"]
	range_max = json["RangeMax"]
	speed = json["Speed"]
	initiative = json["Initiative"]
	movement_kind = scenario.movement_kinds[int(json["MovementKind"])]
	terrain_strength = json["TerrainStrength"]
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Name": gname,
		"Offence": offence,
		"Defence": defence,
		"RangeMin": range_min,
		"RangeMax": range_max,
		"Speed": speed,
		"Initiative": initiative,
		"MovementKind": movement_kind.id,
		"TerrainStrength": terrain_strength
	}
	
func get_name():
	return gname
