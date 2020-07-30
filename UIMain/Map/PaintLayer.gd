extends Control

var map

func _draw():
	draw_rect(map.view_rectangle, Color.white, false, 2.0, false)

func _process(delta):
	update()
