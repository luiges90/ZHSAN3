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
	$_Id.text = str(current_person.id)
	$Description.bbcode_text = current_person.get_biography_text()
	
	$Portrait.texture = current_person.get_portrait()
	$Name.text = current_person.get_full_name()
	
	$Status/Gender.text = current_person.get_gender_str()
	$Status/Faction.text = current_person.get_belonged_faction_str()
	$Status/Section.text = current_person.get_belonged_section_str()
	$Status/Location.text = current_person.get_location_str()
	$Status/Status.text = current_person.get_status_str()
	$Status/Popularity.text = current_person.get_popularity_str()
	$Status/Prestige.text = current_person.get_prestige_str()
	$Status/Karma.text = current_person.get_karma_str()
	$Status/Merit.text = current_person.get_merit_str()

	$Abilities/Command.text = current_person.get_command_detail_str()
	$Abilities/Strength.text = current_person.get_strength_detail_str()
	$Abilities/Intelligence.text = current_person.get_intelligence_detail_str()
	$Abilities/Politics.text = current_person.get_politics_detail_str()
	$Abilities/Glamour.text = current_person.get_glamour_detail_str()
	
	Util.delete_all_children($Skills)
	for skill in current_person.skills:
		var label = LinkButton.new()
		label.text = skill.get_name_with_level(current_person.skills[skill])
		label.add_color_override("font_color", skill.color)
		label.underline = LinkButton.UNDERLINE_MODE_NEVER
		label.mouse_default_cursor_shape = Control.CURSOR_ARROW
		label.connect("pressed", self, "_on_skill_clicked", [skill])
		label.mouse_filter = Control.MOUSE_FILTER_STOP
		
		$Skills.add_child(label)
		
	Util.delete_all_children($Stunts)
	for stunt in current_person.stunts:
		var label = LinkButton.new()
		label.text = stunt.get_name_with_level(current_person.stunts[stunt])
		label.add_color_override("font_color", stunt.color)
		label.underline = LinkButton.UNDERLINE_MODE_NEVER
		label.mouse_default_cursor_shape = Control.CURSOR_ARROW
		label.connect("pressed", self, "_on_stunt_clicked", [stunt])
		label.mouse_filter = Control.MOUSE_FILTER_STOP
		
		$Stunts.add_child(label)


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

func _on_stunt_clicked(stunt):
	var description = $Description as RichTextLabel
	var bbcode = ""
	bbcode += "[color=#FF7700]" + tr("STUNTS") + "[/color] "
	bbcode += "[color=#" + stunt.color.to_html() + "]" + stunt.get_name() + "[/color]\n"
	bbcode += tr("COMBATIVITY_COST").format({"cost": stunt.combativity_cost}) + "\n"
	bbcode += stunt.description
	description.bbcode_text = bbcode
	
