extends Node2D
class_name Architecture

var id: int setget forbidden
var scenario

var map_position: Vector2 setget forbidden

var gname: String setget forbidden
var title: String setget forbidden

var kind: ArchitectureKind setget forbidden

var _belonged_section setget set_belonged_section, get_belonged_section
var _person_list = Array() setget forbidden, get_persons

var population: int setget forbidden
var military_population: int setget forbidden
var fund: int setget forbidden
var food: int setget forbidden
var agriculture: int setget forbidden
var commerce: int setget forbidden
var morale: int setget forbidden
var endurance: int setget forbidden

var adjacent_archs = {} setget forbidden

var troop: int setget forbidden
var troop_morale: int setget forbidden
var troop_combativity: int setget forbidden

var equipments = {} setget forbidden

var auto_convince = true

var auto_task: bool

var _destroyed: bool = false

var _recently_battled: int setget forbidden

var _resource_packs: Array

signal architecture_clicked
signal architecture_survey_updated

signal faction_changed

func forbidden(x):
	assert(false)
	
func object_type():
	return ScenarioUtil.ObjectType.ARCHITECTURE
	
func _draw():
	pass
	# TODO create debug draw
	#for a in adjacent_archs:
	#	var arch = scenario.architectures[a]
	#	var dest = arch.get_global_transform_with_canvas().origin - get_global_transform_with_canvas().origin
	#	draw_line(Vector2(56, 56), dest, Color(255, 0, 0), 5, true)

func _ready():
	if scenario:
		position.x = map_position.x * scenario.tile_size
		position.y = map_position.y * scenario.tile_size
		scenario.connect("scenario_loaded", self, "_on_scenario_loaded")

####################################
#            Save / Load           #
####################################
func load_data(json: Dictionary, objects):
	id = json["_Id"]
	gname = json["Name"]
	title = json["Title"]
	kind = scenario.architecture_kinds[int(json["Kind"])]
	map_position = Util.load_position(json["MapPosition"])
	
	for id in json["PersonList"]:
		add_person(objects["persons"][int(id)])
	
	population = int(json["Population"])
	military_population = int(json["MilitaryPopulation"])
	fund = int(json["Fund"])
	food = int(json["Food"])
	agriculture = int(json["Agriculture"])
	commerce = int(json["Commerce"])
	morale = int(json["Morale"])
	endurance = int(json["Endurance"])
	
	troop = int(json["Troop"])
	troop_morale = int(json["TroopMorale"])
	troop_combativity = int(json["TroopCombativity"])
	
	auto_task = json.get("_AutoTask", false)
	auto_convince = Util.dict_try_get(json, "_AutoConvince", true)
	
	equipments = Util.convert_dict_to_int_key(json["Equipments"])

	_recently_battled = json["_RecentlyBattled"]

	var resource_pack_json = Util.dict_try_get(json, "_ResourcePacks", [])
	_resource_packs = []
	for p in resource_pack_json:
		var pack = ResourcePack.new()
		pack.set_from_json_dict(p)
		_resource_packs.append(pack)
	
	
func save_data() -> Dictionary:
	var resource_pack_for_json = []
	for p in _resource_packs:
		resource_pack_for_json.append(p.dict_for_json())
	
	return {
		"_Id": id,
		"Name": gname,
		"Title": title,
		"Kind": kind.id,
		"MapPosition": Util.save_position(map_position),
		"Population": population,
		"MilitaryPopulation": military_population,
		"Fund": fund,
		"Food": food,
		"Agriculture": agriculture,
		"Commerce": commerce,
		"Morale": morale,
		"Endurance": endurance,
		"PersonList": Util.id_list(get_persons()),
		"Troop": troop,
		"TroopMorale": troop_morale,
		"TroopCombativity": troop_combativity,
		"Equipments": equipments,
		"_AutoTask": auto_task,
		"_AutoConvince": auto_convince,
		"_RecentlyBattled": _recently_battled,
		"_ResourcePacks": resource_pack_for_json
	}

