extends TabList
class_name ArchitectureList

enum Action { LIST, MOVE_TO }

signal architecture_selected

var _selected_person_ids

func _ready():
	$Tabs.set_tab_title(0, tr('BASIC'))
	$Tabs.set_tab_title(1, tr('INTERNAL'))

func show_data(arch_list: Array):
	match current_action:
		Action.LIST: $Title.text = tr('PERSON_LIST')
		Action.MOVE_TO: $Title.text = tr('AGRICULTURE')
	$SelectionButtons.visible = current_action != Action.LIST
	_populate_basic_data(arch_list, current_action)
	_populate_internal_data(arch_list, current_action)
	show()

func _populate_basic_data(arch_list: Array, action):
	var item_list = $Tabs/Tab1/Grid as GridContainer
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 6
		item_list.add_child(_title(''))
	else:
		item_list.columns = 5
	item_list.add_child(_title(tr('NAME')))
	item_list.add_child(_title(tr('KIND_NAME')))
	item_list.add_child(_title(tr('FACTION_NAME')))
	item_list.add_child(_title(tr('FOOD')))
	item_list.add_child(_title(tr('FUND')))
	for arch in arch_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(arch.id))
		item_list.add_child(_label(arch.get_name()))
		item_list.add_child(_label(arch.kind.get_name()))
		item_list.add_child(_label(arch.get_belonged_faction().get_name()))
		item_list.add_child(_label(Util.nstr(arch.food)))
		item_list.add_child(_label(Util.nstr(arch.fund)))
	
func _populate_internal_data(arch_list: Array, action):
	var item_list = $Tabs/Tab2/Grid as GridContainer
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 6
		item_list.add_child(_title(''))
	else:
		item_list.columns = 5
	item_list.add_child(_title(tr('NAME')))
	item_list.add_child(_title(tr('AGRICULTURE')))
	item_list.add_child(_title(tr('COMMERCE')))
	item_list.add_child(_title(tr('MORALE')))
	item_list.add_child(_title(tr('ENDURANCE')))
	for arch in arch_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(arch.id))
		item_list.add_child(_label(arch.get_name()))
		item_list.add_child(_label(str(arch.agriculture)))
		item_list.add_child(_label(str(arch.commerce)))
		item_list.add_child(_label(str(arch.morale)))
		item_list.add_child(_label(str(arch.endurance)))

func _on_Confirm_pressed():
	var selected_arch = _get_selected_list()
	var task
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
			show_data(arch.get_belonged_faction().get_architectures())
