extends VBoxContainer
class_name SystemMenu

signal save_clicked
signal load_clicked
signal info_clicked

var _confirming = false

func _on_Save_pressed():
	$Click.play()
	_confirming = true
	hide()
	emit_signal("save_clicked")


func _on_Load_pressed():
	$Click.play()
	_confirming = true
	hide()
	emit_signal("load_clicked")


func _on_Quit_pressed():
	get_tree().quit()


func _on_Toolbar_system_clicked():
	show()


func _on_SystemMenu_hide():
	if not _confirming:
		$Close.play()
	_confirming = false


func _on_Info_pressed():
	$Click.play()
	_confirming = true
	hide()
	emit_signal("info_clicked")
