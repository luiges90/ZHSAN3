extends Node
class_name ArchitectureKind

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
var image: Texture2D :
	get:
		return image # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var _image_path: String :
	get:
		return _image_path # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

var agriculture: int :
	get:
		return agriculture # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var commerce: int :
	get:
		return commerce # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var morale: int :
	get:
		return morale # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var endurance: int :
	get:
		return endurance # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden
var population: int :
	get:
		return population # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

func forbidden(x):
	assert(false)

func load_data(json: Dictionary, objects):
	id = json["_Id"]
	gname = json["Name"]
	_image_path = json["Image"]
	image = load("res://Images/Architecture/" + _image_path)
	agriculture = json["Agriculture"]
	commerce = json["Commerce"]
	morale = json["Morale"]
	endurance = json["Endurance"]
	population = json["Population"]
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Name": gname,
		"Image": _image_path,
		"Agriculture": agriculture,
		"Commerce": commerce,
		"Morale": morale,
		"Endurance": endurance,
		"Population": population
	}
	
func get_name() -> StringName:
	return StringName(gname)
