extends VBoxContainer
class_name InfoMenu

signal military_kind_clicked

var _confirming = false

func _on_MilitaryKind_pressed():
	$Click.play()
	_confirming = true
	hide()
	emit_signal("military_kind_clicked")


func _on_InfoMenu_hide():
	if not _confirming:
		$Close.play()
	_confirming = false


func _on_SystemMenu_info_clicked():
	show()
