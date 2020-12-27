extends Node2D
class_name Troop

enum OrderType { MOVE, FOLLOW, ATTACK, ACTIVATE_STUNT, ENTER }
enum AIState { MARCH, COMBAT, RETREAT }

enum Status { NORMAL, CHAOS, FORCED_RETREAT, FORCED_ATTACK, STOP }

var id: int setget forbidden
var scenario

var gname: String setget forbidden

var map_position: Vector2 setget forbidden

var military_kind setget forbidden
var quantity: int setget forbidden
var morale: int setget forbidden
var combativity: int setget forbidden

var status = Status.NORMAL setget forbidden
var active_stunt setget forbidden
var active_stunt_level setget forbidden
var active_stunt_days = 0 setget forbidden

var order_made: bool setget forbidden

var _recently_battled: int setget forbidden

var _person_list = Array() setget forbidden, get_all_persons

var _belonged_section setget forbidden, get_belonged_section
var _starting_arch setget forbidden, get_starting_architecture

var current_order setget forbidden
var _current_path setget forbidden
var _current_path_index = 0 setget forbidden
var _remaining_movement = 0 setget forbidden

var _food_shortage: bool = false

var _orientation = "e" setget forbidden

var _ai_state
var _ai_destination_architecture
var _ai_path

var _destroyed = false

var _leader

var _scenario_loaded = false

var pathfinder: PathFinder

signal troop_clicked
signal animation_step_finished
signal animation_attack_finished

signal starting_architecture_changed
signal troop_survey_updated

signal performed_attack
signal received_attack
signal occupy_architecture
signal destroyed
signal removed
signal position_changed

signal target_troop_destroyed
signal target_architecture_destroyed

signal person_captured
signal person_released

signal start_stunt

func forbidden(x):
	assert(false)
	
func object_type():
	return ScenarioUtil.ObjectType.TROOP
	
func _ready():
	_update_military_kind_sprite()
	$TroopArea/AnimatedSprite.animation = "move_e"
	$TroopArea/AnimatedSprite.play()

	position.x = map_position.x * scenario.tile_size
	position.y = map_position.y * scenario.tile_size
	scale.x = SharedData.TILE_SIZE / 128.0
	scale.y = SharedData.TILE_SIZE / 128.0
	scenario.connect("scenario_loaded", self, "_on_scenario_loaded")
	scenario.connect("scenario_camera_moved", self, "_on_camera_moved")
	
	var click_area = CollisionShape2D.new()
	click_area.shape = RectangleShape2D.new()
	click_area.shape.extents = Vector2(SharedData.TILE_SIZE, SharedData.TILE_SIZE)
	$TroopArea.add_child(click_area)

func set_scenario(scen):
	scenario = scen
	pathfinder = PathFinder.new(self)
	

####################################
#            Save / Load           #
####################################
func load_data(json: Dictionary, objects):
	id = json["_Id"]
	
	map_position = Util.load_position(json["MapPosition"])
	
	for id in json["PersonList"]:
		add_person(objects["persons"][int(id)])
	
	military_kind = scenario.military_kinds[int(json["MilitaryKind"])]
	quantity = json["Quantity"]
	morale = json["Morale"]
	combativity = json["Combativity"]
	
	order_made = json["_OrderMade"]
	
	_orientation = json["_Orientation"]
	
	_starting_arch = scenario.architectures[int(json["StartingArchitecture"])]
	_food_shortage = json["_FoodShortage"]

	_recently_battled = json["_RecentlyBattled"]
	
	_ai_state = json["_AIState"]
	var __arch = json["_AIDestinationArchitecture"]
	if __arch != null:
		_ai_destination_architecture = scenario.architectures[int(__arch)]
		if _starting_arch.id == _ai_destination_architecture.id:
			_ai_path = [_starting_arch.map_position]
		else:
			_ai_path = scenario.get_ai_path(military_kind.movement_kind.id, _starting_arch, _ai_destination_architecture)
	else:
		_ai_destination_architecture = null
	_leader = _person_list[0]
	gname = _leader.get_name() + tr('PERSON_TROOP')
	
