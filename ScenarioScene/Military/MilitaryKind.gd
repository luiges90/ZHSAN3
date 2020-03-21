extends Node
class_name MilitaryKind

var id: int setget forbidden
var scenario

var gname: String setget forbidden

var offence: int setget forbidden
var defence: int setget forbidden
var range_min: int setget forbidden
var range_max: int setget forbidden

var speed: int setget forbidden
var initiative: int setget forbidden
var movement_kind setget forbidden
var terrain_strength setget forbidden

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
