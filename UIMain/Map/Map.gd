extends Control


func _on_Toolbar_map_clicked():
	if visible:
		hide()
	else:
		show()