func save_data() -> Dictionary:
	var order_type
	var order_target = -1
	var order_target_type = ""
	var order_stunt = -1
	var order_stunt_level = 0
	if current_order != null:
		order_type = current_order.type
		if current_order.target != null:
			if current_order.target is Architecture:
				order_target = current_order.target.id
				order_target_type = "Architecture"
			elif current_order.target is Vector2:
				order_target = Util.save_position(current_order.target)
				order_target_type = "Position"
			else:
				order_target = current_order.target.id
				order_target_type = "Troop"
		
		if current_order.has("stunt"):
			order_stunt = current_order.stunt.id
			order_stunt_level = current_order.stunt_level
	return {
		"_Id": id,
		"MapPosition": Util.save_position(map_position),
		"PersonList": Util.id_list(get_persons()),
		"StartingArchitecture": _starting_arch.id,
		"MilitaryKind": military_kind.id,
		"Quantity": quantity,
		"Morale": morale,
		"Combativity": combativity,
		"_OrderMade": order_made,
		"_FoodShortage": _food_shortage,
		"_Orientation": _orientation,
		"_CurrentOrderType": order_type,
		"_CurrentOrderTarget": order_target,
		"_CurrentOrderTargetType": order_target_type,
		"_CurrentOrderStunt": order_stunt,
		"_CurrentOrderStuntLevel": order_stunt_level,
		"_AIState": _ai_state,
		"_AIDestinationArchitecture": _ai_destination_architecture.id if _ai_destination_architecture != null else null,
		"_RecentlyBattled": _recently_battled
	}
	
func _on_scenario_loaded(scenario):
	update_troop_title()
	_scenario_loaded = true

func get_name() -> String:
	return gname

func get_all_persons() -> Array:
	return _person_list
	
func get_persons() -> Array:
	var result = []
	for p in _person_list:
		if p._status == Person.Status.NORMAL:
			result.append(p)
	return result
	
####################################
#        Set up / Tear down        #
####################################
func add_person(p, force: bool = false):
	if _person_list.size() == 0:
		_leader = p
		gname = _leader.get_name() + tr('PERSON_TROOP')
		update_troop_title()
	_person_list.append(p)
	if not force:
		p.set_location(self, true)
		  
func remove_person(p, force: bool = false):
	Util.remove_object(_person_list, p)
	var persons = get_persons()
	if not force and persons.size() <= 0:
		destroy(null)
	elif not force:
		_leader = persons[0]

func create_troop_set_data(in_id: int, starting_arch, kind, in_quantity: int, in_morale: int, in_combativity: int, pos: Vector2):
	id = in_id
	_starting_arch = starting_arch
	set_belonged_section(starting_arch.get_belonged_section())
	military_kind = kind
	if military_kind.has_equipments():
		starting_arch.take_equipment(military_kind, in_quantity)
	quantity = in_quantity
	morale = in_morale
	combativity = in_combativity
	map_position = pos
	_update_military_kind_sprite()
	var camera_rect = scenario.get_camera_viewing_rect() as Rect2
	_on_camera_moved(camera_rect, scenario.get_camera_zoom(), scenario)

####################################
#             Get stat             #
####################################
func get_belonged_section():
	return _belonged_section
	
func get_belonged_faction():
	return _belonged_section.get_belonged_faction()
	
func set_belonged_section(section, force = false):
	_belonged_section = section
	if not force:
		section.add_troop(self, true)
	
func get_starting_architecture():
	return _starting_arch

func get_leader():
	return _leader

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
	var troop_base = military_kind.base_offence * military_kind.terrain_strength[get_current_terrain().id]
	var troop_quantity = military_kind.offence * quantity / military_kind.max_quantity_multiplier
	var ability_factor = ((get_strength() * 0.3 + get_command() * 0.7) + 10) / 100.0
	var morale_factor = (morale + 1) / 100.0
	
	var base = (troop_base + troop_quantity) * ability_factor * morale_factor

	base = apply_influences("modify_troop_offence", {"value": base})
		
	var f = get_belonged_faction()
	if f != null and not f.player_controlled:
		base *= scenario.scenario_config.ai_troop_offence_rate

	return int(base)
	
func get_defence():
	var troop_base = military_kind.base_defence * military_kind.terrain_strength[get_current_terrain().id]
	var troop_quantity = military_kind.defence * quantity / military_kind.max_quantity_multiplier
	var ability_factor = (get_command() + 10) / 100.0
	var morale_factor = (morale + 1) / 100.0

	var base = (troop_base + troop_quantity) * ability_factor * morale_factor

	base = apply_influences("modify_troop_defence", {"value": base})
		
	var f = get_belonged_faction()
	if f != null and not f.player_controlled:
		base *= scenario.scenario_config.ai_troop_defence_rate
		
	return int(base)
	
func get_offence_over_defence():
	return get_offence() / get_defence()

func get_speed():
	var base = military_kind.speed
	base = apply_influences("modify_troop_speed", {"value": base})
	return int(base)
	
func get_initiative():
	var base = military_kind.initiative * military_kind.terrain_strength[get_current_terrain().id]
	base = apply_influences("modify_troop_initiative", {"value": base})
	return int(base)
	
static func cmp_initiative(a, b):
	return a.get_initiative() > b.get_initiative()
	
func get_current_terrain():
	return scenario.get_terrain_at_position(map_position)
	
func get_on_architecture():
	return scenario.get_architecture_at_position(map_position)

