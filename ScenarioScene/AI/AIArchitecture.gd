extends Node
class_name AIArchitecture

var ai

func _init(ai):
	self.ai = ai

func _arch_enough_fund(arch: Architecture):
	return arch.get_workable_persons().size() * 50
	
func _target_troop_quantity(arch: Architecture):
	return 10000
	
func _target_equipment_quantity(arch: Architecture):
	return _target_troop_quantity(arch) / 2.0

func _target_troop_morale(arch: Architecture):
	return 100

func _selected_equipment(arch: Architecture, scenario) -> MilitaryKind:
	var min_value = 9e99
	var result
	for mk in arch.equipments:
		var military_kind = scenario.military_kinds[mk]
		var value = arch.equipments[mk] / ai.military_kind_power(military_kind) * military_kind.equipment_cost
		if value < min_value:
			min_value = value
			result = military_kind
	return result

func _assign_task(arch: Architecture, scenario):
	# TODO better weighting
	var list = arch.get_workable_persons().duplicate()
	var fund = arch.fund
	var enough_fund = _arch_enough_fund(arch)
	var target_troop_morale = _target_troop_morale(arch)
	var min_equipment = _selected_equipment(arch, scenario)
	var a = -9e9 if arch.kind.agriculture <= 0 or fund < 20 else arch.kind.agriculture / float(arch.agriculture + 1)
	var c = -9e9 if arch.kind.commerce <= 0 or fund < 20 else arch.kind.commerce / float(arch.commerce + 1)
	var m = -9e9 if arch.kind.morale <= 0 or fund < 20 else arch.kind.morale / float(arch.morale + 1)
	var e = -9e9 if arch.kind.endurance <= 0 or fund < 20 else arch.kind.endurance / float(arch.endurance + 1)
	var r = -9e9 if arch.population <= 0 or fund < 50 or arch.morale <= 100 or arch.military_population <= 0 else _target_troop_quantity(arch) / (arch.troop + 1)
	var t = -9e9 if arch.troop <= 0 or fund < 20 or arch.troop_morale >= target_troop_morale else (target_troop_morale * 2 / (arch.troop_morale + 10.0) - 1)
	var q = -9e9 if arch.troop <= 0 or fund < enough_fund else _target_equipment_quantity(arch) / (arch.equipments[min_equipment.id] + 1)
	
	if fund < enough_fund:
		c = 9e9
	
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
				person[1].set_working_task(Person.Task.PRODUCE_EQUIPMENT)
				person[1].set_produce_equipment(min_equipment.id)
				list.remove(person[0])
				task_priority[6] -= 0.2
