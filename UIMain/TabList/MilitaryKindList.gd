extends TabList
class_name MilitaryKindList

enum Action { LIST, PRODUCE_EQUIPMENT, SELECT_TROOP_MILITARY_KIND }

signal military_kind_selected
signal military_kind_selected_for_troop

var _selected_person_ids

func _ready():
	$Tabs.set_tab_title(0, tr('BASIC'))
	$Tabs.set_tab_title(1, tr('MOVEMENT_DETAILS'))
	$Tabs.set_tab_title(2, tr('TERRAIN_STRENGTH'))
	$Tabs.remove_child($Tabs/Tab4)
	
func _on_InfoMenu_military_kind_clicked(scenario):
	current_action = Action.LIST
	show_data(scenario.military_kinds.values())

func show_data(list: Array):
	match current_action:
		Action.LIST: 
			$Title.text = tr('PERSON_LIST')
			_max_selection = 0
		Action.PRODUCE_EQUIPMENT: 
			$Title.text = tr('PRODUCE_EQUIPMENT')
			_max_selection = 1
		Action.SELECT_TROOP_MILITARY_KIND:
			$Title.text = tr('SELECT_TROOP_MILITARY_KIND')
			_max_selection = 1
	$SelectionButtons.visible = _max_selection != 0
	$Title.text = tr('MILITARY_KIND_LIST')
	_populate_basic_data(list, current_action)
	_populate_movement_details_data(list, current_action)
	_populate_terrain_strength_data(list, current_action)
	show()

func _populate_basic_data(mk_list: Array, action):
	var item_list = $Tabs/Tab1/Grid as GridContainer
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 9
		item_list.add_child(_title(''))
	else:
		item_list.columns = 8
	item_list.add_child(_title(tr('NAME')))
	item_list.add_child(_title(tr('COST')))
	item_list.add_child(_title(tr('OFFENSE')))
	item_list.add_child(_title(tr('DEFENSE')))
	item_list.add_child(_title(tr('RANGE')))
	item_list.add_child(_title(tr('SPEED')))
	item_list.add_child(_title(tr('INITIATIVE')))
	item_list.add_child(_title(tr('MAX_QUANTITY_MULITPLIER')))
	for mk in mk_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(mk.id))
		item_list.add_child(_label(mk.get_name()))
		item_list.add_child(_label(str(mk.equipment_cost)))
		item_list.add_child(_label(str(mk.offence)))
		item_list.add_child(_label(str(mk.defence)))
		item_list.add_child(_label(str(mk.range_min) + " - " + str(mk.range_max)))
		item_list.add_child(_label(str(mk.speed)))
		item_list.add_child(_label(str(mk.initiative)))
		item_list.add_child(_label("x" + str(mk.max_quantity_multiplier)))

func _populate_movement_details_data(mk_list: Array, action):
	if mk_list.size() <= 0: 
		return
	var item_list = $Tabs/Tab2/Grid as GridContainer
	Util.delete_all_children(item_list)
	
	var terrains = mk_list[0].get_movement_kind_with_name()
	if action != Action.LIST:
		item_list.columns = terrains.size() + 2
		item_list.add_child(_title(''))
	else:
		item_list.columns = terrains.size() + 1
		
	item_list.add_child(_title(tr('NAME')))
	for t in terrains:
		item_list.add_child(_title(t))
	for mk in mk_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(mk.id))
		item_list.add_child(_label(mk.get_name()))
		var terrain = mk.get_movement_kind_with_name()	
		for t in terrain:
			item_list.add_child(_label(str(terrain[t])))
	
func _populate_terrain_strength_data(mk_list: Array, action):
	if mk_list.size() <= 0: 
		return
	var item_list = $Tabs/Tab3/Grid as GridContainer
	Util.delete_all_children(item_list)
	
	var terrains = mk_list[0].get_terrain_strength_with_name()
	if action != Action.LIST:
		item_list.columns = terrains.size() + 2
		item_list.add_child(_title(''))
	else:
		item_list.columns = terrains.size() + 1
		
	item_list.add_child(_title(tr('NAME')))
	for t in terrains:
		item_list.add_child(_title(t))
	for mk in mk_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(mk.id))
		item_list.add_child(_label(mk.get_name()))
		var terrain = mk.get_terrain_strength_with_name()
		for t in terrain:
			item_list.add_child(_label(str(terrain[t])))

func _on_Confirm_pressed():
	var selected_kinds = _get_selected_list()
	match current_action:
		Action.PRODUCE_EQUIPMENT: 
			emit_signal("military_kind_selected", current_action, current_architecture, selected_kinds, {
				"selected_person_ids": _selected_person_ids
			})
		Action.SELECT_TROOP_MILITARY_KIND:
			emit_signal("military_kind_selected_for_troop", current_action, selected_kinds)
	._on_Confirm_pressed()

func _on_PersonList_person_selected(task, arch, selected_person_ids):
	match task:
		PersonList.Action.PRODUCE_EQUIPMENT:
			current_action = Action.PRODUCE_EQUIPMENT
			current_architecture = arch
			_selected_person_ids = selected_person_ids
			var selectable_kinds = []
			for k in arch.scenario.military_kinds.values():
				if k.equipment_cost > 0:
					selectable_kinds.append(k)
			show_data(selectable_kinds)



func _on_CreateTroop_select_military_kind(arch, military_kinds):
	current_action = Action.SELECT_TROOP_MILITARY_KIND
	show_data(military_kinds)