# returns [cost, blocked by object]
func get_movement_cost(position, ignore_troops):
	if not ignore_troops:
		var troop = scenario.get_troop_at_position(position)
		if troop != null:
			return [INF, troop]
	var arch = scenario.get_architecture_at_position(position)
	if arch != null and get_belonged_faction().is_enemy_to(arch.get_belonged_faction()) and arch.endurance > 0:
		return [INF, arch]
	
	var terrain = scenario.get_terrain_at_position(position)
	if terrain != null:
		return [military_kind.movement_kind.movement_cost[terrain.id], null]
	return [INF, null]
	
func enemy_troop_in_range(distance: int):
	var results = []
	for t in scenario.troops:
		var troop = scenario.troops[t]
		if troop.get_belonged_faction().is_enemy_to(get_belonged_faction()) and Util.m_dist(troop.map_position, self.map_position) <= distance and not troop._destroyed:
			results.append(troop)
	return results
	
func friendly_troop_in_range(distance: int):
	var results = []
	for t in scenario.troops:
		var troop = scenario.troops[t]
		if troop.get_belonged_faction().is_friend_to(get_belonged_faction()) and Util.m_dist(troop.map_position, self.map_position) <= distance and not troop._destroyed:
			results.append(troop)
	return results

func enemy_architectures_in_range(distance: int):
	var results = []
	for a in scenario.architectures:
		var architecture = scenario.architectures[a]
		var other_faction = architecture.get_belonged_faction()
		if (other_faction == null or other_faction.is_enemy_to(get_belonged_faction())) and Util.m_dist(architecture.map_position, self.map_position) <= distance:
			results.append(architecture)
	return results
	
func can_occupy():
	var on_arch = scenario.get_architecture_at_position(map_position)
	if on_arch != null:
		var check_positions = Util.squares_in_range(on_arch.map_position, 1)
		for p in check_positions:
			var troop = scenario.get_troop_at_position(p)
			if troop != null and troop.get_belonged_faction().is_enemy_to(get_belonged_faction()):
				return false
		return true
	return false
	
func move_eta(to):
	return int(ScenarioUtil.object_distance(self, to) * 0.2) + 1
	
func critical_chance():
	var chance = -0.05 + float(get_strength()) / 500.0
	chance = apply_influences('add_troop_critical', {"value": chance})
	return chance
	
func anti_critical_chance():
	var chance = -0.1 + float(get_command()) / 500.0
	chance = apply_influences('add_troop_anti_critical', {"value": chance})
	return chance

func critical_damage_rate(other_troop):
	var rate
	if other_troop == null or other_troop is Architecture:
		rate = 1 + float(get_strength()) / 100.0
	else:
		rate = 1 + float(get_strength()) / max(10, other_troop.get_strength())

	rate = apply_influences('modify_troop_critical_damage_rate', {"value": rate})
	return rate
	
func get_movement_area():
	return pathfinder.get_movement_area()

####################################
#             Set order            #
####################################
func _clear_order():
	current_order = null

func set_move_order(position):
	assert(!order_made)
	order_made = true
	current_order = {
		"type": OrderType.MOVE,
		"target": position
	}
	if _scenario_loaded:
		update_troop_title()
	
func set_enter_order(position):
	assert(!order_made)
	order_made = true
	var architecture = scenario.get_architecture_at_position(position)
	current_order = {
		"type": OrderType.ENTER,
		"target": architecture
	}
	if _scenario_loaded:
		update_troop_title()
		
func set_follow_order(troop):
	assert(!order_made)
	order_made = true
	if troop == null:
		current_order = null
	else:
		current_order = {
			"type": OrderType.FOLLOW,
			"target": troop
		}
	if _scenario_loaded:
		update_troop_title()
	
func set_attack_order(troop, arch):
	assert(!order_made)
	order_made = true
	var object
	if troop != null:
		object = troop
	elif arch != null:
		object = arch
	else:
		current_order = null
		return
	current_order = {
		"type": OrderType.ATTACK,
		"target": object
	}
	if _scenario_loaded:
		update_troop_title()

func set_activate_stunt_order(stunt, level):
	assert(!order_made)
	order_made = true
	current_order = {
		"type": OrderType.ACTIVATE_STUNT,
		"target": null,
		"stunt": stunt,
		"stunt_level": level
	}
	if _scenario_loaded:
		update_troop_title()
	
func set_position(pos):
	var old_position = map_position
	map_position = pos
	call_deferred("emit_signal", "position_changed", self, old_position, map_position)
	return _animate_position(old_position, map_position)
	
func add_morale(delta):
	if delta < 0:
		delta = apply_influences("modify_morale_loss", {"value": delta})
	elif delta > 0:
		delta = apply_influences("modify_morale_gain", {"value": delta})

	morale += delta
	morale = clamp(morale, 1, 100)

	
