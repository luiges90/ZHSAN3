extends Node
class_name Person

enum Task { NONE, 
	AGRICULTURE, COMMERCE, MORALE, ENDURANCE, 
	MOVE, 
	RECRUIT_TROOP, TRAIN_TROOP, PRODUCE_EQUIPMENT,
	CONVINCE }
enum Status { NONE,
	NORMAL, WILD, CAPTIVE
}
enum DeadReason { NATURAL, UNNNATURAL }
enum AvailableReason { BROTHER, SPOUSE, CHILDREN, SIBLING, NONE }

var id: int setget forbidden
var scenario

var alive: bool setget forbidden
var gender: bool setget forbidden

var surname: String setget forbidden
var given_name: String setget forbidden
var courtesy_name: String setget forbidden

var _location setget set_location, get_location
var _status = Status.NONE setget forbidden, get_status
var _old_faction_id = -1 setget forbidden

var command: int setget forbidden
var strength: int setget forbidden
var intelligence: int setget forbidden
var politics: int setget forbidden
var glamour: int setget forbidden

var internal_exp: int setget forbidden
var combat_exp: int setget forbidden
var stratagem_exp: int setget forbidden

var command_exp: int setget forbidden
var strength_exp: int setget forbidden
var intelligence_exp: int setget forbidden
var politics_exp: int setget forbidden
var glamour_exp: int setget forbidden

var military_type_exp: Dictionary setget forbidden

var popularity: int setget forbidden
var prestige: int setget forbidden
var karma: int setget forbidden
var merit: int setget forbidden

var available_year: int setget forbidden
var born_year: int setget forbidden
var death_year: int setget forbidden
var available_architecture_id: int setget forbidden
var dead_reason setget forbidden

var working_task setget forbidden
var producing_equipment setget forbidden

var task_days = 0 setget forbidden
var task_target setget forbidden

var skills = {} setget forbidden
var stunts = {} setget forbidden

var strain: int setget forbidden
var father setget forbidden
var mother setget forbidden
var spouses = [] setget forbidden
var brothers = [] setget forbidden

var ideal: int setget forbidden
var loyalty_shift: int

var ambition: int setget forbidden
var morality: int setget forbidden

var troop_damage_dealt: int
var troop_damage_received: int
var arch_damage_dealt: int
var rout_count: int
var routed_count: int
var capture_count: int
var be_captured_count: int

var person_relations = {} setget forbidden

signal person_died
signal person_available

signal convince_success
signal convince_failure

signal move_complete

func forbidden(x):
	assert(false)

func object_type():
	return ScenarioUtil.ObjectType.PERSON

####################################
#           Save / Load            #
####################################

