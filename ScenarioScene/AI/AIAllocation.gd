extends Node
class_name AIAllocation

var _ai

var __section
var __backline_archs
var __frontline_archs

func _init(ai):
	_ai = ai

func _allocate_person(section: Section):
	if randf() > 1 / 30.0:
		return
	if section.get_architectures().size() <= 1:
		return
	
	__section = section
	__backline_archs = []
	__frontline_archs = []
	
	for a in section.get_architectures():
		if a.is_frontline():
			__frontline_archs.append(a)
		else:
			__backline_archs.append(a)
	
	var sha = section.get_architectures()
	sha.shuffle()
	for a in sha:
		var expected_state = __needed_person_state(a)
		if a.get_faction_persons().size() < expected_state['count']:
			var sha2 = section.get_architectures()
			sha2.shuffle()
			for call_from in sha2:
				if a.id == call_from.id:
					continue
				
				var call_from_expected_state = __needed_person_state(call_from)
				var persons = call_from.get_workable_persons()
				if expected_state['frontline'] and not call_from_expected_state['frontline']:
					persons.sort_custom(_ai, "__compare_by_person_troop_leader_merit_desc")
				elif not expected_state['frontline'] and call_from_expected_state['frontline']:
					persons.sort_custom(_ai, "__compare_by_person_troop_leader_merit_asc")
				else:
					persons.shuffle()
				
				while persons.size() > call_from_expected_state['count']:
					var p = persons.pop_front()
					p.move_to_architecture(a)
					if a.get_faction_persons().size() >= expected_state['count']:
						break
 
func __needed_person_state(a):
	var total_person_count = __section.get_persons().size()
	
	var frontline_person_to_backline_ratio = 3.0
	var max_backline_person_count = 3
	
	var arch_count_unit = __frontline_archs.size() * frontline_person_to_backline_ratio + __backline_archs.size()
	var person_count_unit = min(max_backline_person_count, max(total_person_count / arch_count_unit, 1))
	if person_count_unit >= max_backline_person_count:
		frontline_person_to_backline_ratio = (total_person_count - __backline_archs.size() * max_backline_person_count) / __frontline_archs.size() / person_count_unit

	var count
	var frontline
	if a.is_frontline():
		count = person_count_unit * frontline_person_to_backline_ratio
		frontline = true
	else:
		count = person_count_unit
		frontline = false
	return {
		"count": count,
		"frontline": frontline
	}

