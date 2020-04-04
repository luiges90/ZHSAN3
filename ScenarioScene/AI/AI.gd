extends Node

class_name AI

func run_faction(faction: Faction, scenario):
	for sect in faction.get_sections():
		run_section(faction, sect, scenario)
		
func run_section(faction: Faction, section: Section, scenario):
	if not faction.player_controlled:
		_allocate_person(section)
	for arch in section.get_architectures():
		if not faction.player_controlled or arch.auto:
			_assign_task(arch, scenario)

func _assign_task(arch: Architecture, scenario):
	# TODO better weighting
	var list = arch.get_workable_persons().duplicate()
	var a = -9e99 if arch.kind.agriculture <= 0 else arch.kind.agriculture / float(arch.agriculture + 1)
	var c = -9e99 if arch.kind.commerce <= 0 else arch.kind.commerce / float(arch.commerce + 1)
	var m = -9e99 if arch.kind.morale <= 0 else arch.kind.morale / float(arch.morale + 1)
	var e = -9e99 if arch.kind.endurance <= 0 else arch.kind.endurance / float(arch.endurance + 1)
	var r = -9e99 if arch.population <= 0 or arch.morale <= 100 else 10000.0 / (arch.troop + 1)
	var t = (110.0 / (arch.troop_morale + 10.0) - 1) * 2
	var q = -9e99 if arch.troop <= 0 else 5000.0 / (arch.equipments.values().min() + 1)
	var task_priority = [a, c, m, e, r, t, q]
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
			4:
				var person = Util.max_by(list, "get_recruit_troop_ability")
				person[1].set_working_task(Person.Task.RECRUIT_TROOP)
				list.remove(person[0])
				task_priority[4] -= 0.2
			5:
				var person = Util.max_by(list, "get_train_troop_ability")
				person[1].set_working_task(Person.Task.TRAIN_TROOP)
				list.remove(person[0])
				task_priority[5] -= 0.2
			6:
				var person = Util.max_by(list, "get_produce_equipment_ability")
				var equipment = Util.dict_min(arch.equipments)
				person[1].set_working_task(Person.Task.PRODUCE_EQUIPMENT)
				person[1].set_produce_equipment(equipment)
				list.remove(person[0])
				task_priority[6] -= 0.2

func _allocate_person(section: Section):
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
