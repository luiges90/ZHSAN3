extends TabList
class_name MilitaryKindList

enum Action { LIST, PRODUCE_EQUIPMENT, SELECT_TROOP_MILITARY_KIND, SELECT_TROOP_NAVAL_KIND }

signal military_kind_selected

# sorted military kind list
var _sorted_list

var _selected_person_ids

var _current_architecture

func _ready():
	_add_tab('BASIC')
	_add_tab('MOVEMENT_DETAILS')
	_add_tab('TERRAIN_STRENGTH')
	
	self.connect("single_pressed_signal",Callable(self,"__on_clickable_label_click"))
	# self.connect("long_pressed_signal",Callable(self,"__on_clickable_label_long_pressed"))

	
func _on_InfoMenu_military_kind_clicked(scenario):
	_current_architecture = null
	current_action = Action.LIST
	show_data(scenario.military_kinds.values())

func show_data(list: Array):
	super.show_data(list)
	match current_action:
		Action.LIST: 
			$Title.text = tr('MILITARY_KIND_LIST')
			_max_selection = 0
		Action.PRODUCE_EQUIPMENT: 
			$Title.text = tr('PRODUCE_EQUIPMENT')
			_max_selection = 1
		Action.SELECT_TROOP_MILITARY_KIND:
			$Title.text = tr('SELECT_TROOP_MILITARY_KIND')
			_max_selection = 1
		Action.SELECT_TROOP_NAVAL_KIND:
			$Title.text = tr('SELECT_TROOP_NAVAL_KIND')
			_max_selection = 1
	$SelectionButtons.visible = _max_selection != 0

	_selected_table = "military_kind_list" 
	_populate_basic_data(list, current_action)
	_populate_movement_details_data(list, current_action)
	_populate_terrain_strength_data(list, current_action)
	show()
	super._post_show()

func _populate_basic_data(mk_list: Array, action):
	var item_list = tabs['BASIC'] as GridContainer
	_sorted_list = mk_list # default military kind list
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 10
		item_list.add_child(_title(''))
	else:
		item_list.columns = 9
	item_list.add_child(_title_sorting(tr('KIND_NAME'), self, "_on_title_sorting_click", mk_list))
	item_list.add_child(_title_sorting(tr('COST'), self, "_on_title_sorting_click", mk_list))
	item_list.add_child(_title_sorting(tr('OFFENCE'), self, "_on_title_sorting_click", mk_list))
	item_list.add_child(_title_sorting(tr('DEFENCE'), self, "_on_title_sorting_click", mk_list))
	item_list.add_child(_title_sorting(tr('RANGE'), self, "_on_title_sorting_click", mk_list))
	item_list.add_child(_title_sorting(tr('SPEED'), self, "_on_title_sorting_click", mk_list))
	item_list.add_child(_title_sorting(tr('INITIATIVE'), self, "_on_title_sorting_click", mk_list))
	item_list.add_child(_title_sorting(tr('MAX_QUANTITY_MULITPLIER'), self, "_on_title_sorting_click", mk_list))
	item_list.add_child(_title_sorting(tr('AMOUNT_PER_SOLDIER'), self, "_on_title_sorting_click", mk_list))
	if _current_architecture != null:
		item_list.columns += 1
		item_list.add_child(_title_sorting(tr('AMOUNT_IN_ARCHITECTURE'), self, "_on_title_sorting_click", mk_list))
	match _current_order:
		_sorting_order.DESC:
			_sorted_list = _sorting_list(mk_list.duplicate())
		_sorting_order.ASC:
			_sorted_list = _sorting_list(mk_list.duplicate())
	for mk in _sorted_list:
		var cb
		if action != Action.LIST:
			cb = _checkbox(mk.id)
			item_list.add_child(cb)
		item_list.add_child(_clickable_label_with_long_pressed_event(mk.get_name(), self, mk, cb))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(mk.equipment_cost), self, mk, cb))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(mk.base_offence) + " + x" + str(mk.offence), self, mk, cb))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(mk.base_defence) + " + x" + str(mk.defence), self, mk, cb))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(mk.range_min) + " - " + str(mk.range_max), self, mk, cb))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(mk.speed), self, mk, cb))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(mk.initiative), self, mk, cb))
		item_list.add_child(_clickable_label_with_long_pressed_event("x" + str(mk.max_quantity_multiplier), self, mk, cb))
		item_list.add_child(_clickable_label_with_long_pressed_event(str(mk.amount_to_troop_ratio), self, mk, cb))
		if _current_architecture != null:
			item_list.add_child(_clickable_label_with_long_pressed_event(str(_current_architecture.get_equipment_text(mk)), self, mk, cb))

