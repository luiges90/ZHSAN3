extends ContextMenu
class_name ArchitectureMenu

signal person_list_clicked
signal architecture_list_clicked
signal faction_list_clicked
signal architecture_toggle_auto_task
signal architecture_create_troop

var showing_architecture
var _opening_list

func show_menu(arch, mouse_x, mouse_y):
	if arch.get_belonged_faction() == null:
		$MainMenu/Internal.visible = false
		$MainMenu/Military.visible = false
		$MainMenu/Officers.visible = false
		$MainMenu/ToggleAutoTask.visible = false
		$MainMenu/FactionDetail.visible = false
		$MainMenu/FactionArchitectures.visible = false
	else:
		var is_player = arch.get_belonged_faction().player_controlled
		$MainMenu/Internal.visible = is_player
		$MainMenu/Military.visible = is_player
		$MainMenu/Officers.visible = is_player
		$MainMenu/ToggleAutoTask.visible = is_player

	showing_architecture = arch
	
	margin_left = mouse_x
	margin_top = mouse_y
	
	$MainMenu/ToggleAutoTask.text = tr('TOGGLE_MANUAL_TASK') if arch.auto_task else tr('TOGGLE_AUTO_TASK')
	
	var has_only_one_arch = arch.get_belonged_faction() != null and arch.get_belonged_faction().get_architectures().size() < 2
	$OfficersMenu/Move.disabled = has_only_one_arch
	$OfficersMenu/Call.disabled = has_only_one_arch
	
	show()
	
func _hide_submenus():
	$InternalMenu.hide()
	$MilitaryMenu.hide()
	$OfficersMenu.hide()


func _on_Internal_pressed():
	_open_submenu()
	$InternalMenu.show()
	
	
func _on_Military_pressed():
	_open_submenu()
	$MilitaryMenu.show()


func _on_Officers_pressed():
	_open_submenu()
	$OfficersMenu.show()


func _on_PersonList_pressed():
	_select_item()
	emit_signal("person_list_clicked", showing_architecture, showing_architecture.get_persons(), PersonList.Action.LIST)


func _on_Agriculture_pressed():
	_select_item()
	emit_signal("person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.AGRICULTURE)


func _on_Commerce_pressed():
	_select_item()
	emit_signal("person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.COMMERCE)


func _on_Morale_pressed():
	_select_item()
	emit_signal("person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.MORALE)


func _on_Endurance_pressed():
	_select_item()
	emit_signal("person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.ENDURANCE)


func _on_Move_pressed():
	_select_item()
	emit_signal("person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.MOVE)


func _on_Call_pressed():
	_select_item()
	var list = []
	for a in showing_architecture.get_belonged_faction().get_architectures():
		if a.id != showing_architecture.id:
			Util.append_all(list, a.get_workable_persons())
	emit_signal("person_list_clicked", showing_architecture, list, PersonList.Action.CALL)


func _on_ArchitectureDetail_pressed():
	_select_item()
	emit_signal("architecture_list_clicked", showing_architecture, [showing_architecture], PersonList.Action.LIST)


func _on_RecruitTroop_pressed():
	_select_item()
	emit_signal("person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.RECRUIT_TROOP)



func _on_TrainTroop_pressed():
	_select_item()
	emit_signal("person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.TRAIN_TROOP)



func _on_ProduceEquipment_pressed():
	_select_item()
	emit_signal("person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.PRODUCE_EQUIPMENT)



func _on_FactionArchitectures_pressed():
	_select_item()
	emit_signal("architecture_list_clicked", showing_architecture, showing_architecture.get_belonged_faction().get_architectures(), PersonList.Action.LIST)


func _on_ToggleAutoTask_pressed():
	_select_item()
	emit_signal("architecture_toggle_auto_task", showing_architecture)


func _on_StartCampaign_pressed():
	_select_item()
	emit_signal("architecture_create_troop", showing_architecture, showing_architecture.get_workable_persons(), showing_architecture.scenario.military_kinds)



func _on_ArchitectureAndTroopMenu_architecture_clicked(arch, mx, my):
	show_menu(arch, mx, my)


func _on_FactionDetail_pressed():
	_select_item()
	emit_signal("faction_list_clicked", showing_architecture, [showing_architecture.get_belonged_faction()], FactionList.Action.LIST)
