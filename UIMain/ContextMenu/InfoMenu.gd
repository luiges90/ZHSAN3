extends ContextMenu
class_name InfoMenu

signal military_kind_clicked

func _on_MilitaryKind_pressed():
	_select_item()
	emit_signal("military_kind_clicked")


func _on_SystemMenu_info_clicked():
	show()
