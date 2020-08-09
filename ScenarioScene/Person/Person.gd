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

var gender: bool setget forbidden

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

var command_exp: int setget forbidden
var strength_exp: int setget forbidden
var intelligence_exp: int setget forbidden
var politics_exp: int setget forbidden
var glamour_exp: int setget forbidden

var popularity: int setget forbidden
var karma: int setget forbidden

var working_task setget forbidden
var producing_equipment setget forbidden

var task_days = 0 setget forbidden

var skills = [] setget forbidden

func forbidden(x):
	assert(false)

####################################
#           Save / Load            #
####################################

func load_data(json: Dictionary, objects):
	id = json["_Id"]
	_status = int(json["Status"])
	gender = json["Gender"]
	surname = json["Surname"]
	given_name = json["GivenName"]
	courtesy_name = json["CourtesyName"]
	command = int(json["Command"])
	strength = int(json["Strength"])
	intelligence = int(json["Intelligence"])
	politics = int(json["Politics"])
	glamour = int(json["Glamour"])
	command_exp = int(json["CommandExperience"])
	strength_exp = int(json["StrengthExperience"])
	intelligence_exp = int(json["IntelligenceExperience"])
	politics_exp = int(json["PoliticsExperience"])
	glamour_exp = int(json["GlamourExperience"])
	popularity = int(json["Popularity"])
	karma = int(json["Karma"])
	working_task = int(json["Task"])
	producing_equipment = null if json["ProducingEquipment"] == null else int(json["ProducingEquipment"])
	for id in json["Skills"]:
		skills.append(objects["skills"][int(id)])
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Status": _status,
		"Gender": gender,
		"Surname": surname,
		"GivenName": given_name,
		"CourtesyName": courtesy_name,
		"Command": command,
		"Strength": strength,
		"Intelligence": intelligence,
		"Politics": politics,
		"Glamour": glamour,
		"CommandExperience": command_exp,
		"StrengthExperience": strength_exp,
		"IntelligenceExperience": intelligence_exp,
		"PoliticsExperience": politics_exp,
		"GlamourExperience": glamour_exp,
		"Popularity": popularity,
		"Karma": karma,
		"Task": working_task,
		"ProducingEquipment": producing_equipment,
		"Skills": Util.id_list(skills)
	}
	
#####################################
#          Getters / Basic          #
#####################################
func get_gender_str() -> String:
	return tr('FEMALE') if gender else tr('MALE')

func get_name() -> String:
	return surname + given_name
	
func get_full_name() -> String:
	var name = surname + given_name
	if courtesy_name.length() > 0:
		name += "(" + courtesy_name + ")"
	return name
	
func get_popularity():
	return popularity
	
func get_popularity_str():
	return str(popularity)
	
func get_karma():
	return karma
	
func get_karma_str():
	return str(karma)
	
func get_portrait():
	if SharedData.person_portraits.has(id):
		return SharedData.person_portraits[id]
	else:
		if gender:
			if SharedData.person_portraits.has(SharedData.PERSON_PORTRAIT_DEFAULT_FEMALE):
				return SharedData.person_portraits[SharedData.PERSON_PORTRAIT_DEFAULT_FEMALE]
			else:
				return SharedData.person_portraits[SharedData.PERSON_PORTRAIT_BLANK]
		elif command + strength > intelligence + politics:
			if SharedData.person_portraits.has(SharedData.PERSON_PORTRAIT_DEFAULT_MALE_MARTIAL):
				return SharedData.person_portraits[SharedData.PERSON_PORTRAIT_DEFAULT_MALE_MARTIAL]
			else:
				return SharedData.person_portraits[SharedData.PERSON_PORTRAIT_BLANK]
		else:
			if SharedData.person_portraits.has(SharedData.PERSON_PORTRAIT_DEFAULT_MALE_OFFICER):
				return SharedData.person_portraits[SharedData.PERSON_PORTRAIT_DEFAULT_MALE_OFFICER]
			else:
				return SharedData.person_portraits[SharedData.PERSON_PORTRAIT_BLANK]

#####################################
#    Getters / Tasks and Statuses   #
#####################################
func get_location(): 
	return _location

func get_location_str():
	var location = get_location()
	return location.get_name() if location != null else '----'

func get_status():
	return _status
	