func load_data(json: Dictionary, objects):
	id = json["_Id"]
	_status = int(json["Status"])
	alive = json["Alive"]
	gender = json["Gender"]
	surname = json["Surname"]
	given_name = json["GivenName"]
	courtesy_name = json["CourtesyName"]
	available_year = json['AvailableYear']
	born_year = json['BornYear']
	death_year = json['DeathYear']
	available_architecture_id = json['AvailableArchitectureId']
	command = int(json["Command"])
	strength = int(json["Strength"])
	intelligence = int(json["Intelligence"])
	politics = int(json["Politics"])
	glamour = int(json["Glamour"])
	internal_exp = int(json["InternalExperience"])
	combat_exp = int(json["CombatExperience"])
	command_exp = int(json["CommandExperience"])
	strength_exp = int(json["StrengthExperience"])
	intelligence_exp = int(json["IntelligenceExperience"])
	politics_exp = int(json["PoliticsExperience"])
	glamour_exp = int(json["GlamourExperience"])
	stratagem_exp = int(json["StratagemExperience"])
	military_type_exp = json["MilitaryTypeExperience"]
	popularity = int(json["Popularity"])
	prestige = int(json["Prestige"])
	karma = int(json["Karma"])
	merit = int(json["Merit"])
	working_task = int(json["Task"]) if json["Task"] != null else Task.NONE
	producing_equipment = Util.dict_try_get(json, "ProducingEquipment", null)
	strain = int(json["Strain"])
	ideal = int(json["Ideal"])
	loyalty_shift = int(json["LoyaltyShift"])
	ambition = int(json["Ambition"])
	morality = int(json["Morality"])
	for id in json["Skills"]:
		skills[objects["skills"][int(id)]] = json["Skills"][id]
	for id in json["Stunts"]:
		stunts[objects["stunts"][int(id)]] = json["Stunts"][id]
	troop_damage_dealt = Util.dict_try_get(json, "TroopDamageDealt", 0)
	troop_damage_received = Util.dict_try_get(json, "TroopDamageReceived", 0)
	arch_damage_dealt = Util.dict_try_get(json, "ArchDamageDealt", 0)
	rout_count = Util.dict_try_get(json, "RoutCount", 0)
	routed_count = Util.dict_try_get(json, "RoutedCount", 0)
	capture_count = Util.dict_try_get(json, "CaptureCount", 0)
	be_captured_count = Util.dict_try_get(json, "BeCapturedCount", 0)
	person_relations = Util.dict_try_get(json, "PersonRelations", {})
	
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Status": _status,
		"Alive": alive,
		"Gender": gender,
		"Surname": surname,
		"GivenName": given_name,
		"CourtesyName": courtesy_name,
		"AvailableYear": available_year,
		"BornYear": born_year,
		"DeathYear": death_year,
		"AvailableArchitectureId": available_architecture_id,
		"Command": command,
		"Strength": strength,
		"Intelligence": intelligence,
		"Politics": politics,
		"Glamour": glamour,
		"InternalExperience": internal_exp,
		"CombatExperience": combat_exp,
		"CommandExperience": command_exp,
		"StrengthExperience": strength_exp,
		"IntelligenceExperience": intelligence_exp,
		"PoliticsExperience": politics_exp,
		"GlamourExperience": glamour_exp,
		"StratagemExperience": stratagem_exp,
		"MilitaryTypeExperience": military_type_exp,
		"Popularity": popularity,
		"Prestige": prestige,
		"Karma": karma,
		"Merit": merit,
		"Task": working_task,
		"TaskTarget": task_target.id if task_target != null else -1,
		"ProducingEquipment": producing_equipment,
		"Skills": Util.id_key_dict(skills),
		"Stunts": Util.id_key_dict(stunts),
		"FatherId": father.id if father != null else -1,
		"MotherId": mother.id if mother != null else -1,
		"SpouseIds": Util.id_list(spouses),
		"BrotherIds": Util.id_list(brothers),
		"Strain": strain,
		"OldFaction": _old_faction_id,
		"Ideal": ideal,
		"LoyaltyShift": loyalty_shift,
		"Ambition": ambition,
		"Morality": morality,
		"TroopDamageDealt": troop_damage_dealt,
		"TroopDamageReceived": troop_damage_received,
		"ArchDamageDealt": arch_damage_dealt,
		"RoutCount": rout_count,
		"RoutedCount": routed_count,
		"CaptureCount": capture_count,
		"BeCapturedCount": be_captured_count,
		"PersonRelations": person_relations
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
	
# range: 0 - 10000
func get_popularity():
	return popularity
	
func get_popularity_str():
	return str(popularity)
	
func set_popularity(v):
	popularity = clamp(v, 0, 10000)
	
# range: -10000 - 10000
func get_karma():
	return karma
	
func set_karma(v):
	karma = clamp(v, -10000, 10000)
	
func get_karma_str():
	return str(karma)
	
# range: -10000 - 10000
func get_prestige():
	return prestige
	
func get_prestige_str():
	return str(prestige)
	
func set_prestige(v):
	prestige = clamp(v, -10000, 10000)
	
func cmp_prestige_desc(a, b):
	return a.get_prestige() > b.get_prestige()

func get_merit():
	return merit
	
func get_merit_str():
	return str(merit)
	
func set_merit(v):
	merit = v

func get_ambition():
	return ambition
	
func get_ambition_str():
	return str(ambition)
	
func set_ambition(v):
	ambition = clamp(v, 0, 100)

func get_morality():
	return morality
	
func get_morality_str():
	return str(morality)
	
func set_morality(v):
	morality = clamp(v, 0, 100)
	
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
	
func get_age():
	if scenario.scenario_config != null and scenario.scenario_config.person_natural_death:
		return scenario.get_year() - born_year + 1
	else:
		return 30
	
