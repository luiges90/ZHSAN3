extends Panel
class_name PersonDetail

signal on_select_skills
signal on_select_stunts
signal on_save

var current_person: Person
var _editables = ['Merit', 'Karma', 'Popularity', 'Prestige', 'Ambition', 'Morality',
				  'Command', 'Strength', 'Intelligence', 'Politics', 'Glamour', 'Ideal',
				  'BornYear', 'Father', 'Mother', 'Spouses', 'Brothers', "Braveness", "Calmness"]

var _shift_held_down = false
var has_active_subwindow = false
var _editing = false

var _custom_persons = {}

func _on_PersonDetail_hide():
	$Close.play()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and not has_active_subwindow and not _editing:
			hide()
	elif event is InputEventKey:
		if event.scancode == KEY_SHIFT:
			_shift_held_down = event.pressed


func set_data(editing = false, custom_persons = {}):
	_custom_persons = custom_persons
	_editing = editing
	
	$Edit.visible = editing or GameConfig.enable_edit
	$EditingButtons.visible = editing
	for e in _editables:
		find_child(e).visible = true
		find_child(e + 'Edit').visible = false
	$SkillsHeader/Edit.visible = false
	$SkillsHeader/Label2.visible = false
	$StuntsHeader/Edit.visible = false
	$StuntsHeader/Label2.visible = false
	
	$_Id.text = str(current_person.id)
	if !editing:
		$Description.text = current_person.get_biography_text()
	
	$Portrait.texture = current_person.get_portrait()
	$Name.text = current_person.get_full_name()
	$SurnameEdit.text = current_person.surname
	$GivenNameEdit.text = current_person.given_name
	$CourtesyNameEdit.text = current_person.courtesy_name
	
	$Status/Gender.text = current_person.get_gender_str()
	$Status/GenderButton.text = current_person.get_gender_str()
	if !editing:
		$Status/Faction.text = current_person.get_belonged_faction_str()
		$Status/Section.text = current_person.get_belonged_section_str()
		$Status/Location.text = current_person.get_location_str()
		$Status/Status.text = current_person.get_status_str()
	$Status/Popularity.text = current_person.get_popularity_str()
	$Status/Prestige.text = current_person.get_prestige_str()
	$Status/Karma.text = current_person.get_karma_str()
	$Status/Merit.text = current_person.get_merit_str()
	$Status/Ambition.text = current_person.get_ambition_str()
	$Status/Morality.text = current_person.get_morality_str()
	$Status/Braveness.text = current_person.get_braveness_str()
	$Status/Calmness.text = current_person.get_calmness_str()

	$Abilities/Command.text = current_person.get_command_detail_str()
	$Abilities/Strength.text = current_person.get_strength_detail_str()
	$Abilities/Intelligence.text = current_person.get_intelligence_detail_str()
	$Abilities/Politics.text = current_person.get_politics_detail_str()
	$Abilities/Glamour.text = current_person.get_glamour_detail_str()
	
	$Relations/Ideal.text = str(current_person.ideal)
	$Relations/BornYear.text = str(current_person.born_year)
	$Relations/Age.text = str(current_person.get_age())
	$Relations/Father.text = current_person.get_father_name()
	$Relations/FatherEdit.text = current_person.get_father_name()
	$Relations/Mother.text = current_person.get_mother_name()
	$Relations/MotherEdit.text = current_person.get_mother_name()
	$Relations/Spouses.text = current_person.get_spouse_names()
	$Relations/SpousesEdit.text = current_person.get_spouse_names()
	$Relations/Brothers.text = current_person.get_brother_names()
	$Relations/BrothersEdit.text = current_person.get_brother_names()

	_update_skill_list()
	_update_stunt_list()
	
	if editing:
		_on_Edit_pressed()

func _update_skill_list():
	Util.delete_all_children($Skills)
	var skills = current_person.get_skills()
	for skill in skills:
		var label = LinkButton.new()
		label.text = skill.get_name_with_level(skills[skill])
		label.add_theme_color_override("font_color", skill.color)
		label.underline = LinkButton.UNDERLINE_MODE_NEVER
		label.mouse_default_cursor_shape = Control.CURSOR_ARROW
		label.connect("pressed",Callable(self,"_on_skill_clicked").bind(skill))
		label.mouse_filter = Control.MOUSE_FILTER_STOP
		
		$Skills.add_child(label)
		
func _update_stunt_list():
	Util.delete_all_children($Stunts)
	var stunts = current_person.get_stunts()
	for stunt in stunts:
		var label = LinkButton.new()
		label.text = stunt.get_name_with_level(stunts[stunt])
		label.add_theme_color_override("font_color", stunt.color)
		label.underline = LinkButton.UNDERLINE_MODE_NEVER
		label.mouse_default_cursor_shape = Control.CURSOR_ARROW
		label.connect("pressed",Callable(self,"_on_stunt_clicked").bind(stunt))
		label.mouse_filter = Control.MOUSE_FILTER_STOP
		
		$Stunts.add_child(label)


