extends VBoxContainer

signal person_list_clicked

func _on_Button_pressed():
	emit_signal("person_list_clicked")
