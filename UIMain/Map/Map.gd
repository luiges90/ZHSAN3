extends Control


func _on_Toolbar_map_clicked():
	if visible:
		hide()
	else:
		show()

func _on_camera_moved(camera_rect: Rect2, zoom: Vector2, scen):
	print(camera_rect, zoom, scen)
	pass
