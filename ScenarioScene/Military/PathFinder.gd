extends Node
class_name PathFinder

var troop
var scenario

func _init(troop):
	self.troop = troop
	self.scenario = troop.scenario

class PositionItem:
	var position: Vector2
	var movement_left: int
	func _init(pos, movement):
		position = pos
		movement_left = movement

func get_movement_area():
	var start_item = PositionItem.new(troop.map_position, troop.get_speed())
	var area = [start_item]
	var position_queue = [start_item]
	while position_queue.size() > 0:
		var item = position_queue.pop_front()
		
		var up = item.position + Vector2.UP
		var terrain = scenario.get_terrain_at_position(up)
		var movement_cost = troop.get_movement_cost(terrain)
		if item.movement_left - movement_cost >= 0:
			var found = false
			for a in area:
				if a.position == up:
					found = true
					if item.movement_left - movement_cost > a.movement_left:
						a.movement_left = item.movement_left - movement_cost
			if not found:
				var new_item = PositionItem.new(up, item.movement_left - movement_cost)
				position_queue.push_back(new_item)
				area.append(new_item)
			
		var down = item.position + Vector2.DOWN
		terrain = scenario.get_terrain_at_position(down)
		movement_cost = troop.get_movement_cost(terrain)
		if item.movement_left - movement_cost >= 0:
			var found = false
			for a in area:
				if a.position == down:
					found = true
					if item.movement_left - movement_cost > a.movement_left:
						a.movement_left = item.movement_left - movement_cost
			if not found:
				var new_item = PositionItem.new(down, item.movement_left - movement_cost)
				position_queue.push_back(new_item)
				area.append(new_item)
				
		var left = item.position + Vector2.LEFT
		terrain = scenario.get_terrain_at_position(left)
		movement_cost = troop.get_movement_cost(terrain)
		if item.movement_left - movement_cost >= 0:
			var found = false
			for a in area:
				if a.position == left:
					found = true
					if item.movement_left - movement_cost > a.movement_left:
						a.movement_left = item.movement_left - movement_cost
			if not found:
				var new_item = PositionItem.new(left, item.movement_left - movement_cost)
				position_queue.push_back(new_item)
				area.append(new_item)
				
		var right = item.position + Vector2.RIGHT
		terrain = scenario.get_terrain_at_position(right)
		movement_cost = troop.get_movement_cost(terrain)
		if item.movement_left - movement_cost >= 0:
			var found = false
			for a in area:
				if a.position == right:
					found = true
					if item.movement_left - movement_cost > a.movement_left:
						a.movement_left = item.movement_left - movement_cost
			if not found:
				var new_item = PositionItem.new(right, item.movement_left - movement_cost)
				position_queue.push_back(new_item)
				area.append(new_item)
	
	var area_pos = []
	for a in area:
		area_pos.append(a.position)
	return area_pos
