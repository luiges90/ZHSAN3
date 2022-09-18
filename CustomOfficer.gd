extends Control

signal back_button_pressed

var custom_persons: Dictionary
var current_person
var _scenario

var _editing_person_id = null

func __load_custom_officers():
	var file = File.new()
	var err = file.open("user://custom_persons.json", File.READ)
	
	if err == ERR_FILE_NOT_FOUND:
		file.open("user://custom_persons.json", File.WRITE)
		file.store_line("{}")
		file.close()
		
	custom_persons = {}
	for pid in _scenario.persons:
		var p = _scenario.persons[pid]
		if p.is_custom:
			custom_persons[pid] = p



func _on_Back_pressed():
	emit_signal("back_button_pressed")
	$Close.play()
	hide()


func _on_New_pressed():
	_editing_person_id = null
	
	current_person = Person.new()
	current_person.scenario = _scenario
	current_person.is_custom = true
	current_person.set_born_year(170)
	current_person.set_death_year(230)
	current_person.set_surname(tr('SURNAME'))
	current_person.set_given_name(tr('GIVEN_NAME'))
	current_person.set_courtesy_name(tr('COURTESY_NAME'))
	$PersonDetail._on_PersonList_person_row_clicked(current_person, true, custom_persons)
	

func _on_Edit_pressed():
	$PersonList.edit_mode_select(custom_persons.values(), PersonList.Action.EDIT_MODE_CHOOSE_EDIT_OFFICER)


func _on_PersonDetail_on_select_skills(person):
	$InfoList._on_PersonDetail_edit_skills_clicked(person)


func _on_PersonDetail_on_select_stunts(person):
	$InfoList._on_PersonDetail_edit_stunts_clicked(person)


func _on_InfoList_edit_skill_item_selected(selected):
	$PersonDetail._on_InfoList_edit_skill_item_selected(selected)
	

func _on_InfoList_edit_stunt_item_selected(selected):
	$PersonDetail._on_InfoList_edit_stunt_item_selected(selected)


func _on_PersonDetail_on_save(person):
	if _editing_person_id == null:
		if custom_persons.size() > 0:
			var free_id = custom_persons.keys().max()
			person._set_id(free_id + 1)
		else:
			person._set_id(30000)
		person.set_inactive()
		custom_persons[person.id] = person
	
	$PersonDetail.hide()
	
	var file = File.new()
	file.open("user://custom_persons.json", File.WRITE)
	var data = []
	for p in custom_persons:
		data.append(custom_persons[p].save_data())
	file.store_line(JSON.new().stringify(data))


func _on_CustomOfficer_visibility_changed():
	_scenario = Scenario.new()
	SharedData.loading_file_path = "res://Scenarios/_Common"
	_scenario._ready(true)
	
	__load_custom_officers()
	

func _on_PersonList_person_selected(current_action, current_architecture, selected):
	var person = custom_persons[selected[0]]
	_editing_person_id = person.id
	$PersonDetail._on_PersonList_person_row_clicked(person, true, custom_persons)
