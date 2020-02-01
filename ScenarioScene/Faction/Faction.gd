extends Node

var _id
var _architecture_list

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

static func load_data(json):
	var faction = load("res://ScenarioScene/Faction/Faction.gd").new()
	faction._id = json["Id"]
	return faction
	
func add_architecture(arch):
	arch.belonged_faction = self
	_architecture_list.add(arch)
