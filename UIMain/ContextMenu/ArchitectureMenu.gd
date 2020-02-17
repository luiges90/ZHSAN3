extends VBoxContainer
class_name ArchitectureMenu

signal person_list_clicked

var showing_architecture
var _opening_list

func show_menu(arch, mouse_x, mouse_y):
	if GameConfig.se_enabled:
		($OpenSound as AudioStreamPlayer).play()
	showing_architecture = arch
	margin_left = mouse_x
	margin_top = mouse_y
	show()

func _on_Button_pressed():
	if GameConfig.se_enabled:
		($SelectSound as AudioStreamPlayer).play()
	emit_signal("person_list_clicked", showing_architecture)
	_opening_list = true
	hide()


func _on_ArchitectureMenu_hide():
	if GameConfig.se_enabled and not _opening_list:
		($CloseSound as AudioStreamPlayer).play()
	_opening_list = false
