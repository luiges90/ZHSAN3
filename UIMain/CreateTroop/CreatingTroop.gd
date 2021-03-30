extends Node
class_name CreatingTroop

var military_kind
var naval_military_kind
var quantity: int 
var morale: int
var combativity: int

var persons = Array()

## TODO reuse functions from Troop	
func get_persons() -> Array:
	return persons

func get_leader():
	return get_persons()[0]

func get_strength():
	var strength = get_leader().get_strength()
	var max_strength = 0
	for p in get_persons():
		var sub_strength = p.get_strength()
		if p.get_strength() > max_strength:
			max_strength = p.get_strength()
	strength = max(strength, max_strength * 0.7)
	return strength
	
func get_command():
	var command = get_leader().get_command()
	var max_command = 0
	for p in get_persons():
		var sub_command = p.get_command()
		if sub_command > max_command:
			max_command = sub_command
	command = max(command, max_command * 0.7)
	return command

func get_offence():
	var troop_base = military_kind.base_offence
	var troop_quantity = military_kind.offence * quantity / military_kind.max_quantity_multiplier
	var ability_factor = ((get_strength() * 0.3 + get_command() * 0.7) + 10) / 100.0
	var morale_factor = (morale + 5) / 100.0
	
	var base = (troop_base + troop_quantity) * ability_factor * morale_factor

	base = apply_influences("modify_troop_offence", {"value": base})

	return int(base)
	
func get_defence():
	var troop_base = military_kind.base_defence
	var troop_quantity = military_kind.defence * quantity / military_kind.max_quantity_multiplier
	var ability_factor = (get_command() + 10) / 100.0
	var morale_factor = (morale + 10) / 100.0

	var base = (troop_base + troop_quantity) * ability_factor * morale_factor

	base = apply_influences("modify_troop_defence", {"value": base})
		
	return int(base)

func get_speed():
	var base = military_kind.speed
	base = apply_influences("modify_troop_speed", {"value": base})
	return int(base)
	
func get_initiative():
	var base = military_kind.initiative
	base = apply_influences("modify_troop_initiative", {"value": base})
	return int(base)
	
func critical_chance():
	var chance = -0.05 + float(get_strength()) / 500.0
	chance = apply_influences('add_troop_critical', {"value": chance})
	return chance
	
func anti_critical_chance():
	var chance = -0.1 + float(get_command()) / 500.0
	chance = apply_influences('add_troop_anti_critical', {"value": chance})
	return chance

func critical_damage_rate():
	var rate = 1 + float(get_strength()) / 100.0
	rate = apply_influences('modify_troop_critical_damage_rate', {"value": rate})
	return rate

####################################
#         Influence System         #
####################################
func apply_influences(operation, params: Dictionary):
	if params.has("value"):
		var value = params["value"]
		var all_params = params.duplicate()
		all_params["troop"] = self
		
		all_params["value"] = value
		value = military_kind.apply_influences(operation, all_params)

		for p in get_persons():
			all_params["value"] = value
			value = p.apply_influences(operation, all_params)

		return value