####################################
#        Set up / Tear down        #
####################################
func setup_after_load():
	for kind in scenario.military_kinds:
		if scenario.military_kinds[kind].has_equipments():
			if not equipments.has(kind):
				equipments[kind] = 0
	
func _on_scenario_loaded(scenario):
	($SpriteArea/Sprite as Sprite).texture = kind.image
	($SpriteArea/Sprite/Title/Label as Label).text = title
	
	var faction = get_belonged_faction()
	if faction:
		($Flag as Sprite).modulate = faction.color
		
func set_adjacency(archs, ai_paths):
	for kind in ai_paths:
		for path in ai_paths[kind].list:
			if path.start_architecture == id:
				if not adjacent_archs.has(path.end_architecture):
					adjacent_archs[path.end_architecture] = {}
				adjacent_archs[path.end_architecture][kind] = path.path

####################################
#             Get stat             #
####################################
func is_frontline() -> bool:
	for arch_id in adjacent_archs:
		if scenario.architectures[arch_id].get_belonged_faction() != null and scenario.architectures[arch_id].get_belonged_faction().is_enemy_to(get_belonged_faction()):
			return true
	return false
	
func is_frontline_including_blank() -> bool:
	for arch_id in adjacent_archs:
		if scenario.architectures[arch_id].get_belonged_faction() == null or scenario.architectures[arch_id].get_belonged_faction().is_enemy_to(get_belonged_faction()):
			return true
	return false

func get_name() -> String:
	return gname
	
func get_belonged_faction():
	return _belonged_section.get_belonged_faction() if _belonged_section != null else null
	
func get_belonged_faction_color():
	var f = get_belonged_faction()
	return f.color if f != null else Color(1, 1, 1)
	
func get_belonged_faction_str():
	var f = get_belonged_faction()
	return f.get_name() if f != null else '----'
	
func get_belonged_section(): 
	return _belonged_section

func get_belonged_section_str():
	var f = get_belonged_section()
	return f.get_name() if f != null else '----'
	
func set_belonged_section(section, force = false):
	_belonged_section = section
	if not force:
		section.add_architecture(self, true)
		
func get_persons() -> Array:
	return _person_list
	
func get_faction_persons() -> Array:
	var result = []
	for p in _person_list:
		if p.get_status() == Person.Status.NORMAL:
			result.append(p)
	return result
	
func get_workable_persons() -> Array:
	var result = []
	for p in _person_list:
		if p.get_status() == Person.Status.NORMAL and p.task_days == 0:
			result.append(p)
	return result
	
func get_wild_persons() -> Array:
	var result = []
	for p in _person_list:
		if p.get_status() == Person.Status.WILD:
			result.append(p)
	return result
	
func get_idling_persons() -> Array:
	var result = []
	for p in _person_list:
		if p.get_status() == Person.Status.NORMAL and p.task_days == 0 and p.working_task == Person.Task.NONE:
			result.append(p)
	return result
	
func get_captive_persons() -> Array:
	var result = []
	for p in _person_list:
		if p.get_status() == Person.Status.CAPTIVE:
			result.append(p)
	return result


func _expected_fund_expenditure():
	var officer_expenditure = 0
	for p in get_faction_persons():
		officer_expenditure += p.get_salary()

	return officer_expenditure
	
func expected_fund_income():
	var income = commerce * sqrt(sqrt(population + 1000)) * sqrt(morale) / 20.0
	for p in get_workable_persons():
		income = p.apply_influences('modify_person_fund_income', {"value": income, "person": p, "architecture": self})
	
	var f = get_belonged_faction()
	if f != null and not f.player_controlled:
		income *= scenario.scenario_config.ai_fund_rate
	
	return income - _expected_fund_expenditure()


func _expected_food_expenditure():
	var soldier_expenditure = troop + get_troop_in_packs()
	
	var equipment_expenditure = 0
	for equipment in equipments:
		var kind = scenario.military_kinds[equipment]
		equipment_expenditure += equipments[equipment] * kind.food_per_soldier

	return soldier_expenditure + equipment_expenditure
	
