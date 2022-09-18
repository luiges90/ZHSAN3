extends TabList
class_name InfoList

enum Action { 
	EDIT_SKILL,
	EDIT_STUNT
}

signal edit_skill_item_selected
signal edit_stunt_item_selected

var current_person

func _ready():
	_add_tab('BASIC')
	
func _on_PersonDetail_edit_skills_clicked(person):
	current_action = Action.EDIT_SKILL
	current_person = person
	_on_InfoMenu_skills_clicked(person.scenario)
	

func _on_PersonDetail_edit_stunts_clicked(person):
	current_action = Action.EDIT_STUNT
	current_person = person
	_on_InfoMenu_stunts_clicked(person.scenario)


func _on_InfoMenu_skills_clicked(scenario):
	$Title.text = tr('SKILL_LIST')
	show_data(scenario.skills)
	show()
	
func _on_InfoMenu_stunts_clicked(scenario):
	$Title.text = tr('STUNT_LIST')
	show_data(scenario.stunts)
	show()
	

func show_data(data):
	super.show_data(data)
	_allow_empty_selection = true
	
	var item_list = tabs['BASIC'] as GridContainer
	Util.delete_all_children(item_list)
	
	item_list.columns = 4
	item_list.add_child(_title(''))
	item_list.add_child(_title(tr('ID')))
	item_list.add_child(_title(tr('NAME')))
	item_list.add_child(_title(tr('DESCRIPTION')))

	for i in data:
		var item = data[i]
		var color = item.get_color() if item.has_method('get_color') else null
		
		var checked = false
		if current_person != null:
			match current_action:
				Action.EDIT_SKILL: checked = current_person.skills.has(item)
				Action.EDIT_STUNT: checked = current_person.stunts.has(item)
		
		item_list.add_child(_checkbox(item.id, checked))
		item_list.add_child(_label(str(item.id)))
		item_list.add_child(_label(item.get_name(), color))
		item_list.add_child(_label(item.description))
		

func _on_Confirm_pressed():
	if current_action == Action.EDIT_SKILL:
		var selected = _get_selected_list()
		call_deferred("emit_signal", "edit_skill_item_selected", selected)
	elif current_action == Action.EDIT_STUNT:
		var selected = _get_selected_list()
		call_deferred("emit_signal", "edit_stunt_item_selected", selected)
		
	$ConfirmSound.play()
	super._on_Confirm_pressed()
