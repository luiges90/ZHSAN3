extends Control

onready var map_size = Vector2($MapTexture.rect_size.x, $MapTexture.rect_size.y)

var view_rectangle = Rect2(0, 0, 0, 0)
var architecture_positions = {}
var troop_positions = {}

var _scenario

signal focus_camera

func _ready():
	$PaintLayer.map = self

func _on_Toolbar_map_clicked():
	if visible:
		hide()
	else:
		show()
		
		
func __camera_position_to_map_position(position: Vector2) -> Vector2:
	var x = position.x / (_scenario.map_size.x * _scenario.tile_size) * map_size.x
	var y = position.y / (_scenario.map_size.y * _scenario.tile_size) * map_size.y
	return Vector2(x, y)
	
func __scen_position_to_map_position(position: Vector2) -> Vector2:
	var x = position.x / _scenario.map_size.x * map_size.x
	var y = position.y / _scenario.map_size.y * map_size.y
	return Vector2(x, y)
	
func __map_position_to_scen_position(position: Vector2) -> Vector2:
	var x = position.x * _scenario.map_size.x / map_size.x
	var y = position.y * _scenario.map_size.y / map_size.y
	return Vector2(x, y)

func _on_camera_moved(camera_rect: Rect2, zoom: Vector2, scen):
	_scenario = scen
	
	var top_left = __camera_position_to_map_position(camera_rect.position)
	var bottom_right = __camera_position_to_map_position(camera_rect.position + camera_rect.size)
	view_rectangle.position = top_left
	view_rectangle.size = bottom_right - top_left
	
func _on_architecture_faction_changed(arch, scen):
	_scenario = scen
	
	var faction = arch.get_belonged_faction()
	var color
	if faction != null:
		color = faction.color
	else:
		color = Color.white
	architecture_positions[arch.id] = {
		"position": __scen_position_to_map_position(arch.map_position),
		"color": color
	}
	
func _on_troop_position_changed(scen, troop, old_position, new_position):
	_scenario = scen
	
	troop_positions[troop.id]['position'] = __scen_position_to_map_position(new_position)
	
func _on_troop_created(scen, troop):
	_scenario = scen
	
	var faction = troop.get_belonged_faction()
	var color
	if faction != null:
		color = faction.color
	else:
		color = Color.white
	troop_positions[troop.id] = {
		"position": __scen_position_to_map_position(troop.map_position),
		"color": color
	}
	
func _on_troop_removed(scen, troop):
	troop_positions.erase(troop.id)


func _on_PaintLayer_mouse_down(event):
	if event.button_mask == BUTTON_LEFT:
		var real_pos = Vector2(event.position.x, event.position.y)
		if real_pos.x >= 0 and real_pos.y >= 0 and real_pos.x <= $PaintLayer.rect_size.x and real_pos.y <= $PaintLayer.rect_size.y:
			call_deferred("emit_signal", 'focus_camera', __map_position_to_scen_position(real_pos))