func get_status_str() -> String:
	if is_faction_leader():
		return tr('STATUS_FACTION_LEADER')
	match _status:
		Status.NONE: return '--'
		Status.NORMAL: return tr('STATUS_NORMAL')
		Status.WILD: return tr('STATUS_WILD')
		_: return '--'

func get_belonged_faction():
	return get_location().get_belonged_faction()
	
func get_belonged_faction_str():
	var faction = get_belonged_faction()
	return faction.get_name() if faction != null else '----'
	
func get_belonged_section():
	return get_location().get_belonged_section()
	
func get_belonged_section_str():
	var section = get_belonged_section()
	return section.get_name() if section != null else '----'
	
func is_faction_leader():
	var faction = get_belonged_faction()
	return faction != null and faction.get_leader().id == id
	
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

#####################################
#         Getters / Abilities       #
#####################################
func get_command():
	return command + command_exp / 1000
	
func get_command_detail_str():
	return str(command) + "(+" + str(command_exp / 1000) + ")"
	
func get_strength():
	return strength + strength_exp / 1000
	
func get_strength_detail_str():
	return str(strength) + "(+" + str(strength_exp / 1000) + ")"
	
func get_intelligence():
	return intelligence + intelligence_exp / 1000
	
func get_intelligence_detail_str():
	return str(intelligence) + "(+" + str(intelligence_exp / 1000) + ")"
	
func get_politics():
	return politics + politics_exp / 1000
	
func get_politics_detail_str():
	return str(politics) + "(+" + str(politics_exp / 1000) + ")"
	
func get_glamour():
	return glamour + glamour_exp / 1000
	
func get_glamour_detail_str():
	return str(glamour) + "(+" + str(glamour_exp / 1000) + ")"
	
func get_agriculture_ability():
	var base = 0.25 * get_intelligence() + 0.5 * get_politics() + 0.25 * get_glamour()
	base = apply_influences('modify_person_agriculture_ability', {"value": base})
	return base
	
func get_commerce_ability():
	var base = 0.5 * get_intelligence() + 0.25 * get_politics() + 0.25 * get_glamour()
	base = apply_influences('modify_person_commerce_ability', {"value": base})
	return base
	
func get_morale_ability():
	var base = 0.25 * get_command() + 0.25 * get_strength() + 0.5 * get_glamour()
	base = apply_influences('modify_person_morale_ability', {"value": base})
	return base
	
func get_endurance_ability():
	var base = 0.25 * get_command() + 0.25 * get_strength() + 0.25 * get_intelligence() + 0.25 * get_politics()
	base = apply_influences('modify_person_endurance_ability', {"value": base})
	return base
	
func get_recruit_troop_ability():
	var base = 0.5 * get_strength() + 0.5 * get_glamour()
	base = apply_influences('modify_person_recruit_ability', {"value": base})
	return base
	
func get_train_troop_ability():
	var base = 0.5 * get_command() + 0.5 * get_strength()
	base = apply_influences('modify_person_training_ability', {"value": base})
	return base
	
func get_produce_equipment_ability():
	var base = 0.5 * get_intelligence() + 0.5 * get_politics()
	base = apply_influences('modify_person_produce_equipment_ability', {"value": base})
	return base
	
func get_merit():
	return get_command() + get_strength() + get_intelligence() + get_politics() + get_glamour()
	
func get_troop_leader_merit():
	return get_command() * 1.7 + get_strength() * 0.3
	
func get_max_troop_quantity() -> int:
	return 5000

####################################
#         Influence System         #
####################################
func apply_influences(operation, params):
	if params.has("value"):
		var value = params["value"]
		for skill in skills:
			value = skill.apply_influences(operation, {"value": value})
		return value

#####################################
# Manipulation / Tasks and Statuses #
#####################################
	
func set_location(item, force = false):
	if _location != null:
		_location.remove_person(self)
	_location = item
	if not force:
		item.add_person(self, true)

func become_wild():
	_status = Status.WILD

func set_working_task(work):
	working_task = work
	producing_equipment = null
	
func set_produce_equipment(equipment: int):
	producing_equipment = equipment
	
func move_to_architecture(arch):
	var old_location = get_location()
	set_location(arch)
	working_task = Task.MOVE
	task_days = int(ScenarioUtil.object_distance(old_location, arch) * 0.2)
		
		
####################################
#             Day event            #
####################################
func day_event():
	if task_days > 0:
		task_days -= 1
	
