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
	SELECT_ADVISOR,
	CONVINCE_TARGET,
	CONVINCE_PERSON
}

signal person_selected
signal person_row_clicked

# sorted person list
var _sorted_list

var _detail_showing = false

var _previously_selected_person_ids = []

func _ready():
	_add_tab('BASIC')
	_add_tab('ABILITY')
	_add_tab('INTERNAL')
	_add_tab('MILITARY')
	_add_tab('COMBAT_EXPERIENCE')
	_add_tab('PERSONAL_RELATIONS')

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
	.show_data(person_list)
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
		Action.CONVINCE_TARGET:
			$Title.text = tr('CONVINCE_TARGET')
			_max_selection = 1
		Action.CONVINCE_PERSON:
			$Title.text = tr('CONVINCE_PERSON')
			_max_selection = 1
	$SelectionButtons.visible = _max_selection != 0

	_selected_table = "person_list" 
	_populate_relevant_data(person_list, current_action)
	_populate_basic_data(person_list, current_action)
	_populate_ability_data(person_list, current_action)
	_populate_internal_data(person_list, current_action)
	_populate_military_data(person_list, current_action)
	_populate_combat_experience_data(person_list, current_action)
	_populate_personal_relation_data(person_list, current_action)
	
	show()
	._post_show()
	
func _populate_relevant_data(person_list: Array, action):
	match current_action:
		Action.CONVINCE_TARGET:
			_add_tab('RELEVANCE', 0)
			
			var item_list = tabs['RELEVANCE'] as GridContainer
			_sorted_list = person_list # default person list
			Util.delete_all_children(item_list)
			
			item_list.columns = 12
			item_list.add_child(_title(''))
			item_list.add_child(_title_sorting(tr('PERSON_NAME'), self, "_on_title_sorting_click", person_list))
			item_list.add_child(_title_sorting(tr('LOCATION'), self, "_on_title_sorting_click", person_list))
			item_list.add_child(_title_sorting(tr('STATUS'), self, "_on_title_sorting_click", person_list))
			item_list.add_child(_title_sorting(tr('GENDER'), self, "_on_title_sorting_click", person_list))
			item_list.add_child(_title_sorting(tr('AGE'), self, "_on_title_sorting_click", person_list))
			item_list.add_child(_title_sorting(tr('LOYALTY'), self, "_on_title_sorting_click", person_list))
			item_list.add_child(_title_sorting(tr('MERIT'), self, "_on_title_sorting_click", person_list))
			item_list.add_child(_title_sorting(tr('POPULARITY'), self, "_on_title_sorting_click", person_list))
			item_list.add_child(_title_sorting(tr('PRESTIGE'), self, "_on_title_sorting_click", person_list))
			item_list.add_child(_title_sorting(tr('KARMA'), self, "_on_title_sorting_click", person_list))
			item_list.add_child(_title_sorting(tr('ETA'), self, "_on_title_sorting_click", person_list))
			
			match _current_order:
				_sorting_order.DESC:
					_sorted_list = _sorting_list(person_list.duplicate())
				_sorting_order.ASC:
					_sorted_list = _sorting_list(person_list.duplicate())
			
			for person in _sorted_list:
				var checkbox = _checkbox(person.id)
				item_list.add_child(checkbox)
				item_list.add_child(_clickable_label_with_long_pressed_event(person.get_name(), self, person, checkbox))
				item_list.add_child(_clickable_label_with_long_pressed_event(person.get_location().get_name(), self, person, checkbox))
				item_list.add_child(_clickable_label_with_long_pressed_event(person.get_status_str(), self, person, checkbox))
				item_list.add_child(_clickable_label_with_long_pressed_event(person.get_gender_str(), self, person, checkbox))
				item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_age()), self, person, checkbox))
				item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_loyalty()), self, person, checkbox))
				item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_merit()), self, person, checkbox))
				item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_popularity()), self, person, checkbox))
				item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_prestige()), self, person, checkbox))
				item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_karma()), self, person, checkbox))
				item_list.add_child(_clickable_label_with_long_pressed_event(str(current_architecture.move_eta(person.get_location()) * 2) + tr('DAY_UNIT'), self, person, checkbox))
			
		Action.CONVINCE_PERSON:
			_add_tab('RELEVANCE', 0)
			
			var item_list = tabs['RELEVANCE'] as GridContainer
			_sorted_list = person_list # default person list
			Util.delete_all_children(item_list)
			
			item_list.columns = 6
			item_list.add_child(_title(''))
			item_list.add_child(_title_sorting(tr('PERSON_NAME'), self, "_on_title_sorting_click", person_list))
			item_list.add_child(_title_sorting(tr('BELONGED_ARCHITECTURE'), self, "_on_title_sorting_click", person_list))
			item_list.add_child(_title_sorting(tr('ADVISOR_RECOMMENDED'), self, "_on_title_sorting_click", person_list))
			item_list.add_child(_title_sorting(tr('SUCCESS_RATE'), self, "_on_title_sorting_click", person_list))
			item_list.add_child(_title_sorting(tr('CONVINCE_ABILITY'), self, "_on_title_sorting_click", person_list))
			
			match _current_order:
				_sorting_order.DESC:
					_sorted_list = _sorting_list(person_list.duplicate())
				_sorting_order.ASC:
					_sorted_list = _sorting_list(person_list.duplicate())
			
			var other_person = person_list[0].scenario.persons[_previously_selected_person_ids[0]]
			for person in _sorted_list:
				var checkbox = _checkbox(person.id)
				item_list.add_child(checkbox)
				item_list.add_child(_clickable_label_with_long_pressed_event(person.get_name(), self, person, checkbox))
				item_list.add_child(_clickable_label_with_long_pressed_event(person.get_location().get_name(), self, person, checkbox))
				item_list.add_child(_clickable_label_with_long_pressed_event(Util.bstr(person.convince_recommended(other_person)), self, person, checkbox))
				item_list.add_child(_clickable_label_with_long_pressed_event(str(person.displayed_convince_probability(other_person)) + "%", self, person, checkbox))
				item_list.add_child(_clickable_label_with_long_pressed_event(str(round(person.get_convince_ability())), self, person, checkbox))

		_:
			_remove_tab('RELEVANCE')

		

