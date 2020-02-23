extends Node2D
class_name ZhsanMap

onready var tile_size = (find_node('*') as TileMap).cell_size[0]
onready var map_size = Vector2(390, 390)

var quadrant_size = Vector2(100, 100)

func _on_MainCamera_camera_moved(camera_top_left: Vector2, camera_bottom_right):
	var top_left = (find_node('*') as TileMap).world_to_map(camera_top_left)
	var bottom_right = (find_node('*') as TileMap).world_to_map(camera_bottom_right)

	var quadrant_left = int(top_left.x / quadrant_size.x)
	var quadrant_right = int(bottom_right.x / quadrant_size.x)
	var quadrant_top = int(top_left.y / quadrant_size.y)
	var quadrant_bottom = int(bottom_right.y / quadrant_size.y)
	for node in get_children():
		var name = node.name
		var y = int(name.substr(0, name.find('x')))
		var x = int(name.substr(name.find('x') + 1))
		node.visible = quadrant_left <= x and x <= quadrant_right and quadrant_top <= y and y <= quadrant_bottom