func expected_food_income():
	var income = agriculture * sqrt(sqrt(population + 1000)) * sqrt(morale) / 2.0
	for p in get_workable_persons():
		income = p.apply_influences('modify_person_food_income', {"value": income, "person": p, "architecture": self})
		
	var f = get_belonged_faction()
	if f != null and not f.player_controlled:
		income *= scenario.scenario_config.ai_food_rate
	
	return income - _expected_food_expenditure()
	
func expected_population_gain():
	var base = population * ((morale - 200) / 600000.0 * (float(kind.population - population) / kind.population)) + 10

	for p in get_workable_persons():
		base = p.apply_influences('modify_person_population_gain', {"value": base, "person": p, "architecture": self})
	
	return base
	
func get_defence():
	var base = 1500 + endurance + morale * 3 + troop * 0.05
	for p in get_workable_persons():
		base = p.apply_influences('modify_person_architecture_defence', {"value": base, "person": p, "architecture": self})
		
	var f = get_belonged_faction()
	if f != null and not f.player_controlled:
		base *= scenario.scenario_config.ai_troop_defence_rate
		
	return base
	
func get_offence():
	var base = endurance + morale * 0.5 + troop * 0.1
	for p in get_workable_persons():
		base = p.apply_influences('modify_person_architecture_offence', {"value": base, "person": p, "architecture": self})
		
	var f = get_belonged_faction()
	if f != null and not f.player_controlled:
		base *= scenario.scenario_config.ai_troop_offence_rate
		
	return base
	
func get_equipment_text(military_kind):
	if military_kind.has_equipments():
		return str(equipments[military_kind.id])
	else:
		return "----"

func get_total_equipments():
	var r = 0
	for t in equipments:
		r += equipments[t]
	return r
	
func anti_critical_chance():
	return 0.0

func get_fund_in_packs():
	var result = 0
	for p in _resource_packs:
		result += p.fund
	return result
	
func get_fund_in_packs_str():
	var result = ""
	for p in _resource_packs:
		if p.fund > 0:
			result += tr("RESOURCE_PACK_ITEM").format({"amount": p.fund, "day": p.day_left})
	return result
	
func get_food_in_packs():
	var result = 0
	for p in _resource_packs:
		result += p.food
	return result
	
func get_food_in_packs_str():
	var result = ""
	for p in _resource_packs:
		if p.food > 0:
			result += tr("RESOURCE_PACK_ITEM").format({"amount": p.food, "day": p.day_left})
	return result

func get_troop_in_packs():
	var result = 0
	for p in _resource_packs:
		result += p.troop
	return result
	
func get_troop_in_packs_str():
	var result = ""
	for p in _resource_packs:
		if p.troop > 0:
			result += tr("RESOURCE_PACK_ITEM").format({"amount": p.troop, "day": p.day_left})
	return result

####################################
#           Get function           #
####################################

func enemy_troop_in_range(distance: int):
	var results = []
	for t in scenario.troops:
		var troop = scenario.troops[t]
		if troop.get_belonged_faction().is_enemy_to(get_belonged_faction()) and Util.m_dist(troop.map_position, self.map_position) <= distance:
			results.append(troop)
	return results
	
func enemy_troop_quantity_in_range(distance: int):
	var result = 0
	for t in enemy_troop_in_range(distance):
		result += t.quantity
	return result
	
func enemy_troop_in_architecture():
	var troop = scenario.get_troop_at_position(map_position)
	if troop != null and get_belonged_faction() != null and  get_belonged_faction().is_enemy_to(troop.get_belonged_faction()):
		return troop
	return null
	
func friendly_troop_in_range(distance: int):
	var results = []
	for t in scenario.troops:
		var troop = scenario.troops[t]
		if troop.get_belonged_faction().is_friend_to(get_belonged_faction()) and Util.m_dist(troop.map_position, self.map_position) <= distance:
			results.append(troop)
	return results
	
