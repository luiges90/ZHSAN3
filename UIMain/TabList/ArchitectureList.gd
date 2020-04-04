extends TabList
class_name ArchitectureList

enum Action { LIST, MOVE_TO }

signal architecture_selected

var _selected_person_ids

func _ready():
	$Tabs.set_tab_title(0, tr('BASIC'))
	$Tabs.set_tab_title(1, tr('INTERNAL'))
	$Tabs.set_tab_title(2, tr('MILITARY'))
	$Tabs.set_tab_title(3, tr('EQUIPMENTS'))

func show_data(arch_list: Array):
	match current_action:
		Action.LIST: 
			$Title.text = tr('PERSON_LIST')
			_max_selection = 0
		Action.MOVE_TO: 
			$Title.text = tr('MOVE')
			_max_selection = 1
	$SelectionButtons.visible = _max_selection != 0
	$Title.text = tr('ARCHITECTURE_LIST')
	_populate_basic_data(arch_list, current_action)
	_populate_internal_data(arch_list, current_action)
	_populate_military_data(arch_list, current_action)
	_populate_equipments_data(arch_list, current_action)
	show()

func _populate_basic_data(arch_list: Array, action):
	var item_list = $Tabs/Tab1/Grid as GridContainer
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 7
		item_list.add_child(_title(''))
	else:
		item_list.columns = 6
	item_list.add_child(_title(tr('NAME')))
	item_list.add_child(_title(tr('KIND_NAME')))
	item_list.add_child(_title(tr('FACTION_NAME')))
	item_list.add_child(_title(tr('FOOD')))
	item_list.add_child(_title(tr('FUND')))
	item_list.add_child(_title(tr('PERSON_COUNT')))
	for arch in arch_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(arch.id))
		item_list.add_child(_label(arch.get_name()))
		item_list.add_child(_label(arch.kind.get_name()))
		item_list.add_child(_label(arch.get_belonged_faction().get_name()))
		item_list.add_child(_label(Util.nstr(arch.food)))
		item_list.add_child(_label(Util.nstr(arch.fund)))
		item_list.add_child(_label(str(arch.get_persons().size())))
	
func _populate_internal_data(arch_list: Array, action):
	var item_list = $Tabs/Tab2/Grid as GridContainer
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 8
		item_list.add_child(_title(''))
	else:
		item_list.columns = 7
	item_list.add_child(_title(tr('NAME')))
	item_list.add_child(_title(tr('POPULATION')))
	item_list.add_child(_title(tr('MILITARY_POPULATION')))
	item_list.add_child(_title(tr('AGRICULTURE')))
	item_list.add_child(_title(tr('COMMERCE')))
	item_list.add_child(_title(tr('MORALE')))
	item_list.add_child(_title(tr('ENDURANCE')))
	for arch in arch_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(arch.id))
		item_list.add_child(_label(arch.get_name()))
		item_list.add_child(_label(str(arch.population)))
		item_list.add_child(_label(str(arch.military_population)))
		item_list.add_child(_label(str(arch.agriculture)))
		item_list.add_child(_label(str(arch.commerce)))
		item_list.add_child(_label(str(arch.morale)))
		item_list.add_child(_label(str(arch.endurance)))
		
func _populate_military_data(arch_list: Array, action):
	var item_list = $Tabs/Tab3/Grid as GridContainer
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 5
		item_list.add_child(_title(''))
	else:
		item_list.columns = 4
	item_list.add_child(_title(tr('NAME')))
	item_list.add_child(_title(tr('TROOP')))
	item_list.add_child(_title(tr('TROOP_MORALE')))
	item_list.add_child(_title(tr('COMBATIVITY')))
	for arch in arch_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(arch.id))
		item_list.add_child(_label(arch.get_name()))
		item_list.add_child(_label(str(arch.troop)))
		item_list.add_child(_label(str(arch.troop_morale)))
		item_list.add_child(_label(str(arch.troop_combativity)))
		
func _populate_equipments_data(arch_list: Array, action):
	var item_list = $Tabs/Tab4/Grid as GridContainer
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
		
	for arch in arch_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(arch.id))
		item_list.add_child(_label(arch.get_name()))
		for k in kinds:
			item_list.add_child(_label(str(arch.equipments[k.id])))
	

func _on_Confirm_pressed():
	var selected_arch = _get_selected_list()
	match current_action:
		Action.MOVE_TO: 
			emit_signal("architecture_selected", current_action, current_architecture, selected_arch, {
				"selected_person_ids": _selected_person_ids
			})
	._on_Confirm_pressed()


func _on_ArchitectureMenu_architecture_list_clicked(arch, archs: Array, action):
	current_action = action
	current_architecture = arch
	show_data(archs)


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
		
