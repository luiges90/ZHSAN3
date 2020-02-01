extends Node

var _id
var _architecture_list

var scenario

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func load_data(json):
	_id = json["Id"]
	
func add_architecture(arch):
	arch.belonged_faction = self
	_architecture_list.add(arch)
