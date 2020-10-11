extends Node2D
class_name Troop

enum OrderType { MOVE, FOLLOW, ATTACK, ENTER }
enum AIState { MARCH, COMBAT, RETREAT }

var id: int setget forbidden
var scenario

var gname: String setget forbidden

var map_position: Vector2 setget forbidden

var military_kind setget forbidden
var quantity: int setget forbidden
var morale: int setget forbidden
var combativity: int setget forbidden

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

onready var pathfinder: PathFinder = PathFinder.new(self)

signal troop_clicked
signal animation_step_finished
signal animation_attack_finished

signal starting_architecture_changed
signal troop_survey_updated

signal occupy_architecture
signal destroyed
signal removed
signal position_changed

signal target_troop_destroyed
signal target_architecture_destroyed

signal person_captured
signal person_released

func forbidden(x):
	assert(false)
	
func object_type():
	return ScenarioUtil.ObjectType.TROOP
	
func _ready():
	_update_military_kind_sprite()
	$TroopArea/AnimatedSprite.animation = "move_e"
	$TroopArea/AnimatedSprite.play()
	
	if scenario:
		position.x = map_position.x * scenario.tile_size
		position.y = map_position.y * scenario.tile_size
		scale.x = SharedData.TILE_SIZE / 128.0
		scale.y = SharedData.TILE_SIZE / 128.0
		scenario.connect("scenario_loaded", self, "_on_scenario_loaded")
		scenario.connect("scenario_camera_moved", self, "_on_camera_moved")
	

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
	
	_orientation = json["_Orientation"]
	
	_starting_arch = scenario.architectures[int(json["StartingArchitecture"])]
	_food_shortage = json["_FoodShortage"]
	
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
	gname = _person_list[0].get_name() + tr('PERSON_TROOP')
	
func save_data() -> Dictionary:
	var order_type
	var order_target
	var order_target_type
	if current_order != null:
		order_type = current_order.type
		if current_order.target is Architecture:
			order_target = current_order.target.id
			order_target_type = "Architecture"
		elif current_order.target is Vector2:
			order_target = Util.save_position(current_order.target)
			order_target_type = "Position"
		else:
			order_target = current_order.target.id
			order_target_type = "Troop"
	return {
		"_Id": id,
		"MapPosition": Util.save_position(map_position),
		"PersonList": Util.id_list(get_persons()),
		"StartingArchitecture": _starting_arch.id,
		"MilitaryKind": military_kind.id,
		"Quantity": quantity,
		"Morale": morale,
		"Combativity": combativity,
		"_FoodShortage": _food_shortage,
		"_Orientation": _orientation,
		"_CurrentOrderType": order_type,
		"_CurrentOrderTarget": order_target,
		"_CurrentOrderTargetType": order_target_type,
		"_AIState": _ai_state,
		"_AIDestinationArchitecture": _ai_destination_architecture.id if _ai_destination_architecture != null else null
	}
	
func _on_scenario_loaded(scenario):
	update_troop_title()

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
	_person_list.append(p)
	if not force:
		p.set_location(self, true)
		  
func remove_person(p, force: bool = false):
	Util.remove_object(_person_list, p)
	if not force and _person_list.size() <= 0:
		destroy(null)

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
	gname = _person_list[0].get_name() + tr('PERSON_TROOP')
	_update_military_kind_sprite()
	update_troop_title()
	var camera_rect = scenario.get_camera_viewing_rect() as Rect2
	_on_camera_moved(camera_rect, scenario.get_camera_zoom(), scenario)

####################################
#             Get stat             #
####################################
func ai_value():
	return get_offence() + get_defence()

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
	return _person_list[0]

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

	for p in get_persons():
		base = p.apply_influences("modify_person_troop_offence", {"value": base, "person": p, "troop": self})
		
	var f = get_belonged_faction()
	if f != null and not f.player_controlled:
		base *= scenario.scenario_config.ai_troop_offence_rate

	return int(base)
	
func get_defence():
	var troop_base = military_kind.base_defence
	var troop_quantity = military_kind.defence * quantity / military_kind.max_quantity_multiplier
	var ability_factor = (get_command() + 10) / 100.0
	var morale_factor = (morale + 10) / 100.0

	var base = (troop_base + troop_quantity) * ability_factor * morale_factor
	for p in get_persons():
		base = p.apply_influences("modify_person_troop_defence", {"value": base, "person": p, "troop": self})
		
	var f = get_belonged_faction()
	if f != null and not f.player_controlled:
		base *= scenario.scenario_config.ai_troop_defence_rate
		
	return int(base)
	
