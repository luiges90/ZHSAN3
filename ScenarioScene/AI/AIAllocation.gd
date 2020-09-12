extends Node
class_name AIAllocation

enum _ARCH_CLASS {
	BACKLINE, FRONTLINE_BLANK, FRONTLINE, UNDER_ATTACK
}

var _ai

var __section
var __backline_archs
var __frontline_blank_archs
var __frontline_archs
var __under_attack_archs

func _init(ai):
	_ai = ai

func _allocate_person(section: Section):
	if section.get_architectures().size() <= 1:
		return
	
	__section = section
	__backline_archs = []
	__frontline_blank_archs = []
	__frontline_archs = []
	__under_attack_archs = []
	var __low_endurance_archs = []
	
	var section_person_count = section.get_persons().size()
	var architecture_count = section.get_architectures().size()
	for a in section.get_architectures():
		match __arch_class(a):
			_ARCH_CLASS.UNDER_ATTACK: __under_attack_archs.append(a)
			_ARCH_CLASS.FRONTLINE: 
				__frontline_archs.append(a)
				if a.endurance <= 50:
					__low_endurance_archs.append(a)
			_ARCH_CLASS.FRONTLINE_BLANK: 
				__frontline_blank_archs.append(a)
				if a.endurance <= 50 or (a.get_faction_persons().size() <= 0 and section_person_count >= architecture_count):
					__low_endurance_archs.append(a)
			_: __backline_archs.append(a)
			
	if __low_endurance_archs.size() <= 0 or randf() < 0.1:
		if randf() > 1 / 30.0 and __under_attack_archs.size() <= 0:
			return
	
	var sha = section.get_architectures()
	for a in sha:
		var expected_state = __needed_person_state(a)
		if a.get_faction_persons().size() < expected_state['count']:
			var sha2 = section.get_architectures()
			for call_from in sha2:
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
	if a.enemy_troop_in_range(6):
		return _ARCH_CLASS.UNDER_ATTACK
	elif a.is_frontline():
		return _ARCH_CLASS.FRONTLINE
	elif a.is_frontline_including_blank():
		return _ARCH_CLASS.FRONTLINE_BLANK
	else:
		return _ARCH_CLASS.BACKLINE
