extends Control

signal back_button_pressed

var custom_persons: Dictionary
var current_person
var _scenario

var _editing_person_id = null

func __load_custom_officers():
	var file = File.new()
	var err = file.open("user://custom_persons.json", File.READ)
	
	if err == OK:
		var json = file.get_as_text()
		var data = parse_json(json)
		custom_persons = {}
		for d in data:
			var person = Person.new()
			person.load_data(d, {"skills": _scenario.skills, "stunts": _scenario.stunts})
			person.scenario = _scenario
			custom_persons[person.id] = person
	elif err == ERR_FILE_NOT_FOUND:
		file.open("user://custom_persons.json", File.WRITE)
		file.store_line("{}")
		file.close()
		custom_persons = {}
	else:
		custom_persons = {}


func _on_Back_pressed():
	emit_signal("back_button_pressed")
	$Close.play()
	hide()


func _on_New_pressed():
	_editing_person_id = null
	
	current_person = Person.new()
	current_person.scenario = _scenario
	current_person.set_born_year(170)
	current_person.set_death_year(230)
	$PersonDetail._on_PersonList_person_row_clicked(current_person, true)
	

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
	if custom_persons.size() > 0:
		var free_id = custom_persons.keys().max()
		person._set_id(free_id + 1)
	else:
		person._set_id(30000)
	if _editing_person_id == null:
		custom_persons[person.id] = person
	
	$PersonDetail.hide()
	
	var file = File.new()
	file.open("user://custom_persons.json", File.WRITE)
	var data = []
	for p in custom_persons:
		data.append(custom_persons[p].save_data())
	file.store_line(to_json(data))


func _on_CustomOfficer_visibility_changed():
	_scenario = Scenario.new()
	SharedData.loading_file_path = "res://Scenarios/_Common"
	_scenario._ready(true)
	
	__load_custom_officers()
	

func _on_PersonList_person_selected(current_action, current_architecture, selected):
	var person = custom_persons[selected[0]]
	$PersonDetail._on_PersonList_person_row_clicked(person, true)
