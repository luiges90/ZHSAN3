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
var sorting_order = ""
const TypeOrder = [TYPE_STRING, TYPE_INT]
var clicked_label = ""

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
	item_list.add_child(_title_sorting(tr('PERSON_NAME'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('BELONGED_ARCHITECTURE'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('STATUS'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('MERIT'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('POPULARITY'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('PRESTIGE'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('KARMA'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('TASK'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('TASK_DAYS'), self, "__on_title_sorting_click", person_list))
	if sorting_order != "":
		sorted_list = sorting_list(person_list.duplicate())
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
	item_list.add_child(_title_sorting(tr('PERSON_NAME'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('COMMAND'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('STRENGTH'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('INTELLIGENCE'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('POLITICS'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('GLAMOUR'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('COMMAND_EXPERIENCE'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('STRENGTH_EXPERIENCE'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('INTELLIGENCE_EXPERIENCE'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('POLITICS_EXPERIENCE'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('GLAMOUR_EXPERIENCE'), self, "__on_title_sorting_click", person_list))
	if sorting_order != "":
		sorted_list = sorting_list(person_list.duplicate())
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
	item_list.add_child(_title_sorting(tr('PERSON_NAME'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('TASK'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('AGRICULTURE_ABILITY'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('COMMERCE_ABILITY'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('MORALE_ABILITY'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('ENDURANCE_ABILITY'), self, "__on_title_sorting_click", person_list))
	if sorting_order != "":
		sorted_list = sorting_list(person_list.duplicate())
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
	item_list.add_child(_title_sorting(tr('PERSON_NAME'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('TASK'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('PRODUCING_EQUIPMENT_TYPE'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('RECRUIT_ABILITY'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('TRAIN_ABILITY'), self, "__on_title_sorting_click", person_list))
	item_list.add_child(_title_sorting(tr('PRODUCE_EQUIPMENT_ABILITY'), self, "__on_title_sorting_click", person_list))
	if sorting_order != "":
		sorted_list = sorting_list(person_list.duplicate())
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
	

func __on_title_sorting_click(label, object):
	# get clicked title
	clicked_label = label.text
	# click again to change ordering
	if sorting_order == "desc":
		sorting_order = "asc"
	else:
		sorting_order = "desc"
	# update the list
	show_data(object)	

func sorting_list(person_list_copy):	
	var sort_list = []
	if person_list_copy.size() != 0:
		sort_list.append(person_list_copy.pop_front())
		if clicked_label == tr("PERSON_NAME"):
			for person in person_list_copy:
				var count = 0
				var list_sorted = false
				for item in sort_list:
					# if person added, switch to new one
					if list_sorted:
						break
					if sorting_order == "desc":
						if !customComparison(person.get_name(), item.get_name()):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
					elif sorting_order == "asc":
						if customComparison(person.get_name(), item.get_name()):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
		elif clicked_label == tr("BELONGED_ARCHITECTURE"):
			for person in person_list_copy:
				var count = 0
				var list_sorted = false
				for item in sort_list:
					# if person added, switch to new one
					if list_sorted:
						break
					if sorting_order == "desc":
						if !customComparison(person.get_location().get_name(), item.get_location().get_name()):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
					elif sorting_order == "asc":
						if customComparison(person.get_location().get_name(), item.get_location().get_name()):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
		elif clicked_label == tr("STATUS"):
			for person in person_list_copy:
				var count = 0
				var list_sorted = false
				for item in sort_list:
					# if person added, switch to new one
					if list_sorted:
						break
					if sorting_order == "desc":
						if !customComparison(person.get_status_str(), item.get_status_str()):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
					elif sorting_order == "asc":
						if customComparison(person.get_status_str(), item.get_status_str()):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
		elif clicked_label == tr("MERIT"):
			for person in person_list_copy:
				var count = 0
				var list_sorted = false
				for item in sort_list:
					# if person added, switch to new one
					if list_sorted:
						break
					if sorting_order == "desc":
						if !customComparison(person.get_merit(), item.get_merit()):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
					elif sorting_order == "asc":
						if customComparison(person.get_merit(), item.get_merit()):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
		elif clicked_label == tr("POPULARITY"):
			for person in person_list_copy:
				var count = 0
				var list_sorted = false
				for item in sort_list:
					# if person added, switch to new one
					if list_sorted:
						break
					if sorting_order == "desc":
						if !customComparison(person.get_popularity(), item.get_popularity()):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
					elif sorting_order == "asc":
						if customComparison(person.get_popularity(), item.get_popularity()):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
		elif clicked_label == tr("PRESTIGE"):
			for person in person_list_copy:
				var count = 0
				var list_sorted = false
				for item in sort_list:
					# if person added, switch to new one
					if list_sorted:
						break
					if sorting_order == "desc":
						if !customComparison(person.get_prestige(), item.get_prestige()):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
					elif sorting_order == "asc":
						if customComparison(person.get_prestige(), item.get_prestige()):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
		elif clicked_label == tr("KARMA"):
			for person in person_list_copy:
				var count = 0
				var list_sorted = false
				for item in sort_list:
					# if person added, switch to new one
					if list_sorted:
						break
					if sorting_order == "desc":
						if !customComparison(person.get_karma(), item.get_karma()):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
					elif sorting_order == "asc":
						if customComparison(person.get_karma(), item.get_karma()):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
		elif clicked_label == tr("TASK"):
			for person in person_list_copy:
				var count = 0
				var list_sorted = false
				for item in sort_list:
					# if person added, switch to new one
					if list_sorted:
						break
					if sorting_order == "desc":
						if !customComparison(person.get_working_task_str(), item.get_working_task_str()):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
					elif sorting_order == "asc":
						if customComparison(person.get_working_task_str(), item.get_working_task_str()):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
		elif clicked_label == tr("TASK_DAYS"):
			for person in person_list_copy:
				var count = 0
				var list_sorted = false
				for item in sort_list:
					# if person added, switch to new one
					if list_sorted:
						break
					if sorting_order == "desc":
						if !customComparison(person.task_days, item.task_days):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
					elif sorting_order == "asc":
						if customComparison(person.task_days, item.task_days):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
		elif clicked_label == tr("COMMAND"):
			for person in person_list_copy:
				var count = 0
				var list_sorted = false
				for item in sort_list:
					# if person added, switch to new one
					if list_sorted:
						break
					if sorting_order == "desc":
						if !customComparison(person.get_command(), item.get_command()):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
					elif sorting_order == "asc":
						if customComparison(person.get_command(), item.get_command()):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
		elif clicked_label == tr("STRENGTH"):
				for person in person_list_copy:
					var count = 0
					var list_sorted = false
					for item in sort_list:
						# if person added, switch to new one
						if list_sorted:
							break
						if sorting_order == "desc":
							if !customComparison(person.get_strength(), item.get_strength()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
						elif sorting_order == "asc":
							if customComparison(person.get_strength(), item.get_strength()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
		elif clicked_label == tr("INTELLIGENCE"):
				for person in person_list_copy:
					var count = 0
					var list_sorted = false
					for item in sort_list:
						# if person added, switch to new one
						if list_sorted:
							break
						if sorting_order == "desc":
							if !customComparison(person.get_intelligence(), item.get_intelligence()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
						elif sorting_order == "asc":
							if customComparison(person.get_intelligence(), item.get_intelligence()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
		elif clicked_label == tr("POLITICS"):
				for person in person_list_copy:
					var count = 0
					var list_sorted = false
					for item in sort_list:
						# if person added, switch to new one
						if list_sorted:
							break
						if sorting_order == "desc":
							if !customComparison(person.get_politics(), item.get_politics()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
						elif sorting_order == "asc":
							if customComparison(person.get_politics(), item.get_politics()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
		elif clicked_label == tr("GLAMOUR"):
				for person in person_list_copy:
					var count = 0
					var list_sorted = false
					for item in sort_list:
						# if person added, switch to new one
						if list_sorted:
							break
						if sorting_order == "desc":
							if !customComparison(person.get_glamour(), item.get_glamour()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
						elif sorting_order == "asc":
							if customComparison(person.get_glamour(), item.get_glamour()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
		elif clicked_label == tr("COMMAND_EXPERIENCE"):
				for person in person_list_copy:
					var count = 0
					var list_sorted = false
					for item in sort_list:
						# if person added, switch to new one
						if list_sorted:
							break
						if sorting_order == "desc":
							if !customComparison(person.command_exp, item.command_exp):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
						elif sorting_order == "asc":
							if customComparison(person.command_exp, item.command_exp):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
		elif clicked_label == tr("STRENGTH_EXPERIENCE"):
				for person in person_list_copy:
					var count = 0
					var list_sorted = false
					for item in sort_list:
						# if person added, switch to new one
						if list_sorted:
							break
						if sorting_order == "desc":
							if !customComparison(person.strength_exp, item.strength_exp):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
						elif sorting_order == "asc":
							if customComparison(person.strength_exp, item.strength_exp):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
		elif clicked_label == tr("INTELLIGENCE_EXPERIENCE"):
				for person in person_list_copy:
					var count = 0
					var list_sorted = false
					for item in sort_list:
						# if person added, switch to new one
						if list_sorted:
							break
						if sorting_order == "desc":
							if !customComparison(person.intelligence_exp, item.intelligence_exp):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
						elif sorting_order == "asc":
							if customComparison(person.intelligence_exp, item.intelligence_exp):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
		elif clicked_label == tr("POLITICS_EXPERIENCE"):
				for person in person_list_copy:
					var count = 0
					var list_sorted = false
					for item in sort_list:
						# if person added, switch to new one
						if list_sorted:
							break
						if sorting_order == "desc":
							if !customComparison(person.politics_exp, item.politics_exp):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
						elif sorting_order == "asc":
							if customComparison(person.politics_exp, item.politics_exp):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
		elif clicked_label == tr("GLAMOUR_EXPERIENCE"):
			for person in person_list_copy:
				var count = 0
				var list_sorted = false
				for item in sort_list:
					# if person added, switch to new one
					if list_sorted:
						break
					if sorting_order == "desc":
						if !customComparison(person.glamour_exp, item.glamour_exp):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
					elif sorting_order == "asc":
						if customComparison(person.glamour_exp, item.glamour_exp):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
		elif clicked_label == tr("AGRICULTURE_ABILITY"):
				for person in person_list_copy:
					var count = 0
					var list_sorted = false
					for item in sort_list:
						# if person added, switch to new one
						if list_sorted:
							break
						if sorting_order == "desc":
							if !customComparison(person.get_agriculture_ability(), item.get_agriculture_ability()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
						elif sorting_order == "asc":
							if customComparison(person.get_agriculture_ability(), item.get_agriculture_ability()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
		elif clicked_label == tr("COMMERCE_ABILITY"):
				for person in person_list_copy:
					var count = 0
					var list_sorted = false
					for item in sort_list:
						# if person added, switch to new one
						if list_sorted:
							break
						if sorting_order == "desc":
							if !customComparison(person.get_commerce_ability(), item.get_commerce_ability()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
						elif sorting_order == "asc":
							if customComparison(person.get_commerce_ability(), item.get_commerce_ability()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
		elif clicked_label == tr("MORALE_ABILITY"):
				for person in person_list_copy:
					var count = 0
					var list_sorted = false
					for item in sort_list:
						# if person added, switch to new one
						if list_sorted:
							break
						if sorting_order == "desc":
							if !customComparison(person.get_morale_ability(), item.get_morale_ability()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
						elif sorting_order == "asc":
							if customComparison(person.get_morale_ability(), item.get_morale_ability()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
		elif clicked_label == tr("ENDURANCE_ABILITY"):
				for person in person_list_copy:
					var count = 0
					var list_sorted = false
					for item in sort_list:
						# if person added, switch to new one
						if list_sorted:
							break
						if sorting_order == "desc":
							if !customComparison(person.get_endurance_ability(), item.get_endurance_ability()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
						elif sorting_order == "asc":
							if customComparison(person.get_endurance_ability(), item.get_endurance_ability()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
		elif clicked_label == tr("PRODUCING_EQUIPMENT_TYPE"):
				for person in person_list_copy:
					var count = 0
					var list_sorted = false
					for item in sort_list:
						# if person added, switch to new one
						if list_sorted:
							break
						if sorting_order == "desc":
							if !customComparison(person.get_producing_equipment_name(), item.get_producing_equipment_name()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
						elif sorting_order == "asc":
							if customComparison(person.get_producing_equipment_name(), item.get_producing_equipment_name()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
		elif clicked_label == tr("RECRUIT_ABILITY"):
				for person in person_list_copy:
					var count = 0
					var list_sorted = false
					for item in sort_list:
						# if person added, switch to new one
						if list_sorted:
							break
						if sorting_order == "desc":
							if !customComparison(person.get_recruit_troop_ability(), item.get_recruit_troop_ability()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
						elif sorting_order == "asc":
							if customComparison(person.get_recruit_troop_ability(), item.get_recruit_troop_ability()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
		elif clicked_label == tr("TRAIN_ABILITY"):
				for person in person_list_copy:
					var count = 0
					var list_sorted = false
					for item in sort_list:
						# if person added, switch to new one
						if list_sorted:
							break
						if sorting_order == "desc":
							if !customComparison(person.get_train_troop_ability(), item.get_train_troop_ability()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
						elif sorting_order == "asc":
							if customComparison(person.get_train_troop_ability(), item.get_train_troop_ability()):
								sort_list.insert(count,person)
								list_sorted = true
							else:
								if count == sort_list.size() - 1:
									sort_list.insert(count+1,person)
									list_sorted = true
								count += 1
		elif clicked_label == tr("PRODUCE_EQUIPMENT_ABILITY"):
			for person in person_list_copy:
				var count = 0
				var list_sorted = false
				for item in sort_list:
					# if person added, switch to new one
					if list_sorted:
						break
					if sorting_order == "desc":
						if !customComparison(person.get_produce_equipment_ability(), item.get_produce_equipment_ability()):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
					elif sorting_order == "asc":
						if customComparison(person.get_produce_equipment_ability(), item.get_produce_equipment_ability()):
							sort_list.insert(count,person)
							list_sorted = true
						else:
							if count == sort_list.size() - 1:
								sort_list.insert(count+1,person)
								list_sorted = true
							count += 1
	return sort_list
	
# comparison
func customComparison(a, b):
	if typeof(a) != typeof(b):
		if typeof(a) in TypeOrder and typeof(b) in TypeOrder:
			return TypeOrder.find( typeof(a) ) < TypeOrder.find( typeof(b) )
		else:
			return typeof(a) < typeof(b)
	else:
		return a < b
