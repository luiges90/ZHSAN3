extends Panel
class_name PersonDetail

var current_person: Person


func _on_PersonDetail_hide():
	$Close.play()


func set_data():
	$Portrait.texture = current_person.get_portrait()
	
	$Status/Gender.text = current_person.get_gender_str()
	$Status/Faction.text = current_person.get_belonged_faction_str()
	$Status/Section.text = current_person.get_belonged_section_str()
	$Status/Location.text = current_person.get_location()
	$Status/Status.text = current_person.get_status_str()

	$Abilities/Command.text = current_person.command
	$Abilities/Strength.text = current_person.strength
	$Abilities/Intelligence.text = current_person.intelligence
	$Abilities/Politics.text = current_person.politics
	$Abilities/Glamour.text = current_person.glamour
