extends Node2D
class_name Architecture

var id: int setget forbidden
var scenario

var map_position: Vector2 setget forbidden

var gname: String
var title: String

var kind: ArchitectureKind setget forbidden
var _belonged_faction setget set_belonged_faction, get_belonged_faction
var _person_list = Array() setget forbidden, get_persons

var population: int setget forbidden
var fund: int setget forbidden
var food: int setget forbidden
var agriculture: int setget forbidden
var commerce: int setget forbidden
var morale: int setget forbidden
var endurance: int setget forbidden

signal architecture_clicked
signal architecture_survey_updated

func forbidden(x):
	assert(false)

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
	fund = json["Fund"]
	food = json["Food"]
	agriculture = json["Agriculture"]
	commerce = json["Commerce"]
	morale = json["Morale"]
	endurance = json["Endurance"]
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Name": gname,
		"Title": title,
		"Kind": kind.id,
		"MapPosition": Util.save_position(map_position),
		"Population": population,
		"Fund": fund,
		"Food": food,
		"Agriculture": agriculture,
		"Commerce": commerce,
		"Morale": morale,
		"Endurance": endurance,
		"PersonList": Util.id_list(get_persons())
	}
	
func _on_scenario_loaded():
	($SpriteArea/Sprite as Sprite).texture = kind.image
	($SpriteArea/Sprite/Title/Label as Label).text = title
	
	var faction = get_belonged_faction()
	if faction:
		($Flag as Sprite).modulate = faction.color
		
func get_name() -> String:
	return gname
	
func get_belonged_faction(): 
	return _belonged_faction
	
func set_belonged_faction(faction, force = false):
	_belonged_faction = faction
	if not force:
		faction.add_architecture(self, true)
		
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

	population *= 1 + ((morale - 200) / 20000.0 * (float(kind.population - population) / kind.population))
	population += 10
	
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

func _develop_agriculture(p: Person):
	agriculture += Util.f2ri(p.get_agriculture_ability() / 10.0 / max(1, float(agriculture) / kind.agriculture))
	
func _develop_commerce(p: Person):
	commerce += Util.f2ri(p.get_commerce_ability() / 10.0 / max(1, float(commerce) / kind.commerce))
	
func _develop_morale(p: Person):
	morale += Util.f2ri(p.get_morale_ability() / 10.0 / max(1, float(morale) / kind.morale))
	
func _develop_endurance(p: Person):
	endurance += Util.f2ri(p.get_endurance_ability() / 10.0 / max(1, float(endurance) / kind.endurance))
