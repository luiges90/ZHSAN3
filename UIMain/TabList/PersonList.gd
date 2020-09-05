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
	SELECT_TROOP_LEADER,
	SELECT_ADVISOR
}

signal person_selected
signal person_row_clicked

# sorted person list
var _sorted_list

var _detail_showing = false

func _ready():
	$Tabs.set_tab_title(0, tr('BASIC'))
	$Tabs.set_tab_title(1, tr('ABILITY'))
	$Tabs.set_tab_title(2, tr('INTERNAL'))
	$Tabs.set_tab_title(3, tr('MILITARY'))
	$Tabs.set_tab_title(4, tr('PERSONAL_RELATIONS'))
	self.connect("single_pressed_signal", self, "__on_clickable_label_click")
	self.connect("long_pressed_signal", self, "__on_clickable_label_long_pressed")
	
func handle_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			if _detail_showing:
				_detail_showing = false
			else:
				.handle_input(event)


func _on_InfoMenu_persons_clicked(scenario):
	current_action = Action.LIST
	show_data(scenario.get_living_persons())


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
		Action.SELECT_ADVISOR:
			$Title.text = tr('ASSIGN_ADVISOR')
			_max_selection = 1
	$SelectionButtons.visible = _max_selection != 0

	_selected_table = "person_list" 
	_populate_basic_data(person_list, current_action)
	_populate_ability_data(person_list, current_action)
	_populate_internal_data(person_list, current_action)
	_populate_military_data(person_list, current_action)
	_populate_personal_relation_data(person_list, current_action)
	show()
	

func _populate_basic_data(person_list: Array, action):
	var item_list = $Tabs/Tab1/Grid as GridContainer
	_sorted_list = person_list # default person list
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 12
		item_list.add_child(_title(''))
	else:
		item_list.columns = 11
	item_list.add_child(_title_sorting(tr('PERSON_NAME'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('BELONGED_ARCHITECTURE'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('STATUS'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('GENDER'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('AGE'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('MERIT'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('POPULARITY'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('PRESTIGE'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('KARMA'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('TASK'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('TASK_DAYS'), self, "_on_title_sorting_click", person_list))
	match _current_order:
		_sorting_order.DESC:
			_sorted_list = _sorting_list(person_list.duplicate())
		_sorting_order.ASC:
			_sorted_list = _sorting_list(person_list.duplicate())
	for person in _sorted_list:
		var checkbox = _checkbox(person.id)
		if action != Action.LIST:
			item_list.add_child(checkbox)
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_name(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_location().get_name(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_status_str(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_gender_str(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_age()), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_merit()), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_popularity()), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_prestige()), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_karma()), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_working_task_str(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.task_days) + tr('DAY_UNIT'), self, person, checkbox))

func _populate_ability_data(person_list: Array, action):
	var item_list = $Tabs/Tab2/Grid as GridContainer
	_sorted_list = person_list # default person list
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 12
		item_list.add_child(_title(''))
	else:
		item_list.columns = 11
	item_list.add_child(_title_sorting(tr('PERSON_NAME'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('COMMAND'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('STRENGTH'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('INTELLIGENCE'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('POLITICS'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('GLAMOUR'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('COMMAND_EXPERIENCE'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('STRENGTH_EXPERIENCE'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('INTELLIGENCE_EXPERIENCE'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('POLITICS_EXPERIENCE'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('GLAMOUR_EXPERIENCE'), self, "_on_title_sorting_click", person_list))
	match _current_order:
		_sorting_order.DESC:
			_sorted_list = _sorting_list(person_list.duplicate())
		_sorting_order.ASC:
			_sorted_list = _sorting_list(person_list.duplicate())
	for person in _sorted_list:
		var checkbox = _checkbox(person.id)
		if action != Action.LIST:
			item_list.add_child(checkbox)
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_name(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_command()), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_strength()), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_intelligence()), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_politics()), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_glamour()), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.command_exp), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.strength_exp), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.intelligence_exp), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.politics_exp), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.glamour_exp), self, person, checkbox))
		
func _populate_internal_data(person_list: Array, action):
	var item_list = $Tabs/Tab3/Grid as GridContainer
	_sorted_list = person_list # default person list
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 7
		item_list.add_child(_title(''))
	else:
		item_list.columns = 6
	item_list.add_child(_title_sorting(tr('PERSON_NAME'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('TASK'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('AGRICULTURE_ABILITY'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('COMMERCE_ABILITY'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('MORALE_ABILITY'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('ENDURANCE_ABILITY'), self, "_on_title_sorting_click", person_list))
	match _current_order:
		_sorting_order.DESC:
			_sorted_list = _sorting_list(person_list.duplicate())
		_sorting_order.ASC:
			_sorted_list = _sorting_list(person_list.duplicate())
	for person in _sorted_list:
		var checkbox = _checkbox(person.id)
		if action != Action.LIST:
			item_list.add_child(checkbox)
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_name(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_working_task_str(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(round(person.get_agriculture_ability())), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(round(person.get_commerce_ability())), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(round(person.get_morale_ability())), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(round(person.get_endurance_ability())), self, person, checkbox))
		
		
func _populate_military_data(person_list: Array, action):
	var item_list = $Tabs/Tab4/Grid as GridContainer
	_sorted_list = person_list # default person list
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 7
		item_list.add_child(_title(''))
	else:
		item_list.columns = 6
	item_list.add_child(_title_sorting(tr('PERSON_NAME'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('TASK'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('PRODUCING_EQUIPMENT_TYPE'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('RECRUIT_ABILITY'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('TRAIN_ABILITY'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('PRODUCE_EQUIPMENT_ABILITY'), self, "_on_title_sorting_click", person_list))
	match _current_order:
		_sorting_order.DESC:
			_sorted_list = _sorting_list(person_list.duplicate())
		_sorting_order.ASC:
			_sorted_list = _sorting_list(person_list.duplicate())
	for person in _sorted_list:
		var checkbox = _checkbox(person.id)
		if action != Action.LIST:
			item_list.add_child(checkbox)
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_name(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_working_task_str(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_producing_equipment_name(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(round(person.get_recruit_troop_ability())), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(round(person.get_train_troop_ability())), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(round(person.get_produce_equipment_ability())), self, person, checkbox))

func _populate_personal_relation_data(person_list: Array, action):
	var item_list = $Tabs/Tab5/Grid as GridContainer
	var sorted_list = person_list # sorted person list
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 6
		item_list.add_child(_title(''))
	else:
		item_list.columns = 5
	item_list.add_child(_title_sorting(tr('PERSON_NAME'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('FATHER'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('MOTHER'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('SPOUSE'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('BROTHER'), self, "_on_title_sorting_click", person_list))
	match _current_order:
		_sorting_order.DESC:
			_sorted_list = _sorting_list(person_list.duplicate())
		_sorting_order.ASC:
			_sorted_list = _sorting_list(person_list.duplicate())
	for person in _sorted_list:
		var checkbox = _checkbox(person.id)
		if action != Action.LIST:
			item_list.add_child(checkbox)
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_name(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_father_name(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_mother_name(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_spouse_names(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_brother_names(), self, person, checkbox))
		

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

func __on_clickable_label_long_pressed(label, receiver, object, checkbox):
	if receiver == self:
		emit_signal('person_row_clicked', object)
		_detail_showing = true

func __on_clickable_label_click(label, receiver, object, checkbox):
	if receiver == self:
		if checkbox != null:
			_checkbox_change_status(checkbox)

func _on_TroopMenu_troop_person_clicked(troop):
	current_action = Action.LIST
	show_data(troop.get_persons())
	
