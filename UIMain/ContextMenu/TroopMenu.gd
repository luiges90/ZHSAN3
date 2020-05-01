extends ContextMenu
class_name TroopMenu

var showing_troop
var _opening_list

signal move_clicked
signal attack_clicked
signal enter_clicked

func show_menu(troop, mouse_x, mouse_y):	
	showing_troop = troop
	
	margin_left = mouse_x
	margin_top = mouse_y
	
	show()


func _on_ArchitectureAndTroopMenu_troop_clicked(troop, mx, my):
	show_menu(troop, mx, my)


func _on_Move_pressed():
	_select_item()
	emit_signal("move_clicked", showing_troop)


func _on_Attack_pressed():
	_select_item()
	emit_signal("attack_clicked", showing_troop)


func _on_Enter_pressed():
	_select_item()
	emit_signal("enter_clicked", showing_troop)
