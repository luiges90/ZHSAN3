extends ContextMenu
class_name ArchitectureMenu

signal person_list_clicked
signal architecture_list_clicked
signal faction_list_clicked
signal architecture_toggle_auto_task
signal architecture_create_troop
signal remove_advisor
signal transport_clicked
signal auto_convince
signal attach_army

var showing_architecture
var _opening_list

func show_menu(arch, mouse_x, mouse_y, right_clicked):
	if arch.get_belonged_faction() == null:
		$H/MainMenu/Internal.visible = false
		$H/MainMenu/Military.visible = false
		$H/MainMenu/Officers.visible = false
		$H/MainMenu/Transport.visible = false
		$H/MainMenu/Faction.visible = false
		$H/MainMenu/ToggleAutoTask.visible = false
		$H/MainMenu/FactionDetail.visible = false
	else:
		var is_player = arch.get_belonged_faction().player_controlled and not right_clicked
		$H/MainMenu/Internal.visible = is_player
		$H/MainMenu/Military.visible = is_player
		$H/MainMenu/Officers.visible = is_player
		$H/MainMenu/Faction.visible = is_player
		$H/MainMenu/Transport.visible = is_player
		$H/MainMenu/ToggleAutoTask.visible = is_player
		$H/MainMenu/FactionDetail.visible = true

	showing_architecture = arch
	
	margin_left = mouse_x
	margin_top = mouse_y
	
	$H/MainMenu/ToggleAutoTask.text = tr('TOGGLE_MANUAL_TASK') if arch.auto_task else tr('TOGGLE_AUTO_TASK')
	
	var has_only_one_arch = arch.get_belonged_faction() != null and arch.get_belonged_faction().get_architectures().size() < 2
	$H/OfficersMenu/Move.disabled = has_only_one_arch
	$H/OfficersMenu/Call.disabled = has_only_one_arch
	$H/FactionMenu/RemoveAdvisor.disabled = arch.get_belonged_faction() != null and arch.get_belonged_faction().advisor == null
	
	$H/MainMenu/Transport.disabled = not arch.can_transport_resources()
	if $H/MainMenu/Transport.disabled:
		if arch.surrounded():
			$H/MainMenu/Transport.hint_tooltip = tr('TRANSPORT_DISABLED_HINT_SURROUNDED')
		else:
			$H/MainMenu/Transport.hint_tooltip = ""
	else:
		$H/MainMenu/Transport.hint_tooltip = ""
		
	$H/OfficersMenu/AutoConvince.text = tr('MANUAL_CONVINCE') if arch.auto_convince else tr('AUTO_CONVINCE')
	
	show()
	
func _open_submenu():
	$H/MilitaryMenu/Blank.rect_min_size = Vector2(0, $H/MainMenu/Military.rect_position.y + 4)
	$H/OfficersMenu/Blank.rect_min_size = Vector2(0, $H/MainMenu/Officers.rect_position.y + 4)
	$H/FactionMenu/Blank.rect_min_size = Vector2(0, $H/MainMenu/Faction.rect_position.y + 4)
	$H/FactionDetailsMenu/Blank.rect_min_size = Vector2(0, $H/MainMenu/FactionDetail.rect_position.y + 4)
	._open_submenu()
	
func _hide_submenus():
	$H/InternalMenu.hide()
	$H/MilitaryMenu.hide()
	$H/OfficersMenu.hide()
	$H/FactionMenu.hide()
	$H/FactionDetailsMenu.hide()


func _on_Internal_pressed():
	_open_submenu()
	$H/InternalMenu.show()
	
	
func _on_Military_pressed():
	_open_submenu()
	$H/MilitaryMenu.show()


func _on_Officers_pressed():
	_open_submenu()
	$H/OfficersMenu.show()
	

func _on_Faction_pressed():
	_open_submenu()
	$H/FactionMenu.show()
	

func _on_Main_FactionDetail_pressed():
	_open_submenu()
	$H/FactionDetailsMenu.show()


func _on_PersonList_pressed():
	_select_item()
	call_deferred("emit_signal", "person_list_clicked", showing_architecture, showing_architecture.get_persons(), PersonList.Action.LIST)


