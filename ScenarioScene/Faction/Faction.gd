extends Node

var _id
var _architecture_list

var scenario

var dname
var color

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func load_data(json):
	_id = json["_Id"]
	dname = json["Name"]
	
func add_architecture(arch, force = false):
	_architecture_list.add(arch)
	if not force:
		arch.set_belonged_faction(self, true)
