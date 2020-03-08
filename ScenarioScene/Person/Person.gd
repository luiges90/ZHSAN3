extends Node
class_name Person

enum Task { NONE, AGRICULTURE, COMMERCE, MORALE, ENDURANCE, MOVE }

var id: int setget forbidden
var scenario

var surname: String setget forbidden
var given_name: String setget forbidden
var courtesy_name: String setget forbidden

var _belonged_architecture setget set_belonged_architecture,get_belonged_architecture

var command: int setget forbidden
var strength: int setget forbidden
var intelligence: int setget forbidden
var politics: int setget forbidden
var glamour: int setget forbidden

var working_task setget forbidden

func forbidden(x):
	assert(false)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func load_data(json: Dictionary):
	id = json["_Id"]
	surname = json["Surname"]
	given_name = json["GivenName"]
	courtesy_name = json["CourtesyName"]
	command = json["Command"]
	strength = json["Strength"]
	intelligence = json["Intelligence"]
	politics = json["Politics"]
	glamour = json["Glamour"]
	working_task = json["Task"]
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Surname": surname,
		"GivenName": given_name,
		"CourtesyName": courtesy_name,
		"Command": command,
		"Strength": strength,
		"Intelligence": intelligence,
		"Politics": politics,
		"Glamour": glamour,
		"Task": working_task
	}

func get_name() -> String:
	return surname + given_name
	
func get_belonged_architecture(): 
	return _belonged_architecture
	
func set_belonged_architecture(arch, force = false):
	_belonged_architecture = arch
	if not force:
		arch.add_person(self, true)
		
func get_agriculture_ability():
	return 0.25 * intelligence + 0.5 * politics + 0.25 * glamour
	
func get_commerce_ability():
	return 0.5 * intelligence + 0.25 * politics + 0.25 * glamour
	
func get_morale_ability():
	return 0.25 * command + 0.25 * strength + 0.5 * glamour
	
func get_endurance_ability():
	return 0.25 * command + 0.25 * strength + 0.25 * intelligence + 0.25 * politics
	
func set_working_task(work):
	working_task = work
	
func get_working_task_str():
	match working_task:
		Task.NONE: return tr('NONE')
		Task.AGRICULTURE: return tr('AGRICULTURE')
		Task.COMMERCE: return tr('COMMERCE')
		Task.MORALE: return tr('MORALE')
		Task.ENDURANCE: return tr('ENDURANCE')
		_: return tr('NONE')
		
func move_to_architecture(arch):
	print(self.get_name() + ' move to ' + arch.get_name())
	pass
		
func day_event():
	pass
