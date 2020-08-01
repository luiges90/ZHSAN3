extends Control

var map

func _draw():
	draw_rect(map.view_rectangle, Color.white, false, 2.0, false)
	
	for p in map.architecture_positions:
		var item = map.architecture_positions[p]
		var rect = Rect2(item['position'].x - 6, item['position'].y - 6, 12, 12)
		draw_rect(rect, item['color'], true, 1.0, false)
		draw_rect(rect, Color.white, false, 1.0, false)
		
	for p in map.troop_positions:
		var item = map.troop_positions[p]
		var rect = Rect2(item['position'].x - 4, item['position'].y - 4, 8, 8)
		draw_rect(rect, item['color'], true, 1.0, false)
		draw_rect(rect, Color.white, false, 1.0, false)

func _process(delta):
	update()
