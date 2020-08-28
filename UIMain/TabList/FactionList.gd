extends TabList
class_name FactionList

enum Action { 
	LIST
}

# sorted faction list
var _sorted_list

func _ready():
	$Tabs.set_tab_title(0, tr('BASIC'))
	$Tabs.remove_child($Tabs/Tab2)
	$Tabs.remove_child($Tabs/Tab3)
	$Tabs.remove_child($Tabs/Tab4)
	
func _on_InfoMenu_factions_clicked(scenario):
	current_action = Action.LIST
	show_data(scenario.factions.values())
	
func show_data(list: Array):
	match current_action:
		Action.LIST: 
			$Title.text = tr('FACTION_LIST')
			_max_selection = 0
	$SelectionButtons.visible = _max_selection != 0

	_selected_table = "faction_list" 
	_populate_basic_data(list, current_action)
	show()

func _populate_basic_data(list: Array, action):
	var item_list = $Tabs/Tab1/Grid as GridContainer
	_sorted_list = list # default faction list
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 7
		item_list.add_child(_title(''))
	else:
		item_list.columns = 6
	item_list.add_child(_title_sorting(tr('FACTION_NAME'), self, "_on_title_sorting_click", list))
	item_list.add_child(_title_sorting(tr('PERSON_COUNT'), self, "_on_title_sorting_click", list))
	item_list.add_child(_title_sorting(tr('ARCHITECTURE_COUNT'), self, "_on_title_sorting_click", list))
	item_list.add_child(_title_sorting(tr('TOTAL_FUND'), self, "_on_title_sorting_click", list))
	item_list.add_child(_title_sorting(tr('TOTAL_FOOD'), self, "_on_title_sorting_click", list))
	item_list.add_child(_title_sorting(tr('TOTAL_TROOP'), self, "_on_title_sorting_click", list))
	match _current_order:
		_sorting_order.DESC:
			_sorted_list = _sorting_list(list.duplicate())
		_sorting_order.ASC:
			_sorted_list = _sorting_list(list.duplicate())
	for f in _sorted_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(f.id))
		item_list.add_child(_label(f.get_name()))
		item_list.add_child(_label(str(f.get_persons().size())))
		item_list.add_child(_label(str(f.get_architectures().size())))
		item_list.add_child(_label(str(f.get_total_fund())))
		item_list.add_child(_label(str(f.get_total_food())))
		item_list.add_child(_label(str(f.get_total_troop())))


func _on_ArchitectureMenu_faction_list_clicked(architecture, faction, action):
	current_architecture = architecture
	current_action = action
	show_data(faction)