func get_order_text():
	if current_order == null:
		return ""
	match current_order.type:
		OrderType.MOVE: return "MOVE"
		OrderType.ATTACK: return "ATTACK"
		OrderType.FOLLOW: return "FOLLOW"
		OrderType.ENTER: return "ENTER"
		OrderType.ACTIVATE_STUNT: return "ACTIVATE_STUNT"
		_: return ""
		
func get_order_target_text():
	if current_order == null or current_order.target == null:
		return ""
	elif current_order.target is Vector2:
		return str(current_order.target)
	else:
		return current_order.target.get_name()
		
func occupy():
	for p in get_persons():
		if p == get_leader():
			p.add_popularity(2)
			p.add_prestige(4)
		else:
			p.add_popularity(1)
			p.add_prestige(2)
	
	var arch = scenario.get_architecture_at_position(map_position)
	arch.change_faction(get_belonged_section())
	call_deferred("emit_signal", "occupy_architecture", self, arch)


func set_recently_battled():
	_recently_battled = 5


func add_combativity(delta):
	if delta < 0:
		delta = apply_influences("modify_combativity_loss", {"value": delta})
	elif delta > 0:
		delta = apply_influences("modify_combativity_gain", {"value": delta})
		
	combativity += delta
	combativity = clamp(combativity, 0, 100)


func set_status(in_status):
	status = in_status
	update_status_sprite()


####################################
#              Stunts              #
####################################

func available_stunts():
	var result = {}
	var stunts = get_leader().stunts
	for stunt in stunts:
		if stunt.combativity_cost <= combativity and stunt.check_conditions(self):
			result[stunt] = stunts[stunt]
	return result


func activate_stunt(stunt, level):
	assert(stunt.combativity_cost <= combativity)
	combativity -= stunt.combativity_cost
	active_stunt = stunt
	active_stunt_level = level
	active_stunt_days = stunt.duration
	active_stunt_days = apply_influences("add_active_stunt_days", {"value": active_stunt_days})
	_animate_stunt_start(stunt)
	current_order = null

func get_active_stunt_name():
	if active_stunt == null:
		return "----"
	return active_stunt.get_name() + active_stunt_level
	
func get_active_stunt_days_str():
	if active_stunt == null:
		return "--"
	return str(active_stunt_days)

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
		if active_stunt != null:
			all_params["value"] = value
			value = active_stunt.apply_influences(operation, active_stunt_level, all_params)
		for p in get_persons():
			all_params["value"] = value
			value = p.apply_influences(operation, all_params)

		return value


####################################
#          Order Execution         #
####################################
var _attack_count_in_turn = 0
var __step_retry = 0
func prepare_orders():
	_remaining_movement = get_speed()
	_current_path = null
	_current_path_index = 0
	__step_retry = 0
	_attack_count_in_turn = 0
	pathfinder.prepare_orders()
	if current_order != null:
		if current_order.type == OrderType.MOVE:
			_current_path = pathfinder.get_stored_path_to(current_order.target)


enum ExecuteStepType { MOVED, BLOCKED, STOPPED }
class ExecuteStepResult:
	var type #:ExecuteStepType
	var new_position
	func _init(t, n):
		type = t
		new_position = n

func execute_step() -> ExecuteStepResult:
	if current_order != null and current_order.type == OrderType.ACTIVATE_STUNT:
		activate_stunt(current_order.stunt, current_order.stunt_level)
		return ExecuteStepResult.new(ExecuteStepType.STOPPED, null)
	elif current_order != null and current_order.type == OrderType.MOVE:
		_current_path_index += 1
		if _current_path_index >= _current_path.size():
			return ExecuteStepResult.new(ExecuteStepType.STOPPED, null)
		var new_position = _current_path[_current_path_index]
		var movement_cost = get_movement_cost(new_position, false)
		if movement_cost[1] != null:
			_current_path_index -= 1
			__step_retry += 1
			if __step_retry <= 3:
				return ExecuteStepResult.new(ExecuteStepType.BLOCKED, null)
			else:
				var random_position = Util.random_shift_position(new_position)
				var random_movement_cost = get_movement_cost(random_position, false)
				if _remaining_movement >= random_movement_cost[0]:
					_remaining_movement -= random_movement_cost[0]
					__step_retry = 0
					return ExecuteStepResult.new(ExecuteStepType.MOVED, random_position)
				else:
					return ExecuteStepResult.new(ExecuteStepType.STOPPED, null)
		elif _remaining_movement >= movement_cost[0]:
			_remaining_movement -= movement_cost[0]
			__step_retry = 0
			return ExecuteStepResult.new(ExecuteStepType.MOVED, new_position)
		else:
			return ExecuteStepResult.new(ExecuteStepType.STOPPED, null)
	elif current_order != null and (current_order.type == OrderType.FOLLOW || current_order.type == OrderType.ATTACK || current_order.type == OrderType.ENTER):
		var target = current_order.target
		if is_instance_valid(target) and not target._destroyed:
			var step_result = pathfinder.stupid_path_to_step(target.map_position)
			
			if step_result == null:
				__step_retry += 1
				if __step_retry <= 3:
					return ExecuteStepResult.new(ExecuteStepType.BLOCKED, null)
				else:
					return ExecuteStepResult.new(ExecuteStepType.STOPPED, null)
			elif _remaining_movement >= step_result[1]:
				_remaining_movement -= step_result[1]
				__step_retry = 0
				return ExecuteStepResult.new(ExecuteStepType.MOVED, step_result[0])
			else:
				return ExecuteStepResult.new(ExecuteStepType.STOPPED, null)
		else:
			return ExecuteStepResult.new(ExecuteStepType.STOPPED, null)
	else:
		return ExecuteStepResult.new(ExecuteStepType.STOPPED, null)
		
