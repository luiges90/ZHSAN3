extends TabList
class_name ArchitectureList

enum Action { LIST, MOVE_TO, TRANSPORT_RESOURCE_TO, SELECT_ARCHITECTURE_FOR_NEW_FACTION }

signal architecture_selected
signal architecture_row_clicked

var _selected_person_ids

# sorted architecture list
var _sorted_list

var _detail_showing = false

func _ready():
	_add_tab('BASIC')
	_add_tab('INTERNAL')
	_add_tab('RESOURCES')
	_add_tab('MILITARY')
	_add_tab('EQUIPMENTS')
	
func handle_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			if _detail_showing:
				_detail_showing = false
			else:
				.handle_input(event)
				
func select_architecture_for_new_faction(arch_list: Array):
	current_action = Action.SELECT_ARCHITECTURE_FOR_NEW_FACTION
	show_data(arch_list)
	
func _on_InfoMenu_architectures_clicked(scenario):
	current_action = Action.LIST
	show_data(scenario.architectures.values())

func show_data(arch_list: Array):
	.show_data(arch_list)
	match current_action:
		Action.LIST: 
			$Title.text = tr('ARCHITECTURE_LIST')
			_max_selection = 0
		Action.MOVE_TO: 
			$Title.text = tr('MOVE')
			_max_selection = 1
		Action.TRANSPORT_RESOURCE_TO:
			$Title.text = tr('TRANSPORT')
			_max_selection = 1
		Action.SELECT_ARCHITECTURE_FOR_NEW_FACTION:
			$Title.text = tr('SELECT_ARCHITECTURE_FOR_NEW_FACTION')
			_max_selection = -1
	$SelectionButtons.visible = _max_selection != 0

	_selected_table = "architecture_list" 
	_populate_basic_data(arch_list, current_action)
	if current_action != Action.SELECT_ARCHITECTURE_FOR_NEW_FACTION:
		_populate_internal_data(arch_list, current_action)
		_populate_resource_data(arch_list, current_action)
		_populate_military_data(arch_list, current_action)
		_populate_equipments_data(arch_list, current_action)
	show()
	._post_show()

func _populate_basic_data(arch_list: Array, action):
	var item_list = tabs['BASIC'] as GridContainer
	_sorted_list = arch_list # default arch list
	Util.delete_all_children(item_list)
	if action == Action.LIST:
		item_list.columns = 8
	elif action == Action.SELECT_ARCHITECTURE_FOR_NEW_FACTION:
		item_list.columns = 2
		item_list.add_child(_title(''))
	else:
		item_list.columns = 9
		item_list.add_child(_title(''))
	item_list.add_child(_title_sorting(tr('NAME'), self, "_on_title_sorting_click", arch_list))
	if action != Action.SELECT_ARCHITECTURE_FOR_NEW_FACTION:
		item_list.add_child(_title_sorting(tr('KIND_NAME'), self, "_on_title_sorting_click", arch_list))
		item_list.add_child(_title_sorting(tr('FACTION_NAME'), self, "_on_title_sorting_click", arch_list))
		item_list.add_child(_title_sorting(tr('POPULATION'), self, "_on_title_sorting_click", arch_list))
		item_list.add_child(_title_sorting(tr('FOOD'), self, "_on_title_sorting_click", arch_list))
		item_list.add_child(_title_sorting(tr('FUND'), self, "_on_title_sorting_click", arch_list))
		item_list.add_child(_title_sorting(tr('PERSON_COUNT'), self, "_on_title_sorting_click", arch_list))
		item_list.add_child(_title_sorting(tr('WILD_PERSON_COUNT'), self, "_on_title_sorting_click", arch_list))
	match _current_order:
		_sorting_order.DESC:
			_sorted_list = _sorting_list(arch_list.duplicate())
		_sorting_order.ASC:
			_sorted_list = _sorting_list(arch_list.duplicate())
	for arch in _sorted_list:
		if action == Action.SELECT_ARCHITECTURE_FOR_NEW_FACTION:
			item_list.add_child(_checkbox(arch['_Id']))
			item_list.add_child(_clickable_label(arch['Name'], self, "__on_clickable_label_click", arch))
		else:
			if action != Action.LIST:
				item_list.add_child(_checkbox(arch.id))
			item_list.add_child(_clickable_label(arch.get_name(), self, "__on_clickable_label_click", arch))
			item_list.add_child(_clickable_label(arch.kind.get_name(), self, "__on_clickable_label_click", arch))
			item_list.add_child(_clickable_label(arch.get_belonged_faction_str(), self, "__on_clickable_label_click", arch))
			item_list.add_child(_clickable_label(Util.nstr(arch.population), self, "__on_clickable_label_click", arch))
			item_list.add_child(_clickable_label(Util.nstr(arch.food), self, "__on_clickable_label_click", arch))
			item_list.add_child(_clickable_label(Util.nstr(arch.fund), self, "__on_clickable_label_click", arch))
			item_list.add_child(_clickable_label(str(arch.get_idling_persons().size()) + "/" + str(arch.get_workable_persons().size()) + "/" + str(arch.get_faction_persons().size()), self, "__on_clickable_label_click", arch))
			item_list.add_child(_clickable_label(str(arch.get_wild_persons().size()), self, "__on_clickable_label_click", arch))
	
