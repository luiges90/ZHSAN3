extends Node

static func _op_cond(op_not, op_value):
	return (not op_not and op_value) or (op_not and not op_value)

static func __quadratic(level):
	return 0.25 * level * level + 0.5 * level + 0.25

static func check_conditions(influence_container, params: Dictionary, level = 1):
	for condition in influence_container.conditions:
		var operator = Util.dict_try_get(condition, "Operator", [])
		var op_not = operator.has('not')
		match condition['Operation']:
			'gender_male':
				if params.has('person'):
					if _op_cond(op_not, params['person'].gender):
						return false
			'gender_female':
				if params.has('person'):
					if _op_cond(op_not, not params['person'].gender):
						return false
			'is_leader': 
				if params.has('troop') and params.has('person'):
					if _op_cond(op_not, params['troop'].get_leader() != params['person']):
						return false
			'is_military_type':
				if params.has('troop'):
					if condition['Id'] is Array:
						if _op_cond(op_not, not (params['troop'].military_kind.type in condition['Id'])):
							return false
					else:
						if _op_cond(op_not, params['troop'].military_kind.type != condition['Id']):
							return false
				elif params.has('military_kind'):
					if condition['Id'] is Array:
						if _op_cond(op_not, not (params['military_kind'].type in condition['Id'])):
							return false
					else:
						if _op_cond(op_not, params['military_kind'].type != condition['Id']):
							return false
			'is_terrain':
				if params.has('troop'):
					if condition['Id'] is Array:
						if _op_cond(op_not, not (params['troop'].get_current_terrain().id in condition['Id'])):
							return false
					else:
						if _op_cond(op_not, params['troop'].get_current_terrain().id != condition['Id']):
							return false
			'is_on_own_architecture':
				if params.has('troop'):
					var arch = params['troop'].get_on_architecture()
					if _op_cond(op_not, arch == null or !arch.get_belonged_faction().is_friend_to(params['troop'].get_belonged_faction())):
						return false
			'is_on_enemy_architecture':
				if params.has('troop'):
					var arch = params['troop'].get_on_architecture()
					if _op_cond(op_not, arch == null or !arch.get_belonged_faction().is_enemy_to(params['troop'].get_belonged_faction())):
						return false
			'target_is_troop':
				if params.has('target'):
					if _op_cond(op_not, params['target'].object_type() != ScenarioUtil.ObjectType.TROOP):
						return false
			'target_is_architecture':
				if params.has('target'):
					if _op_cond(op_not, params['target'].object_type() != ScenarioUtil.ObjectType.ARCHITECTURE):
						return false
			'internal_experience_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].internal_exp < condition['Value'] * __quadratic(level)):
						return false
			'combat_experience_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].combat_exp < condition['Value'] * __quadratic(level)):
						return false
			'stratagem_experience_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].stratagem_exp < condition['Value'] * __quadratic(level)):
						return false
			'command_at_least':
				if params.has('person'):
					var inc = condition['level_increment'] if condition.has('level_increment') else 0
					if _op_cond(op_not, params['person'].get_command() < condition['Value'] + inc * (level - 1)):
						return false
			'command_experience_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].command_exp < condition['Value'] * __quadratic(level)):
						return false
			'strength_at_least':
				if params.has('person'):
					var inc = condition['level_increment'] if condition.has('level_increment') else 0
					if _op_cond(op_not, params['person'].get_strength() < condition['Value'] + inc * (level - 1)):
						return false
			'strength_experience_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].strength_exp < condition['Value'] * __quadratic(level)):
						return false
			'intelligence_at_least':
				if params.has('person'):
					var inc = condition['level_increment'] if condition.has('level_increment') else 0
					if _op_cond(op_not, params['person'].get_intelligence() < condition['Value'] + inc * (level - 1)):
						return false
			'intelligence_experience_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].intelligence_exp < condition['Value'] * __quadratic(level)):
						return false
			'politics_at_least':
				if params.has('person'):
					var inc = condition['level_increment'] if condition.has('level_increment') else 0
					if _op_cond(op_not, params['person'].get_politics() < condition['Value'] + inc * (level - 1)):
						return false
			'politics_experience_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].politics_exp < condition['Value'] * __quadratic(level)):
						return false
			'glamour_at_least':
				if params.has('person'):
					var inc = condition['level_increment'] if condition.has('level_increment') else 0
					if _op_cond(op_not, params['person'].get_glamour() < condition['Value'] + inc * (level - 1)):
						return false
			'glamour_experience_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].glamour_exp < condition['Value'] * __quadratic(level)):
						return false
			'military_type_experience_at_least':
				if params.has('person') and params.has('military_type'):
					if _op_cond(op_not, params['person'].get_military_type_experience(params['military_type']) < condition['Value'] * __quadratic(level)):
						return false
			'popularity_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].get_popularity() < condition['Value'] * level):
						return false
			'prestige_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].get_prestige() < condition['Value'] * level):
						return false
			'karma_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].get_karma() < condition['Value'] * level):
						return false
			'merit_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].get_merit() < condition['Value'] * level):
						return false
			'ambition_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].get_ambition() < condition['Value']):
						return false
			'morality_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].get_morality() < condition['Value']):
						return false
			'troop_damage_dealt_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].troop_damage_dealt < condition['Value'] * __quadratic(level)):
						return false
			'troop_damage_received_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].troop_damage_received < condition['Value'] * __quadratic(level)):
						return false
			'arch_damage_dealt_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].arch_damage_dealt < condition['Value'] * __quadratic(level)):
						return false
			'rout_count_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].rout_count < condition['Value'] * __quadratic(level)):
						return false
			'routed_count_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].routed_count < condition['Value'] * __quadratic(level)):
						return false
			'capture_count_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].capture_count < condition['Value'] * __quadratic(level)):
						return false
			'be_captured_count_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].be_captured_count < condition['Value'] * __quadratic(level)):
						return false
	return true