func create_troop_positions() -> Array:
	var positions = Util.squares_in_range(map_position, 1)
	var result = []
	for p in positions:
		if scenario.get_troop_at_position(p) == null:
			result.append(p)
	return result
	
func move_eta(to):
	return int(ScenarioUtil.object_distance(self, to) * 0.2) + 1

func surrounded():
	if enemy_troop_in_architecture():
		return true

	var enemy_troops = enemy_troop_in_range(1)
	if enemy_troops.size() >= 3:
		return true
	return false

	
####################################
#            Time event            #
####################################

func day_event():
	_develop_internal()
	_develop_population()
	_develop_military()
	_move_resource_packs()

	if _recently_battled > 0:
		_recently_battled -= 1
		
func month_event():
	_develop_resources()
	_decay_internal()

####################################
#           Manipulation           #
####################################
func receive_attack_damage(damage, attacker):
	endurance -= damage
	if endurance <= 0:
		endurance = 0
		_play_destroyed_animation()
		return true
	else:
		return false

func consume_food(amount) -> bool:
	if food >= amount:
		food -= amount
		return true
	else:
		return false

####################################
#            Set command           #
####################################
func set_person_task(task, persons: Array):
	for p in persons:
		p.set_working_task(task)
		
func add_person(p, force: bool = false):
	_person_list.append(p)
	if not force:
		p.set_location(self, true)
		
func remove_person(p, force: bool = false):
	Util.remove_object(_person_list, p)
	
func change_faction(to_section):
	var target_faction_destroyed = false
	var old_faction = get_belonged_faction()
	# forcibly move persons away
	var move_to = null
	if old_faction != null:
		move_to = ScenarioUtil.nearest_architecture_of_faction(old_faction, map_position, self)
		
	if old_faction != null:
		if move_to != null:
			for person in get_persons():
				person.move_to_architecture(move_to)
		else:
			for t in old_faction.get_troops():
				t.destroy(null)
			for person in get_persons():
				person.become_wild()
			target_faction_destroyed = true
			
	# forcibly move the capital too if capable
	if old_faction != null:
		if self == old_faction.capital:
			var new_capital
			var max_pop = 0
			for a in old_faction.get_architectures():
				if a == self:
					continue
				if a.population >= max_pop:
					max_pop = a.population
					new_capital = a
			if new_capital != null:
				old_faction.set_capital(new_capital)
				# TODO penalties, signal

	# redirect all resource packs
	if old_faction != null and move_to != null:
		for p in _resource_packs:
			p.fund *= _transport_loss(move_to)
			p.food *= _transport_loss(move_to)
			p.troop_morale *= _transport_loss(move_to)
			p.day_left += _transport_eta(move_to)
			move_to._resource_packs.append(p)
		_resource_packs.clear()
	
	# burn the treasury
	fund = fund / 10
	food = food / 10
	for k in equipments:
		equipments[k] = equipments[k] / 10

	# reduce morale
	var faction = to_section.get_belonged_faction()
	if faction != null:
		morale = int(clamp(faction.get_leader().karma + 50, 0, 100))
	else:
		morale = 0
	
	# switch faction
	var old_section = get_belonged_section()
	if old_section != null:
		old_section.remove_architecture(self)
	to_section.add_architecture(self)
	
	# if old faction has no more archs, destroy it
	if target_faction_destroyed:
		old_faction.destroy()
	
	# update UI
	if faction != null:
		($Flag as Sprite).modulate = faction.color
	else:
		($Flag as Sprite).modulate = Color.white
	
	call_deferred("emit_signal", 'faction_changed', self)


func set_recently_battled():
	_recently_battled = 5
	

func can_transport_resources():
	return not surrounded() and get_belonged_faction() != null and get_belonged_faction().get_architectures().size() > 1