func get_offence_over_defence():
	return get_offence() / get_defence()

func get_speed():
	var base = military_kind.speed
	for p in get_persons():
		base = p.apply_influences("modify_person_troop_speed", {"value": base, "person": p, "troop": self})
	return int(base)
	
func get_initiative():
	var base = military_kind.initiative
	for p in get_persons():
		base = p.apply_influences("modify_person_troop_initiative", {"value": base, "person": p, "troop": self})
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

####################################
#             Set order            #
####################################
func _clear_order():
	current_order = null

func set_move_order(position):
	current_order = {
		"type": OrderType.MOVE,
		"target": position
	}
	
func set_enter_order(position):
	var architecture = scenario.get_architecture_at_position(position)
	current_order = {
		"type": OrderType.ENTER,
		"target": architecture
	}
		
func set_follow_order(troop):
	if troop == null:
		current_order = null
	else:
		current_order = {
			"type": OrderType.FOLLOW,
			"target": troop
		}
	
func set_attack_order(troop, arch):
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

func get_movement_area():
	return pathfinder.get_movement_area()
	
func set_position(pos):
	var old_position = map_position
	map_position = pos
	emit_signal("position_changed", self, old_position, map_position)
	return _animate_position(old_position, map_position)
	
func get_order_text():
	if current_order == null:
		return ""
	match current_order.type:
		OrderType.MOVE: return "MOVE"
		OrderType.ATTACK: return "ATTACK"
		OrderType.FOLLOW: return "FOLLOW"
		OrderType.ENTER: return "ENTER"
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
	emit_signal("occupy_architecture", self, arch)

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
	if current_order != null and current_order.type == OrderType.MOVE:
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
						
					for p in get_persons():
						damage = p.apply_influences("modify_person_troop_damage", {"value": damage, "person": p, "troop": self, "target": target})
					for p in get_persons():
						counter_damage = p.apply_influences("modify_person_troop_counter_damage", {"value": counter_damage, "person": p, "troop": self, "target": target})
						
					damage = int(damage)
					counter_damage = int(counter_damage)
					
					var damage_for_merit = damage * (10 if target is Architecture else 1)
					var merit_rate = min(sqrt(damage_for_merit / (counter_damage + 100.0)), 5) + damage_for_merit / 1000.0
					for p in get_persons():
						if p == get_leader():
							p.add_command_exp(40)
							p.add_strength_exp(60)
							p.add_merit((merit_rate - 0.5) * 25)
							p.add_popularity(merit_rate / 2)
							p.add_prestige(merit_rate - 1.25)
						else:
							p.add_command_exp(20)
							p.add_strength_exp(30)
							p.add_merit((merit_rate - 0.5) * 12.5)
							p.add_popularity(merit_rate / 4)
							p.add_prestige(merit_rate / 2 - 0.625)
					
					var other_merit_rate = min(sqrt(counter_damage / (damage + 100.0)), 5) + counter_damage / 1000.0
					if not target is Architecture:
						for p in target.get_persons():
							if p == get_leader():
								p.add_command_exp(80)
								p.add_strength_exp(20)
								p.add_merit((merit_rate - 0.5) * 25)
								p.add_popularity(other_merit_rate / 2)
								p.add_prestige(other_merit_rate - 1.25)
							else:
								p.add_command_exp(40)
								p.add_strength_exp(10)
								p.add_merit((merit_rate - 0.5) * 12.5)
								p.add_popularity(other_merit_rate / 4)
								p.add_prestige(other_merit_rate / 2 - 0.625)
				
					receive_attack_damage(counter_damage, target)
					target.receive_attack_damage(damage, self)
					
					return _animate_attack(target, counter_damage, damage)
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
	return check_destroy(attacker)
			
func check_destroy(attacker):
	if quantity <= 0:
		destroy(attacker)
		return true
	return false

