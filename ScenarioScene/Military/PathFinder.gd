extends Node
class_name PathFinder

var troop
var scenario

var _stored_paths = {}

func _init(troop):
	self.troop = troop
	self.scenario = troop.scenario

class PositionItem:
	var position: Vector2
	var movement_left: int
	func _init(pos, movement):
		position = pos
		movement_left = movement

func get_movement_area() -> Array:
	var start_item = PositionItem.new(troop.map_position, troop.get_speed())
	var area = [start_item]
	var position_queue = [start_item]
	_stored_paths.clear()
	_stored_paths[start_item.position] = [start_item.position]
	while position_queue.size() > 0:
		var item = position_queue.pop_front()
		
		var up = item.position + Vector2.UP
		_step_forward(item, up, area, position_queue, _stored_paths)
		
		var down = item.position + Vector2.DOWN
		_step_forward(item, down, area, position_queue, _stored_paths)
		
		var left = item.position + Vector2.LEFT
		_step_forward(item, left, area, position_queue, _stored_paths)
		
		var right = item.position + Vector2.RIGHT
		_step_forward(item, right, area, position_queue, _stored_paths)
	
	var area_pos = []
	for a in area:
		area_pos.append(a.position)
	return area_pos
	
func get_stored_path_to(position) -> Array:
	return _stored_paths[position] 

func _step_forward(last_position_item, position, area, position_queue, stored_paths):
	var movement_cost = troop.get_movement_cost(position, true)[0]
	if last_position_item.movement_left - movement_cost >= 0:
		var found = false
		for a in area:
			if a.position == position:
				found = true
				if last_position_item.movement_left - movement_cost > a.movement_left:
					a.movement_left = last_position_item.movement_left - movement_cost
					stored_paths[position] = stored_paths[last_position_item.position] + [position]
					position_queue.push_back(a)
		if not found:
			var new_item = PositionItem.new(position, last_position_item.movement_left - movement_cost)
			position_queue.push_back(new_item)
			area.append(new_item)
			stored_paths[position] = stored_paths[last_position_item.position] + [position]

# return [next_position, movement_cost]
func stupid_path_to_step(target_position):
	var x = target_position.x - troop.map_position.x
	var y = target_position.y - troop.map_position.y
	if abs(x) + abs(y) <= 1:
		return null
	
	var new_position = troop.map_position
	var alt_position = troop.map_position
	if x != 0 or y != 0:
		if x >= 0 and y >= 0:
			if x >= y:
				new_position.x += 1
				alt_position.y += 1
			else:
				new_position.y += 1
				alt_position.x += 1
		elif x >= 0 and y < 0:
			if x >= -y:
				new_position.x += 1
				alt_position.y -= 1
			else:
				new_position.y -= 1
				alt_position.x += 1
		elif x < 0 and y >= 0:
			if -x >= y:
				new_position.x -= 1
				alt_position.y += 1
			else:
				new_position.y += 1
				alt_position.x -= 1
		elif x < 0 and y < 0:
			if -x >= -y:
				new_position.x -= 1
				alt_position.y -= 1
			else:
				new_position.y -= 1
				alt_position.x -= 1
	var movement_cost = troop.get_movement_cost(new_position, false)
	var movement_cost2 = troop.get_movement_cost(alt_position, false)
	if movement_cost[1] != null and movement_cost2[1] != null:
		return null
	elif movement_cost[0] <= movement_cost2[0]:
		return [new_position, movement_cost[0]]
	elif movement_cost2[0] <= movement_cost[0]:
		return [alt_position, movement_cost2[0]]
	else:
		assert(false)
		return null