func transport_resources(destination, fund_to_transport: int, food_to_transport: int, troop_to_transport: int, to_transport_equipments_id_key):
	assert(fund_to_transport >= 0)
	assert(food_to_transport >= 0)
	assert(troop_to_transport >= 0)
	assert(fund_to_transport <= fund)
	assert(food_to_transport <= food)
	assert(troop_to_transport <= troop)
	assert(get_belonged_faction() == destination.get_belonged_faction())
	
	fund -= fund_to_transport
	food -= food_to_transport
	troop -= troop_to_transport
	var to_transfer_equipments = {}
	for e in to_transport_equipments_id_key:
		assert(to_transport_equipments_id_key[e] >= 0)
		assert(equipments[e] >= to_transport_equipments_id_key[e])
		equipments[e] -= to_transport_equipments_id_key[e]
		to_transfer_equipments[e] = to_transport_equipments_id_key[e]

	var pack = ResourcePack.new()
	pack.fund = int(fund_to_transport * _transport_loss(destination))
	pack.food = int(food_to_transport * _transport_loss(destination))
	pack.troop = troop_to_transport
	pack.troop_morale = int(troop_morale * _transport_loss(destination))
	pack.day_left = _transport_eta(destination)
	pack.equipments = to_transfer_equipments
	destination._resource_packs.append(pack)


func _transport_eta(arch):
	var result = int(ScenarioUtil.object_distance(self, arch) * 0.4) + 1
	for p in get_workable_persons():
		result = p.apply_influences("modify_transport_time", {"value": result, "person": p, "architecture": self})
	return int(result)

func _transport_loss(arch):
	var eta = int(ScenarioUtil.object_distance(self, arch) * 0.4) + 1
	for p in get_workable_persons():
		eta = p.apply_influences("modify_transport_loss", {"value": eta, "person": p, "architecture": self})
	
	return min(1.0, 1.81342 / (1.75862 + 0.024067 * eta))
	

func toggle_auto_convince():
	auto_convince = not auto_convince
	

####################################
#          Order Execution         #
####################################
func _develop_population():
	var population_increase = expected_population_gain()
	
	var decrease = 0
	var enemy_troop = enemy_troop_in_architecture()
	if enemy_troop != null:
		decrease += enemy_troop.quantity / 200.0
	decrease += enemy_troop_quantity_in_range(4) / 2000.0
	for p in get_workable_persons():
		p.apply_influences("modify_person_architecture_population_loss", {"value": decrease, "person": p, "architecture": self})
	
	population = Util.f2ri(population + population_increase - decrease)
	military_population += Util.f2ri(population_increase * 0.4)
	

func _develop_resources():
	fund = Util.f2ri(fund + expected_fund_income())
	food = Util.f2ri(food + expected_food_income())

	if fund <= 0:
		fund = 0
		for p in get_faction_persons():
			p.loyalty_shift -= (100 - p.get_morality()) / 4 + 5
	if food <= 0:
		food = 0
		troop = troop * 9 / 10
		troop_morale = max(0, troop_morale - 10)
		for e in equipments:
			equipments[e] = equipments[e] * 9 / 10
	
func _decay_internal():
	var factor = 1
	var enemy_troop = enemy_troop_in_architecture()
	if enemy_troop != null:
		factor += enemy_troop.quantity / 1000.0
	factor += enemy_troop_quantity_in_range(4) / 5000.0
	for p in get_workable_persons():
		p.apply_influences("modify_person_architecture_internal_decay", {"value": factor, "person": p, "architecture": self})
		
	agriculture -= Util.f2ri(agriculture * 0.005 * factor)
	commerce -= Util.f2ri(commerce * 0.005 * factor)
	morale -= Util.f2ri(morale * 0.01 * factor)
	endurance -= Util.f2ri(endurance * 0.005 * factor)
	
func _develop_internal():
	if enemy_troop_in_architecture() == null:
		for p in get_workable_persons():
			match p.working_task:
				Person.Task.AGRICULTURE: _develop_agriculture(p)
				Person.Task.COMMERCE: _develop_commerce(p)
				Person.Task.MORALE: _develop_morale(p)
				Person.Task.ENDURANCE: _develop_endurance(p)
			
