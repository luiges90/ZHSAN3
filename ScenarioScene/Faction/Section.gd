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

####################################
#             Save / Load          #
####################################
func load_data(json: Dictionary, objects):
	id = json["_Id"]
	gname = json["Name"]
	
	for id in json["ArchitectureList"]:
		add_architecture(objects["architectures"][int(id)])
	for id in json["TroopList"]:
		add_troop(objects["troops"][int(id)])
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Name": gname,
		"ArchitectureList": Util.id_list(get_architectures()),
		"TroopList": Util.id_list(get_troops())
	}
	
####################################
#           GÌ°èet function           #
####################################
func get_name():
	return gname

func get_architectures():
	return _architecture_list

func get_troops():
	return _troop_list

func get_belonged_faction(): 
	return _belonged_faction

func get_persons():
	var result = []
	for a in get_architectures():
		Util.append_all(result, a.get_faction_persons())
	return result

func get_total_fund():
	var result = 0
	for a in get_architectures():
		result += a.fund
	return result

func get_total_food():
	var result = 0
	for a in get_architectures():
		result += a.food
	return result
	
func get_total_troop():
	var result = 0
	for a in get_architectures():
		result += a.troop
	return result

####################################
#           Manipulation           #
####################################
func add_architecture(arch, force: bool = false):
	_architecture_list.append(arch)
	if not force:
		arch.set_belonged_section(self, true)
		
func remove_architecture(arch, force: bool = false):
	_architecture_list.erase(arch)
	if not force:
		arch.set_belonged_section(null, true)

func add_troop(troop, force: bool = false):
	_troop_list.append(troop)
	if not force:
		troop.set_belonged_section(self, true)
		
func remove_troop(troop):
	_troop_list.erase(troop)
	scenario.remove_troop(troop)
	
func set_belonged_faction(faction, force = false):
	_belonged_faction = faction
	if not force:
		faction.add_architecture(self, true)

func destroy():
	for t in get_troops():
		t.destroy(null)
	