func _on_Agriculture_pressed():
	_select_item()
	call_deferred("emit_signal", "person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.AGRICULTURE)


func _on_Commerce_pressed():
	_select_item()
	call_deferred("emit_signal", "person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.COMMERCE)


func _on_Morale_pressed():
	_select_item()
	call_deferred("emit_signal", "person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.MORALE)


func _on_Endurance_pressed():
	_select_item()
	call_deferred("emit_signal", "person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.ENDURANCE)


func _on_Move_pressed():
	_select_item()
	call_deferred("emit_signal", "person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.MOVE)


func _on_Call_pressed():
	_select_item()
	var list = []
	for a in showing_architecture.get_belonged_faction().get_architectures():
		if a.id != showing_architecture.id:
			Util.append_all(list, a.get_workable_persons())
	call_deferred("emit_signal", "person_list_clicked", showing_architecture, list, PersonList.Action.CALL)


func _on_ArchitectureDetail_pressed():
	_select_item()
	call_deferred("emit_signal", "architecture_list_clicked", showing_architecture, [showing_architecture], PersonList.Action.LIST)


func _on_RecruitTroop_pressed():
	_select_item()
	call_deferred("emit_signal", "person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.RECRUIT_TROOP)



func _on_TrainTroop_pressed():
	_select_item()
	call_deferred("emit_signal", "person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.TRAIN_TROOP)



func _on_ProduceEquipment_pressed():
	_select_item()
	call_deferred("emit_signal", "person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.PRODUCE_EQUIPMENT)



func _on_FactionArchitectures_pressed():
	_select_item()
	call_deferred("emit_signal", "architecture_list_clicked", showing_architecture, showing_architecture.get_belonged_faction().get_architectures(), PersonList.Action.LIST)


func _on_ToggleAutoTask_pressed():
	_select_item()
	call_deferred("emit_signal", "architecture_toggle_auto_task", showing_architecture)


func _on_StartCampaign_pressed():
	_select_item()
	call_deferred("emit_signal", "architecture_create_troop", showing_architecture, showing_architecture.get_workable_persons(), showing_architecture.scenario.military_kinds)


func _on_ArchitectureAndTroopMenu_architecture_clicked(arch, mx, my):
	show_menu(arch, mx, my, false)


func _on_FactionDetail_pressed():
	_select_item()
	call_deferred("emit_signal", "faction_list_clicked", showing_architecture, [showing_architecture.get_belonged_faction()], FactionList.Action.LIST)


func _on_FactionPersons_pressed():
	_select_item()
	call_deferred("emit_signal", "person_list_clicked", showing_architecture, showing_architecture.get_belonged_faction().get_persons(), PersonList.Action.LIST)



func _on_AssignAdvisor_pressed():
	_select_item()
	call_deferred("emit_signal", "person_list_clicked", showing_architecture, showing_architecture.get_belonged_faction().get_advisor_candidates(), PersonList.Action.SELECT_ADVISOR)



func _on_RemoveAdvisor_pressed():
	_select_item()
	call_deferred("emit_signal", "remove_advisor", showing_architecture)



func _on_Convince_pressed():
	_select_item()
	call_deferred("emit_signal", "person_list_clicked", showing_architecture, showing_architecture.get_belonged_faction().get_convince_targets(), PersonList.Action.CONVINCE_TARGET)



func _on_Transport_pressed():
	_select_item()
	call_deferred("emit_signal", "transport_clicked", showing_architecture)


func _on_AutoConvince_pressed():
	_select_item()
	call_deferred("emit_signal", "auto_convince", showing_architecture)


func _on_AttachArmy_pressed():
	_select_item()
	
	var eligible_persons = []
	for p in showing_architecture.get_faction_persons():
		if p.attached_army == null:
			eligible_persons.append(p)
	
	call_deferred("emit_signal", "attach_army", showing_architecture, eligible_persons, showing_architecture.scenario.military_kinds)


func _on_DetachArmy_pressed():
	pass #todo


func _on_UpdateAttachedArmy_pressed():
	pass # Replace with function body.
