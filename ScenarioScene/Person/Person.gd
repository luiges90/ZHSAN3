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
var prestige: int setget forbidden
var karma: int setget forbidden
var merit: int setget forbidden

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
	prestige = int(json["Prestige"])
	karma = int(json["Karma"])
	merit = int(json["Merit"])
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
		"Prestige": prestige,
		"Karma": karma,
		"Merit": merit,
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
	
func get_prestige():
	return prestige
	
func get_prestige_str():
	return str(prestige)
	
func get_merit():
	return merit
	
func get_merit_str():
	return str(merit)
	
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

func get_salary():
	var base = 10
	base = apply_influences("modify_person_salary", {"value": base, "person": self})
	return base

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
		
func get_biography_text():
	var bio = scenario.biographies
	if bio.has(id):
		return bio[id].text
	else:
		return ""

#####################################
#         Getters / Abilities       #
#####################################
func get_command():
	return command + command_exp / 1000
	
func get_command_detail_str():
	return str(get_command()) + "(+" + str(command_exp / 1000) + ")"
	
func get_strength():
	return strength + strength_exp / 1000
	
func get_strength_detail_str():
	return str(get_strength()) + "(+" + str(strength_exp / 1000) + ")"
	
func get_intelligence():
	return intelligence + intelligence_exp / 1000
	
func get_intelligence_detail_str():
	return str(get_intelligence()) + "(+" + str(intelligence_exp / 1000) + ")"
	
func get_politics():
	return politics + politics_exp / 1000
	
func get_politics_detail_str():
	return str(get_politics()) + "(+" + str(politics_exp / 1000) + ")"
	
func get_glamour():
	return glamour + glamour_exp / 1000
	
func get_glamour_detail_str():
	return str(get_glamour()) + "(+" + str(glamour_exp / 1000) + ")"
	
func get_agriculture_ability():
	var base = 0.25 * get_intelligence() + 0.5 * get_politics() + 0.25 * get_glamour()
	base = apply_influences('modify_person_agriculture_ability', {"value": base, "person": self})
	return base
	
func get_commerce_ability():
	var base = 0.5 * get_intelligence() + 0.25 * get_politics() + 0.25 * get_glamour()
	base = apply_influences('modify_person_commerce_ability', {"value": base, "person": self})
	return base
	
func get_morale_ability():
	var base = 0.25 * get_command() + 0.25 * get_strength() + 0.5 * get_glamour()
	base = apply_influences('modify_person_morale_ability', {"value": base, "person": self})
	return base
	
func get_endurance_ability():
	var base = 0.25 * get_command() + 0.25 * get_strength() + 0.25 * get_intelligence() + 0.25 * get_politics()
	base = apply_influences('modify_person_endurance_ability', {"value": base, "person": self})
	return base
	
func get_recruit_troop_ability():
	var base = 0.5 * get_strength() + 0.5 * get_glamour()
	base = apply_influences('modify_person_recruit_ability', {"value": base, "person": self})
	return base
	
func get_train_troop_ability():
	var base = 0.5 * get_command() + 0.5 * get_strength()
	base = apply_influences('modify_person_training_ability', {"value": base, "person": self})
	return base
	
func get_produce_equipment_ability():
	var base = 0.5 * get_intelligence() + 0.5 * get_politics()
	base = apply_influences('modify_person_produce_equipment_ability', {"value": base, "person": self})
	return base

func get_troop_leader_ability(params = null):
	var mk = params["military_kind"] if params != null else null
	var out_params = {
		"person": self
	}
	if mk != null:
		out_params['military_kind'] = mk
	
	var command = get_command()
	var strength = get_strength()
	
	var command_factor = 1
	var strength_factor = 1
	for s in skills:
		command_factor *= ScenarioUtil.influence_troop_leader_defensive_factor(s, out_params)
		strength_factor *= ScenarioUtil.influence_troop_leader_offensive_factor(s, out_params)
	
	return command * 1.7 + strength * 0.3
	
func get_max_troop_quantity() -> int:
	var base = 5000
	base = apply_influences('modify_person_max_troop_quantity', {"value": base, "person": self})
	return base

####################################
#         Influence System         #
####################################
func apply_influences(operation, params: Dictionary):
	if params.has("value"):
		var value = params["value"]
		for skill in skills:
			value = skill.apply_influences(operation, {"value": value, "person": self})
		return value

####################################
#       Manipulation / Basic       #
####################################
func add_popularity(delta):
	if delta > 0:
		popularity = Util.f2ri(popularity + delta * (1.0 - popularity / 10000.0))
	elif delta < 0:
		popularity = max(0, Util.f2ri(popularity - delta))
		
func add_prestige(delta):
	if delta > 0:
		prestige = Util.f2ri(prestige + delta * (1.0 - max(0, prestige) / 10000.0))
	elif delta < 0:
		if prestige > 0:
			if abs(delta) <= prestige:
				prestige = prestige + Util.f2ri(delta)
				delta = 0
			else:
				delta = delta + prestige
				prestige = 0
		if delta < 0:
			prestige = Util.f2ri(prestige + delta * (1.0 - abs(prestige) / 10000.0))
	
func add_karma(delta):
	if delta > 0:
		karma = Util.f2ri(karma + delta * (1.0 - abs(karma) / 10000.0))
	elif delta < 0:
		if karma > 0:
			if abs(delta) <= karma:
				karma = karma + Util.f2ri(delta)
				delta = 0
			else:
				delta = delta + karma
				karma = 0
		if delta < 0:
			karma = Util.f2ri(karma + delta * (1.0 - abs(karma) / 10000.0))
			
func add_merit(delta):
	merit = Util.f2ri(merit + delta)

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
	
func clear_working_task():
	working_task = null
	producing_equipment = null

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
	task_days = apply_influences("modify_person_movement_time", {"value": task_days, "person": self})
		
####################################
#     Manipulation / Abilities     #
####################################

func add_command_exp(delta):
	delta = apply_influences("modify_person_experience_gain", {"value": delta, "person": self})
	command_exp = Util.f2ri(command_exp + delta * (50.0 / (get_command() + 50)))
	
func add_strength_exp(delta):
	delta = apply_influences("modify_person_experience_gain", {"value": delta, "person": self})
	strength_exp = Util.f2ri(strength_exp + delta * (50.0 / (get_strength() + 50)))
	
func add_intelligence_exp(delta):
	delta = apply_influences("modify_person_experience_gain", {"value": delta, "person": self})
	intelligence_exp = Util.f2ri(intelligence_exp + delta * (50.0 / (get_intelligence() + 50)))
	
func add_politics_exp(delta):
	delta = apply_influences("modify_person_experience_gain", {"value": delta, "person": self})
	politics_exp = Util.f2ri(politics_exp + delta * (50.0 / (get_politics() + 50)))
	
func add_glamour_exp(delta):
	delta = apply_influences("modify_person_experience_gain", {"value": delta, "person": self})
	glamour_exp = Util.f2ri(glamour_exp + delta * (50.0 / (get_glamour() + 50)))
	

####################################
#             Day event            #
####################################
func day_event():
	if task_days > 0:
		task_days -= 1
	
