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

signal architecture_clicked
signal architecture_survey_updated

func forbidden(x):
	assert(false)
	
func _draw():
	pass
	# TODO create debug draw
	# for a in adjacent_archs:
	#	var arch = scenario.architectures[a]
	#	var dest = arch.get_global_transform_with_canvas().origin - get_global_transform_with_canvas().origin
	#	draw_line(Vector2(0, 0), dest, Color(255, 0, 0), 5, true)

# Called when the node enters the scene tree for the first time.
func _ready():
	if scenario:
		position.x = map_position.x * scenario.tile_size
		position.y = map_position.y * scenario.tile_size
		scenario.connect("scenario_loaded", self, "_on_scenario_loaded")
	
func load_data(json: Dictionary):
	id = json["_Id"]
	gname = json["Name"]
	title = json["Title"]
	kind = scenario.architecture_kinds[int(json["Kind"])]
	map_position = Util.load_position(json["MapPosition"])
	
	population = json["Population"]
	military_population = json["MilitaryPopulation"]
	fund = json["Fund"]
	food = json["Food"]
	agriculture = json["Agriculture"]
	commerce = json["Commerce"]
	morale = json["Morale"]
	endurance = json["Endurance"]
	
	troop = json["Troop"]
	troop_morale = json["TroopMorale"]
	troop_combativity = json["TroopCombativity"]
	
func save_data() -> Dictionary:
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
		"TroopCombativity": troop_combativity
	}
	
func _on_scenario_loaded():
	($SpriteArea/Sprite as Sprite).texture = kind.image
	($SpriteArea/Sprite/Title/Label as Label).text = title
	
	var faction = get_belonged_faction()
	if faction:
		($Flag as Sprite).modulate = faction.color
		
func set_adjacency(archs, ai_paths):
	for kind in ai_paths:
		for path in ai_paths[kind].list:
			if path.start_architecture == id:
				adjacent_archs[path.end_architecture] = path.path
				
func is_frontline() -> bool:
	for arch_id in adjacent_archs:
		if scenario.architectures[arch_id].belonged_faction().id != id:
			return true
	return false

func get_name() -> String:
	return gname
	
func get_belonged_faction():
	return _belonged_section.get_belonged_faction() if _belonged_section != null else null
	
func get_belonged_section(): 
	return _belonged_section
	
func set_belonged_section(section, force = false):
	_belonged_section = section
	if not force:
		section.add_architecture(self, true)
		
func get_persons() -> Array:
	return _person_list
	
func get_workable_persons() -> Array:
	var result = []
	for p in _person_list:
		if p.task_days == 0:
			result.append(p)
	return result
	
func add_person(p, force: bool = false):
	_person_list.append(p)
	if not force:
		p.set_belonged_architecture(self, true)

func _on_SpriteArea_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("architecture_clicked", self, event.global_position.x, event.global_position.y)
			
func day_event():
	for p in get_persons():
		p.day_event()
	_develop_internal()
	_develop_military()
		
func month_event():
	_develop_resources()
	_decay_internal()
	emit_signal("architecture_survey_updated", self)
	
func set_person_task(task, persons: Array):
	for p in persons:
		p.set_working_task(task)

func _develop_resources():
	fund += commerce * sqrt(sqrt(population + 1000)) * sqrt(morale) / 100
	food += agriculture * sqrt(sqrt(population + 1000)) * sqrt(morale)
	
	var population_increase = population * ((morale - 200) / 20000.0 * (float(kind.population - population) / kind.population)) + 10
	population += population_increase
	military_population += population_increase * 0.4
	
	
func _decay_internal():
	agriculture -= Util.f2ri(agriculture * 0.005)
	commerce -= Util.f2ri(commerce * 0.005)
	morale -= Util.f2ri(morale * 0.01)
	endurance -= Util.f2ri(endurance * 0.005)
	
	
func _develop_internal():
	for p in get_persons():
		match p.working_task:
			Person.Task.AGRICULTURE: _develop_agriculture(p)
			Person.Task.COMMERCE: _develop_commerce(p)
			Person.Task.MORALE: _develop_morale(p)
			Person.Task.ENDURANCE: _develop_endurance(p)
			
func _develop_military():
	for p in get_persons():
		match p.working_task:
			Person.Task.RECRUIT_TROOP: _recruit_troop(p)
			Person.Task.TRAIN_TROOP: _train_troop(p)

func _develop_agriculture(p: Person):
	if kind.agriculture > 0:
		agriculture += Util.f2ri(p.get_agriculture_ability() * 0.02 / max(1, float(agriculture) / kind.agriculture))
	
func _develop_commerce(p: Person):
	if kind.commerce > 0:
		commerce += Util.f2ri(p.get_commerce_ability() * 0.02 / max(1, float(commerce) / kind.commerce))
	
func _develop_morale(p: Person):
	if kind.morale > 0:
		morale += Util.f2ri(p.get_morale_ability() * 0.02 / max(1, float(morale) / kind.morale))
	
func _develop_endurance(p: Person):
	if kind.endurance > 0:
		endurance += Util.f2ri(p.get_endurance_ability() * 0.02 / max(1, float(endurance) / kind.endurance))

func _recruit_troop(p: Person):
	if military_population > 0 and morale > 100:
		var quantity = Util.f2ri(p.get_recruit_troop_ability() * sqrt(sqrt(military_population)) * morale * 0.0005)
		if quantity > 0:
			var old_quantity = troop
			troop += quantity
			population -= quantity
			military_population -= quantity
			troop_morale = Util.f2ri(troop_morale * old_quantity / float(troop))
			troop_combativity = Util.f2ri(troop_combativity * old_quantity / float(troop))
			morale -= Util.f2ri(quantity / 50.0)
	
func _train_troop(p: Person):
	troop_morale += min(100, Util.f2ri(p.get_train_troop_ability() * (110.0 / (troop_morale + 10.0) - 1) * 0.1))
	troop_combativity += min(100, Util.f2ri(p.get_train_troop_ability() * (110.0 / (troop_combativity + 10.0) - 1) * 0.1))


