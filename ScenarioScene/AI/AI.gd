extends Node

class_name AI

func run_faction(faction, scenario):
	for sect in faction.get_sections():
		run_section(sect, scenario)
		
func run_section(section, scenario):
	_allocate_person(section)
	for arch in section.get_architectures():
		_assign_task(arch)

func _assign_task(arch):
	var list = arch.get_workable_persons().duplicate()
	var a = -999999 if arch.kind.agriculture <= 0 else float(arch.agriculture) / arch.kind.agriculture
	var c = -999999 if arch.kind.commerce <= 0 else float(arch.commerce) / arch.kind.commerce
	var m = -999999 if arch.kind.morale <= 0 else float(arch.morale) / arch.kind.morale
	var e = -999999 if arch.kind.endurance <= 0 else float(arch.endurance) / arch.kind.endurance
	var task_priority = [-a, -c, -m, -e]
	while list.size() > 0:
		var task = Util.max_pos(task_priority)
		match task[0]:
			0: 
				var person = Util.max_by(list, "get_agriculture_ability")
				person[1].set_working_task(Person.Task.AGRICULTURE)
				list.remove(person[0])
				task_priority[0] -= 0.2
			1:
				var person = Util.max_by(list, "get_commerce_ability")
				person[1].set_working_task(Person.Task.COMMERCE)
				list.remove(person[0])
				task_priority[1] -= 0.2
			2:
				var person = Util.max_by(list, "get_morale_ability")
				person[1].set_working_task(Person.Task.MORALE)
				list.remove(person[0])
				task_priority[2] -= 0.2
			3:
				var person = Util.max_by(list, "get_endurance_ability")
				person[1].set_working_task(Person.Task.ENDURANCE)
				list.remove(person[0])
				task_priority[3] -= 0.2

func _allocate_person(section):
	# TODO consider frontlines, person ability etc
	var person_per_arch = section.get_persons().size() / section.get_architectures().size()
	for a in section.get_architectures():
		if a.get_persons().size() < person_per_arch:
			var archs = section.get_architectures()
			archs.shuffle()
			for a2 in archs:
				if a.id == a2.id:
					continue
				var persons = a2.get_persons()
				persons.shuffle()
				while persons.size() > person_per_arch:
					var p = persons.pop_back()
					p.move_to_architecture(a)
					if a.get_persons().size() >= person_per_arch:
						break
