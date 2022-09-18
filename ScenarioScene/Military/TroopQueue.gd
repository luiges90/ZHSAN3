extends Node
class_name TroopQueue

var queue: Array
var troops: Array

func _init(in_queue: Array):
	troops = in_queue.duplicate()
	queue = in_queue.duplicate()
	
func execute():
	queue.shuffle()
	queue.sort_custom(Callable(Troop,"cmp_initiative"))
	for troop in queue:
		troop.prepare_orders()
	while queue.size() > 0:
		var troop = queue.pop_front()
		if is_instance_valid(troop) and not troop._destroyed:
			var step = troop.execute_step()

			if step.type == Troop.ExecuteStepType.MOVED:
				var result = troop.set_position(step.new_position)
				if result:
					await troop.animation_step_finished
					
			var enter = troop.execute_enter()
					
			var attack = troop.execute_attack()
			if attack:
				await troop.animation_attack_finished
			
			if step.type != Troop.ExecuteStepType.STOPPED:
				queue.push_back(troop)
		
	for troop in troops:
		if is_instance_valid(troop):
			troop.after_order_cleanup()

