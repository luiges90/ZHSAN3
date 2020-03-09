extends Node
class_name Section

var id: int setget forbidden
var scenario

var gname: String setget forbidden

var _belonged_faction setget set_belonged_faction, get_belonged_faction 
var _architecture_list: Array setget forbidden, get_architectures

func forbidden(x):
	assert(false)

func load_data(json: Dictionary):
	id = json["_Id"]
	gname = json["Name"]
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Name": gname,
		"ArchitectureList": Util.id_list(get_architectures())
	}

func get_architectures():
	return _architecture_list

func add_architecture(arch, force: bool = false):
	_architecture_list.append(arch)
	if not force:
		arch.set_belonged_section(self, true)

func get_belonged_faction(): 
	return _belonged_faction
	
func set_belonged_faction(faction, force = false):
	_belonged_faction = faction
	if not force:
		faction.add_architecture(self, true)