func _develop_military():
	for p in get_workable_persons():
		match p.working_task:
			Person.Task.RECRUIT_TROOP: _recruit_troop(p)
			Person.Task.TRAIN_TROOP: _train_troop(p)
			Person.Task.PRODUCE_EQUIPMENT: _produce_equipment(p)
			
func _develop_cost(p):
	var base = 2
	p.apply_influences("modify_person_develop_internal_cost", {"value": base, "person": p, "architecture": self})
	return base

func _develop_agriculture(p: Person):
	var cost = _develop_cost(p)
	if fund > cost:
		fund -= cost
		if kind.agriculture > 0:
			var delta = Util.f2ri(p.get_agriculture_ability() * 0.04 / max(1, float(agriculture) / kind.agriculture))
			agriculture += delta
			p.add_internal_exp(5)
			p.add_intelligence_exp(5)
			p.add_politics_exp(10)
			p.add_glamour_exp(5)
			p.add_merit(delta * 5)
			p.add_popularity(0.1 * delta)
			p.add_prestige(0.1 * delta)
			p.add_karma(0.1 * delta)
	
func _develop_commerce(p: Person):
	var cost = _develop_cost(p)
	if fund > cost:
		fund -= cost
		if kind.commerce > 0:
			var delta = Util.f2ri(p.get_commerce_ability() * 0.04 / max(1, float(commerce) / kind.commerce))
			commerce += delta
			p.add_internal_exp(5)
			p.add_intelligence_exp(10)
			p.add_politics_exp(5)
			p.add_glamour_exp(5)
			p.add_merit(delta * 5)
			p.add_popularity(0.15 * delta)
			p.add_prestige(0.1 * delta)
			p.add_karma(0.05 * delta)
	
func _develop_morale(p: Person):
	var cost = _develop_cost(p)
	if fund > cost:
		fund -= cost
		if kind.morale > 0:
			var delta = Util.f2ri(p.get_morale_ability() * 0.04 / max(1, float(morale) / kind.morale))
			morale += delta
			p.add_internal_exp(5)
			p.add_command_exp(5)
			p.add_strength_exp(5)
			p.add_glamour_exp(10)
			p.add_merit(delta * 5)
			p.add_popularity(0.15 * delta)
			if p.get_strength() >= p.get_glamour():
				p.add_prestige(0.15 * delta)
				p.add_karma(0.05 * delta)
			else:
				p.add_prestige(0.05 * delta)
				p.add_karma(0.15 * delta)
			
func _develop_endurance(p: Person):
	if enemy_troop_in_range(1).size() > 0:
		return
	var cost = _develop_cost(p)
	if fund > cost:
		fund -= cost
		if kind.endurance > 0:
			var delta = Util.f2ri(p.get_endurance_ability() * 0.04 / max(1, float(endurance) / kind.endurance))
			endurance += delta
			p.add_internal_exp(5)
			p.add_command_exp(5)
			p.add_strength_exp(5)
			p.add_intelligence_exp(5)
			p.add_politics_exp(5)
			p.add_merit(delta * 5)
			p.add_popularity(0.1 * delta)
			p.add_prestige(0.15 * delta)
			p.add_karma(0.05 * delta)
			
func _recruit_troop(p: Person):
	if fund > 50 and military_population > 0 and morale > 100:
		fund -= 50
		var quantity = min(min(Util.f2ri(p.get_recruit_troop_ability() * sqrt(sqrt(military_population)) * morale * 0.001), population), military_population)
		if quantity > 0:
			var f = get_belonged_faction()
			if f != null and not f.player_controlled:
				quantity *= scenario.scenario_config.ai_troop_recruit_rate
			
			var old_quantity = troop
			troop += quantity
			population -= quantity
			military_population -= quantity
			troop_morale = Util.f2ri((troop_morale * old_quantity + 50 * quantity) / float(troop))
			morale -= Util.f2ri(quantity / 50.0)
			p.add_internal_exp(5)
			p.add_strength_exp(10)
			p.add_glamour_exp(10)
			p.add_merit(0.1 * quantity)
			p.add_popularity(0.002 * quantity)
			p.add_prestige(0.002 * quantity)
	
