extends Node
class_name Person

enum Task { NONE, 
	AGRICULTURE, COMMERCE, MORALE, ENDURANCE, 
	MOVE, 
	RECRUIT_TROOP, TRAIN_TROOP, PRODUCE_EQUIPMENT }
enum Status { NONE,
	NORMAL, WILD
}

var id: int setget forbidden
var scenario

var surname: String setget forbidden
var given_name: String setget forbidden
var courtesy_name: String setget forbidden

var _location setget set_location, get_location
var _status = Status.NONE setget forbidden, get_status

var command: int setget forbidden
var strength: int setget forbidden
var intelligence: int setget forbidden
var politics: int setget forbidden
var glamour: int setget forbidden

var working_task setget forbidden
var producing_equipment setget forbidden

var task_days = 0 setget forbidden


func forbidden(x):
	assert(false)


func load_data(json: Dictionary):
	id = json["_Id"]
	surname = json["Surname"]
	given_name = json["GivenName"]
	courtesy_name = json["CourtesyName"]
	command = int(json["Command"])
	strength = int(json["Strength"])
	intelligence = int(json["Intelligence"])
	politics = int(json["Politics"])
	glamour = int(json["Glamour"])
	working_task = int(json["Task"])
	producing_equipment = null if json["ProducingEquipment"] == null else int(json["ProducingEquipment"])
	
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
		"Task": working_task,
		"ProducingEquipment": producing_equipment
	}

func get_name() -> String:
	return surname + given_name
	
func get_location(): 
	return _location
	
func set_location(item, force = false):
	if _location != null:
		_location.remove_person(self)
	_location = item
	if not force:
		item.add_person(self, true)
		
func get_status():
	return _status
	
func set_status(status, force = false):
	_status = status
	
func get_agriculture_ability():
	return 0.25 * intelligence + 0.5 * politics + 0.25 * glamour
	
func get_commerce_ability():
	return 0.5 * intelligence + 0.25 * politics + 0.25 * glamour
	
func get_morale_ability():
	return 0.25 * command + 0.25 * strength + 0.5 * glamour
	
func get_endurance_ability():
	return 0.25 * command + 0.25 * strength + 0.25 * intelligence + 0.25 * politics
	
func get_recruit_troop_ability():
	return 0.5 * strength + 0.5 * glamour
	
func get_train_troop_ability():
	return 0.5 * command + 0.5 * strength
	
func get_produce_equipment_ability():
	return 0.5 * intelligence + 0.5 * politics
	
func get_leader_value():
	return command
	
func set_working_task(work):
	working_task = work
	producing_equipment = null
	
func set_produce_equipment(equipment: int):
	producing_equipment = equipment
	
func get_working_task_str():
	match working_task:
		Task.NONE: return tr('NONE')
		Task.AGRICULTURE: return tr('AGRICULTURE')
		Task.COMMERCE: return tr('COMMERCE')
		Task.MORALE: return tr('MORALE')
		Task.ENDURANCE: return tr('ENDURANCE')
		Task.RECRUIT_TROOP: return tr('RECRUIT_TROOP')
		Task.TRAIN_TROOP: return tr('TRAIN_TROOP')
		Task.PRODUCE_EQUIPMENT: return tr('PRODUCE_EQUIPMENT')
		_: return tr('NONE')
		
func get_producing_equipment_name():
	if producing_equipment == null:
		return "--"
	else:
		return scenario.military_kinds[int(producing_equipment)].get_name()

func get_max_troop_quantity() -> int:
	return 5000
		
func move_to_architecture(arch):
	var old_location = get_location()
	set_location(arch)
	working_task = Task.MOVE
	task_days = int(ScenarioUtil.object_distance(old_location, arch) * 0.2)
		
func day_event():
	if task_days > 0:
		task_days -= 1
	
