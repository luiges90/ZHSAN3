extends TabList
class_name PersonList

enum Action { 
	LIST, 
	AGRICULTURE, 
	COMMERCE, 
	MORALE, 
	ENDURANCE, 
	MOVE, 
	CALL, 
	RECRUIT_TROOP, 
	TRAIN_TROOP, 
	PRODUCE_EQUIPMENT,
	SELECT_TROOP_PERSON,
	SELECT_TROOP_LEADER
}

signal person_selected
signal person_row_clicked

var _detail_showing = false

func _ready():
	$Tabs.set_tab_title(0, tr('BASIC'))
	$Tabs.set_tab_title(1, tr('ABILITY'))
	$Tabs.set_tab_title(2, tr('INTERNAL'))
	$Tabs.set_tab_title(3, tr('MILITARY'))
	
func handle_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			if _detail_showing:
				_detail_showing = false
			else:
				.handle_input(event)


func _on_ArchitectureMenu_person_list_clicked(arch, persons: Array, action):
	current_action = action
	current_architecture = arch
	show_data(persons)


func show_data(person_list: Array):
	match current_action:
		Action.LIST: 
			$Title.text = tr('PERSON_LIST')
			_max_selection = 0
		Action.AGRICULTURE: 
			$Title.text = tr('AGRICULTURE')
			_max_selection = -1
		Action.COMMERCE: 
			$Title.text = tr('COMMERCE')
			_max_selection = -1
		Action.MORALE: 
			$Title.text = tr('MORALE')
			_max_selection = -1
		Action.ENDURANCE: 
			$Title.text = tr('ENDURANCE')
			_max_selection = -1
		Action.MOVE: 
			$Title.text = tr('MOVE')
			_max_selection = -1
		Action.CALL: 
			$Title.text = tr('CALL')
			_max_selection = -1
		Action.RECRUIT_TROOP:
			$Title.text = tr('RECRUIT_TROOP')
			_max_selection = -1
		Action.TRAIN_TROOP:
			$Title.text = tr('TRAIN_TROOP')
			_max_selection = -1
		Action.PRODUCE_EQUIPMENT:
			$Title.text = tr('PRODUCE_EQUIPMENT')
			_max_selection = -1
		Action.SELECT_TROOP_PERSON:
			$Title.text = tr('SELECT_TROOP_PERSON')
			_max_selection = 3
		Action.SELECT_TROOP_LEADER:
			$Title.text = tr('SELECT_TROOP_LEADER')
			_max_selection = 1
	$SelectionButtons.visible = _max_selection != 0

	_populate_basic_data(person_list, current_action)
	_populate_ability_data(person_list, current_action)
	_populate_internal_data(person_list, current_action)
	_populate_military_data(person_list, current_action)
	show()
	

func _populate_basic_data(person_list: Array, action):
	var item_list = $Tabs/Tab1/Grid as GridContainer
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 8
		item_list.add_child(_title(''))
	else:
		item_list.columns = 7
	item_list.add_child(_title(tr('PERSON_NAME')))
	item_list.add_child(_title(tr('BELONGED_ARCHITECTURE')))
	item_list.add_child(_title(tr('STATUS')))
	item_list.add_child(_title(tr('POPULARITY')))
	item_list.add_child(_title(tr('KARMA')))
	item_list.add_child(_title(tr('TASK')))
	item_list.add_child(_title(tr('TASK_DAYS')))
	for person in person_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(person.id))
		item_list.add_child(_clickable_label(person.get_name(), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(person.get_location().get_name(), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(person.get_status_str(), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.get_popularity()), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.get_karma()), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(person.get_working_task_str(), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.task_days) + tr('DAY_UNIT'), self, "__on_clickable_label_click", person))

func _populate_ability_data(person_list: Array, action):
	var item_list = $Tabs/Tab2/Grid as GridContainer
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 7
		item_list.add_child(_title(''))
	else:
		item_list.columns = 6
	item_list.add_child(_title(tr('PERSON_NAME')))
	item_list.add_child(_title(tr('COMMAND')))
	item_list.add_child(_title(tr('STRENGTH')))
	item_list.add_child(_title(tr('INTELLIGENCE')))
	item_list.add_child(_title(tr('POLITICS')))
	item_list.add_child(_title(tr('GLAMOUR')))
	for person in person_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(person.id))
		item_list.add_child(_clickable_label(person.get_name(), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.get_command()), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.get_strength()), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.get_intelligence()), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.get_politics()), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.get_glamour()), self, "__on_clickable_label_click", person))
		
func _populate_internal_data(person_list: Array, action):
	var item_list = $Tabs/Tab3/Grid as GridContainer
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 7
		item_list.add_child(_title(''))
	else:
		item_list.columns = 6
	item_list.add_child(_title(tr('PERSON_NAME')))
	item_list.add_child(_title(tr('TASK')))
	item_list.add_child(_title(tr('AGRICULTURE_ABILITY')))
	item_list.add_child(_title(tr('COMMERCE_ABILITY')))
	item_list.add_child(_title(tr('MORALE_ABILITY')))
	item_list.add_child(_title(tr('ENDURANCE_ABILITY')))
	for person in person_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(person.id))
		item_list.add_child(_clickable_label(person.get_name(), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(person.get_working_task_str(), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(round(person.get_agriculture_ability())), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(round(person.get_commerce_ability())), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(round(person.get_morale_ability())), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(round(person.get_endurance_ability())), self, "__on_clickable_label_click", person))
		
		
func _populate_military_data(person_list: Array, action):
	var item_list = $Tabs/Tab4/Grid as GridContainer
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 7
		item_list.add_child(_title(''))
	else:
		item_list.columns = 6
	item_list.add_child(_title(tr('PERSON_NAME')))
	item_list.add_child(_title(tr('TASK')))
	item_list.add_child(_title(tr('PRODUCING_EQUIPMENT_TYPE')))
	item_list.add_child(_title(tr('RECRUIT_ABILITY')))
	item_list.add_child(_title(tr('TRAIN_ABILITY')))
	item_list.add_child(_title(tr('PRODUCE_EQUIPMENT_ABILITY')))
	for person in person_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(person.id))
		item_list.add_child(_clickable_label(person.get_name(), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(person.get_working_task_str(), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(person.get_producing_equipment_name(), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(round(person.get_recruit_troop_ability())), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(round(person.get_train_troop_ability())), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(round(person.get_produce_equipment_ability())), self, "__on_clickable_label_click", person))


func _on_Confirm_pressed():
	var selected = _get_selected_list()
	emit_signal("person_selected", current_action, current_architecture, selected)
	._on_Confirm_pressed()


func _on_CreateTroop_select_person(arch, persons):
	current_action = Action.SELECT_TROOP_PERSON
	current_architecture = arch
	show_data(persons)


func _on_CreateTroop_select_leader(arch, persons):
	current_action = Action.SELECT_TROOP_LEADER
	current_architecture = arch
	show_data(persons)


func __on_clickable_label_click(label, person):
	emit_signal('person_row_clicked', person)
	_detail_showing = true
