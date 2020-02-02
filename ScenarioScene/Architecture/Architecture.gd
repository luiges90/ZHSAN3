extends Node2D

var _id
var _map_position
var _belonged_faction

var scenario

var dname
var title

# Called when the node enters the scene tree for the first time.
func _ready():
	position.x = _map_position.x * scenario.tile_size
	position.y = _map_position.y * scenario.tile_size
	
func load_data(json):
	_id = json["_Id"]
	dname = json["Name"]
	title = json["Title"]
	_map_position = Vector2(json["MapPositionX"], json["MapPositionY"])
	data_loaded()
	
func data_loaded():
	$Sprite/Title/Label.text = title
	
func get_belonged_faction(): 
	return _belonged_faction
	
func set_belonged_faction(faction, force = false):
	_belonged_faction = faction
	if not force:
		faction.add_architecture(self)
	

