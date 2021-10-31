extends TabList
class_name AttachedArmyList

enum Action { LIST, DETACH, UPDATE, CREATE_TROOP }

signal attached_army_selected

var _sorted_list

func _ready():
	_add_tab('BASIC')

func show_data(army_list: Array):
	.show_data(army_list)
	match current_action:
		Action.LIST: 
			$Title.text = tr('ATTACHED_ARMY_LIST')
			_max_selection = 0
		Action.DETACH:
			$Title.text = tr('DETACH_ARMY')
			_max_selection = 1
		Action.UPDATE:
			$Title.text = tr('UPDATE_ATTACHED_ARMY')
			_max_selection = 1
		Action.CREATE_TROOP:
			$Title.text = tr('ATTACHED_ARMY_TROOP')
			_max_selection = 1
	$SelectionButtons.visible = _max_selection != 0

	_selected_table = "architecture_list" 
	_populate_basic_data(army_list, current_action)

	show()
	._post_show()


func _populate_basic_data(army_list: Array, action):
	var item_list = tabs['BASIC'] as GridContainer
	_sorted_list = army_list # default arch list

	Util.delete_all_children(item_list)

	if action == Action.LIST:
		item_list.columns = 7
	else:
		item_list.columns = 8
		item_list.add_child(_title(''))
	item_list.add_child(_title_sorting(tr('OFFICERS'), self, "_on_title_sorting_click", army_list))
	item_list.add_child(_title_sorting(tr('MILITARY_KIND'), self, "_on_title_sorting_click", army_list))
	item_list.add_child(_title_sorting(tr('NAVAL_MILITARY_KIND'), self, "_on_title_sorting_click", army_list))
	item_list.add_child(_title_sorting(tr('QUANTITY'), self, "_on_title_sorting_click", army_list))
	item_list.add_child(_title_sorting(tr('TROOP_MORALE'), self, "_on_title_sorting_click", army_list))
	item_list.add_child(_title_sorting(tr('COMBATIVITY'), self, "_on_title_sorting_click", army_list))
	item_list.add_child(_title_sorting(tr('EXPERIENCE'), self, "_on_title_sorting_click", army_list))

	match _current_order:
		_sorting_order.DESC:
			_sorted_list = _sorting_list(army_list.duplicate())
		_sorting_order.ASC:
			_sorted_list = _sorting_list(army_list.duplicate())
	for army in _sorted_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(army.id))
		item_list.add_child(_clickable_label(army.get_officers_name_list(), self, "__on_clickable_label_click", army))
		item_list.add_child(_clickable_label(army.military_kind.get_name(), self, "__on_clickable_label_click", army))
		item_list.add_child(_clickable_label(army.naval_military_kind.get_name(), self, "__on_clickable_label_click", army))
		item_list.add_child(_clickable_label(Util.nstr(army.quantity), self, "__on_clickable_label_click", army))
		item_list.add_child(_clickable_label(str(army.morale), self, "__on_clickable_label_click", army))
		item_list.add_child(_clickable_label(str(army.combativity), self, "__on_clickable_label_click", army))
		item_list.add_child(_clickable_label(str(army.experience), self, "__on_clickable_label_click", army))
		
func __get_compare_value(_clicked_label, a, b):
	var a1 = ""
	var b1 = ""
	if _clicked_label == tr("NAME"):
		a1 = a.get_name()
		b1 = b.get_name()
	elif _clicked_label == tr("MILITARY_KIND_NAME"):
		a1 = a.military_kind.get_name()
		b1 = b.military_kind.get_name()
	elif _clicked_label == tr("NAVAL_MILITARY_KIND_NAME"):
		a1 = a.naval_military_kind.get_name()
		b1 = b.naval_military_kind.get_name()
	elif _clicked_label == tr("QUANTITY"):
		a1 = a.quantity
		b1 = b.quantity
	elif _clicked_label == tr("MORALE"):
		a1 = a.morale
		b1 = b.morale
	elif _clicked_label == tr("COMBATIVITY"):
		a1 = a.combativity
		b1 = b.combativity
	elif _clicked_label == tr("EXPERIENCE"):
		a1 = a.experience
		b1 = b.experience
	elif _clicked_label == tr("OFFICERS"):
		a1 = a.get_officers_name_list()
		b1 = b.get_officers_name_list()
	return [a1, b1]


func _on_ArchitectureMenu_show_attached_army_list(arch, armies):
	current_architecture = arch
	current_action = Action.LIST
	show_data(armies)


func _on_ArchitectureMenu_detach_army(arch, armies):
	current_architecture = arch
	current_action = Action.DETACH
	show_data(armies)


func _on_Confirm_pressed():
	var selected_army = _get_selected_list()

	call_deferred("emit_signal", "attached_army_selected", current_action, current_architecture, selected_army, {})
	._on_Confirm_pressed()

	
func _on_ArchitectureMenu_update_attached_army(arch, armies):
	current_architecture = arch
	current_action = Action.UPDATE
	show_data(armies)


func _on_ArchitectureMenu_create_troop_from_attached_army(arch, armies):
	current_architecture = arch
	current_action = Action.CREATE_TROOP
	show_data(armies)