func cmp_age_desc(a, b):
	return a.get_age() > b.get_age()
	
func get_expected_death_year():
	return death_year if dead_reason == DeadReason.NATURAL else death_year + 10 + get_strength() / 10
	
func set_ideal(v):
	ideal = v
	
func set_born_year(v):
	born_year = v

func set_death_year(v):
	death_year = v

#####################################
#    Getters / Tasks and Statuses   #
#####################################
func get_location(): 
	return _location

func get_location_str():
	var location = get_location()
	return location.get_name() if location != null else '----'
	
func get_old_faction():
	if _old_faction_id == -1:
		return null
	else:
		return scenario.factions[_old_faction_id]
	
func get_belonged_architecture():
	if _status == Status.CAPTIVE:
		var faction = get_old_faction()
		if faction != null:
			return get_old_faction().capital
	var loc = get_location()
	if loc != null:
		if loc.object_type() == ScenarioUtil.ObjectType.TROOP:
			return loc.get_starting_architecture()
		else:
			return loc
	return null

func get_status():
	return _status
	
func get_status_str() -> String:
	if is_faction_leader():
		match _status:
			Status.CAPTIVE: return tr('STATUS_LEADER_IN_CAPTIVE')
			_: return tr('STATUS_FACTION_LEADER')
	else:
		match _status:
			Status.NONE: return '--'
			Status.NORMAL: return tr('STATUS_NORMAL')
			Status.WILD: return tr('STATUS_WILD')
			Status.CAPTIVE: return tr('STATUS_CAPTIVE')
			_: return '--'

func get_belonged_faction():
	if _status == Status.WILD or _status == Status.NONE:
		return null
	elif _status == Status.CAPTIVE:
		if _old_faction_id == -1 or not scenario.factions.has(_old_faction_id):
			return null
		return scenario.factions[_old_faction_id]
	else:
		var location = get_location()
		return location.get_belonged_faction() if location != null else null
	
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

# range: -100 to 100
func get_person_relation(other):
	if self == other:
		return 999

	var result = (75 - get_ideal_difference(other)) / 3.0 # -25 to 25

	result += other.get_prestige() / 500.0 # -20 to 20
	result += other.get_popularity() / 2000.0 # 0 to 5
	result += other.get_karma() / 1000.0 * (max(0, get_karma() / 2500.0 + 1)) # -50 to 50
	result += min(0, -((get_ambition() + other.get_ambition()) / 20 - 5) * 8) # -40 to 0

	result += Util.dict_try_get(person_relations, other.id, {'value': 0})['value']

	if is_intimate_to(other):
		result += 50
	if is_close_blood_to(other):
		result += 10
	if is_same_strain_to(other):
		result += 10

	return int(result)

func get_person_relation_to_leader():
	var faction = get_belonged_faction()
	return get_person_relation(faction.get_leader()) if faction != null else 0

#####################################
#         Getters / Abilities       #
#####################################
func get_id():
	return id
	
func _set_id(v):
	id = v
	
func _set_gender(v):
	gender = v

func get_command():
	return command + command_exp / 1000
	
func set_command(v):
	command = v
	
func get_command_detail_str():
	return str(get_command()) + "(+" + str(command_exp / 1000) + ")"
	
func get_strength():
	return strength + strength_exp / 1000
	
func set_strength(v):
	strength = v
	
func get_strength_detail_str():
	return str(get_strength()) + "(+" + str(strength_exp / 1000) + ")"
	
func get_intelligence():
	return intelligence + intelligence_exp / 1000

func set_intelligence(v):
	intelligence = v
	
func get_intelligence_detail_str():
	return str(get_intelligence()) + "(+" + str(intelligence_exp / 1000) + ")"
	
func get_politics():
	return politics + politics_exp / 1000
	
func set_politics(v):
	politics = v
	
func get_politics_detail_str():
	return str(get_politics()) + "(+" + str(politics_exp / 1000) + ")"
	
func get_glamour():
	return glamour + glamour_exp / 1000
	
func set_glamour(v):
	glamour = v
	
func get_glamour_detail_str():
	return str(get_glamour()) + "(+" + str(glamour_exp / 1000) + ")"

