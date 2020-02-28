extends Node

class_name AI

func run_faction(faction, scenario):
	for arch in faction.get_architectures():
		_assign_task(arch)

func _assign_task(arch):
	var list = arch.get_persons().duplicate()
	var a = float(arch.agriculture) / arch.kind.agriculture
	var c = float(arch.commerce) / arch.kind.commerce
	var m = float(arch.morale) / arch.kind.morale
	var e = float(arch.endurance) / arch.kind.endurance
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
