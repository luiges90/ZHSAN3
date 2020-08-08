extends Panel
class_name PersonDetail

var current_person: Person


func _on_PersonDetail_hide():
	$Close.play()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			hide()

func set_data():
	$Portrait.texture = current_person.get_portrait()
	$Name.text = current_person.get_full_name()
	
	$Status/Gender.text = current_person.get_gender_str()
	$Status/Faction.text = current_person.get_belonged_faction_str()
	$Status/Section.text = current_person.get_belonged_section_str()
	$Status/Location.text = current_person.get_location_str()
	$Status/Status.text = current_person.get_status_str()

	$Abilities/Command.text = str(current_person.command)
	$Abilities/Strength.text = str(current_person.strength)
	$Abilities/Intelligence.text = str(current_person.intelligence)
	$Abilities/Politics.text = str(current_person.politics)
	$Abilities/Glamour.text = str(current_person.glamour)


func _on_PersonList_person_row_clicked(person):
	current_person = person
	set_data()
	show()
