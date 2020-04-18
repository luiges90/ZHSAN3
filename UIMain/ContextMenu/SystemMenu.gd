extends ContextMenu
class_name SystemMenu

signal save_clicked
signal load_clicked
signal info_clicked


func _on_Save_pressed():
	_select_item()
	emit_signal("save_clicked")


func _on_Load_pressed():
	_select_item()
	emit_signal("load_clicked")


func _on_Quit_pressed():
	get_tree().quit()


func _on_Toolbar_system_clicked():
	show()


func _on_Info_pressed():
	_select_item()
	emit_signal("info_clicked")
