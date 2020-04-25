extends Node
class_name CreatingTroop

var military_kind
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
	var strength = get_leader().strength
	var max_strength = 0
	for p in get_persons():
		if p.strength > max_strength:
			max_strength = p.strength
	strength = max(strength, max_strength * 0.7)
	return strength
	
func get_command():
	var command = get_leader().command
	var max_command = 0
	for p in get_persons():
		if p.command > max_command:
			max_command = p.command
	command = max(command, max_command * 0.7)
	return command

func get_offence():
	var troop_base = military_kind.base_offence
	var troop_quantity = military_kind.offence * quantity / military_kind.max_quantity_multiplier
	var ability_factor = ((get_strength() * 0.3 + get_command() * 0.7) + 10) / 100.0
	var morale_factor = (morale + 5) / 100.0
	
	return int((troop_base + troop_quantity) * ability_factor * morale_factor)
	
func get_defence():
	var troop_base = military_kind.base_defence
	var troop_quantity = military_kind.defence * quantity / military_kind.max_quantity_multiplier
	var ability_factor = (get_command() + 10) / 100.0
	var morale_factor = (morale + 10) / 100.0
	
	return int((troop_base + troop_quantity) * ability_factor * morale_factor)

func get_speed():
	return military_kind.speed
	
func get_initiative():
	return military_kind.initiative