func _populate_internal_data(arch_list: Array, action):
	var item_list = tabs['INTERNAL'] as GridContainer
	_sorted_list = arch_list # default arch list
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 8
		item_list.add_child(_title(''))
	else:
		item_list.columns = 7
	item_list.add_child(_title_sorting(tr('NAME'), self, "_on_title_sorting_click", arch_list))
	item_list.add_child(_title_sorting(tr('POPULATION'), self, "_on_title_sorting_click", arch_list))
	item_list.add_child(_title_sorting(tr('MILITARY_POPULATION'), self, "_on_title_sorting_click", arch_list))
	item_list.add_child(_title_sorting(tr('AGRICULTURE'), self, "_on_title_sorting_click", arch_list))
	item_list.add_child(_title_sorting(tr('COMMERCE'), self, "_on_title_sorting_click", arch_list))
	item_list.add_child(_title_sorting(tr('MORALE'), self, "_on_title_sorting_click", arch_list))
	item_list.add_child(_title_sorting(tr('ENDURANCE'), self, "_on_title_sorting_click", arch_list))
	match _current_order:
		_sorting_order.DESC:
			_sorted_list = _sorting_list(arch_list.duplicate())
		_sorting_order.ASC:
			_sorted_list = _sorting_list(arch_list.duplicate())
	for arch in _sorted_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(arch.id))
		item_list.add_child(_clickable_label(arch.get_name(), self, "__on_clickable_label_click", arch))
		item_list.add_child(_clickable_label(str(arch.population), self, "__on_clickable_label_click", arch))
		item_list.add_child(_clickable_label(str(arch.military_population), self, "__on_clickable_label_click", arch))
		item_list.add_child(_clickable_label(str(arch.agriculture), self, "__on_clickable_label_click", arch))
		item_list.add_child(_clickable_label(str(arch.commerce), self, "__on_clickable_label_click", arch))
		item_list.add_child(_clickable_label(str(arch.morale), self, "__on_clickable_label_click", arch))
		item_list.add_child(_clickable_label(str(arch.endurance), self, "__on_clickable_label_click", arch))
		
