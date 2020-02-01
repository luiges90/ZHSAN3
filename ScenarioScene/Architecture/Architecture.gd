extends Node2D

var _id
var _map_position
var belonged_faction

var scenario

# Called when the node enters the scene tree for the first time.
func _ready():
	position.x = _map_position.x * scenario.tile_size
	position.y = _map_position.y * scenario.tile_size

func load_data(json):
	_id = json["Id"]
	_map_position = Vector2(json["MapPositionX"], json["MapPositionY"])

	
	
