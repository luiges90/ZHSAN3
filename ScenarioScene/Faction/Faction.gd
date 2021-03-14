extends Node
class_name Faction

var id: int setget forbidden
var scenario

var gname: String setget forbidden
var color: Color setget forbidden

var leader setget forbidden, get_leader
var advisor setget forbidden, get_advisor

var _section_list = Array() setget forbidden, get_sections

var capital setget forbidden

var player_controlled: bool

var _destroyed: bool = false setget forbidden

signal destroyed

func forbidden(x):
	assert(false)


func get_name():
	return gname

####################################
#           Save / Load            #
####################################

func load_data(json: Dictionary, objects):
	id = json["_Id"]
	gname = json["Name"]
	color = Util.load_color(json["Color"])
	player_controlled = json["PlayerControlled"]
	for id in json["SectionList"]:
		add_section(objects["sections"][int(id)])
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Name": gname,
		"Leader": leader.id,
		"Advisor": advisor.id if advisor != null else -1,
		"Color": Util.save_color(color),
		"PlayerControlled": player_controlled,
		"SectionList": Util.id_list(get_sections()),
		"Capital": capital.id
	}
	
####################################
#           G���et function           #
####################################

func get_architectures() -> Array:
	var result = []
	for s in get_sections():
		Util.append_all(result, s.get_architectures())
	return result
	
func get_persons() -> Array:
	var result = []
	for s in get_sections():
		Util.append_all(result, s.get_persons())
	return result
	
func get_advisor_candidates() -> Array:
	var result = []
	for p in get_persons():
		if p.get_status() == Person.Status.NORMAL and p.intelligence >= 70:
			result.append(p)
	return result
	
func get_troops() -> Array:
	var result = []
	for s in get_sections():
		Util.append_all(result, s.get_troops())
	return result
	
func get_total_fund():
	var result = 0
	for s in get_sections():
		result += s.get_total_fund()
	return result

func get_total_food():
	var result = 0
	for s in get_sections():
		result += s.get_total_food()
	return result
	
func get_total_troop():
	var result = 0
	for s in get_sections():
		result += s.get_total_troop()
	return result
	
func get_sections() -> Array:
	return _section_list
	
func is_friend_to(faction):
	return self == faction
	
func is_enemy_to(faction):
	return self != faction
	
func get_leader():
	return leader
	
func get_leader_name():
	return leader.get_name()
	
func get_advisor():
	return advisor
	
func get_advisor_name():
	var a = get_advisor()
	return a.get_name() if a != null else "----"
	
func get_intelligent_advisor():
	return advisor if advisor != null and advisor.get_intelligence() > leader.get_intelligence() else leader

var __get_convince_targets = null
func get_convince_targets():
	if __get_convince_targets != null:
		return __get_convince_targets
	var result = []
	for a in scenario.architectures:
		var arch = scenario.architectures[a]
		var candidates = []
		if arch.get_belonged_faction() == self:
			Util.append_all(candidates, arch.get_wild_persons())
			Util.append_all(candidates, arch.get_captive_persons())
		else:
			candidates = arch.get_faction_persons()
			Util.append_all(candidates, arch.get_wild_persons())
		var filtered_candidates = []
		for c in candidates:
			if c.get_loyalty() < 100:
				filtered_candidates.append(c)
		Util.append_all(result, filtered_candidates)
	__get_convince_targets = result
	return result

func get_architectures_can_transport_resource_to(from = null):
	var valid_architectures = []
	for a in get_architectures():
		if a.can_transport_resources() and a != from:
			valid_architectures.append(a)
	return valid_architectures

####################################
#           Manipulation           #
####################################
func _set_leader(person):
	if not scenario._loading_scenario:
		assert(person != null and person.get_belonged_faction() == self)
	leader = person

func _set_advisor(person):
	if not scenario._loading_scenario:
		assert(person == null or person.get_belonged_faction() == self)
	advisor = person

func add_section(section, force: bool = false):
	_section_list.append(section)
	if not force:
		section.set_belonged_faction(self, true)

func destroy():
	scenario.remove_faction(self)
	_destroyed = true
	call_deferred("emit_signal", "destroyed", self)
	
func change_leader():
	if get_persons().size() <= 1:
		destroy()
		return
	
	var successor = null
	
	if successor == null:
		var candidates = leader.get_children()
		candidates.sort_custom(leader, "cmp_age_desc")
		for p in candidates:
			if not p.gender and p.get_belonged_faction() == self:
				successor = p
				break
				
	if successor == null:
		var candidates = leader.get_siblings()
		candidates.sort_custom(leader, "cmp_age_desc")
		for p in candidates:
			if not p.gender and p.get_belonged_faction() == self:
				successor = p
				break
	
	if successor == null:
		var candidates = leader.get_persons_with_same_strain()
		candidates.sort_custom(leader, "cmp_age_desc")
		for p in candidates:
			if not p.gender and p.get_belonged_faction() == self:
				successor = p
				break
				
	if successor == null:
		var candidates = leader.brothers
		candidates.sort_custom(leader, "cmp_age_desc")
		for p in candidates:
			if not p.gender and p.get_belonged_faction() == self:
				successor = p
				break
	
	if successor == null:
		var candidates = get_persons()
		candidates.sort_custom(leader, "cmp_prestige_desc")
		for p in candidates:
			if not p.gender and p.get_belonged_faction() == self:
				successor = p
				break
		
	leader = successor
	
func set_capital(arch):
	assert(arch.get_belonged_faction() == self)
	capital = arch

####################################
#               Events             #
####################################
func day_event():
	for arch in get_architectures():
		arch.day_event()
		
	# clear cache
	__get_convince_targets = null

func month_event():
	for arch in get_architectures():
		arch.month_event()
