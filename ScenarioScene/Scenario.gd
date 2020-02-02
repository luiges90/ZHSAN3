extends Node

var tile_size
var map_size

var factions = Dictionary()
var architectures = Dictionary()

signal scenario_loaded

# Called when the node enters the scene tree for the first time.
func _ready():
	_setup()
	
	_load_data("user://Scenarios/000Test.json")
	emit_signal("scenario_loaded")
	
func _setup():
	tile_size = $Map.cell_size[0]
	map_size = $Map.get_used_rect().size
	
	$Camera.scenario = self

func _load_data(path):
	var file = File.new()
	file.open(path, File.READ)
	
	var json = file.get_as_text()
	var obj = parse_json(json)
	
	var architecture_scene = load("res://ScenarioScene/Architecture/Architecture.tscn")
	for item in obj["Architectures"]:
		var instance = architecture_scene.instance()
		instance.scenario = self
		instance.load_data(item)
		architectures[instance.get_id()] = instance
		add_child(instance)
		
	var faction_scene = load("res://ScenarioScene/Faction/Faction.tscn")
	for item in obj["Factions"]:
		var instance = faction_scene.instance()
		instance.scenario = self
		instance.load_data(item)
		factions[instance.get_id()] = instance
		add_child(faction_scene.instance())
