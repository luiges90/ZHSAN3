extends Node
class_name Person

var _id: int setget ,get_id
var scenario

var surname: String
var given_name: String
var courtesy_name: String

var _belonged_architecture setget set_belonged_architecture,get_belonged_architecture

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func load_data(json: Dictionary):
	_id = json["_Id"]
	surname = json["Surname"]
	given_name = json["GivenName"]
	courtesy_name = json["CourtesyName"]
	
func get_id() -> int:
	return _id
	
func get_name() -> String:
	return surname + given_name
	
func get_belonged_architecture(): 
	return _belonged_architecture
	
func set_belonged_architecture(arch, force = false):
	_belonged_architecture = arch
	if not force:
		arch.add_person(self, true)
