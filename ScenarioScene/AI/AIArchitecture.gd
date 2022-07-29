extends Node
class_name AIArchitecture

var ai

var _convincing_persons = {}

func _init(ai):
	self.ai = ai

func _arch_enough_fund(arch: Architecture):
	return arch.expected_fund_income() > arch.get_workable_persons().size() * 50
	
func _arch_enough_food(arch: Architecture):
	return arch.expected_food_income() > arch._expected_food_expenditure() # one month of extra income for storage

func _target_fund(arch: Architecture):
	return arch._expected_fund_expenditure() * 12 + 50 * (arch.get_workable_persons().size() + 3)

func _target_food(arch: Architecture):
	return (arch._expected_food_expenditure() + 3000) * 12
	
func _target_troop_quantity(arch: Architecture):
	var frontline = ai._frontline_connected_archs(arch)
	var troops = 5000
	if arch.is_frontline_including_blank():
		troops = 10000
	for a in frontline:
		troops += a.troop
	return troops
	
func _target_equipment_quantity(arch: Architecture):
	return _target_troop_quantity(arch)

func _target_troop_morale(arch: Architecture):
	return 100

func _selected_equipment(arch: Architecture, scenario) -> MilitaryKind:
	var min_value = 9e99
	var result
	for mk in arch.equipments:
		var military_kind = scenario.military_kinds[mk]
		var value = arch.equipments[mk] / ai._military_kind_power(military_kind) * military_kind.equipment_cost * scenario.military_kinds[mk].amount_to_troop_ratio
		if value < min_value:
			min_value = value
			result = military_kind
	return result

func _outside_task(arch: Architecture, scenario):
	var workable_persons = arch.get_workable_persons()
	if randf() < 0.3:
		if workable_persons.size() > 0:
			var convince_targets = arch.get_belonged_faction().get_convince_targets()
			var convincer = Util.max_by(workable_persons, "get_convince_ability")[1]
			for target in convince_targets:
				if convincer.convince_probability(target) > 0.5 and not _convincing_persons.has(target.id) and convincer.outside_task_eta_days(target) < 5:
					convincer.go_for_convince(target)
					_convincing_persons[target.id] = target
					convincer.connect("convince_success", self, "_on_convince_done")
					convincer.connect("convince_failure", self, "_on_convince_done")
					break
					
func _on_convince_done(convincer, convinced):
	_convincing_persons.erase(convinced)
	convincer.disconnect("convince_success", self, "_on_convince_done")
	convincer.disconnect("convince_failure", self, "_on_convince_done")

func _assign_task(arch: Architecture, scenario):
	var list = arch.get_workable_persons().duplicate()
	var fund = arch.fund
	var food = arch.food
	var enough_fund = _arch_enough_fund(arch)
	var enough_food = _arch_enough_food(arch)
	var target_troop_morale = _target_troop_morale(arch)
	var min_equipment = _selected_equipment(arch, scenario)
	var has_enemy_troop_in_range = arch.enemy_troop_in_range(4).size() > 0
	var has_enemy_troop_next_to_city = arch.enemy_troop_in_range(1).size() > 0
	var has_enemy_troop_in_city = arch.enemy_troop_in_architecture() != null
	var a = -9e9 if arch.kind.agriculture <= 0 or fund < 20 or has_enemy_troop_in_range or has_enemy_troop_in_city else arch.kind.agriculture / float(arch.agriculture + 1)
	var c = -9e9 if arch.kind.commerce <= 0 or fund < 20 or has_enemy_troop_in_range or has_enemy_troop_in_city else arch.kind.commerce / float(arch.commerce + 1)
	var m = -9e9 if arch.kind.morale <= 0 or fund < 20 or has_enemy_troop_in_city else arch.kind.morale / float(arch.morale + 1)
	var e = -9e9 if arch.kind.endurance <= 0 or fund < 20 or has_enemy_troop_next_to_city else arch.kind.endurance / float(arch.endurance + 1)
	var r = -9e9 if arch.population <= 0 or fund < 50 or arch.morale <= 100 or arch.military_population <= 0 or not enough_food else _target_troop_quantity(arch) / (arch.troop + 1)
	var t = -9e9 if arch.troop <= 0 or fund < 20 or arch.troop_morale >= target_troop_morale else target_troop_morale * 2 / (arch.troop_morale + 10.0)
	var q = -9e9 if arch.troop <= 0 or fund < 100 or not enough_fund or not enough_food or arch.troop < arch.equipments[min_equipment.id] else arch.troop / (arch.equipments[min_equipment.id] + 1) / min_equipment.amount_to_troop_ratio
	
	if not enough_fund:
		c *= 99
	
	if not enough_food:
		a *= 99

	if arch.endurance <= min(50, arch.kind.endurance):
		e *= 99
	
	var task_priority = [a, c, m, e, r, t, q]
	var military_population = arch.military_population
	while list.size() > 0:
		var task = Util.max_pos(task_priority)
		match task[0]:
			0: 
				var person = Util.max_by(list, "get_agriculture_ability")
				person[1].set_working_task(Person.Task.AGRICULTURE)
				list.remove(person[0])
				task_priority[0] -= 0.5
			1:
				var person = Util.max_by(list, "get_commerce_ability")
				person[1].set_working_task(Person.Task.COMMERCE)
				list.remove(person[0])
				task_priority[1] -= 0.5
			2:
				var person = Util.max_by(list, "get_morale_ability")
				person[1].set_working_task(Person.Task.MORALE)
				list.remove(person[0])
				task_priority[2] -= 0.5
			3:
				var person = Util.max_by(list, "get_endurance_ability")
				person[1].set_working_task(Person.Task.ENDURANCE)
				list.remove(person[0])
				task_priority[3] -= 0.5
			4:
				var person = Util.max_by(list, "get_recruit_troop_ability")
				var quantity = min(min(Util.f2ri(person[1].get_recruit_troop_ability() * sqrt(sqrt(arch.military_population)) * arch.morale * 0.001), arch.population), arch.military_population)
				person[1].set_working_task(Person.Task.RECRUIT_TROOP)
				list.remove(person[0])
				task_priority[4] -= 0.5
				military_population -= quantity
				if military_population < 0: #减去该人预期完成量，剩余为负数就不做了
					task_priority[4] = -9e9
			5:
				var person = Util.max_by(list, "get_train_troop_ability")
				person[1].set_working_task(Person.Task.TRAIN_TROOP)
				list.remove(person[0])
				task_priority[5] -= 0.5
			6:
				var person = Util.max_by(list, "get_produce_equipment_ability")
				person[1].set_working_task(Person.Task.PRODUCE_EQUIPMENT)
				person[1].set_produce_equipment(min_equipment.id)
				list.remove(person[0])
				task_priority[6] -= 0.5

func _manage_attached_army(arch: Architecture, scenario):
	if arch.troop > 5000:
		var workable_persons = arch.get_workable_persons()
		for person in workable_persons:
			if person.get_command() >= 80:
				pass