func execute_enter():
	if current_order != null and current_order.type == OrderType.ENTER:
		var architecture = current_order.target
		if Util.m_dist(map_position, architecture.map_position) <= 1:
			architecture.accept_entering_troop(self)
			_destroyed = true
			_remove()
			
		
func execute_attack():
	if current_order != null and current_order.type == OrderType.ATTACK and _attack_count_in_turn < 1:
		var target = current_order.target
		if is_instance_valid(self) and is_instance_valid(target) and not self._destroyed and not target._destroyed:
			var dist = Util.m_dist(map_position, current_order.target.map_position)
			if dist >= military_kind.range_min and dist <= military_kind.range_max:
				var target_valid = (target is Architecture and target.endurance > 0) or (not target is Architecture and target.quantity > 0)
				var self_valid = quantity > 0
				if self_valid and target_valid:
					_attack_count_in_turn += 1
					set_recently_battled()
					target.set_recently_battled()
					
					var exp_factor = 1.0

					var actual_offence = get_offence()
					var actual_defence = get_defence()
					var actual_target_offence = target.get_offence()
					var actual_target_defence = target.get_defence()
					if not (target is Architecture):
						actual_offence *= military_kind.get_type_offensive_effectivenss(target.military_kind)
						actual_defence *= military_kind.get_type_defensive_effectivenss(target.military_kind)
						actual_target_offence *= target.military_kind.get_type_offensive_effectivenss(military_kind)
						actual_target_defence *= target.military_kind.get_type_defensive_effectivenss(military_kind)
					
					var damage = exp(0.693147 * log(float(actual_offence) / actual_target_defence) + 6.21461) + 1
					var counter_damage
					if military_kind.receive_counter_attacks:
						counter_damage = exp(0.693147 * log(float(actual_target_offence) / actual_defence) + 6.21461) * 0.5 + 1
					else:
						counter_damage = 0
					if target is Architecture:
						damage = damage * military_kind.architecture_attack_factor
					else:
						var target_on_arch = target.get_on_architecture()
						if target_on_arch != null:
							damage = apply_influences("modify_troop_damage_on_architecture", {"value": damage, "target": target})
						
					damage = apply_influences("modify_troop_damage", {"value": damage, "target": target})
					counter_damage = apply_influences("modify_troop_counter_damage", {"value": counter_damage, "target": target})
					
					var critical = false
					if randf() < critical_chance() - target.anti_critical_chance():
						critical = true
						damage *= critical_damage_rate(target)
						exp_factor += 0.5
					
					damage = max(1, int(damage))
					if military_kind.receive_counter_attacks:
						counter_damage = max(1, int(counter_damage))

					var damage_for_merit = damage * (10 if target is Architecture else 1)
					var merit_rate = min(sqrt(damage_for_merit / (counter_damage + 100.0)), 5) + damage_for_merit / 1000.0
					for p in get_persons():
						if p == get_leader():
							p.add_combat_exp(20)
							p.add_military_type_exp(military_kind.type, 20 * exp_factor)
							p.add_command_exp(20)
							p.add_strength_exp(30)
							p.add_merit((merit_rate - 0.5) * 25)
							p.add_popularity(merit_rate / 2)
							p.add_prestige(merit_rate - 1.25)
							if target is Architecture:
								p.arch_damage_dealt += damage
							else:
								p.troop_damage_dealt += damage
							p.troop_damage_received += counter_damage
						else:
							p.add_combat_exp(10)
							p.add_military_type_exp(military_kind.type, 10 * exp_factor)
							p.add_command_exp(10)
							p.add_strength_exp(15)
							p.add_merit((merit_rate - 0.5) * 12.5)
							p.add_popularity(merit_rate / 4)
							p.add_prestige(merit_rate / 2 - 0.625)
					
					var other_merit_rate = min(sqrt(counter_damage / (damage + 100.0)), 5) + counter_damage / 1000.0
					if not target is Architecture:
						for p in target.get_persons():
							if p == get_leader():
								p.add_combat_exp(20)
								p.add_military_type_exp(military_kind.type, 20 * exp_factor)
								p.add_command_exp(40)
								p.add_strength_exp(10)
								p.add_merit((merit_rate - 0.5) * 25)
								p.add_popularity(other_merit_rate / 2)
								p.add_prestige(other_merit_rate - 1.25)
								p.troop_damage_dealt += counter_damage
								p.troop_damage_received += damage
							else:
								p.add_combat_exp(10)
								p.add_military_type_exp(military_kind.type, 10 * exp_factor)
								p.add_command_exp(20)
								p.add_strength_exp(5)
								p.add_merit((merit_rate - 0.5) * 12.5)
								p.add_popularity(other_merit_rate / 4)
								p.add_prestige(other_merit_rate / 2 - 0.625)
				
					receive_attack_damage(counter_damage, target)
					target.receive_attack_damage(damage, self)
					
					return _animate_attack(target, counter_damage, damage, critical)
				else:
					return false
			else:
				return false
		else:
			return false
	else:
		return false
		
