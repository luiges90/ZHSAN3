extends Control

signal back_button_pressed

var custom_persons
var current_person = Person.new()

func _ready():
	__load_custom_officers()
	

func __load_custom_officers():
	var file = File.new()
	var err = file.open("user://custom_persons.json", File.READ)
	
	if err == OK:
		var json = file.get_as_text()
		custom_persons = parse_json(json)
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
	$PersonDetail._on_PersonList_person_row_clicked(current_person, true)
	

func _on_Edit_pressed():
	$PersonList.show_data(custom_persons)
