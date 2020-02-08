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
	
func _on_scenario_loaded():
	($SpriteArea/Sprite as Sprite).texture = kind.image
	($SpriteArea/Sprite/Title/Label as Label).text = title
	
	var faction = get_belonged_faction()
	if faction:
		($Flag as Sprite).modulate = faction.color
	
func get_belonged_faction(): 
	return _belonged_faction
	
func set_belonged_faction(faction, force = false):
	_belonged_faction = faction
	if not force:
		faction.add_architecture(self, true)
		
func get_persons() -> Array:
	return _person_list
	
func add_person(p, force: bool = false):
	_person_list.append(p)
	if not force:
		p.set_belonged_architecture(self, true)

func _on_SpriteArea_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("architecture_clicked", self)
			
func day_event():
	for p in get_persons():
		p.day_event()
		
func month_event():
	_develop_resources()
	emit_signal("architecture_survey_updated", self)

func _develop_resources():
	fund += commerce * sqrt(sqrt(population + 1000)) * sqrt(morale) / 100
	food += agriculture * sqrt(sqrt(population + 1000)) * sqrt(morale)

	var a = 10 * exp(10 * population / kind.population + 5)
	var b = exp(10 * population / kind.population) + exp(5)
	population *= 1 + a / (b * b) / 100
	population += ((morale - 100) * sqrt(kind.population)) / 1000.0
	