func receive_attack_damage(damage, attacker):
	quantity -= damage
	add_morale(-Util.f2ri(damage / 100.0 * max(0.0, 1.1 - get_leader().get_glamour() / 100.0)))
	return check_destroy(attacker)
			
func check_destroy(attacker):
	if quantity <= 0 or morale <= 0 or len(get_persons()) <= 0:
		destroy(attacker)
		return true
	return false

func destroy(attacker):
	# affect nearby troop morale
	for t in friendly_troop_in_range(4):
		if not t._destroyed:
			t.add_morale(5 + min(5, t.get_leader().get_glamour() / 20))
	for t in enemy_troop_in_range(4):
		if not t._destroyed:
			t.add_morale(-10 + min(5, t.get_leader().get_glamour() / 20))

	# keep rout counts
	get_leader().routed_count += 1
	if attacker != null and not attacker is Architecture:
		attacker.get_leader().rout_count += 1
	
	# capture and release persons
	var captured_persons = []
	var released_persons = []
	var list = get_all_persons().duplicate()
	for p in list:
		if p._status == Person.Status.CAPTIVE: 
			released_persons.append(p)
			var captive_return_to = p.get_old_faction().capital
			p.become_free()
			p.move_to_architecture(captive_return_to)
		else:
			var capture_chance
			if attacker != null and not attacker is Architecture and attacker.get_persons().size() > 0:
				var capture_ability = Util.max_by(attacker.get_persons(), "get_capture_ability")[2]
				var escape_ability = p.get_escape_ability()
				var ratio = capture_ability / escape_ability 
				capture_chance = 0.726 / (1 + exp(-0.613 * (ratio - 4.644)))
			else:
				capture_chance = -1
				
			if attacker != null and randf() < capture_chance:
				if p == get_leader():
					p.add_merit(-60)
					p.add_prestige(-4)
				else:
					p.add_merit(-30)
					p.add_prestige(-2)
				p.become_captured(attacker)
				captured_persons.append(p)
				p.be_captured_count += 1
				attacker.get_leader().capture_count += 1
			else:
				var return_to = get_starting_architecture()
				if return_to.get_belonged_faction() != self.get_belonged_faction():
					return_to = self.get_belonged_faction().capital
				if p == get_leader():
					p.add_merit(-40)
					p.add_prestige(-2)
				else:
					p.add_merit(-20)
					p.add_prestige(-1)
				p.move_to_architecture(return_to)
	assert(len(get_all_persons()) == 0)
			
	if captured_persons.size() > 0:
		call_deferred("emit_signal", "person_captured", attacker, captured_persons)
	if released_persons.size() > 0:
		call_deferred("emit_signal", "person_released", self, released_persons)
	
	# perform destroy
	call_deferred("emit_signal", "destroyed", self)
	_destroyed = true
		
func _remove():
	assert(len(get_all_persons()) == 0)
	call_deferred("emit_signal", "removed", self)
	for t in scenario.troops:
		var troop = scenario.troops[t]
		if troop.current_order != null and troop.current_order.type == OrderType.ATTACK and troop.current_order.target == self:
			troop._clear_order()
	get_belonged_section().remove_troop(self)
	queue_free()
	
func after_order_cleanup():
	if current_order != null and current_order.type == OrderType.MOVE and current_order.target == map_position:
		current_order = null
	pathfinder.after_order_cleanup()
	
