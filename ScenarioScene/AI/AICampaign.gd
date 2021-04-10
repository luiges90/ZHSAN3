extends Node
class_name AICampaign

var ai

func _init(ai):
	self.ai = ai
	
var ___sorting_create_troop_offensive
var ___nearby_troops = []
var ___nearby_terrain = {}
func _create_troops(from_architecture, target, scenario, offensive) -> Array:
	if from_architecture.troop <= 0 || from_architecture.troop_morale <= 0: 
		return []

	___sorting_create_troop_offensive = offensive

	# compute nearby terrain
	___nearby_terrain.clear()
	var nearby_squares = Util.squares_in_range(target.map_position, 6)
	for s in nearby_squares:
		var terrain = scenario.get_terrain_at_position(s)
		if terrain != null:
			Util.dict_inc(___nearby_terrain, terrain.id, 1)
	
	var troops_created = []
	var stop_creating_troop = false
	while !stop_creating_troop:
		var avail_positions = from_architecture.create_troop_positions()
		var persons = from_architecture.get_workable_persons()
		
		if persons.size() <= 0:
			break
		
		var avail_military_kinds = {}
		var avail_naval_military_kinds = {}
		if from_architecture == target:
			for mk in from_architecture.equipments:
				if scenario.military_kinds[mk].is_naval():
					avail_naval_military_kinds[mk] = from_architecture.equipments[mk]
				elif from_architecture.equipments[mk] > 100:
					avail_military_kinds[mk] = from_architecture.equipments[mk]
		else:
			var avail_movement_kinds = scenario.get_ai_path_available_movement_kinds(from_architecture, target)
			for mk in scenario.military_kinds:
				if scenario.military_kinds[mk].is_naval():
					avail_naval_military_kinds[mk] = scenario.military_kinds[mk]
				elif avail_movement_kinds.has(scenario.military_kinds[mk].movement_kind.id) and from_architecture.equipments.has(mk) and from_architecture.equipments[mk] > 1000:
					avail_military_kinds[mk] = from_architecture.equipments[mk]
		if avail_military_kinds.size() <= 0 or avail_naval_military_kinds.size() <= 0:
			break

		var max_value = 0
		var selected_naval_military_kind = null
		for mk in avail_naval_military_kinds:
			var military_kind = scenario.military_kinds[mk]
			var v = ___get_ai_value(military_kind)
			if ___get_ai_value(military_kind) > max_value:
				max_value = v
				selected_naval_military_kind = military_kind
		
		var candidates = []
		for equipment_id in avail_military_kinds:
			var troop = CreatingTroop.new()
			troop.military_kind = scenario.military_kinds[equipment_id]
			troop.naval_military_kind = selected_naval_military_kind
			
			var leader = Util.max_by(persons, "get_troop_leader_ability", {"military_kind": troop.military_kind})[1]
			troop.persons = [leader]
			
			troop.morale = from_architecture.troop_morale
			troop.combativity = from_architecture.troop_combativity
			troop.quantity = min(from_architecture.equipments[equipment_id] / 100 * 100, leader.get_max_troop_quantity() * troop.military_kind.max_quantity_multiplier)
			assert(troop.quantity > 0)
			
			candidates.append(troop)
		
		candidates.sort_custom(self, "__compare_troop_ai_value")
		var inner_troops_created = false
		for troop in candidates:
			if avail_positions.size() > 0 and persons.size() > 0:
				var valid = true
				for p in troop.persons:
					if p.get_location() != from_architecture:
						valid = false
				if valid and ai._ai_troop.consider_make_troop(troop, from_architecture == target):
					inner_troops_created = true
					var position = Util.random_from(avail_positions)
					if position != null:
						troops_created.append(scenario.create_troop(from_architecture, troop, position))
			else:
				stop_creating_troop = true
		if not inner_troops_created:
			stop_creating_troop = true
		
	return troops_created
	
func __starting_architecture_changed(troop):
	troop._ai_state = Troop.AIState.RETREAT
	troop._ai_destination_architecture = troop.get_starting_architecture()
	if troop.get_starting_architecture() == troop._ai_destination_architecture:
		troop._ai_path = [troop._ai_destination_architecture.map_position]
	else:
		troop._ai_path = troop.scenario.get_ai_path(troop.military_kind.movement_kind.id, troop.get_starting_architecture(), troop._ai_destination_architecture)
	
func _setup_starting_architecture_changed_signal(troop):
	troop.connect("starting_architecture_changed", self, "__starting_architecture_changed")

func defence(arch, section, scenario):
	var enemy_troops = arch.enemy_troop_in_range(6)
	if enemy_troops.size() > 0:
		___nearby_troops = enemy_troops
		var troops = _create_troops(arch, arch, scenario, false)
		for troop in troops:
			troop._ai_state = Troop.AIState.COMBAT
			troop._ai_destination_architecture = arch
			troop._ai_path = [arch.map_position]
			_setup_starting_architecture_changed_signal(troop)

func offence(arch, section, scenario):
	var selected_target
	var self_power = ai._estimated_arch_military_power(arch)
	var selected_target_power = self_power
	for a in ai._frontline_connected_archs(arch):
		var target_power = ai._estimated_arch_military_power(a) + arch.endurance * 1000000 + Util.m_dist(arch.map_position, a.map_position)
		if target_power < self_power and target_power < selected_target_power:
			selected_target = a
			selected_target_power = target_power
	
	if selected_target != null:
		var troops = _create_troops(arch, selected_target, scenario, true)
		for troop in troops:
			troop._ai_state = Troop.AIState.MARCH
			troop._ai_destination_architecture = selected_target
			troop._ai_path = scenario.get_ai_path(troop.military_kind.movement_kind.id, troop.get_starting_architecture(), troop._ai_destination_architecture)
			_setup_starting_architecture_changed_signal(troop)
			
func __compare_troop_ai_value(a, b):
	if ___get_ai_value(a) > ___get_ai_value(b):
		return true
	return false

func ___get_ai_value(troop):
	var offensive = ___sorting_create_troop_offensive

	var offence = troop.get_offence()
	var defence = troop.get_defence()
	var speed = troop.get_speed()
	var initiative = troop.get_initiative()
	var siege = troop.get_architecture_attack_factor()

	var terrain_factor = 0
	var terrain_speed_factor = 0
	var terrain_strengths = troop.get_terrain_strengths()
	var terrain_movement = troop.get_movement_costs()
	for ts in terrain_strengths:
		terrain_factor += terrain_strengths[ts] * Util.dict_try_get(___nearby_terrain, ts, 0)
	for tm in terrain_movement:
		terrain_speed_factor += (1.0 / terrain_movement[tm]) * Util.dict_try_get(___nearby_terrain, tm, 0)
	offence *= terrain_factor
	defence *= terrain_factor
	speed *= terrain_speed_factor
	initiative *= terrain_factor

	if not troop.is_receive_counter_attacks():
		offence *= 1.2
		defence *= 0.8

	if offensive:
		offence = offence * 2 + offence * siege
		defence = defence * 2

	var range_factor = sqrt(troop.get_range_max()) - sqrt(troop.get_range_min()) + 1

	return (offence + defence) * speed * sqrt(initiative) * range_factor
