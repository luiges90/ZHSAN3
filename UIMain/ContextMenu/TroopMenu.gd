extends Control
class_name TroopMenu

var showing_troop
var _opening_list

func show_menu(troop, mouse_x, mouse_y):	
	if GameConfig.se_enabled:
		($OpenSound as AudioStreamPlayer).play()
	showing_troop = troop
	
	margin_left = mouse_x
	margin_top = mouse_y
	
	show()


func _on_ArchitectureAndTroopMenu_troop_clicked(troop, mx, my):
	show_menu(troop, mx, my)



func _on_TroopMenu_hide():
	if GameConfig.se_enabled and not _opening_list:
		($CloseSound as AudioStreamPlayer).play()
	_opening_list = false