func _populate_resource_data(arch_list: Array, action):
	var item_list = tabs['RESOURCES'] as GridContainer
	_sorted_list = arch_list # default arch list
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 6
		item_list.add_child(_title(''))
	else:
		item_list.columns = 5
	item_list.add_child(_title_sorting(tr('NAME'), self, "_on_title_sorting_click", arch_list))
	item_list.add_child(_title_sorting(tr('FUND'), self, "_on_title_sorting_click", arch_list))
	item_list.add_child(_title_sorting(tr('DELIVERING_FUND'), self, "_on_title_sorting_click", arch_list))
	item_list.add_child(_title_sorting(tr('FOOD'), self, "_on_title_sorting_click", arch_list))
	item_list.add_child(_title_sorting(tr('DELIVERING_FOOD'), self, "_on_title_sorting_click", arch_list))
	match _current_order:
		_sorting_order.DESC:
			_sorted_list = _sorting_list(arch_list.duplicate())
		_sorting_order.ASC:
			_sorted_list = _sorting_list(arch_list.duplicate())
	for arch in _sorted_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(arch.id))
		item_list.add_child(_clickable_label(arch.get_name(), self, "__on_clickable_label_click", arch))
		item_list.add_child(_clickable_label(str(arch.fund), self, "__on_clickable_label_click", arch))
		item_list.add_child(_clickable_label(str(arch.get_fund_in_packs_str()), self, "__on_clickable_label_click", arch))
		item_list.add_child(_clickable_label(str(arch.food), self, "__on_clickable_label_click", arch))
		item_list.add_child(_clickable_label(str(arch.get_food_in_packs_str()), self, "__on_clickable_label_click", arch))

		
func _populate_military_data(arch_list: Array, action):
	var item_list = tabs['MILITARY'] as GridContainer
	_sorted_list = arch_list # default arch list
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 6
		item_list.add_child(_title(''))
	else:
		item_list.columns = 5
	item_list.add_child(_title_sorting(tr('NAME'), self, "_on_title_sorting_click", arch_list))
	item_list.add_child(_title_sorting(tr('TROOP'), self, "_on_title_sorting_click", arch_list))
	item_list.add_child(_title_sorting(tr('DELIVERING_TROOP'), self, "_on_title_sorting_click", arch_list))
	item_list.add_child(_title_sorting(tr('TROOP_MORALE'), self, "_on_title_sorting_click", arch_list))
	item_list.add_child(_title_sorting(tr('COMBATIVITY'), self, "_on_title_sorting_click", arch_list))
	match _current_order:
		_sorting_order.DESC:
			_sorted_list = _sorting_list(arch_list.duplicate())
		_sorting_order.ASC:
			_sorted_list = _sorting_list(arch_list.duplicate())
	for arch in _sorted_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(arch.id))
		item_list.add_child(_clickable_label(arch.get_name(), self, "__on_clickable_label_click", arch))
		item_list.add_child(_clickable_label(str(arch.troop), self, "__on_clickable_label_click", arch))
		item_list.add_child(_clickable_label(str(arch.get_troop_in_packs_str()), self, "__on_clickable_label_click", arch))
		item_list.add_child(_clickable_label(str(arch.troop_morale), self, "__on_clickable_label_click", arch))
		item_list.add_child(_clickable_label(str(arch.troop_combativity), self, "__on_clickable_label_click", arch))
		
func _populate_equipments_data(arch_list: Array, action):
	var item_list = tabs['EQUIPMENTS'] as GridContainer
	_sorted_list = arch_list # default arch list
	Util.delete_all_children(item_list)
	
	var all_kinds = arch_list[0].scenario.military_kinds.values()
	var kinds = Util.array_filter(all_kinds, 'has_equipments')
	var kind_names = []
	for kind in kinds:
		kind_names.append(kind.get_name())
		
	if action != Action.LIST:
		item_list.columns = kind_names.size() + 2
		item_list.add_child(_title(''))
	else:
		item_list.columns = kind_names.size() + 1
	item_list.add_child(_title(tr('NAME')))
	for kind in kinds:
		item_list.add_child(_title(kind.get_name()))
	match _current_order:
		_sorting_order.DESC:
			_sorted_list = _sorting_list(arch_list.duplicate())
		_sorting_order.ASC:
			_sorted_list = _sorting_list(arch_list.duplicate())
	for arch in _sorted_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(arch.id))
		item_list.add_child(_clickable_label(arch.get_name(), self, "__on_clickable_label_click", arch))
		for k in kinds:
			item_list.add_child(_clickable_label(str(arch.equipments[k.id]), self, "__on_clickable_label_click", arch))
	
