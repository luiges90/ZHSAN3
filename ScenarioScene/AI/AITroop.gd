extends Node
class_name AITroop

var ai

func _init(ai):
	self.ai = ai

func run_troop(troop, scenario):
	if consider_retreat(troop):
		troop._ai_state = Troop.AIState.RETREAT
		
	var on_arch = scenario.get_architecture_at_position(troop.map_position)
	if on_arch != null and troop.get_belonged_faction().is_enemy_to(on_arch.get_belonged_faction()):
		troop.occupy()
	
	if troop._ai_state == Troop.AIState.COMBAT:
		var enemy_troops = []
		var targets = troop.enemy_troop_in_range(troop.military_kind.range_max)
		if targets.size() > 0:
			var target = Util.max_by(targets, "get_offence_over_defence")[1]
			troop.set_attack_order(target, null)
		else:
			targets = troop.enemy_troop_in_range(6)
			if targets.size() > 0:
				var target = Util.max_by(targets, "get_offence_over_defence")[1]
				troop.set_attack_order(target, null)
			elif troop.get_belonged_faction().is_enemy_to(troop._ai_destination_architecture.get_belonged_faction()):
				var target = troop._ai_destination_architecture
				var set_target = false
				if Util.m_dist(troop.map_position, target.map_position) <= troop.military_kind.range_max:
					if target.endurance > 0:
						troop.set_attack_order(null, target)
						set_target = true
					else:
						troop.get_movement_area()
						troop.set_move_order(target.map_position)
						set_target = true
				else:
					var movement_area = troop.get_movement_area().duplicate()
					movement_area.shuffle()
					for p in movement_area:
						if Util.m_dist(p, target.map_position) <= troop.military_kind.range_max and scenario.get_troop_at_position(p) == null:
							troop.set_move_order(p)
							set_target = true
							break
				if not set_target:
					troop._ai_state = Troop.AIState.MARCH
			elif troop.get_belonged_faction() == troop._ai_destination_architecture.get_belonged_faction():
				troop._ai_state = Troop.AIState.MARCH
			else:
				troop._ai_state = Troop.AIState.RETREAT
				
	if troop._ai_state == Troop.AIState.MARCH:
		var movement_area = troop.get_movement_area()
		var done = false
		for p in movement_area:
			if p == troop._ai_destination_architecture.map_position:
				troop.set_enter_order(troop._ai_destination_architecture.map_position)
				done = true
				break
			else:
				var d = Util.m_dist(p, troop._ai_destination_architecture.map_position)
				if d <= troop.military_kind.range_max:
					if troop._ai_destination_architecture.get_belonged_faction() == troop.get_belonged_faction():
						troop.set_enter_order(troop._ai_destination_architecture.map_position)
					else:
						troop._ai_state = Troop.AIState.COMBAT
						troop.set_attack_order(null, troop._ai_destination_architecture)
					done = true
					break
		if not done:
			var __path = troop._ai_path.duplicate()
			__path.invert()
			for p in __path:
				for q in movement_area:
					if p[0] == q.x and p[1] == q.y:
						troop.set_move_order(q)
						done = true
						break
				if done:
					break
		if not done:
			troop._ai_state = Troop.AIState.RETREAT
	
	if troop._ai_state == Troop.AIState.RETREAT:
		if Util.m_dist(troop.map_position, troop.get_starting_architecture().map_position) <= 1:
			troop.set_enter_order(troop.get_starting_architecture().map_position)
		else:
			var movement_area = troop.get_movement_area()
			var done = false
			for p in troop._ai_path:
				for q in movement_area:
					if p[0] == q.x and p[1] == q.y:
						troop.set_move_order(q)
						done = true
						break
				if done:
					break
			if not done:
				troop.set_enter_order(troop.get_starting_architecture().map_position)
	
	assert(troop.current_order != null)



func consider_retreat(troop):
	return troop.quantity < 1000

func consider_make_troop(troop, defend: bool):
	if defend:
		return troop.quantity > 1000
	else:
		return troop.quantity > 3000