func _populate_movement_details_data(mk_list: Array, action):
	if mk_list.size() <= 0: 
		return
	var item_list = tabs['MOVEMENT_DETAILS'] as GridContainer
	_sorted_list = mk_list # default military kind list
	Util.delete_all_children(item_list)
	
	var terrains = mk_list[0].get_movement_kind_with_name()
	if action != Action.LIST:
		item_list.columns = terrains.size() + 2
		item_list.add_child(_title(''))
	else:
		item_list.columns = terrains.size() + 1
	item_list.add_child(_title(tr('KIND_NAME')))
	for t in terrains:
		item_list.add_child(_title(t))
	match _current_order:
		_sorting_order.DESC:
			_sorted_list = _sorting_list(mk_list.duplicate())
		_sorting_order.ASC:
			_sorted_list = _sorting_list(mk_list.duplicate())
	for mk in _sorted_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(mk.id))
		item_list.add_child(_label(mk.get_name()))
		var terrain = mk.get_movement_kind_with_name()	
		for t in terrain:
			item_list.add_child(_label(str(terrain[t])))
	
func _populate_terrain_strength_data(mk_list: Array, action):
	if mk_list.size() <= 0: 
		return
	var item_list = tabs['TERRAIN_STRENGTH'] as GridContainer
	_sorted_list = mk_list # default military kind list
	Util.delete_all_children(item_list)
	
	var terrains = mk_list[0].get_terrain_strength_with_name()
	if action != Action.LIST:
		item_list.columns = terrains.size() + 2
		item_list.add_child(_title(''))
	else:
		item_list.columns = terrains.size() + 1
		
	item_list.add_child(_title(tr('KIND_NAME')))
	for t in terrains:
		item_list.add_child(_title(t))
	match _current_order:
		_sorting_order.DESC:
			_sorted_list = _sorting_list(mk_list.duplicate())
		_sorting_order.ASC:
			_sorted_list = _sorting_list(mk_list.duplicate())
	for mk in _sorted_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(mk.id))
		item_list.add_child(_label(mk.get_name()))
		var terrain = mk.get_terrain_strength_with_name()
		for t in terrain:
			item_list.add_child(_label(str(terrain[t])))

func __get_compare_value(_clicked_label, a, b):
	var a1 = ""
	var b1 = ""
	if _clicked_label == tr("KIND_NAME"):
		a1 = a.get_name()
		b1 = b.get_name()
	elif _clicked_label == tr("COST"):
		a1 = a.equipment_cost
		b1 = b.equipment_cost
	elif _clicked_label == tr("OFFENCE"):
		a1 = a.offence
		b1 = b.offence
	elif _clicked_label == tr("DEFENCE"):
		a1 = a.defence
		b1 = b.defence
	elif _clicked_label == tr("RANGE"):
		a1 = a.range_max
		b1 = b.range_max
	elif _clicked_label == tr("SPEED"):
		a1 = a.speed
		b1 = b.speed
	elif _clicked_label == tr("INITIATIVE"):
		a1 = a.initiative
		b1 = b.initiative
	elif _clicked_label == tr("MAX_QUANTITY_MULITPLIER"):
		a1 = a.max_quantity_multiplier
		b1 = b.max_quantity_multiplier
	elif _clicked_label == tr('AMOUNT_IN_ARCHITECTURE'):
		if _current_architecture != null:
			if a.has_equipments():
				a1 = _current_architecture.equipments[a.id]
			else:
				a1 = 0
			if b.has_equipments():
				b1 = _current_architecture.equipments[b.id]
			else:
				b1 = 0
		else:
			a1 = 0
			b1 = 0
		
	return [a1, b1]

func _on_Confirm_pressed():
	var selected_kinds = _get_selected_list()
	match current_action:
		Action.PRODUCE_EQUIPMENT: 
			call_deferred("emit_signal", "military_kind_selected", current_action, current_architecture, selected_kinds, {
				"selected_person_ids": _selected_person_ids
			})
		Action.SELECT_TROOP_MILITARY_KIND:
			call_deferred("emit_signal", "military_kind_selected", current_action, selected_kinds, {"naval": false})
		Action.SELECT_TROOP_NAVAL_KIND:
			call_deferred("emit_signal", "military_kind_selected", current_action, selected_kinds, {"naval": true})
	$ConfirmSound.play()
	super._on_Confirm_pressed()

func _on_PersonList_person_selected(task, arch, selected_person_ids):
	_current_architecture = arch
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

func __on_clickable_label_click(label, receiver, object, checkbox):
	if receiver == self:
		if checkbox != null:
			_checkbox_change_status(checkbox)

func _on_CreateTroop_select_military_kind(arch, military_kinds, naval):
	_current_architecture = arch
	if naval:
		current_action = Action.SELECT_TROOP_NAVAL_KIND
	else:
		current_action = Action.SELECT_TROOP_MILITARY_KIND
	show_data(military_kinds)
