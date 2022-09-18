extends Node2D
class_name ZhsanMap

@onready var tile_size = (find_child('*') as TileMap).cell_size[0]
@onready var map_size = Vector2(390, 390)

var quadrant_size = Vector2(100, 100)

func _on_MainCamera_camera_moved(camera_rect: Rect2, zoom: Vector2):
	var top_left = (find_child('*') as TileMap).local_to_map(camera_rect.position)
	var bottom_right = (find_child('*') as TileMap).local_to_map(camera_rect.position + camera_rect.size)

	var quadrant_left = int(top_left.x / quadrant_size.x)
	var quadrant_right = int(bottom_right.x / quadrant_size.x)
	var quadrant_top = int(top_left.y / quadrant_size.y)
	var quadrant_bottom = int(bottom_right.y / quadrant_size.y)
	for node in get_children():
		var name = node.name
		var y = int(name.substr(0, 1))
		var x = int(name.substr(2, 1))
		node.visible = quadrant_left <= x and x <= quadrant_right and quadrant_top <= y and y <= quadrant_bottom


func _get_terrain_id_at_position(pos: Vector2):
	var quadrant_x = int(pos.x / quadrant_size.x)
	var quadrant_y = int((pos.y + 1) / quadrant_size.y)
	return (find_child(str(quadrant_y) + 'x' + str(quadrant_x)) as TileMap).get_cell(pos.x, pos.y + 1)
	
