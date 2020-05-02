extends Node
class_name Section

var id: int setget forbidden
var scenario

var gname: String setget forbidden

var _belonged_faction setget set_belonged_faction, get_belonged_faction 
var _architecture_list: Array setget forbidden, get_architectures
var _troop_list: Array setget forbidden, get_troops

func forbidden(x):
	assert(false)

func load_data(json: Dictionary):
	id = json["_Id"]
	gname = json["Name"]
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Name": gname,
		"ArchitectureList": Util.id_list(get_architectures()),
		"TroopList": Util.id_list(get_troops())
	}
	
func get_name():
	return gname

func get_architectures():
	return _architecture_list

func add_architecture(arch, force: bool = false):
	_architecture_list.append(arch)
	if not force:
		arch.set_belonged_section(self, true)

func get_troops():
	return _troop_list

func add_troop(troop, force: bool = false):
	_troop_list.append(troop)
	if not force:
		troop.set_belonged_section(self, true)

func get_belonged_faction(): 
	return _belonged_faction
	
func set_belonged_faction(faction, force = false):
	_belonged_faction = faction
	if not force:
		faction.add_architecture(self, true)

func get_persons():
	var result = []
	for a in get_architectures():
		Util.append_all(result, a.get_persons())
	return result