func day_event():
	order_made = false
	update_troop_title()

	if get_starting_architecture().get_belonged_faction() != get_belonged_faction():
		var move_to = ScenarioUtil.nearest_architecture_of_faction(get_belonged_faction(), map_position)
		if move_to != null:
			_starting_arch = move_to
			call_deferred("emit_signal", "starting_architecture_changed", self)
	
	var food_required = int((1 + military_kind.food_per_soldier) * Util.m_dist(map_position, _starting_arch.map_position) * 0.25)
	if not _starting_arch.consume_food(food_required):
		if not _food_shortage:
			_food_shortage = true
		else:
			quantity = int(quantity * 0.9)
	else:
		_food_shortage = false

	if _recently_battled > 0:
		_recently_battled -= 1
		
		var add_morale_value = 0
		var add_combativity_value = 5

		add_morale_value = apply_influences("add_morale_per_day_during_battle", {"value": add_morale_value})
		add_combativity_value = apply_influences("add_combativity_per_day_during_battle", {"value": add_combativity_value})

		add_morale(add_morale_value)
		add_combativity(add_combativity_value)

	if active_stunt_days > 0:
		active_stunt_days -= 1
		if active_stunt_days <= 0:
			active_stunt = null
			call_deferred("_animate_stunt_stop")
		
	call_deferred("emit_signal", "troop_survey_updated", self)
		

####################################
#                UI                #
####################################
func update_status_sprite():
	$TroopArea/ChaosSprite.visible = false
	$TroopArea/ForcedRetreatSprite.visible = false
	$TroopArea/ForcedAttractSprite.visible = false
	$TroopArea/StopSprite.visible = false
	$TroopArea/ChaosSprite.playing = false
	$TroopArea/ForcedRetreatSprite.playing = false
	$TroopArea/ForcedAttractSprite.playing = false
	$TroopArea/StopSprite.playing = false
	match status:
		Status.CHAOS: 
			$TroopArea/ChaosSprite.visible = true
			$TroopArea/ChaosSprite.playing = true
		Status.FORCED_RETREAT: 
			$TroopArea/ForcedRetreatSprite.visible = true
			$TroopArea/ForcedRetreatSprite.playing = true
		Status.FORCED_ATTACK: 
			$TroopArea/ForcedRetreatSprite.visible = true
			$TroopArea/ForcedRetreatSprite.playing = true
		Status.STOP: 
			$TroopArea/StopSprite.visible = true
			$TroopArea/StopSprite.playing = true
	

func update_troop_title():
	if quantity > 0:
		$TroopTitle.show_data(self)

func _update_military_kind_sprite():
	var animated_sprite = $TroopArea/AnimatedSprite as AnimatedSprite
	if animated_sprite != null:
		var textures = SharedData.troop_images.get(military_kind.id, null)
		if textures != null:
			animated_sprite.frames = SharedData.troop_sprite_frames[military_kind.id]

	var sounds = SharedData.troop_sounds.get(military_kind.id, null)
	if sounds != null:
		$MovingSound.stream = sounds["moving"]
		$AttackSound.stream = sounds["attack"]
		$CriticalSound.stream = sounds["critical"]
	

		
func _animate_position(old_position, destination_position):
	_orientation = _get_animation_orientation(old_position, destination_position)
	var animated_sprite = $TroopArea/AnimatedSprite as AnimatedSprite
	animated_sprite.animation = "move_" + _orientation
	
	var destination = destination_position * scenario.tile_size
	var viewing_rect = scenario.get_camera_viewing_rect() as Rect2
	var troop_rect = Rect2($TroopArea.global_position, Vector2(SharedData.TILE_SIZE, SharedData.TILE_SIZE))
	if GameConfig.enable_troop_animations and viewing_rect.intersects(troop_rect):
		var animation = Animation.new()
		animation.length = 1.0 / GameConfig.troop_animation_speed
		var value_track_idx = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(value_track_idx, ".:position")
		animation.track_insert_key(value_track_idx, 0, position)
		animation.track_insert_key(value_track_idx, animation.length, destination)
		var sound_track_idx = animation.add_track(Animation.TYPE_AUDIO)
		animation.track_set_path(sound_track_idx, "MovingSound")
		animation.audio_track_insert_key(sound_track_idx, 0, $MovingSound.stream)
		$AnimationPlayer.add_animation("Move", animation)
		$AnimationPlayer.play("Move")
		return true
	else:
		position = destination
		return false

