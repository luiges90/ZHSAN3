extends Node
class_name Faction

var _id: int setget ,get_id
var scenario

var gname: String
var color: Color

var _architecture_list = Array() setget ,get_architectures

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func load_data(json: Dictionary):
	_id = json["_Id"]
	gname = json["Name"]
	color = Util.load_color(json["Color"])
	
func get_id() -> int:
	return _id
	
func get_architectures() -> Array:
	return _architecture_list
	
func add_architecture(arch, force: bool = false):
	_architecture_list.append(arch)
	if not force:
		arch.set_belonged_faction(self, true)
