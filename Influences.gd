extends Node

static func apply_influences(influence_container, in_operation, params: Dictionary):
	if params.has("value"):
		var value = params['value']
		var level = params['level'] if params.has('level') else 1
		
		if not Conditions.check_conditions(influence_container, params):
			return value
		
		for influence in influence_container.influences:
			if in_operation == influence['Operation']:
				if influence['Operation'].begins_with('modify'):
					value = value * max(0, 1 + influence["Value"] * level)
				elif influence['Operation'].begins_with('add'):
					value = value + influence["Value"] * level
				else:
					assert('Value Operation shall start with add or modify')
		return value
	else:
		assert('Applying influences must provide value in params')


static func influence_troop_leader_offensive_factor(influence_container, level: int, params: Dictionary):
	if not Conditions.check_conditions(influence_container, params):
		return 1
	
	for influence in influence_container.influences:
		if influence['Operation'] == "modify_person_troop_offence":
			return 1 + influence["Value"] * level
	
	return 1

static func influence_troop_leader_defensive_factor(influence_container, level: int, params: Dictionary):
	if not Conditions.check_conditions(influence_container, params):
		return 1
	
	for influence in influence_container.influences:
		if influence['Operation'] == "modify_person_troop_defence":
			return 1 + influence["Value"] * level
	
	return 1

static func influence_troop_leader_critical_factor(influence_container, level: int, params: Dictionary):
	if not Conditions.check_conditions(influence_container, params):
		return 1
	
	for influence in influence_container.influences:
		if influence['Operation'] == "add_person_troop_critical":
			return 1 + influence["Value"] * level
	
	return 1

static func influence_troop_leader_anti_critical_factor(influence_container, level: int, params: Dictionary):
	if not Conditions.check_conditions(influence_container, params):
		return 1
	
	for influence in influence_container.influences:
		if influence['Operation'] == "add_person_troop_anti_critical":
			return 1 + influence["Value"] * level
	
	return 1