func get_military_type_experience(type):
	return Util.dict_try_get(military_type_exp, type, 0)
	
func get_agriculture_ability():
	var base = 0.25 * get_intelligence() + 0.5 * get_politics() + 0.25 * get_glamour()
	base *= 1 + sqrt(get_popularity()) * 0.1 + sign(get_prestige()) * sqrt(abs(get_prestige())) * 0.15 + sign(get_karma()) * sqrt(abs(get_karma())) * 0.1
	base = apply_influences('modify_person_agriculture_ability', {"value": base, "person": self})
	return base
	
func get_commerce_ability():
	var base = 0.5 * get_intelligence() + 0.25 * get_politics() + 0.25 * get_glamour()
	base *= 1 + sqrt(get_popularity()) * 0.15 + sign(get_prestige()) * sqrt(abs(get_prestige())) * 0.2 + sign(get_karma()) * sqrt(abs(get_karma())) * 0.2
	base = apply_influences('modify_person_commerce_ability', {"value": base, "person": self})
	return base
	
func get_morale_ability():
	var base = 0.25 * get_command() + 0.25 * get_strength() + 0.5 * get_glamour()
	base *= 1 + sqrt(get_popularity()) * 0.1 + sign(get_prestige()) * sqrt(abs(get_prestige())) * 0.1 + sign(get_karma()) * sqrt(abs(get_karma())) * 0.4
	base = apply_influences('modify_person_morale_ability', {"value": base, "person": self})
	return base
	
func get_endurance_ability():
	var base = 0.25 * get_command() + 0.25 * get_strength() + 0.25 * get_intelligence() + 0.25 * get_politics()
	base *= 1 + sqrt(get_popularity()) * 0.025 + sign(get_prestige()) * sqrt(abs(get_prestige())) * 0.05 + sign(get_karma()) * sqrt(abs(get_karma())) * 0.05
	base = apply_influences('modify_person_endurance_ability', {"value": base, "person": self})
	return base
	
func get_recruit_troop_ability():
	var base = 0.5 * get_strength() + 0.5 * get_glamour()
	base *= 1 + sqrt(get_popularity()) * 0.3 + sign(get_prestige()) * sqrt(abs(get_prestige())) * 0.2 + sign(get_karma()) * sqrt(abs(get_karma())) * 0.05
	base = apply_influences('modify_person_recruit_ability', {"value": base, "person": self})
	return base
	
func get_train_troop_ability():
	var base = 0.5 * get_command() + 0.5 * get_strength()
	base *= 1 + sqrt(get_popularity()) * 0.2 + sign(get_prestige()) * sqrt(abs(get_prestige())) * 0.05 + sign(get_karma()) * sqrt(abs(get_karma())) * 0.05
	base = apply_influences('modify_person_training_ability', {"value": base, "person": self})
	return base
	
func get_produce_equipment_ability():
	var base = 0.5 * get_intelligence() + 0.5 * get_politics()
	base *= 1 + sqrt(get_popularity()) * 0.025 + sign(get_prestige()) * sqrt(abs(get_prestige())) * 0.05 + sign(get_karma()) * sqrt(abs(get_karma())) * 0.05
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
	var critical_factor = 1
	var anti_critical_factor = 1
	var range_factor = sqrt(mk.range_max) - sqrt(mk.range_min) + 1 if mk != null else 1
	for s in skills:
		command_factor *= Influences.influence_troop_leader_defensive_factor(s, skills[s], out_params)
		strength_factor *= Influences.influence_troop_leader_offensive_factor(s, skills[s], out_params)
		critical_factor *= Influences.influence_troop_leader_critical_factor(s, skills[s], out_params)
		anti_critical_factor *= Influences.influence_troop_leader_anti_critical_factor(s, skills[s], out_params)
	
	return (command * command_factor * 0.7 * anti_critical_factor + strength * strength_factor * 0.3 * critical_factor) * range_factor
	
func get_max_troop_quantity() -> int:
	var base = 5000
	base = apply_influences('modify_person_max_troop_quantity', {"value": base, "person": self})
	return base

func get_probability_precision_as_advisor() -> int:
	return int(exp(-0.1351 * get_intelligence() + 14.1682))
	
