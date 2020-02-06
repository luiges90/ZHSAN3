extends Node2D
class_name Architecture

var _id: int setget forbidden ,get_id
var scenario

var _map_position: Vector2

var gname: String
var title: String

var kind: ArchitectureKind
var _belonged_faction setget set_belonged_faction, get_belonged_faction
var _person_list = Array() setget forbidden, get_persons

var _fund: int setget forbidden, get_fund
var _food: int setget forbidden, get_food
var _agriculture: int setget forbidden, get_agriculture
var _commerce: int setget forbidden, get_commerce
var _morale: int setget forbidden, get_morale
var _endurance: int setget forbidden, get_endurance

signal architecture_clicked

func forbidden(x):
	assert(false)

# Called when the node enters the scene tree for the first time.
func _ready():
	if scenario:
		position.x = _map_position.x * scenario.tile_size
		position.y = _map_position.y * scenario.tile_size
		scenario.connect("scenario_loaded", self, "_on_scenario_loaded")
	
func load_data(json: Dictionary):
	_id = json["_Id"]
	gname = json["Name"]
	title = json["Title"]
	kind = scenario.architecture_kinds[int(json["Kind"])]
	_map_position = Util.load_position(json["MapPosition"])
	
	_fund = json["Fund"]
	_food = json["Food"]
	_agriculture = json["Agriculture"]
	_commerce = json["Commerce"]
	_morale = json["Morale"]
	_endurance = json["Endurance"]
	
func _on_scenario_loaded():
	($SpriteArea/Sprite as Sprite).texture = kind.image
	($SpriteArea/Sprite/Title/Label as Label).text = title
	
	var faction = get_belonged_faction()
	if faction:
		($Flag as Sprite).modulate = faction.color
	
func get_id() -> int:
	return _id
	
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
		
func get_fund() -> int:
	return _fund
	
func get_food() -> int:
	return _food

func get_agriculture() -> int:
	return _agriculture
	
func get_commerce() -> int:
	return _commerce
	
func get_morale() -> int:
	return _morale
	
func get_endurance() -> int:
	return _endurance

func _on_SpriteArea_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("architecture_clicked", self)
			
func day_event():
	print('day_event: ' + gname)
	for p in get_persons():
		p.day_event()
