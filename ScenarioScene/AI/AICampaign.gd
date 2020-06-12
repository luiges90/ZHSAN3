extends Node
class_name AICampaign

var ai

func _init(ai):
	self.ai = ai

func defence(arch, scenario):
	var enemy_troops = arch.enemy_troop_in_range(6)
	if enemy_troops.size() > 0:
		while true:
			var avail_positions = arch.create_troop_positions()
			var persons = arch.get_persons()
			var equipment_id = Util.dict_max(arch.equipments)
			
			if avail_positions.size() <= 0 or arch.equipments[equipment_id] <= 100 or persons.size() <= 0:
				break
			
			var leader = Util.max_by(persons, "get_leader_value")[1]
			
			var troop = CreatingTroop.new()
			troop.persons = [leader]
			troop.military_kind = scenario.military_kinds[equipment_id]
			troop.quantity = arch.equipments[equipment_id] / 100 * 100
			troop.morale = arch.troop_morale
			troop.combativity = arch.troop_combativity
			
			var position = Util.random_from(avail_positions)
			if position != null:
				scenario.create_troop(arch, troop, position)