func get_convince_ability() -> int:
	var base = 0.25 * get_intelligence() + 0.75 * get_glamour()
	base = apply_influences('modify_person_convince_ability', {"value": base, "person": self})
	return base

func get_capture_ability():
	var base = 0.5 * get_strength() + 0.5 * get_intelligence()
	base = apply_influences('modify_person_capture_ability', {"value": base, "person": self})
	return base
	
func get_escape_ability():
	var base = 0.5 * get_strength() + 0.5 * get_intelligence()
	base = apply_influences('modify_person_escape_ability', {"value": base, "person": self})
	return base
	
func __sort_key_id(x, y):
	return x[0].id < y[0].id

func get_skills():
	var sorted = []
	for s in skills:
		sorted.append([s, skills[s]])
	sorted.sort_custom(self, "__sort_key_id")
	var sorted_d = {}
	for s in sorted:
		sorted_d[s[0]] = s[1]
	return sorted_d
	
func set_skills(skill_ids):
	var to_remove = []
	for s in skills:
		if not skill_ids.has(s.id):
			to_remove.append(s)
	for s in to_remove:
		skills.erase(s)
	for id in skill_ids:
		var s = scenario.skills[id]
		if not skills.has(s):
			skills[s] = 1
	
func increment_skill_level(skill):
	if skills[skill] < skill.max_level:
		skills[skill] += 1

func decrement_skill_level(skill):
	if skills[skill] > 1:
		skills[skill] -= 1
	else:
		skills.erase(skill)

func get_stunts():
	var sorted = []
	for s in stunts:
		sorted.append([s, stunts[s]])
	sorted.sort_custom(self, "__sort_key_id")
	var sorted_d = {}
	for s in sorted:
		sorted_d[s[0]] = s[1]
	return sorted_d
	
func set_stunts(stunt_ids):
	var to_remove = []
	for s in stunts:
		if not stunt_ids.has(s.id):
			to_remove.append(s)
	for s in to_remove: 
		stunts.erase(s)
	for id in stunt_ids:
		var s = scenario.stunts[id]
		if not stunts.has(s):
			stunts[s] = 1
	
func increment_stunt_level(stunt):
	if stunts[stunt] < stunt.max_level:
		stunts[stunt] += 1

func decrement_stunt_level(stunt):
	if stunts[stunt] > 1:
		stunts[stunt] -= 1
	else:
		stunts.erase(stunt)

	
#####################################
#         Getters / Relations       #
#####################################
func get_father_name():
	return father.get_name() if father != null else '----'
	
func get_mother_name():
	return mother.get_name() if mother != null else '----'
	
func get_spouse_names():
	var result = ''
	for s in spouses:
		result += "、" + s.get_name()
	if len(result) > 0:
		result = result.substr(1)
	else:
		result = "----"
	return result

func get_brother_names():
	var result = ''
	for s in brothers:
		result += "、" + s.get_name()
	if len(result) > 0:
		result = result.substr(1)
	else:
		result = "----"
	return result
	
func get_children():
	var result = []
	for id in scenario.persons:
		var p = scenario.persons[id]
		if p.father == self or p.mother == self:
			result.append(p)
	return result
	
func get_siblings():
	var result = []
	for id in scenario.persons:
		var p = scenario.persons[id]
		if (p.father != null and p.father == self.father) or (p.mother != null and p.mother == self.mother):
			result.append(p)
	return result

func get_persons_with_same_strain():
	var result = []
	for id in scenario.persons:
		var p = scenario.persons[id]
		if p.strain == self.strain:
			result.append(p)
	return result
	
# range: -75 to 75
func get_ideal_offset(other_person) -> int:
	var r = abs(ideal - other_person.ideal)
	if r > 75:
		r = abs(150 - r)
	return r
	
