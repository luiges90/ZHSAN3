extends Node

var tile_size

var _faction_scene
var _architecture_scene

var factions = Array()
var architectures = Array()

# Called when the node enters the scene tree for the first time.
func _ready():
	_setup()
	
	_load_game("user://Scenarios/000Test.json")
	
	_faction_scene = load("res://ScenarioScene/Faction/Faction.tscn")
	_architecture_scene = load("res://ScenarioScene/Architecture/Architecture.tscn")
	
	add_child(_faction_scene.instance())
	add_child(_architecture_scene.instance())

func _setup():
	tile_size = $Map.cell_size[0]

func _load_game(path):
	var file = File.new()
	file.open(path, File.READ)
	
	var json = file.get_as_text()
	var obj = parse_json(json)
	
	for item in obj["Architectures"]:
		var a = load("res://ScenarioScene/Architecture/Architecture.gd").load_data(item)
		architectures.append(a)
		
	for item in obj["Factions"]:
		var f = load("res://ScenarioScene/Faction/Faction.gd").load_data(item)
		factions.append(f)
