extends Node
class_name TerrainDetail

var id: int setget forbidden
var scenario

var gname: String setget forbidden

var terrain_ids = [] setget forbidden
 
func forbidden(x):
	assert(false)

func load_data(json: Dictionary):
	id = json["_Id"]
	gname = json["Name"]
	terrain_ids = json["TerrainIds"]
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Name": gname,
		"TerrainIds": terrain_ids
	}

func get_name() -> String:
	return gname
