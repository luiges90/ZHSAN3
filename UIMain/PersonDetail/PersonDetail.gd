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
	$Description.bbcode_text = ""
	
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
	
	Util.delete_all_children($Skills)
	for skill in current_person.skills:
		var label = LinkButton.new()
		label.text = skill.get_name()
		label.add_color_override("font_color", skill.color)
		label.underline = LinkButton.UNDERLINE_MODE_NEVER
		label.mouse_default_cursor_shape = Control.CURSOR_ARROW
		label.connect("pressed", self, "_on_skill_clicked", [skill])
		label.mouse_filter = Control.MOUSE_FILTER_STOP
		
		$Skills.add_child(label)


func _on_PersonList_person_row_clicked(person):
	current_person = person
	set_data()
	show()

func _on_skill_clicked(skill):
	var description = $Description as RichTextLabel
	var bbcode = ""
	bbcode += "[color=#FF7700]" + tr("SKILLS") + "[/color] "
	bbcode += "[color=#" + skill.color.to_html() + "]" + skill.get_name() + "[/color]\n"
	bbcode += skill.description
	description.bbcode_text = bbcode