func _on_PersonList_person_row_clicked(person, editing = false, custom_persons = []):
	current_person = person
	set_data(editing, custom_persons)
	show()

func _on_skill_clicked(skill):
	var description = $Description as RichTextLabel
	var bbcode = ""
	bbcode += "[color=#FF7700]" + tr("SKILLS") + "[/color] "
	bbcode += "[color=#" + skill.color.to_html() + "]" + skill.get_name() + "[/color]\n"
	bbcode += skill.description
	description.text = bbcode
	
	if $SkillsHeader/Edit.visible:
		if _shift_held_down:
			current_person.decrement_skill_level(skill)
		else:
			current_person.increment_skill_level(skill)
		_update_skill_list()

func _on_stunt_clicked(stunt):
	var description = $Description as RichTextLabel
	var bbcode = ""
	bbcode += "[color=#FF7700]" + tr("STUNTS") + "[/color] "
	bbcode += "[color=#" + stunt.color.to_html() + "]" + stunt.get_name() + "[/color]\n"
	bbcode += tr("COMBATIVITY_COST").format({"cost": stunt.combativity_cost}) + "\n"
	bbcode += stunt.description
	description.text = bbcode
	
	if $StuntsHeader/Edit.visible:
		if _shift_held_down:
			current_person.decrement_stunt_level(stunt)
		else:
			current_person.increment_stunt_level(stunt)
		_update_stunt_list()

func _on_Edit_pressed():
	$Edit.visible = false
	$SkillsHeader/Edit.visible = true
	$SkillsHeader/Label2.visible = true
	$StuntsHeader/Edit.visible = true
	$StuntsHeader/Label2.visible = true
	
	$Status/Gender.visible = false
	$Status/GenderButton.visible = true
	$Name.visible = false
	$SurnameEdit.visible = true
	$GivenNameEdit.visible = true
	$CourtesyNameEdit.visible = true
	
	$Relations/AgeLabel.visible = false
	$Relations/Age.visible = false
	$Relations/DeathYearLabel.visible = true
	$Relations/DeathYearEdit.visible = true
	$Relations/DeathYearEdit.text = str(current_person.death_year)
	
	for e in _editables:
		var nonedit = find_child(e)
		var edit = find_child(e + 'Edit')
		nonedit.visible = false
		edit.visible = true
		match e:
			'Command': edit.text = str(current_person.command)
			'Strength': edit.text = str(current_person.strength)
			'Intelligence': edit.text = str(current_person.intelligence)
			'Politics': edit.text = str(current_person.politics)
			'Glamour': edit.text = str(current_person.glamour)
			_: edit.text = nonedit.text
			


func _on_MeritEdit_text_changed(new_text):
	current_person.set_merit(int(new_text))


func _on_KarmaEdit_text_changed(new_text):
	current_person.set_karma(int(new_text))


func _on_PopularityEdit_text_changed(new_text):
	current_person.set_popularity(int(new_text))


func _on_PrestigeEdit_text_changed(new_text):
	current_person.set_prestige(int(new_text))


func _on_AmbitionEdit_text_changed(new_text):
	current_person.set_ambition(int(new_text))


func _on_MoralityEdit_text_changed(new_text):
	current_person.set_morality(int(new_text))


func _on_CommandEdit_text_changed(new_text):
	current_person.set_meta_pressed(int(new_text))


func _on_StrengthEdit_text_changed(new_text):
	current_person.set_strength(int(new_text))


func _on_IntelligenceEdit_text_changed(new_text):
	current_person.set_intelligence(int(new_text))


func _on_PoliticsEdit_text_changed(new_text):
	current_person.set_politics(int(new_text))


func _on_GlamourEdit_text_changed(new_text):
	current_person.set_glamour(int(new_text))
	
	
func _on_BornYearEdit_text_changed(new_text):
	current_person.set_born_year(int(new_text))


func _on_DeathYearEdit_text_changed(new_text):
	current_person.set_death_year(int(new_text))



func _on_Skills_Edit_pressed():
	has_active_subwindow = true
	call_deferred("emit_signal", "on_select_skills", current_person)

func _on_Stunts_Edit_pressed():
	has_active_subwindow = true
	call_deferred("emit_signal", "on_select_stunts", current_person)

func _on_InfoList_edit_skill_item_selected(selected):
	current_person.set_skills(selected)
	_update_skill_list()
	has_active_subwindow = false

func _on_InfoList_edit_stunt_item_selected(selected):
	current_person.set_stunts(selected)
	_update_stunt_list()
	has_active_subwindow = false


func _on_Save_pressed():
	call_deferred("emit_signal", "on_save", current_person)


func _on_Cancel_pressed():
	var btn_ok = $ConfirmationDialog.get_ok_button()
	btn_ok.text = tr("EXIT")
	
	var btn_cancel = $ConfirmationDialog.get_cancel_button()
	btn_cancel.text = tr("RETURN")

	$ConfirmationDialog.popup()


func _on_ConfirmationDialog_confirmed():
	hide()


func _on_GenderButton_pressed():
	current_person._set_gender(not current_person.gender)
	$Status/Gender.text = current_person.get_gender_str()
	$Status/GenderButton.text = current_person.get_gender_str()
	$Portrait.texture = current_person.get_portrait()


