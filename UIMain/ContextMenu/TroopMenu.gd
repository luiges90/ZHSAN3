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
