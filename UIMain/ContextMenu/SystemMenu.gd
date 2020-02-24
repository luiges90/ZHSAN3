extends VBoxContainer
class_name SystemMenu

signal save_clicked
signal load_clicked

func _on_Save_pressed():
	$Click.play()
	emit_signal("save_clicked")


func _on_Load_pressed():
	$Click.play()
	emit_signal("load_clicked")


func _on_Quit_pressed():
	$Click.play()


func _on_Toolbar_system_clicked():
	show()


func _on_SystemMenu_hide():
	$Close.play()
