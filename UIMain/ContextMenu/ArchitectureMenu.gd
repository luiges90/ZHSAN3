extends Control
class_name ArchitectureMenu

signal person_list_clicked
signal architecture_list_clicked

var showing_architecture
var _opening_list

func show_menu(arch, mouse_x, mouse_y):
	if arch.get_belonged_faction() == null:
		$MainMenu/Internal.visible = false
		$MainMenu/Officers.visible = false
	else:
		var is_player = arch.get_belonged_faction().player_controlled
		$MainMenu/Internal.visible = is_player
		$MainMenu/Officers.visible = is_player
	
	if GameConfig.se_enabled:
		($OpenSound as AudioStreamPlayer).play()
	showing_architecture = arch
	
	margin_left = mouse_x
	margin_top = mouse_y
	
	show()
	
func _hide_submenus():
	$InternalMenu.hide()
	$MilitaryMenu.hide()
	$OfficersMenu.hide()


func _on_Internal_pressed():
	if GameConfig.se_enabled:
		($OpenSound as AudioStreamPlayer).play()
	_hide_submenus()
	$InternalMenu.show()
	

func _on_Officers_pressed():
	if GameConfig.se_enabled:
		($OpenSound as AudioStreamPlayer).play()
	_hide_submenus()
	$OfficersMenu.show()


func _on_PersonList_pressed():
	if GameConfig.se_enabled:
		($SelectSound as AudioStreamPlayer).play()
	emit_signal("person_list_clicked", showing_architecture, showing_architecture.get_persons(), PersonList.Action.LIST)
	_opening_list = true
	hide()


func _on_ArchitectureMenu_hide():
	if GameConfig.se_enabled and not _opening_list:
		($CloseSound as AudioStreamPlayer).play()
	_hide_submenus()
	_opening_list = false


func _on_Agriculture_pressed():
	if GameConfig.se_enabled:
		($SelectSound as AudioStreamPlayer).play()
	emit_signal("person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.AGRICULTURE)
	_opening_list = true
	hide()


func _on_Commerce_pressed():
	if GameConfig.se_enabled:
		($SelectSound as AudioStreamPlayer).play()
	emit_signal("person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.COMMERCE)
	_opening_list = true
	hide()


func _on_Morale_pressed():
	if GameConfig.se_enabled:
		($SelectSound as AudioStreamPlayer).play()
	emit_signal("person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.MORALE)
	_opening_list = true
	hide()


func _on_Endurance_pressed():
	if GameConfig.se_enabled:
		($SelectSound as AudioStreamPlayer).play()
	emit_signal("person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.ENDURANCE)
	_opening_list = true
	hide()


func _on_Move_pressed():
	if GameConfig.se_enabled:
		($SelectSound as AudioStreamPlayer).play()
	emit_signal("person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.MOVE)
	_opening_list = true
	hide()

func _on_Call_pressed():
	if GameConfig.se_enabled:
		($SelectSound as AudioStreamPlayer).play()
	var list = []
	for a in showing_architecture.get_belonged_faction().get_architectures():
		if a.id != showing_architecture.id:
			Util.append_all(list, a.get_workable_persons())
	emit_signal("person_list_clicked", showing_architecture, list, PersonList.Action.CALL)
	_opening_list = true
	hide()


func _on_ArchitectureDetail_pressed():
	if GameConfig.se_enabled:
		($SelectSound as AudioStreamPlayer).play()
	emit_signal("architecture_list_clicked", showing_architecture, [showing_architecture], PersonList.Action.LIST)
	_opening_list = true
	hide()


func _on_Military_pressed():
	if GameConfig.se_enabled:
		($OpenSound as AudioStreamPlayer).play()
	_hide_submenus()
	$MilitaryMenu.show()


func _on_RecruitTroop_pressed():
	if GameConfig.se_enabled:
		($SelectSound as AudioStreamPlayer).play()
	emit_signal("person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.RECRUIT_TROOP)
	_opening_list = true
	hide()


func _on_TrainTroop_pressed():
	if GameConfig.se_enabled:
		($SelectSound as AudioStreamPlayer).play()
	emit_signal("person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.TRAIN_TROOP)
	_opening_list = true
	hide()


func _on_ProduceEquipment_pressed():
	if GameConfig.se_enabled:
		($SelectSound as AudioStreamPlayer).play()
	emit_signal("person_list_clicked", showing_architecture, showing_architecture.get_workable_persons(), PersonList.Action.PRODUCE_EQUIPMENT)
	_opening_list = true
	hide()


func _on_FactionArchitectures_pressed():
	if GameConfig.se_enabled:
		($SelectSound as AudioStreamPlayer).play()
	emit_signal("architecture_list_clicked", showing_architecture, showing_architecture.get_belonged_faction().get_architectures(), PersonList.Action.LIST)
	_opening_list = true
	hide()
