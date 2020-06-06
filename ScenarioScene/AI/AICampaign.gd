extends Node
class_name AICampaign

var ai

func _init(ai):
	self.ai = ai

func defence(arch, scenario):
	var enemy_troops = arch.enemy_troop_in_range(6)
	if enemy_troops.size() > 0:
		var persons = arch.get_persons()
		var leader = Util.max_by(persons, "get_leader_value")[1]
		var equipment_id = Util.dict_max(arch.equipments)
		
		var troop = CreatingTroop.new()
		troop.persons = [leader]
		troop.military_kind = scenario.military_kinds[equipment_id]
		troop.quantity = arch.equipments[equipment_id] / 100 * 100
		troop.morale = arch.troop_morale
		troop.combativity = arch.troop_combativity
		
		var position = Util.random_from(arch.create_troop_positions())
		if position != null:
			scenario.create_troop(arch, troop, position)