# range: -75 to 75
func get_ideal_difference(other_person) -> float:
	var diff = get_ideal_offset(other_person)
	diff -= 15
	diff += abs(get_command() - other_person.get_command()) / 50.0 # 0 - 2
	diff += abs(get_strength() - other_person.get_strength()) / 50.0 # 0 - 2
	diff += abs(get_intelligence() - other_person.get_intelligence()) / 50.0 # 0 - 2
	diff += abs(get_politics() - other_person.get_politics()) / 50.0 # 0 - 2
	diff += abs(get_glamour() - other_person.get_glamour()) / 50.0 # 0 - 2
	diff += abs(get_age() - other_person.get_age()) / 20.0 # 0 - 5
	diff += abs(get_ambition() - other_person.get_ambition()) / 10 # 0 - 10
	diff += abs(get_morality() - other_person.get_morality()) / 10 # 0 - 10

	return diff

func is_intimate_to(other_person) -> bool:
	return spouses.has(other_person) or brothers.has(other_person)

func is_close_blood_to(other_person) -> bool:
	return (father != null and (father == other_person or other_person.father == self or other_person.father == father)) or \
		(mother != null and (mother == other_person  or other_person.mother == self or other_person.mother == mother))

func is_same_strain_to(other_person) -> bool:
	return other_person.strain == strain
	
func is_related_blood_to(other_person) -> bool:
	if is_close_blood_to(other_person):
		return true
	var p_grandfather = father.father if father != null else null
	var p_grandmother = father.mother if father != null else null
	var m_grandfather = mother.father if mother != null else null
	var m_grandmother = mother.mother if mother != null else null
	var op_grandfather = other_person.father.father if other_person.father != null else null
	var op_grandmother = other_person.father.mother if other_person.father != null else null
	var om_grandfather = other_person.mother.father if other_person.mother != null else null
	var om_grandmother = other_person.mother.mother if other_person.mother != null else null
	if p_grandfather != null and p_grandfather == other_person.father:
		return true
	if m_grandfather != null and m_grandfather == other_person.father:
		return true
	if op_grandfather != null and op_grandfather == father:
		return true
	if om_grandfather != null and om_grandfather == father:
		return true
	if p_grandmother != null and p_grandmother == other_person.mother:
		return true
	if m_grandmother != null and m_grandmother == other_person.mother:
		return true
	if op_grandmother != null and op_grandmother == mother:
		return true
	if om_grandmother != null and om_grandmother == mother:
		return true
		
	return false


func convince_probability(other_person) -> float:
	var self_diff = other_person.get_ideal_difference(self)
	var leader_diff = other_person.get_ideal_difference(get_belonged_faction().leader)
	var ability = get_convince_ability()
	var advisor = get_belonged_faction().get_intelligent_advisor()
	var advisor_factor = max(0, -8.22565 * exp(-0.01875 * advisor.get_intelligence()) + 2.19742)

	return (1 - (self_diff * 0.3 + leader_diff * 0.7) / 100.0 + (ability + advisor_factor * 10.0) / 100.0) * (1 - (other_person.get_loyalty() - 50) / 50.0)
	
func displayed_convince_probability(other_person):
	var prob = convince_probability(other_person)
	var advisor = get_belonged_faction().get_intelligent_advisor()
	var precision = advisor.get_probability_precision_as_advisor()
	return min(100, max(0, Util.pround(prob * 100, precision)))
	
func convince_recommended(other_person):
	var advisor = get_belonged_faction().get_intelligent_advisor()
	return displayed_convince_probability(other_person) >= 100 - advisor.get_probability_precision_as_advisor()
	
func outside_task_eta_days(target):
	return _move_eta(target.get_location()) * 2
	
func get_loyalty():
	if get_belonged_faction() == null:
		return 0
	var leader = get_belonged_faction().leader
	if self == leader:
		return 999
	
	var loyalty = 100
	loyalty += get_person_relation(leader)

	loyalty += get_morality() / 2 - 25
	loyalty -= get_ambition() / 5 - 10
	
	var prestige = leader.get_prestige()
	if prestige >= 0:
		loyalty += prestige / 1000
	else:
		loyalty += prestige / 200
		
	var karma = leader.get_karma()
	var karma_diff = abs(leader.get_karma() - get_karma())
	if karma < 0:
		loyalty -= karma_diff / 100 * abs(karma / 5000.0)
	
	loyalty += loyalty_shift
	return int(loyalty)

####################################
#         Influence System         #
####################################
func apply_influences(operation, params: Dictionary):
	if params.has("value"):
		var value = params["value"]
		var all_params = params.duplicate()
		all_params["person"] = self
		for skill in skills:
			all_params["value"] = value
			value = skill.apply_influences(operation, skills[skill], all_params)
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
#      Manipulation / Statuses      #
#####################################
	