func _on_IdealEdit_text_changed(new_text):
	current_person.set_ideal(int(new_text))


func _on_FatherEdit_pressed():
	var candidates = []
	for pid in current_person.scenario.persons:
		var p = current_person.scenario.persons[pid]
		if !p.gender and p.born_year + 16 <= current_person.born_year and p.death_year - 1 >= current_person.born_year and !p.is_related_blood_to(current_person):
			candidates.append(p)
	for pid in _custom_persons:
		var p = _custom_persons[pid]
		if !p.gender and p.born_year + 16 <= current_person.born_year and p.death_year - 1 >= current_person.born_year and !p.is_related_blood_to(current_person):
			candidates.append(p)
	$PersonList.edit_mode_select(candidates, PersonList.Action.EDIT_MODE_SELECT_FATHER)


func _on_MotherEdit_pressed():
	var candidates = []
	for pid in current_person.scenario.persons:
		var p = current_person.scenario.persons[pid]
		if p.gender and p.born_year + 16 <= current_person.born_year and p.death_year >= current_person.born_year and !p.is_related_blood_to(current_person):
			candidates.append(p)
	for pid in _custom_persons:
		var p = _custom_persons[pid]
		if p.gender and p.born_year + 16 <= current_person.born_year and p.death_year >= current_person.born_year and !p.is_related_blood_to(current_person):
			candidates.append(p)
	$PersonList.edit_mode_select(candidates, PersonList.Action.EDIT_MODE_SELECT_MOTHER)


func _on_PersonList_person_selected(current_action, current_architecture, selected):
	if current_action == PersonList.Action.EDIT_MODE_SELECT_FATHER:
		var p = Util.dict_try_get(current_person.scenario.persons, selected[0], null)
		current_person.set_father(p)
		$Relations/Father.text = current_person.get_father_name()
		$Relations/FatherEdit.text = current_person.get_father_name()
	elif current_action == PersonList.Action.EDIT_MODE_SELECT_MOTHER:
		var p = Util.dict_try_get(current_person.scenario.persons, selected[0], null)
		current_person.set_mother(p)
		$Relations/Mother.text = current_person.get_mother_name()
		$Relations/MotherEdit.text = current_person.get_mother_name()
	elif current_action == PersonList.Action.EDIT_MODE_SELECT_SPOUSE:
		current_person.clear_spouses()
		for pid in selected:
			var p = Util.dict_try_get(current_person.scenario.persons, pid, null)
			if p == null:
				p = _custom_persons[pid]
			current_person.add_spouse(p)
		$Relations/Spouses.text = current_person.get_spouse_names()
		$Relations/SpousesEdit.text = current_person.get_spouse_names()
	elif current_action == PersonList.Action.EDIT_MODE_SELECT_BROTHER:
		current_person.clear_brothers()
		for pid in selected:
			var p = Util.dict_try_get(current_person.scenario.persons, pid, null)
			if p == null:
				p = _custom_persons[pid]
			current_person.add_brother(p)
		$Relations/Brothers.text = current_person.get_brother_names()
		$Relations/BrothersEdit.text = current_person.get_brother_names()


func _on_SpousesEdit_pressed():
	var candidates = []
	for pid in current_person.scenario.persons:
		var p = current_person.scenario.persons[pid]
		if p.gender != current_person.gender and abs(p.born_year - current_person.born_year) <= 25 and !p.is_related_blood_to(current_person):
			candidates.append(p)
	for pid in _custom_persons:
		var p = _custom_persons[pid]
		if p.gender != current_person.gender and abs(p.born_year - current_person.born_year) <= 25 and !p.is_related_blood_to(current_person):
			candidates.append(p)
	$PersonList.edit_mode_select(candidates, PersonList.Action.EDIT_MODE_SELECT_SPOUSE)
	

func _on_BrothersEdit_pressed():
	var candidates = []
	for pid in current_person.scenario.persons:
		var p = current_person.scenario.persons[pid]
		if p.gender == current_person.gender and abs(p.born_year - current_person.born_year) <= 25 and !p.is_related_blood_to(current_person):
			candidates.append(p)
	for pid in _custom_persons:
		var p = _custom_persons[pid]
		if p.gender != current_person.gender and abs(p.born_year - current_person.born_year) <= 25 and !p.is_related_blood_to(current_person):
			candidates.append(p)
	$PersonList.edit_mode_select(candidates, PersonList.Action.EDIT_MODE_SELECT_BROTHER)


func _on_SurnameEdit_text_changed(new_text):
	current_person.set_surname(new_text)


func _on_GivenNameEdit_text_changed(new_text):
	current_person.set_given_name(new_text)


func _on_CourtesyNameEdit_text_changed(new_text):
	current_person.set_courtesy_name(new_text)


func _on_BravenessEdit_text_changed(new_text):
	current_person.set_braveness(int(new_text))


func _on_CalmnessEdit_text_changed(new_text):
	current_person.set_calmness(int(new_text))
