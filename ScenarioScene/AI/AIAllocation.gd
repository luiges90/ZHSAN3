extends Node
class_name AIAllocation

enum _ARCH_CLASS {
	BACKLINE, FRONTLINE_BLANK, FRONTLINE, UNDER_ATTACK, ABANDONED
}

var _ai

var __section
var __backline_archs
var __frontline_blank_archs
var __frontline_archs
var __under_attack_archs
var __low_endurance_archs

func _init(ai):
	_ai = ai

func __class_architectures(section):
	__section = section
	__backline_archs = []
	__frontline_blank_archs = []
	__frontline_archs = []
	__under_attack_archs = []
	__low_endurance_archs = []
	
	for a in section.get_architectures():
		match __arch_class(a):
			_ARCH_CLASS.UNDER_ATTACK: __under_attack_archs.append(a)
			_ARCH_CLASS.FRONTLINE: 
				__frontline_archs.append(a)
				if a.endurance <= 50:
					__low_endurance_archs.append(a)
			_ARCH_CLASS.FRONTLINE_BLANK: 
				__frontline_blank_archs.append(a)
			_: __backline_archs.append(a)


var __surplus_fund = {}
var __surplus_food = {}
var __surplus_troop = {}
var ___sort_by_transport_eta_current_architecture
func __sort_by_fund_deficit(a, b):
	return __surplus_fund[a] < __surplus_fund[b]

func __sort_by_food_deficit(a, b):
	return __surplus_food[a] < __surplus_food[b]

func __sort_by_troop_deficit(a, b):
	return __surplus_troop[a] < __surplus_troop[b]

func __sort_by_transport_eta(a, b):
	return a._transport_eta(___sort_by_transport_eta_current_architecture) < b._transport_eta(___sort_by_transport_eta_current_architecture)

func _allocate_resources(section: Section, _ai_architecture: AIArchitecture):
	if section.get_architectures().size() <= 1:
		return
	
	__class_architectures(section)

	if not randf() < 1 / 10.0:
		return
	
	# calculate expected resources
	var total_fund = 0
	var total_food = 0
	var total_troop = 0
	var total_target_fund = 0
	var total_target_food = 0
	var total_target_troop = 0
	var target_fund = {}
	var target_food = {}
	var target_troop = {}
	__surplus_fund = {}
	__surplus_food = {}
	__surplus_troop = {}
	
	# exclude archs that we cannot transport into or out from
	var valid_architectures = []
	for a in section.get_architectures():
		if a.can_transport_resources():
			valid_architectures.append(a)

	for a in valid_architectures:
		target_fund[a] = _ai_architecture._target_fund(a)
		__surplus_fund[a] = a.fund - target_fund[a] - a.get_fund_in_packs()
		total_fund += a.fund + a.get_fund_in_packs()
		total_target_fund += target_fund[a]

		target_food[a] = _ai_architecture._target_food(a)
		__surplus_food[a] = a.food - target_food[a] - a.get_food_in_packs()
		total_food += a.food + a.get_food_in_packs()
		total_target_food += target_food[a]

		target_troop[a] = _ai_architecture._target_troop_quantity(a)
		__surplus_troop[a] = a.troop - target_troop[a] - a.get_troop_in_packs()
		total_troop += a.troop + a.get_troop_in_packs()
		total_target_troop += target_troop[a]

	# if insufficient resource to fulfill all demand, cut all demand pro rata
	if total_target_fund > total_fund:
		var total_deficit_ratio = float(total_fund) / total_target_fund
		for i in target_fund:
			target_fund[i] = int(target_fund[i] * total_deficit_ratio)

	if total_target_food > total_food:
		var total_deficit_ratio = float(total_food) / total_target_food
		for i in target_food:
			target_food[i] = int(target_food[i] * total_deficit_ratio)

	if total_target_troop > total_troop:
		var total_deficit_ratio = float(total_troop) / total_target_troop
		for i in target_troop:
			target_troop[i] = int(target_troop[i] * total_deficit_ratio)

	# distribute resources from surplus to deficit by having deficit places ask nearby surplus greedily, most deficit first
	valid_architectures.sort_custom(self, "__sort_by_fund_deficit")
	for a in valid_architectures:
		if __surplus_fund[a] < 0:
			___sort_by_transport_eta_current_architecture = a
			var from = valid_architectures.duplicate()
			from.sort_custom(self, "__sort_by_transport_eta")
			for a2 in from:
				if a2.fund > target_fund[a2]:
					var to_transfer = int(min(a2.fund - target_fund[a2], max(1000, (target_fund[a] - a.fund) * 12)))
					if to_transfer > 1000:
						a2.transport_resources(a, to_transfer, 0, 0)
						__surplus_fund[a] += to_transfer
				if __surplus_fund[a] >= 0:
					break
					
	valid_architectures.sort_custom(self, "__sort_by_food_deficit")
	for a in valid_architectures:
		if __surplus_food[a] < 0:
			___sort_by_transport_eta_current_architecture = a
			var from = valid_architectures.duplicate()
			from.sort_custom(self, "__sort_by_transport_eta")
			for a2 in from:
				if a2.food > target_food[a2]:
					var to_transfer = int(min(a2.food - target_food[a2], max(100000, (target_food[a] - a.food) * 12)))
					if to_transfer > 100000:
						a2.transport_resources(a, 0, to_transfer, 0)
						__surplus_food[a] += to_transfer
				if __surplus_food[a] >= 0:
					break

	valid_architectures.sort_custom(self, "__sort_by_troop_deficit")
	for a in valid_architectures:
		if __surplus_troop[a] < 0:
			___sort_by_transport_eta_current_architecture = a
			var from = valid_architectures.duplicate()
			from.sort_custom(self, "__sort_by_transport_eta")
			for a2 in from:
				if a2.troop > target_troop[a2]:
					var to_transfer = int(min(a2.troop - target_troop[a2], max(1000, (target_troop[a] - a.troop) * 12)))
					if to_transfer > 1000:
						a2.transport_resources(a, 0, 0, to_transfer)
						__surplus_troop[a] += to_transfer
				if __surplus_troop[a] >= 0:
					break