func set_location(item, force = false):
	if _status != Status.CAPTIVE:
		assert(not is_faction_leader() or get_belonged_faction() == item.get_belonged_faction())
	if _location != null:
		_location.remove_person(self, true)
	_location = item
	if not force:
		item.add_person(self, true)

func become_wild():
	_status = Status.WILD
	_old_faction_id = -1
	
func become_captured(capturer):
	_old_faction_id = get_belonged_faction().id
	_status = Status.CAPTIVE
	set_location(capturer)
	
func become_free():
	_status = Status.NORMAL
	_old_faction_id = -1

func _move_eta(arch):
	var result = get_location().move_eta(arch)
	result = apply_influences("modify_person_movement_time", {"value": result, "person": self})
	return result

func move_to_architecture(arch):
	task_days = _move_eta(arch)
	set_location(arch)
	working_task = Task.MOVE
	
func join_architecture(location_arch):
	_status = Status.NORMAL
	if get_location() != location_arch:
		move_to_architecture(location_arch)
	
	
func become_available():
	var brother_sorted = brothers.duplicate()
	brother_sorted.sort_custom(self, "cmp_age_desc")
	for b in brother_sorted:
		if b._status == Status.NORMAL or b._status == Status.WILD:
			var arch = b.get_belonged_architecture() if b._status != Status.CAPTIVE else b.get_old_faction().capital
			_status = b._status
			arch.add_person(self)
			call_deferred("emit_signal", "person_available", self, AvailableReason.BROTHER, b)
			return
	
	var spouses_sorted = spouses.duplicate()
	spouses_sorted.sort_custom(self, "cmp_age_desc")
	for s in spouses_sorted:
		if s._status == Status.NORMAL or s._status == Status.WILD:
			var arch = s.get_belonged_architecture() if s._status != Status.CAPTIVE else s.get_old_faction().capital
			_status = s._status
			arch.add_person(self)
			call_deferred("emit_signal", "person_available", self, AvailableReason.SPOUSE, s)
			return
	
	if father != null:
		if father._status != Status.NONE:
			var arch = father.get_belonged_architecture() if father._status != Status.CAPTIVE else father.get_old_faction().capital
			_status = father._status
			arch.add_person(self)
			call_deferred("emit_signal", "person_available", self, AvailableReason.CHILDREN, father)
			return
			
	if mother != null:
		if mother._status != Status.NONE:
			var arch = mother.get_belonged_architecture() if mother._status != Status.CAPTIVE else mother.get_old_faction().capital
			_status = mother._status
			arch.add_person(self)
			call_deferred("emit_signal", "person_available", self, AvailableReason.CHILDREN, mother)
			return
	
	var siblings_sorted = get_siblings().duplicate()
	siblings_sorted.sort_custom(self, "cmp_age_desc")
	for p in siblings_sorted:
		if p._status != Status.NONE:
			var arch = p.get_belonged_architecture() if p._status != Status.CAPTIVE else p.get_old_faction().capital
			_status = p._status
			arch.add_person(self)
			call_deferred("emit_signal", "person_available", self, AvailableReason.SIBLING, p)
			return
	
	var arch = scenario.architectures[available_architecture_id]
	_status = Status.WILD
	arch.add_person(self)
	call_deferred("emit_signal", "person_available", self, AvailableReason.NONE, null)
	
func die():
	get_location().remove_person(self)
	if is_faction_leader():
		get_belonged_faction().change_leader()
	var loc = get_location()
	loc.remove_person(self)
	if loc.has_method("check_destroy"):
		loc.check_destroy(null)
	_status = Status.NONE
	alive = false
	call_deferred("emit_signal", 'person_died', self)
	
#####################################
#      Manipulation / Domestic      #
#####################################
	
func clear_working_task():
	working_task = Task.NONE
	producing_equipment = null

func set_working_task(work):
	working_task = work
	producing_equipment = null
	
func set_produce_equipment(equipment: int):
	producing_equipment = equipment
		
####################################
#     Manipulation / Abilities     #
####################################

