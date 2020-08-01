extends Control

onready var map_size = Vector2($MapTexture.rect_size.x, $MapTexture.rect_size.y)

var view_rectangle = Rect2(0, 0, 0, 0)
var architecture_positions = {}
var troop_positions = {}

func _ready():
	$PaintLayer.map = self

func _on_Toolbar_map_clicked():
	if visible:
		hide()
	else:
		show()
		
		
func __camera_position_to_map_position(position: Vector2, scen) -> Vector2:
	var x = position.x / (scen.map_size.x * scen.tile_size) * map_size.x
	var y = position.y / (scen.map_size.y * scen.tile_size) * map_size.y
	return Vector2(x, y)
	
func __scen_position_to_map_position(position: Vector2, scen) -> Vector2:
	var x = position.x / scen.map_size.x * map_size.x
	var y = position.y / scen.map_size.y * map_size.y
	return Vector2(x, y)

func _on_camera_moved(camera_rect: Rect2, zoom: Vector2, scen):
	var top_left = __camera_position_to_map_position(camera_rect.position, scen)
	var bottom_right = __camera_position_to_map_position(camera_rect.position + camera_rect.size, scen)
	view_rectangle.position = top_left
	view_rectangle.size = bottom_right - top_left
	
func _on_architecture_faction_changed(arch, scen):
	var faction = arch.get_belonged_faction()
	var color
	if faction != null:
		color = faction.color
	else:
		color = Color.white
	architecture_positions[arch.id] = {
		"position": __scen_position_to_map_position(arch.map_position, scen),
		"color": color
	}
	
func _on_troop_position_changed(scen, troop, old_position, new_position):
	troop_positions[troop.id]['position'] = __scen_position_to_map_position(new_position, scen)
	
func _on_troop_created(scen, troop):
	var faction = troop.get_belonged_faction()
	var color
	if faction != null:
		color = faction.color
	else:
		color = Color.white
	troop_positions[troop.id] = {
		"position": __scen_position_to_map_position(troop.map_position, scen),
		"color": color
	}
	
func _on_troop_removed(scen, troop):
	troop_positions.erase(troop.id)