func _allocate_person(section: Section):
	if section.get_architectures().size() <= 1:
		return
	
	__class_architectures(section)

	if not (randf() < 1 / 30.0 or __under_attack_archs.size() > 0 or (__low_endurance_archs.size() > 0 and randf() < 1 / 10.0)):
		return
	
	var sha = section.get_architectures()
	for a in sha:
		var expected_state = __needed_person_state(a)
		if a.get_faction_persons().size() < expected_state['count']:
			for call_from in sha:
				if a.id == call_from.id:
					continue
				
				var call_from_expected_state = __needed_person_state(call_from)
				var persons = call_from.get_workable_persons()
				if expected_state['frontline'] and not call_from_expected_state['frontline']:
					persons.sort_custom(_ai, "__compare_by_person_troop_leader_ability_desc")
				elif not expected_state['frontline'] and call_from_expected_state['frontline']:
					persons.sort_custom(_ai, "__compare_by_person_troop_leader_ability_asc")
				
				while persons.size() > call_from_expected_state['count']:
					var p = persons.pop_front()
					p.move_to_architecture(a)
					if a.get_faction_persons().size() >= expected_state['count']:
						break
 
func __needed_person_state(a):
	var total_person_count = __section.get_persons().size()
	
	var under_attack_person_to_backline_ratio = 7.0
	var frontline_person_to_backline_ratio = 5.0
	var frontline_blank_person_to_backline_ratio = 2.0
	
	var arch_count_unit = __backline_archs.size()
	arch_count_unit += __frontline_blank_archs.size() * frontline_blank_person_to_backline_ratio
	arch_count_unit += __frontline_archs.size() * frontline_person_to_backline_ratio
	arch_count_unit += __under_attack_archs.size() * under_attack_person_to_backline_ratio

	var person_count_unit = total_person_count / arch_count_unit

	var count
	var frontline
	match __arch_class(a):
		_ARCH_CLASS.ABANDONED:
			count = 0
			frontline = false
		_ARCH_CLASS.UNDER_ATTACK:
			count = person_count_unit * under_attack_person_to_backline_ratio
			frontline = true
		_ARCH_CLASS.FRONTLINE:
			count = person_count_unit * frontline_person_to_backline_ratio
			frontline = true
		_ARCH_CLASS.FRONTLINE_BLANK: 
			count = person_count_unit * frontline_blank_person_to_backline_ratio
			frontline = false
		_:
			count = person_count_unit
			frontline = false

	return {
		"count": count,
		"frontline": frontline
	}

func __arch_class(a):
	if a.enemy_troop_in_architecture():
		return _ARCH_CLASS.ABANDONED
	elif a.enemy_troop_in_range(6):
		return _ARCH_CLASS.UNDER_ATTACK
	elif a.is_frontline():
		return _ARCH_CLASS.FRONTLINE
	elif a.is_frontline_including_blank():
		return _ARCH_CLASS.FRONTLINE_BLANK
	else:
		return _ARCH_CLASS.BACKLINE
