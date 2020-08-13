extends Node

static func object_distance(a, b) -> int:
	return a.map_position.distance_to(b.map_position)

static func nearest_architecture_of_faction(faction, map_position, exclude = null):
	var result
	var min_dist = 9e9
	for arch in faction.get_architectures():
		if arch == exclude:
			 continue
		var dist = Util.m_dist(map_position, arch.map_position)
		if dist < min_dist:
			min_dist = dist
			result = arch
	return result

static func apply_influences(influence_container, in_operation, params: Dictionary):
	if params.has("value"):
		var value = params['value']
		
		if not _check_conditions(influence_container, params):
			return value
		
		for influence in influence_container.influences:
			if in_operation == influence['Operation']:
				if influence['Operation'].begins_with('modify'):
					value = influence["Value"] * value
				elif influence['Operation'].begins_with('add'):
					value = influence["Value"] + value
				else:
					assert('Value Operation shall starts with add or modify')
		return value
	else:
		assert('Applying influences must provide value in params')

static func _check_conditions(influence_container, params: Dictionary):
	for condition in influence_container.conditions:
		match condition['Operation']:
			'is_leader': 
				if params.has('troop') and params.has('person'):
					if params['troop'].get_leader() != params['person']:
						return false
			'is_military_type':
				if params.has('troop'):
					if params['troop'].military_kind.type != condition['Id']:
						return false
	return true
