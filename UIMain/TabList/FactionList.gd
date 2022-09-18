extends TabList
class_name FactionList

enum Action { 
	LIST
}

# sorted faction list
var _sorted_list

func _ready():
	_add_tab('BASIC')
	
func _on_InfoMenu_factions_clicked(scenario):
	current_action = Action.LIST
	show_data(scenario.factions.values())
	
func show_data(list: Array):
	super.show_data(list)
	match current_action:
		Action.LIST: 
			$Title.text = tr('FACTION_LIST')
			_max_selection = 0
	$SelectionButtons.visible = _max_selection != 0

	_selected_table = "faction_list" 
	_populate_basic_data(list, current_action)
	show()
	super._post_show()

func _populate_basic_data(list: Array, action):
	var item_list = tabs['BASIC'] as GridContainer
	_sorted_list = list # default faction list
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 10
		item_list.add_child(_title(''))
	else:
		item_list.columns = 9
	item_list.add_child(_title_sorting(tr('FACTION_NAME'), self, "_on_title_sorting_click", list))
	item_list.add_child(_title_sorting(tr('CAPITAL_NAME'), self, "_on_title_sorting_click", list))
	item_list.add_child(_title_sorting(tr('LEADER_NAME'), self, "_on_title_sorting_click", list))
	item_list.add_child(_title_sorting(tr('ADVISOR_NAME'), self, "_on_title_sorting_click", list))
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
		item_list.add_child(_label(f.capital.get_name()))
		item_list.add_child(_label(f.get_leader_name()))
		item_list.add_child(_label(f.get_advisor_name()))
		item_list.add_child(_label(str(f.get_persons().size())))
		item_list.add_child(_label(str(f.get_architectures().size())))
		item_list.add_child(_label(str(f.get_total_fund())))
		item_list.add_child(_label(str(f.get_total_food())))
		item_list.add_child(_label(str(f.get_total_troop())))

func __get_compare_value(_clicked_label, a, b):
	var a1 = ""
	var b1 = ""
	if _clicked_label == tr("FACTION_NAME"):
		a1 = a.get_name()
		b1 = b.get_name()
	elif _clicked_label == tr("LEADER_NAME"):
		a1 = a.get_leader_name()
		b1 = b.get_leader_name()
	elif _clicked_label == tr("ADVISOR_NAME"):
		a1 = a.get_advisor_name()
		b1 = b.get_advisor_name()
	elif _clicked_label == tr("PERSON_COUNT"):
		a1 = a.get_persons().size()
		b1 = b.get_persons().size()
	elif _clicked_label == tr("ARCHITECTURE_COUNT"):
		a1 = a.get_architectures().size()
		b1 = b.get_architectures().size()
	elif _clicked_label == tr("TOTAL_FUND"):
		a1 = a.get_total_fund()
		b1 = b.get_total_fund()
	elif _clicked_label == tr("TOTAL_FOOD"):
		a1 = a.get_total_food()
		b1 = b.get_total_food()
	elif _clicked_label == tr("TOTAL_TROOP"):
		a1 = a.get_total_troop()
		b1 = b.get_total_troop()
	return [a1, b1]


func _on_ArchitectureMenu_faction_list_clicked(architecture, faction, action):
	current_architecture = architecture
	current_action = action
	show_data(faction)