func add_internal_exp(delta):
	delta = apply_influences("modify_person_experience_gain", {"value": delta, "person": self})
	internal_exp = Util.f2ri(internal_exp + delta)

func add_combat_exp(delta):
	delta = apply_influences("modify_person_experience_gain", {"value": delta, "person": self})
	combat_exp = Util.f2ri(combat_exp + delta)

func add_stratagem_exp(delta):
	delta = apply_influences("modify_person_experience_gain", {"value": delta, "person": self})
	stratagem_exp = Util.f2ri(stratagem_exp + delta)

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

func add_military_type_exp(type, delta):
	delta = apply_influences("modify_person_experience_gain", {"value": delta, "person": self})
	Util.dict_inc(military_type_exp, type, Util.f2ri(delta))

	
####################################
#     Manipulation / Relations     #
####################################
func set_father(other):
	father = other
	
func set_mother(other):
	mother = other
	
func add_spouse(other):
	if not spouses.has(other):
		spouses.append(other)
	if not other.spouses.has(self):
		other.spouses.append(self)
	
func add_brother(other):
	if not brothers.has(other):
		brothers.append(other)
	if not other.brothers.has(self):
		other.brothers.append(self)
		
#####################################
#        Manipulation / Work        #
#####################################
func set_task_target(target):
	task_target = target

func go_for_convince(target):
	working_task = Task.CONVINCE
	task_days = outside_task_eta_days(target)
	task_target = target
	
func do_convince():
	if task_target._status != Status.WILD and task_target._status != Status.CAPTIVE:
		call_deferred("emit_signal", 'convince_failure', self, task_target)
	else:
		var prob = convince_probability(task_target)
		if randf() < prob:
			add_stratagem_exp(20)
			add_intelligence_exp(20)
			add_glamour_exp(80)
			task_target.join_architecture(get_belonged_architecture())
			call_deferred("emit_signal", 'convince_success', self, task_target)
		else:
			add_stratagem_exp(5)
			add_intelligence_exp(5)
			add_glamour_exp(20)
			call_deferred("emit_signal", 'convince_failure', self, task_target)
	working_task = Task.MOVE
	task_target = null

####################################
#             Day event            #
####################################
func day_event():
	# task days
	if get_location() != null:
		if task_days > 0:
			task_days -= 1
		if task_days == 0:
			match working_task:
				Task.CONVINCE: do_convince()
				Task.MOVE: call_deferred("emit_signal", "move_complete", self)

	var faction = get_belonged_faction()
	if faction != null:
		if randf() < 1 / 10.0:
			# lose loyalty when held captive
			if get_status() == Status.CAPTIVE:
				var factor = 1.0
				if is_faction_leader():
					factor = 0.0
				elif is_intimate_to(faction.leader):
					factor = 0.0
				elif is_close_blood_to(faction.leader):
					factor = 0.25
				elif is_same_strain_to(faction.leader):
					factor = 0.5
				loyalty_shift -= Util.f2ri(max((90.0 - get_morality()) / 20.0 * factor, 0.0))
	
		# loyalty-shift naturalize
		var ideal_diff = get_ideal_difference(faction.leader)
		if randf() < 1 / (ideal_diff / 15.0 + 5):
			if loyalty_shift < 0:
				loyalty_shift += 1
	
		if randf() < 1 / ((75 - ideal_diff) / 15.0 + 5):
			if loyalty_shift > 0:
				loyalty_shift -= 1

	# relation decay
	for p in person_relations.duplicate():
		if person_relations[p]['value'] > 0:
			person_relations[p]['value'] -= person_relations[p]['decay']
			if person_relations[p]['value'] <= 0:
				person_relations.erase(p)
		elif person_relations[p]['value'] < 0:
			person_relations[p]['value'] += person_relations[p]['decay']
			if person_relations[p]['value'] >= 0:
				person_relations.erase(p)
		else:
			person_relations.erase(p)
				
			
	# check death
	if scenario.scenario_config.person_natural_death:
		if get_location() != null and scenario.get_year() >= get_expected_death_year() and randf() < 1 / 240.0:
			die()

			
func month_event():
	# try to be available
	if alive and get_location() == null and scenario.get_year() >= available_year and randf() < 0.2:
		become_available()