var __anim_self_damage = 0
func _animate_attack(target, self_damage, target_damage, critical):
	_orientation = _get_animation_orientation(map_position, target.map_position)
	var reverse_orientation = _get_animation_orientation(target.map_position, map_position)

	var viewing_rect = scenario.get_camera_viewing_rect() as Rect2
	var troop_rect = Rect2($TroopArea.global_position, Vector2(SharedData.TILE_SIZE, SharedData.TILE_SIZE))
	if GameConfig.enable_troop_animations and viewing_rect.intersects(troop_rect):
		var animated_sprite = $TroopArea/AnimatedSprite as AnimatedSprite
		animated_sprite.animation = "attack_" + _orientation
		__anim_self_damage = self_damage

		var other_effect_sprite = target.find_node('EffectSprite')
		
		if critical:
			$CriticalSound.play()
			other_effect_sprite.visible = true
			other_effect_sprite.frame = 0
			other_effect_sprite.play("Critical")
		else:
			$AttackSound.play()
			other_effect_sprite.visible = true
			other_effect_sprite.frame = 0
			other_effect_sprite.play("Hit")
			
		if not target._destroyed:
			call_deferred("emit_signal", "performed_attack", self, target, critical)
			call_deferred("emit_signal", "received_attack", target, self, critical)
		
		if target is Architecture:
			yield($TroopArea/AnimatedSprite, "animation_finished")
			yield(other_effect_sprite, "animation_finished")
			target.find_node("NumberFlashText").text = target.find_node("NumberFlashText").text + "\n↓" + str(target_damage)
			target.find_node("NumberFlashText").find_node('Timer').start()
			if target.endurance <= 0:
				call_deferred("emit_signal", "target_architecture_destroyed", self, target)
		else:
			var area_node = target.find_node("TroopArea")
			var target_animated_sprite = area_node.find_node("AnimatedSprite") as AnimatedSprite
			if target_animated_sprite != null:
				target_animated_sprite.animation = "be_attacked_" + reverse_orientation
				target.__anim_self_damage = target_damage
			if target._destroyed:
				yield($TroopArea/AnimatedSprite, "animation_finished")
				yield(other_effect_sprite, "animation_finished")
				call_deferred("emit_signal", "target_troop_destroyed", self, target)
		
		return true
	else:
		update_troop_title()
		if _destroyed:
			_remove()
		if target._destroyed:
			target._remove()
		return false
	
func _on_AnimatedSprite_animation_finished():
	var animated_sprite = $TroopArea/AnimatedSprite as AnimatedSprite
	if animated_sprite.animation.begins_with("attack_") or animated_sprite.animation.begins_with("be_attacked_"):
		update_troop_title()
		animated_sprite.animation = "move_" + _orientation
		
		if __anim_self_damage > 0 and not _destroyed:
			find_node("NumberFlashText").text = find_node("NumberFlashText").text + "\n↓" + str(__anim_self_damage)
			find_node("NumberFlashText").find_node('Timer').start()
			__anim_self_damage = 0
		
		if _destroyed:
			$TroopArea/AnimatedSprite.hide()
			$TroopArea/Routed.show()
			$TroopArea/Routed.play()
			$TroopArea/Routed/RoutedSound.play()
		else:
			call_deferred("emit_signal", "animation_attack_finished")
	
func _on_Routed_animation_finished():
	call_deferred("emit_signal", "animation_attack_finished")
	_remove()

func _on_AnimationPlayer_animation_finished(anim_name):
	call_deferred("emit_signal", "animation_step_finished")
	
func _on_camera_moved(camera_rect: Rect2, zoom: Vector2, scen):
	if zoom.x >= 1.2 or zoom.y >= 1.2:
		$TroopTitle.visible = false
	else:
		$TroopTitle.visible = true
		$TroopTitle.rect_scale.x = min(1, min(1, zoom.x) + 0.5 / min(1, zoom.x)) * 1.5
		$TroopTitle.rect_scale.y = min(1, min(1, zoom.y) + 0.5 / min(1, zoom.y)) * 1.5

func _get_animation_orientation(from: Vector2, to: Vector2):
	if from.x == to.x:
		if from.y > to.y:
			return "n"
		else:
			return "s"
	elif from.x > to.x:
		if from.y == to.y:
			return "w"
		elif from.y > to.y:
			return "nw"
		else:
			return "sw"
	else:
		if from.y == to.y:
			return "e"
		elif from.y > to.y:
			return "ne"
		else:
			return "se"
			
func _animate_stunt_start(stunt):
	$TroopArea/StuntSprite.animation = stunt.tile_effect
	$TroopArea/StuntSprite.frame = 0
	$TroopArea/StuntSprite.show()
	$TroopArea/StuntSprite.play()
	call_deferred("emit_signal", "start_stunt", self, stunt)

func _animate_stunt_stop():
	$TroopArea/StuntSprite.stop()
	$TroopArea/StuntSprite.hide()
	
func _on_EffectSprite_animation_finished():
	$TroopArea/EffectSprite.hide()

	
####################################
#         UI event handling        #
####################################
func _on_TroopArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			call_deferred("emit_signal", "troop_clicked", self, event.global_position.x, event.global_position.y)

func get_screen_position():
	return get_global_transform_with_canvas().origin