func _populate_basic_data(person_list: Array, action):
	var item_list = tabs['BASIC'] as GridContainer
	_sorted_list = person_list # default person list
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 13
		item_list.add_child(_title(''))
	else:
		item_list.columns = 12
	item_list.add_child(_title_sorting(tr('PERSON_NAME'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('LOCATION'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('STATUS'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('GENDER'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('AGE'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('LOYALTY'), self, "_on_title_sorting_click", person_list))
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
		var checkbox = null
		if action != Action.LIST:
			checkbox = _checkbox(person.id)
			item_list.add_child(checkbox)
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_name(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_location().get_name(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_status_str(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_gender_str(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_age()), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_loyalty()), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_merit()), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_popularity()), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_prestige()), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_karma()), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_working_task_str(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.task_days) + tr('DAY_UNIT'), self, person, checkbox))

func _populate_ability_data(person_list: Array, action):
	var item_list = tabs['ABILITY'] as GridContainer
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
		var checkbox = null
		if action != Action.LIST:
			checkbox = _checkbox(person.id)
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
	var item_list = tabs['INTERNAL'] as GridContainer
	_sorted_list = person_list # default person list
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 8
		item_list.add_child(_title(''))
	else:
		item_list.columns = 7
	item_list.add_child(_title_sorting(tr('PERSON_NAME'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('TASK'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('INTERNAL_EXPERIENCE'), self, "_on_title_sorting_click", person_list))
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
		var checkbox = null
		if action != Action.LIST:
			checkbox = _checkbox(person.id)
			item_list.add_child(checkbox)
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_name(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_working_task_str(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.internal_exp), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(round(person.get_agriculture_ability())), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(round(person.get_commerce_ability())), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(round(person.get_morale_ability())), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(round(person.get_endurance_ability())), self, person, checkbox))
		
		
func _populate_military_data(person_list: Array, action):
	var item_list = tabs['MILITARY'] as GridContainer
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
		var checkbox = null
		if action != Action.LIST:
			checkbox = _checkbox(person.id)
			item_list.add_child(checkbox)
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_name(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_working_task_str(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_producing_equipment_name(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(round(person.get_recruit_troop_ability())), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(round(person.get_train_troop_ability())), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(round(person.get_produce_equipment_ability())), self, person, checkbox))


func _populate_combat_experience_data(person_list: Array, action):
	var item_list = tabs['COMBAT_EXPERIENCE'] as GridContainer
	_sorted_list = person_list # default person list
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 14
		item_list.add_child(_title(''))
	else:
		item_list.columns = 13
	item_list.add_child(_title_sorting(tr('PERSON_NAME'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('COMBAT_EXPERIENCE'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('INFANTRY_EXPERIENCE'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('BOWMAN_EXPERIENCE'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('CALVARY_EXPERIENCE'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('SIEGE_WEAPON_EXPERIENCE'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('TROOP_DAMAGE_DEALT'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('TROOP_DAMAGE_RECEIVED'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('ARCH_DAMAGE_DEALT'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('ROUT_COUNT'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('ROUTED_COUNT'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('CAPTURE_COUNT'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('BE_CAPTURED_COUNT'), self, "_on_title_sorting_click", person_list))
	match _current_order:
		_sorting_order.DESC:
			_sorted_list = _sorting_list(person_list.duplicate())
		_sorting_order.ASC:
			_sorted_list = _sorting_list(person_list.duplicate())
	for person in _sorted_list:
		var checkbox = null
		if action != Action.LIST:
			checkbox = _checkbox(person.id)
			item_list.add_child(checkbox)
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_name(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.combat_exp), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_military_type_experience(MilitaryKind.MilitaryType.INFANTRY)), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_military_type_experience(MilitaryKind.MilitaryType.BOWMAN)), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_military_type_experience(MilitaryKind.MilitaryType.CALVARY)), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.get_military_type_experience(MilitaryKind.MilitaryType.SIEGE)), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.troop_damage_dealt), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.troop_damage_received), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.arch_damage_dealt), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.rout_count), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.routed_count), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.capture_count), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(person.be_captured_count), self, person, checkbox))


func _populate_personal_relation_data(person_list: Array, action):
	var item_list = tabs['PERSONAL_RELATIONS'] as GridContainer
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
		var checkbox = null
		if action != Action.LIST:
			checkbox = _checkbox(person.id)
			item_list.add_child(checkbox)
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_name(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_father_name(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_mother_name(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_spouse_names(), self, person, checkbox))
		item_list.add_child(_clickable_label_with_long_pressed_event(person.get_brother_names(), self, person, checkbox))
		
func __get_compare_value(_clicked_label, a, b):
	var a1 = ""
	var b1 = ""
	if _clicked_label == tr("PERSON_NAME"):
		a1 = a.get_name()
		b1 = b.get_name()
	elif _clicked_label == tr("BELONGED_ARCHITECTURE"):
		a1 = a.get_location().get_name()
		b1 = b.get_location().get_name()
	elif _clicked_label == tr("STATUS"):
		a1 = a.get_status_str()
		b1 = b.get_status_str()
	elif _clicked_label == tr("GENDER"):
		a1 = a.get_gender_str()
		b1 = b.get_gender_str()
	elif _clicked_label == tr("AGE"):
		a1 = a.get_age()
		b1 = b.get_age()
	elif _clicked_label == tr("MERIT"):
		a1 = a.get_merit()
		b1 = b.get_merit()
	elif _clicked_label == tr("LOYALTY"):
		a1 = a.get_loyalty()
		b1 = b.get_loyalty()
	elif _clicked_label == tr("POPULARITY"):
		a1 = a.get_popularity()
		b1 = b.get_popularity()
	elif _clicked_label == tr("PRESTIGE"):
		a1 = a.get_prestige()
		b1 = b.get_prestige()
	elif _clicked_label == tr("KARMA"):
		a1 = a.get_karma()
		b1 = b.get_karma()
	elif _clicked_label == tr("TASK"):
		a1 = a.get_working_task_str()
		b1 = b.get_working_task_str()
	elif _clicked_label == tr("TASK_DAYS"):
		a1 = a.task_days
		b1 = b.task_days
	elif _clicked_label == tr("COMMAND"):
		a1 = a.get_command()
		b1 = b.get_command()
	elif _clicked_label == tr("STRENGTH"):
		a1 = a.get_strength()
		b1 = b.get_strength()
	elif _clicked_label == tr("INTELLIGENCE"):
		a1 = a.get_intelligence()
		b1 = b.get_intelligence()
	elif _clicked_label == tr("POLITICS"):
		a1 = a.get_politics()
		b1 = b.get_politics()
	elif _clicked_label == tr("GLAMOUR"):
		a1 = a.get_glamour()
		b1 = b.get_glamour()
	elif _clicked_label == tr("COMMAND_EXPERIENCE"):
		a1 = a.command_exp
		b1 = b.command_exp
	elif _clicked_label == tr("STRENGTH_EXPERIENCE"):
		a1 = a.strength_exp
		b1 = b.strength_exp
	elif _clicked_label == tr("INTELLIGENCE_EXPERIENCE"):
		a1 = a.intelligence_exp
		b1 = b.intelligence_exp
	elif _clicked_label == tr("POLITICS_EXPERIENCE"):
		a1 = a.politics_exp
		b1 = b.politics_exp
	elif _clicked_label == tr("GLAMOUR_EXPERIENCE"):
		a1 = a.glamour_exp
		b1 = b.glamour_exp
	elif _clicked_label == tr("AGRICULTURE_ABILITY"):
		a1 = a.get_agriculture_ability()
		b1 = b.get_agriculture_ability()
	elif _clicked_label == tr("COMMERCE_ABILITY"):
		a1 = a.get_commerce_ability()
		b1 = b.get_commerce_ability()
	elif _clicked_label == tr("MORALE_ABILITY"):
		a1 = a.get_morale_ability()
		b1 = b.get_morale_ability()
	elif _clicked_label == tr("ENDURANCE_ABILITY"):
		a1 = a.get_endurance_ability()
		b1 = b.get_endurance_ability()
	elif _clicked_label == tr("PRODUCING_EQUIPMENT_TYPE"):
		a1 = a.get_producing_equipment_name()
		b1 = b.get_producing_equipment_name()
	elif _clicked_label == tr("RECRUIT_ABILITY"):
		a1 = a.get_recruit_troop_ability()
		b1 = b.get_recruit_troop_ability()
	elif _clicked_label == tr("TRAIN_ABILITY"):
		a1 = a.get_train_troop_ability()
		b1 = b.get_train_troop_ability()
	elif _clicked_label == tr("PRODUCE_EQUIPMENT_ABILITY"):
		a1 = a.get_produce_equipment_ability()
		b1 = b.get_produce_equipment_ability()
	elif _clicked_label == tr("FATHER"):
		a1 = a.get_father_name()
		b1 = b.get_father_name()
	elif _clicked_label == tr("MOTHER"):
		a1 = a.get_mother_name()
		b1 = b.get_mother_name()
	elif _clicked_label == tr("SPOUSE"):
		a1 = a.get_spouse_names()
		b1 = b.get_spouse_names()
	elif _clicked_label == tr("BROTHER"):
		a1 = a.get_brother_names()
		b1 = b.get_brother_names()
	elif _clicked_label == tr("ETA"):
		a1 = current_architecture.move_eta(a.get_location())
		b1 = current_architecture.move_eta(b.get_location())
	elif _clicked_label == tr("INTERNAL_EXPERIENCE"):
		a1 = a.internal_exp
		b1 = b.internal_exp
	elif _clicked_label == tr("COMBAT_EXPERIENCE"):
		a1 = a.combat_exp
		b1 = b.combat_exp
	elif _clicked_label == tr("INFANTRY_EXPERIENCE"):
		a1 = a.get_military_type_experience(MilitaryKind.MilitaryType.INFANTRY)
		b1 = b.get_military_type_experience(MilitaryKind.MilitaryType.INFANTRY)
	elif _clicked_label == tr("BOWMAN_EXPERIENCE"):
		a1 = a.get_military_type_experience(MilitaryKind.MilitaryType.BOWMAN)
		b1 = b.get_military_type_experience(MilitaryKind.MilitaryType.BOWMAN)
	elif _clicked_label == tr("CAVALRY_EXPERIENCE"):
		a1 = a.get_military_type_experience(MilitaryKind.MilitaryType.CAVALRY)
		b1 = b.get_military_type_experience(MilitaryKind.MilitaryType.CAVALRY)
	elif _clicked_label == tr("SIEGE_WEAPON_EXPERIENCE"):
		a1 = a.get_military_type_experience(MilitaryKind.MilitaryType.SIEGE)
		b1 = b.get_military_type_experience(MilitaryKind.MilitaryType.SIEGE)
	return [a1, b1]

func _on_Confirm_pressed():
	var selected = _get_selected_list()
	match current_action:
		Action.CONVINCE_TARGET: 
			current_action = Action.CONVINCE_PERSON
			_previously_selected_person_ids = selected
			show_data(current_architecture.get_workable_persons())
		Action.CONVINCE_PERSON:
			call_deferred("emit_signal", "person_selected", current_action, current_architecture, selected, {"target": _previously_selected_person_ids[0]})
			$PersonMove.play()
			._on_Confirm_pressed()
		_:
			call_deferred("emit_signal", "person_selected", current_action, current_architecture, selected)
			$ConfirmSound.play()
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
		call_deferred("emit_signal", 'person_row_clicked', object)
		_detail_showing = true

func __on_clickable_label_click(label, receiver, object, checkbox):
	if receiver == self:
		if checkbox != null:
			_checkbox_change_status(checkbox)

func _on_TroopMenu_troop_person_clicked(troop):
	current_action = Action.LIST
	show_data(troop.get_persons())
	
