extends TabList
class_name PersonList

enum Action { LIST, AGRICULTURE, COMMERCE, MORALE, ENDURANCE, MOVE }

signal person_selected

func _ready():
	$Tabs.set_tab_title(0, tr('ABILITY'))
	$Tabs.set_tab_title(1, tr('INTERNAL'))
	

func _on_ArchitectureMenu_person_list_clicked(arch, persons: Array, action):
	current_action = action
	current_architecture = arch
	show_data(persons)


func show_data(person_list: Array):
	match current_action:
		Action.LIST: $Title.text = tr('PERSON_LIST')
		Action.AGRICULTURE: $Title.text = tr('AGRICULTURE')
		Action.COMMERCE: $Title.text = tr('COMMERCE')
		Action.MORALE: $Title.text = tr('MORALE')
		Action.ENDURANCE: $Title.text = tr('ENDURANCE')
	$SelectionButtons.visible = current_action != Action.LIST
	_populate_ability_data(person_list, current_action)
	_populate_internal_data(person_list, current_action)
	show()
	

func _populate_ability_data(person_list: Array, action):
	var item_list = $Tabs/Tab1/Grid as GridContainer
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 7
		item_list.add_child(_title(''))
	else:
		item_list.columns = 6
	item_list.add_child(_title(tr('NAME')))
	item_list.add_child(_title(tr('COMMAND')))
	item_list.add_child(_title(tr('STRENGTH')))
	item_list.add_child(_title(tr('INTELLIGENCE')))
	item_list.add_child(_title(tr('POLITICS')))
	item_list.add_child(_title(tr('GLAMOUR')))
	for person in person_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(person.id))
		item_list.add_child(_label(person.get_name()))
		item_list.add_child(_label(str(person.command)))
		item_list.add_child(_label(str(person.strength)))
		item_list.add_child(_label(str(person.intelligence)))
		item_list.add_child(_label(str(person.politics)))
		item_list.add_child(_label(str(person.glamour)))
		
func _populate_internal_data(person_list: Array, action):
	var item_list = $Tabs/Tab2/Grid as GridContainer
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 7
		item_list.add_child(_title(''))
	else:
		item_list.columns = 6
	item_list.add_child(_title(tr('NAME')))
	item_list.add_child(_title(tr('TASK')))
	item_list.add_child(_title(tr('AGRICULTURE_ABILITY')))
	item_list.add_child(_title(tr('COMMERCE_ABILITY')))
	item_list.add_child(_title(tr('MORALE_ABILITY')))
	item_list.add_child(_title(tr('ENDURANCE_ABILITY')))
	for person in person_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(person.id))
		item_list.add_child(_label(person.get_name()))
		item_list.add_child(_label(str(person.get_working_task_str())))
		item_list.add_child(_label(str(round(person.get_agriculture_ability()))))
		item_list.add_child(_label(str(round(person.get_commerce_ability()))))
		item_list.add_child(_label(str(round(person.get_morale_ability()))))
		item_list.add_child(_label(str(round(person.get_endurance_ability()))))


func _on_Confirm_pressed():
	var selected = _get_selected_list()
	var task
	match current_action:
		Action.AGRICULTURE: 
			task = Person.Task.AGRICULTURE
			emit_signal("person_selected", current_action, current_architecture, selected)
		Action.COMMERCE: 
			task = Person.Task.COMMERCE
			emit_signal("person_selected", current_action, current_architecture, selected)
		Action.MORALE: 
			task = Person.Task.MORALE
			emit_signal("person_selected", current_action, current_architecture, selected)
		Action.ENDURANCE: 
			task = Person.Task.ENDURANCE
			emit_signal("person_selected", current_action, current_architecture, selected)
		Action.MOVE: 
			task = Person.Task.MOVE
			emit_signal("person_selected", current_action, current_architecture, selected)
	._on_Confirm_pressed()

