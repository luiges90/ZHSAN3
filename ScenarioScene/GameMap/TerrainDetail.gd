extends Node
class_name TerrainDetail

var id: int :
	get:
		return id # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var scenario

var gname: String :
	get:
		return gname # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var terrain_ids = [] :
	get:
		return terrain_ids # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var is_naval: bool :
	get:
		return is_naval # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
 
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
