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

# table sorting 
var _sorting_order = ""
const _TYPE_ORDER = [TYPE_STRING, TYPE_INT]
var _clicked_label = ""

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
	$SelectionButtons.visible = _max_selection != 0

	_populate_basic_data(person_list, current_action)
	_populate_ability_data(person_list, current_action)
	_populate_internal_data(person_list, current_action)
	_populate_military_data(person_list, current_action)
	show()
	

func _populate_basic_data(person_list: Array, action):
	var item_list = $Tabs/Tab1/Grid as GridContainer
	var sorted_list = person_list # sorted person list
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 10
		item_list.add_child(_title(''))
	else:
		item_list.columns = 9
	item_list.add_child(_title_sorting(tr('PERSON_NAME'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('BELONGED_ARCHITECTURE'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('STATUS'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('MERIT'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('POPULARITY'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('PRESTIGE'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('KARMA'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('TASK'), self, "_on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('TASK_DAYS'), self, "_on_title_sorting_click", person_list))
	if _sorting_order != "":
		sorted_list = _sorting_list(person_list.duplicate())
	for person in sorted_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(person.id))
		item_list.add_child(_clickable_label(person.get_name(), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(person.get_location().get_name(), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(person.get_status_str(), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.get_merit()), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.get_popularity()), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.get_prestige()), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.get_karma()), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(person.get_working_task_str(), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.task_days) + tr('DAY_UNIT'), self, "__on_clickable_label_click", person))

func _populate_ability_data(person_list: Array, action):
	var item_list = $Tabs/Tab2/Grid as GridContainer
	var sorted_list = person_list # sorted person list
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
	if _sorting_order != "":
		sorted_list = _sorting_list(person_list.duplicate())
	for person in sorted_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(person.id))
		item_list.add_child(_clickable_label(person.get_name(), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.get_command()), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.get_strength()), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.get_intelligence()), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.get_politics()), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.get_glamour()), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.command_exp), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.strength_exp), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.intelligence_exp), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.politics_exp), self, "__on_clickable_label_click", person))
		item_list.add_child(_clickable_label(str(person.glamour_exp), self, "__on_clickable_label_click", person))
		
func _populate_internal_data(person_list: Array, action):
	var item_list = $Tabs/Tab3/Grid as GridContainer
	var sorted_list = person_list # sorted person list
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
	if _sorting_order != "":
		sorted_list = _sorting_list(person_list.duplicate())
	for person in sorted_list:
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
	var sorted_list = person_list # sorted person list
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
	if _sorting_order != "":
		sorted_list = _sorting_list(person_list.duplicate())
	for person in sorted_list:
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

func _on_TroopMenu_troop_person_clicked(troop):
	current_action = Action.LIST
	show_data(troop.get_persons())
	

func _on_title_sorting_click(label, object):
	# get clicked title
	_clicked_label = label.text
	# click again to change ordering
	if _sorting_order == "desc":
		_sorting_order = "asc"
	else:
		_sorting_order = "desc"
	# update the list
	show_data(object)	

# sort the list
func _sorting_list(person_list_copy):	
	var sort_list = []
	if person_list_copy.size() != 0:
		person_list_copy.sort_custom(self,"_custom_comparison")
		# default comparison is in ascending order
		if _sorting_order == "desc":
			person_list_copy.invert()
	return person_list_copy
	
# get value that need to be compared
func _get_compare_value(a, b):
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
	elif _clicked_label == tr("MERIT"):
		a1 = a.get_merit()
		b1 = b.get_merit()
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
	return [a1, b1]
	
# ascending comparison
func _custom_comparison(a, b):
	var a1 = _get_compare_value(a, b)[0]
	var b1 = _get_compare_value(a, b)[1]
	# actual comparison
	if typeof(a1) != typeof(b1):
		if typeof(a1) in _TYPE_ORDER and typeof(b1) in _TYPE_ORDER:
			return _TYPE_ORDER.find( typeof(a1) ) < _TYPE_ORDER.find( typeof(b1) )
		else:
			return typeof(a1) < typeof(b1)
	else:
		return a1 < b1
