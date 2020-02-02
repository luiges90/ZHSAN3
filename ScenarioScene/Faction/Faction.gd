extends Node

var _id
var _architecture_list = Array()

var scenario

var dname
var color

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func load_data(json):
	_id = json["_Id"]
	dname = json["Name"]
	color = Util.load_color(json["Color"])
	for id in json["ArchitectureList"]:
		add_architecture(scenario.architectures[id])
	
func get_id():
	return _id
	
func add_architecture(arch, force = false):
	_architecture_list.append(arch)
	if not force:
		arch.set_belonged_faction(self, true)
