extends Node
class_name AITroop

var ai

func _init(ai):
	self.ai = ai

func run_troop(troop, scenario):
	if consider_retreat(troop):
		troop.set_move_order(troop.get_starting_architecture().map_position)
		check_enter_start_arch(troop)
		return
	var enemy_troops = []
	var targets = troop.enemy_troop_in_range(6)
	var allies = troop.friendly_troop_in_range(6)
	if targets.size() > 0:
		var target = Util.max_by(targets, "get_offence_over_defence")[1]
		troop.set_attack_order(target, null)
	else:
		troop.set_move_order(troop.get_starting_architecture().map_position)
		check_enter_start_arch(troop)
	
func consider_retreat(troop):
	return troop.quantity < 1000

func check_enter_start_arch(troop):
	if Util.m_dist(troop.map_position, troop.get_starting_architecture().map_position):
		troop.set_enter_order(troop.get_starting_architecture().map_position)
