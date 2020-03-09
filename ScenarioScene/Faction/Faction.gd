extends Node
class_name Faction

var id: int setget forbidden
var scenario

var gname: String setget forbidden
var color: Color setget forbidden

var _section_list = Array() setget forbidden, get_sections

var player_controlled: bool

func forbidden(x):
	assert(false)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func get_name():
	return gname

func load_data(json: Dictionary):
	id = json["_Id"]
	gname = json["Name"]
	color = Util.load_color(json["Color"])
	player_controlled = json["PlayerControlled"]
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Name": gname,
		"Color": Util.save_color(color),
		"PlayerControlled": player_controlled,
		"SectionList": Util.id_list(get_sections())
	}
	
func get_architectures() -> Array:
	var result = []
	for s in get_sections():
		Util.append_all(result, s.get_architectures())
	return result
	
func get_sections() -> Array:
	return _section_list
	
func add_section(section, force: bool = false):
	_section_list.append(section)
	if not force:
		section.set_belonged_faction(self, true)
		
func day_event():
	for arch in get_architectures():
		arch.day_event()

func month_event():
	for arch in get_architectures():
		arch.month_event()