func __get_compare_value(_clicked_label, a, b):
	var a1 = ""
	var b1 = ""
	if _clicked_label == tr("NAME"):
		a1 = a.get_name()
		b1 = b.get_name()
	elif _clicked_label == tr("KIND_NAME"):
		a1 = a.kind
		b1 = b.kind
	elif _clicked_label == tr("FACTION_NAME"):
		a1 = a.get_belonged_faction_str()
		b1 = b.get_belonged_faction_str()
	elif _clicked_label == tr("POPULATION"):
		a1 = a.population
		b1 = b.population
	elif _clicked_label == tr("FOOD"):
		a1 = a.food
		b1 = b.food
	elif _clicked_label == tr("FUND"):
		a1 = a.fund
		b1 = b.fund
	elif _clicked_label == tr("PERSON_COUNT"):
		a1 = a.get_persons().size()
		b1 = b.get_persons().size()
	elif _clicked_label == tr("WILD_PERSON_COUNT"):
		a1 = a.get_wild_persons().size()
		b1 = b.get_wild_persons().size()
	elif _clicked_label == tr("MILITARY_POPULATION"):
		a1 = a.military_population
		b1 = b.military_population
	elif _clicked_label == tr("AGRICULTURE"):
		a1 = a.agriculture
		b1 = b.agriculture
	elif _clicked_label == tr("COMMERCE"):
		a1 = a.commerce
		b1 = b.commerce
	elif _clicked_label == tr("MORALE"):
		a1 = a.morale
		b1 = b.morale
	elif _clicked_label == tr("ENDURANCE"):
		a1 = a.endurance
		b1 = b.endurance
	elif _clicked_label == tr("TROOP"):
		a1 = a.troop
		b1 = b.troop
	elif _clicked_label == tr("TROOP_MORALE"):
		a1 = a.troop_morale
		b1 = b.troop_morale
	elif _clicked_label == tr("COMBATIVITY"):
		a1 = a.troop_combativity
		b1 = b.troop_combativity
	elif _clicked_label == tr("TROOP"):
		a1 = a.troop
		b1 = b.troop
	elif _clicked_label == tr("TROOP_MORALE"):
		a1 = a.troop_morale
		b1 = b.troop_morale
	elif _clicked_label == tr("COMBATIVITY"):
		a1 = a.troop_combativity
		b1 = b.troop_combativity
	return [a1, b1]

func _on_Confirm_pressed():
	var selected_arch = _get_selected_list()
	match current_action:
		Action.MOVE_TO: 
			call_deferred("emit_signal", "architecture_selected", current_action, current_architecture, selected_arch, {
				"selected_person_ids": _selected_person_ids
			})
			$PersonMove.play()
			._on_Confirm_pressed()
		Action.TRANSPORT_RESOURCE_TO:
			call_deferred("emit_signal", "architecture_selected", current_action, current_architecture, selected_arch, {})
			$ConfirmSound.play()
			._on_Confirm_pressed()
		_:
			$ConfirmSound.play()
			._on_Confirm_pressed()


func _on_ArchitectureMenu_architecture_list_clicked(arch, archs: Array, action):
	current_action = action
	current_architecture = arch
	show_data(archs)


func __on_clickable_label_click(label, person):
	call_deferred("emit_signal", 'architecture_row_clicked', person)
	_detail_showing = true


func _on_PersonList_person_selected(task, arch, selected_person_ids):
	match task:
		PersonList.Action.MOVE:
			current_action = Action.MOVE_TO
			current_architecture = arch
			_selected_person_ids = selected_person_ids
			var selectable_archs = []
			for a in arch.get_belonged_faction().get_architectures():
				if a != arch:
					selectable_archs.append(a)
			show_data(selectable_archs)
		


func _on_TransportDialog_select_architecture(from_architecture):
	current_action = Action.TRANSPORT_RESOURCE_TO
	current_architecture = from_architecture
	show_data(from_architecture.get_belonged_faction().get_architectures_can_transport_resource_to(from_architecture))
