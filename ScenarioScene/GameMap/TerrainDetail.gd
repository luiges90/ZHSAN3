extends Node
class_name TerrainDetail

var id: int setget forbidden
var scenario

var gname: String setget forbidden

var terrain_ids = [] setget forbidden

var is_naval: bool setget forbidden
 
func forbidden(x):
	assert(false)

func load_data(json: Dictionary, objects):
	id = json["_Id"]
	gname = json["Name"]
	terrain_ids = json["TerrainIds"]
	is_naval = Util.dict_try_get(json, "IsNaval", false)
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Name": gname,
		"TerrainIds": terrain_ids,
		"IsNaval": is_naval
	}

func get_name() -> String:
	return gname
