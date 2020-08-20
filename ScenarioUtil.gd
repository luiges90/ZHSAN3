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
	
class InfluenceContainer:
	var influences: Array
	var conditions: Array
	

static func apply_influences(influence_container, in_operation, params: Dictionary):
	if params.has("value"):
		var value = params['value']
		
		if not check_conditions(influence_container, params):
			return value
		
		for influence in influence_container.influences:
			if in_operation == influence['Operation']:
				if influence['Operation'].begins_with('modify'):
					value = influence["Value"] * value
				elif influence['Operation'].begins_with('add'):
					value = influence["Value"] + value
				else:
					assert('Value Operation shall start with add or modify')
		return value
	else:
		assert('Applying influences must provide value in params')

static func check_conditions(influence_container, params: Dictionary):
	for condition in influence_container.conditions:
		match condition['Operation']:
			'is_leader': 
				if params.has('troop') and params.has('person'):
					if params['troop'].get_leader() != params['person']:
						return false
			'is_military_type':
				if params.has('troop'):
					if condition['Id'] is Array:
						if not (params['troop'].military_kind.type in condition['Id']):
							return false
					else:
						if params['troop'].military_kind.type != condition['Id']:
							return false
				elif params.has('military_kind'):
					if condition['Id'] is Array:
						if not (params['military_kind'].type in condition['Id']):
							return false
					else:
						if params['military_kind'].type != condition['Id']:
							return false
			'is_terrain':
				if params.has('troop'):
					if condition['Id'] is Array:
						if not (params['troop'].get_current_terrain().id in condition['Id']):
							return false
					else:
						if params['troop'].get_current_terrain().id != condition['Id']:
							return false
	return true

static func influence_troop_leader_offensive_factor(influence_container, params: Dictionary):
	if not check_conditions(influence_container, params):
		return 1
	
	for influence in influence_container.influences:
		if influence['Operation'] == "modify_person_troop_offence":
			return influence["Value"]
	
	return 1

static func influence_troop_leader_defensive_factor(influence_container, params: Dictionary):
	if not check_conditions(influence_container, params):
		return 1
	
	for influence in influence_container.influences:
		if influence['Operation'] == "modify_person_troop_de56fence":
			return influence["Value"]
	
	return 1