func _train_troop(p: Person):
	if fund > 20:
		fund -= 20
		var delta = Util.f2ri(p.get_train_troop_ability() * (110.0 / (troop_morale + 10.0) - 1) * 0.1 * (10000.0 / max(1000.0, troop)))
		
		var f = get_belonged_faction()
		if f != null and not f.player_controlled:
			delta *= scenario.scenario_config.ai_troop_training_rate
		
		troop_morale = min(100, troop_morale + delta)
		p.add_internal_exp(5)
		p.add_command_exp(10)
		p.add_strength_exp(10)
		p.add_merit(10)
		p.add_popularity(0.2)
		p.add_prestige(0.2)

func _produce_equipment(p: Person):
	var equipment = p.producing_equipment
	var cost = scenario.military_kinds[equipment].equipment_cost
	if fund > cost:
		var amount = Util.f2ri(p.get_produce_equipment_ability() * 0.4 / scenario.military_kinds[equipment].amount_to_troop_ratio)
		if fund < cost * amount:
			amount = floor(fund / cost)
		if amount > 0:
			fund -= amount * cost
			equipments[equipment] += amount
			p.add_internal_exp(5)
			p.add_intelligence_exp(10)
			p.add_politics_exp(10)
			p.add_merit(0.25 * amount)
			p.add_popularity(0.006 * amount)
			p.add_prestige(0.004 * amount)
		
func accept_entering_troop(in_troop):
	assert(in_troop.quantity > 0)
	troop_morale = int((troop * troop_morale + in_troop.quantity * in_troop.morale) / (troop + in_troop.quantity))
	troop += in_troop.quantity
	if in_troop.military_kind.has_equipments():
		equipments[in_troop.military_kind.id] += int(in_troop.quantity / in_troop.military_kind.amount_to_troop_ratio)
	if in_troop.naval_military_kind.has_equipments():
		equipments[in_troop.naval_military_kind.id] += int(in_troop.quantity / in_troop.naval_military_kind.amount_to_troop_ratio)
	
	var list = in_troop.get_all_persons().duplicate()
	for p in list:
		p.set_location(self)

func take_troop(quantity):
	assert(troop >= quantity)
	troop -= quantity

func take_equipment(kind, quantity):
	assert(equipments[kind.id] >= quantity)
	equipments[kind.id] -= quantity

func _move_resource_packs():
	if can_transport_resources():
		for p in _resource_packs.duplicate():
			p.day_left -= 1
			if p.day_left <= 0:
				fund += p.fund
				food += p.food
				if p.troop > 0:
					troop_morale = Util.f2ri((troop * troop_morale + p.troop * p.troop_morale) / (troop + p.troop))
					troop += p.troop
				for e in p.equipments:
					equipments[int(e)] += p.equipments[e]
				_resource_packs.erase(p)

####################################
#                UI                #
####################################
func _on_SpriteArea_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			call_deferred("emit_signal", "architecture_clicked", self, event.global_position.x, event.global_position.y, false)
			get_tree().set_input_as_handled()
		elif event.button_index == BUTTON_RIGHT and event.pressed:
			call_deferred("emit_signal", "architecture_clicked", self, event.global_position.x, event.global_position.y, true)
			get_tree().set_input_as_handled()
			
			
func get_screen_position():
	return get_global_transform_with_canvas().origin
	
func _play_destroyed_animation():
	var viewing_rect = scenario.get_camera_viewing_rect() as Rect2
	var troop_rect = Rect2($SpriteArea.global_position, Vector2(SharedData.TILE_SIZE, SharedData.TILE_SIZE))
	if GameConfig.enable_troop_animations and viewing_rect.intersects(troop_rect):
		$SpriteArea/Routed.show()
		$SpriteArea/Routed.play()
		$SpriteArea/Routed/RoutedSound.play()


func _on_Routed_animation_finished():
	$SpriteArea/Routed.hide()


func _on_EffectSprite_animation_finished():
	$SpriteArea/EffectSprite.hide()
