extends Node
class_name Architecture

var _id
var _map_position
var belonged_faction

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

static func load_data(json):
	var arch = load("res://ScenarioScene/Architecture/Architecture.gd").new()
	arch._id = json["Id"]
	arch._map_position = Vector2(json["MapPositionX"], json["MapPositionY"])
	return arch
