extends Node
class_name AICampaign

var ai

func _init(ai):
	self.ai = ai
	
func _create_troops(from_architecture, scenario) -> Array:
	var troops_created = []
	var stop_creating_troop = false
	while !stop_creating_troop:
		var avail_positions = from_architecture.create_troop_positions()
		var persons = from_architecture.get_workable_persons()
		var equipment_id = Util.dict_max(from_architecture.equipments)
		
		if avail_positions.size() > 0 and from_architecture.equipments[equipment_id] > 100 and persons.size() > 0:
			var leader = Util.max_by(persons, "get_leader_value")[1]
			
			var troop = CreatingTroop.new()
			troop.persons = [leader]
			troop.military_kind = scenario.military_kinds[equipment_id]
			troop.quantity = min(from_architecture.equipments[equipment_id] / 100 * 100, leader.get_max_troop_quantity())
			troop.morale = from_architecture.troop_morale
			troop.combativity = from_architecture.troop_combativity
			
			if ai._ai_troop.consider_make_troop(troop):
				var position = Util.random_from(avail_positions)
				if position != null:
					troops_created.append(scenario.create_troop(from_architecture, troop, position))
			else:
				stop_creating_troop = true
		else:
			stop_creating_troop = true
			
	return troops_created
	
func __starting_architecture_changed(troop):
	troop._ai_state = Troop.AIState.RETREAT
	troop._ai_destination_architecture = troop.get_starting_architecture()
	troop._ai_path = troop.scenario.get_ai_path(troop.military_kind.movement_kind.id, troop.get_starting_architecture(), troop._ai_destination_architecture)
	
func _setup_starting_architecture_changed_signal(troop):
	troop.connect("starting_architecture_changed", self, "__starting_architecture_changed")

func defence(arch, section, scenario):
	var enemy_troops = arch.enemy_troop_in_range(6)
	if enemy_troops.size() > 0:
		var troops = _create_troops(arch, scenario)
		for troop in troops:
			troop._ai_state = Troop.AIState.COMBAT
			troop._ai_destination_architecture = arch
			troop._ai_path = [arch.map_position]
			_setup_starting_architecture_changed_signal(troop)

func offence(arch, section, scenario):
	var selected_target
	var self_power = ai._estimated_arch_military_power(arch)
	var selected_target_power = self_power
	for a in ai._frontline_connected_archs(arch):
		var target_power = ai._estimated_arch_military_power(a) + arch.endurance * 1000000
		if target_power < self_power and target_power < selected_target_power:
			selected_target = a
			selected_target_power = target_power
	
	if selected_target != null:
		var troops = _create_troops(arch, scenario)
		for troop in troops:
			troop._ai_state = Troop.AIState.MARCH
			troop._ai_destination_architecture = selected_target
			troop._ai_path = scenario.get_ai_path(troop.military_kind.movement_kind.id, troop.get_starting_architecture(), troop._ai_destination_architecture)
			_setup_starting_architecture_changed_signal(troop)
		
	
