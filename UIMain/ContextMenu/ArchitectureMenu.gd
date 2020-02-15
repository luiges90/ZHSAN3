extends VBoxContainer
class_name ArchitectureMenu

signal person_list_clicked

var showing_architecture

func show_menu(arch, mouse_x, mouse_y):
	showing_architecture = arch
	margin_left = mouse_x
	margin_top = mouse_y
	show()

func _on_Button_pressed():
	emit_signal("person_list_clicked", showing_architecture)
	hide()