func destroy(attacker):
	var captured_persons = []
	var released_persons = []
	for p in get_persons():
		var capture_chance
		if attacker.get_persons().size() > 0 and not attacker is Architecture:
			var capture_ability = Util.max_by(attacker.get_persons(), "get_capture_ability")[2]
			var escape_ability = Util.max_by(get_persons(), "get_escape_ability")[2]
			var ratio = capture_ability / escape_ability 
			capture_chance = 0.726 / (1 + exp(-0.613 * (ratio - 4.644)))
		else:
			capture_chance = -1
		if randf() < capture_chance:
			p.become_captured(attacker)
			captured_persons.append(p)
		else:
			if p._status == Person.Status.CAPTIVE:
				released_persons.append(p)
	if captured_persons.size() > 0:
		emit_signal("person_captured", attacker, captured_persons)
	if released_persons.size() > 0:
		emit_signal("person_released", attacker, released_persons)
	
	emit_signal("destroyed", self)
	var return_to = get_starting_architecture()
	if return_to.get_belonged_faction() != self.get_belonged_faction():
		return_to = self.get_belonged_faction().get_architectures()[0]
	for p in get_persons():
		if p._status == Person.Status.CAPTIVE:
			var captive_return_to = p.get_old_faction().capital
			p.become_free()
			p.move_to_architecture(captive_return_to)
		else:
			if p == get_leader():
				p.add_merit(-40)
				p.add_prestige(-2)
			else:
				p.add_merit(-20)
				p.add_prestige(-1)
			p.move_to_architecture(return_to)
	_destroyed = true
		
func _remove():
	emit_signal("removed", self)
	get_belonged_section().remove_troop(self)
	for t in scenario.troops:
		var troop = scenario.troops[t]
		if troop.current_order != null and troop.current_order.type == OrderType.ATTACK and troop.current_order.target == self:
			troop._clear_order()
	queue_free()
	
func after_order_cleanup():
	if current_order != null and current_order.type == OrderType.MOVE and current_order.target == map_position:
		current_order = null
	pathfinder.after_order_cleanup()
	
func day_event():
	if get_starting_architecture().get_belonged_faction() != get_belonged_faction():
		var move_to = ScenarioUtil.nearest_architecture_of_faction(get_belonged_faction(), map_position)
		if move_to != null:
			_starting_arch = move_to
			emit_signal("starting_architecture_changed", self)
	
	var food_required = int((1 + military_kind.food_per_soldier) * Util.m_dist(map_position, _starting_arch.map_position) * 0.25)
	if not _starting_arch.consume_food(food_required):
		if not _food_shortage:
			_food_shortage = true
		else:
			quantity = int(quantity * 0.9)
	else:
		_food_shortage = false
		
	emit_signal("troop_survey_updated", self)
		

####################################
#                UI                #
####################################
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
func _animate_attack(target, self_damage, target_damage):
	_orientation = _get_animation_orientation(map_position, target.map_position)
	var reverse_orientation = _get_animation_orientation(target.map_position, map_position)

	var viewing_rect = scenario.get_camera_viewing_rect() as Rect2
	var troop_rect = Rect2($TroopArea.global_position, Vector2(SharedData.TILE_SIZE, SharedData.TILE_SIZE))
	if GameConfig.enable_troop_animations and viewing_rect.intersects(troop_rect):
		var animated_sprite = $TroopArea/AnimatedSprite as AnimatedSprite
		animated_sprite.animation = "attack_" + _orientation
		__anim_self_damage = self_damage
		
		$AttackSound.play()
		
		if target is Architecture:
			yield($TroopArea/AnimatedSprite, "animation_finished")
			target.find_node("NumberFlashText").text = "↓" + str(target_damage)
			target.find_node("NumberFlashText").find_node('Timer').start()
			if target.endurance <= 0:
				emit_signal("target_architecture_destroyed", self, target)
		else:
			var area_node = target.find_node("TroopArea")
			var target_animated_sprite = area_node.find_node("AnimatedSprite") as AnimatedSprite
			if target_animated_sprite != null:
				target_animated_sprite.animation = "be_attacked_" + reverse_orientation
				target.__anim_self_damage = target_damage
			if target._destroyed:
				yield($TroopArea/AnimatedSprite, "animation_finished")
				emit_signal("target_troop_destroyed", self, target)
		
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
			find_node("NumberFlashText").text = "↓" + str(__anim_self_damage)
			find_node("NumberFlashText").find_node('Timer').start()
			__anim_self_damage = 0
		
		if _destroyed:
			$TroopArea/AnimatedSprite.hide()
			$TroopArea/ClickArea.hide()
			$TroopArea/Routed.show()
			$TroopArea/Routed.play()
			$TroopArea/Routed/RoutedSound.play()
		else:
			emit_signal("animation_attack_finished")
	
func _on_Routed_animation_finished():
	emit_signal("animation_attack_finished")
	_remove()

func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("animation_step_finished")
	
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
			
	
####################################
#         UI event handling        #
####################################
func _on_TroopArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("troop_clicked", self, event.global_position.x, event.global_position.y)

func get_screen_position():
	return get_global_transform_with_canvas().origin


