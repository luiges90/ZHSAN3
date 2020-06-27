extends ContextMenu
class_name TroopMenu

var showing_troop
var _opening_list

signal move_clicked
signal attack_clicked
signal enter_clicked
signal follow_clicked
signal troop_detail_clicked
signal occupy_clicked

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


func _on_Follow_pressed():
	_select_item()
	emit_signal("follow_clicked", showing_troop)


func _on_TroopDetail_pressed():
	_select_item()
	emit_signal("troop_detail_clicked", showing_troop)


func _on_Occupy_pressed():
	_select_item()
	emit_signal("occupy_clicked", showing_troop)
