extends ContextMenu
class_name TroopMenu

var showing_troop
var _opening_list

signal move_clicked
signal attack_clicked
signal stunt_clicked
signal enter_clicked
signal follow_clicked
signal troop_detail_clicked
signal occupy_clicked
signal troop_person_clicked

func show_menu(troop, mouse_x, mouse_y, right_clicked): 
	showing_troop = troop
	
	var is_player = troop.get_belonged_faction().player_controlled

	$H/V/Move.visible = is_player and not troop.order_made
	$H/V/Follow.visible = is_player and not troop.order_made
	$H/V/Attack.visible = is_player and not troop.order_made
	$H/V/Stunt.visible = is_player and not troop.order_made
	$H/V/Enter.visible = is_player and not troop.order_made
	$H/V/Occupy.visible = is_player and not troop.order_made
	$H/V/Occupy.disabled = !troop.can_occupy()
	
	offset_left = mouse_x
	offset_top = mouse_y
	
	for n in $H/Stunt.get_children():
		if n.name != 'Blank':
			$H/Stunt.remove_child(n)
	
	$H/V/Stunt.disabled = troop.available_stunts().size() == 0
	for s in troop.available_stunts():
		var button = Button.new()
		button.text = s.get_name() + "(" + str(s.combativity_cost) + ")"
		button.connect("pressed",Callable(self,"_on_Stunt_item_pressed").bind(s))
		$H/Stunt.add_child(button)
	
	show()
	
func _hide_submenus():
	$H/Stunt.hide()


func _on_ArchitectureAndTroopMenu_troop_clicked(troop, mx, my):
	show_menu(troop, mx, my, false)


func _on_Move_pressed():
	_select_item()
	call_deferred("emit_signal", "move_clicked", showing_troop)


func _on_Attack_pressed():
	_select_item()
	call_deferred("emit_signal", "attack_clicked", showing_troop)


func _on_Stunt_pressed():
	super._open_submenu()
	$H/Stunt.show()
	

func _on_Stunt_item_pressed(stunt):
	_select_item()
	call_deferred("emit_signal", "stunt_clicked", showing_troop, stunt)
	

func _on_Enter_pressed():
	_select_item()
	call_deferred("emit_signal", "enter_clicked", showing_troop)


func _on_Follow_pressed():
	_select_item()
	call_deferred("emit_signal", "follow_clicked", showing_troop)


func _on_TroopDetail_pressed():
	_select_item()
	call_deferred("emit_signal", "troop_detail_clicked", showing_troop)


func _on_Occupy_pressed():
	_select_item()
	call_deferred("emit_signal", "occupy_clicked", showing_troop)


func _on_TroopPerson_pressed():
	_select_item()
	call_deferred("emit_signal", "troop_person_clicked", showing_troop)
