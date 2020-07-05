extends Node
class_name AITroop

var ai

func _init(ai):
	self.ai = ai

func run_troop(troop, scenario):
	if consider_retreat(troop):
		troop._ai_state = Troop.AIState.RETREAT
	
	if troop._ai_state == Troop.AIState.COMBAT:
		var enemy_troops = []
		var targets = troop.enemy_troop_in_range(6)
		var allies = troop.friendly_troop_in_range(6)
		if targets.size() > 0:
			var target = Util.max_by(targets, "get_offence_over_defence")[1]
			troop.set_attack_order(target, null)
		else:
			if troop.get_belonged_faction().is_enemy_to(troop._ai_destination_architecture.get_belonged_faction()):
				var movement_area = troop.get_movement_area()
				var target = troop._ai_destination_architecture
				var set_target = false
				for p in movement_area.shuffle():
					if Util.m_dist(p, target) <= troop.military_kind.range_max:
						troop.set_attack_order(null, target)
						set_target = true
						break
				if not set_target:
					troop._ai_state = Troop.AIState.MARCH
			else:
				troop._ai_state = Troop.AIState.RETREAT
				
	if troop._ai_state == Troop.AIState.MARCH:
		var movement_area = troop.get_movement_area()
		var done = false
		for p in movement_area:
			if troop._ai_path.find_last(p) > 0:
				troop.set_move_order(p)
				done = true
				break
	
	if troop._ai_state == Troop.AIState.RETREAT:
		if Util.m_dist(troop.map_position, troop.get_starting_architecture().map_position) < 1:
			troop.set_enter_order(troop.get_starting_architecture().map_position)
		else:
			var movement_area = troop.get_movement_area()
			var done = false
			for p in movement_area:
				if troop._ai_path.find(p) > 0:
					troop.set_move_order(p)
					done = true
					break
			if not done:
				troop.set_enter_order(troop.get_starting_architecture().map_position)



func consider_retreat(troop):
	return troop.quantity < 1000

