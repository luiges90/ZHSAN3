extends TabList
class_name FactionList

enum Action { 
	LIST
}

func _ready():
	$Tabs.set_tab_title(0, tr('BASIC'))
	$Tabs.remove_child($Tabs/Tab2)
	$Tabs.remove_child($Tabs/Tab3)
	$Tabs.remove_child($Tabs/Tab4)
	
func show_data(list: Array):
	match current_action:
		Action.LIST: 
			$Title.text = tr('FACTION_LIST')
			_max_selection = 0
	$SelectionButtons.visible = _max_selection != 0

	_populate_basic_data(list, current_action)
	show()

func _populate_basic_data(list: Array, action):
	var item_list = $Tabs/Tab1/Grid as GridContainer
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 7
		item_list.add_child(_title(''))
	else:
		item_list.columns = 6
	item_list.add_child(_title(tr('NAME')))
	item_list.add_child(_title(tr('PERSON_COUNT')))
	item_list.add_child(_title(tr('ARCHITECTURE_COUNT')))
	item_list.add_child(_title(tr('FUND')))
	item_list.add_child(_title(tr('FOOD')))
	item_list.add_child(_title(tr('TROOP')))
	for f in list:
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
