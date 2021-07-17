extends Control

signal back_button_pressed

var custom_persons: Array
var current_person
var _scenario

var _editing_person_id = null

func _ready():
	_scenario = Scenario.new()
	SharedData.loading_file_path = "res://Scenarios/_Common"
	_scenario._ready(true)
	
	__load_custom_officers()
	

func __load_custom_officers():
	var file = File.new()
	var err = file.open("user://custom_persons.json", File.READ)
	
	if err == OK:
		var json = file.get_as_text()
		var data = parse_json(json)
		custom_persons = []
		for d in data:
			var person = Person.new()
			person.load_data(d, {"skills": _scenario.skills, "stunts": _scenario.stunts})
			person.scenario = _scenario
			custom_persons.append(person)
	elif err == ERR_FILE_NOT_FOUND:
		file.open("user://custom_persons.json", File.WRITE)
		file.store_line("[]")
		file.close()
		custom_persons = []
	else:
		custom_persons = []


func _on_Back_pressed():
	emit_signal("back_button_pressed")
	$Close.play()
	hide()


func _on_New_pressed():
	_editing_person_id = null
	
	current_person = Person.new()
	current_person.scenario = _scenario
	$PersonDetail._on_PersonList_person_row_clicked(current_person, true)
	

func _on_Edit_pressed():
	$PersonList.show_data(custom_persons)


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
		var free_id = Util.max_by(custom_persons, "get_id")
		person._set_id(free_id[2] + 1)
	else:
		person._set_id(30000)
	if _editing_person_id == null:
		custom_persons.append(person)
	
	$PersonDetail.hide()
	
	var file = File.new()
	file.open("user://custom_persons.json", File.WRITE)
	var data = []
	for p in custom_persons:
		data.append(p.save_data())
	file.store_line(to_json(data))
