extends Panel
class_name TabList

const TITLE_COLOR = Color(0.04, 0.53, 0.79)
# 長按計算時間，單位：毫秒
const LONG_PRESSED_TIME = 500

var current_action
var current_architecture

var _confirming

var _max_selection = -1

# 記錄長按事件作用物體id，用於實現長按動作
var long_pressed_object_id = -1
# 記錄長按事件開始時間，用於實現長按動作
var long_pressed_start_time = -1

# 長按信號
signal long_pressed_signal
# 單擊信號
signal single_pressed_signal

# for title sorting
enum _sorting_order {
	ASC,
	DESC, 
	DEFAULT
}
# current title order
var _current_order = _sorting_order.DEFAULT
var _clicked_label = "" # title to be sorted
var _selected_table = "" # table being selected
const _TYPE_ORDER = [TYPE_STRING, TYPE_INT]

var _current_mouseover_rect

func _ready():
	connect("mouse_entered", self, "_on_TabList_mouse_entered")

func show_data(list):
	# Subclasses should override this
	pass

####################################
# Control generation for subclass  #
####################################
func _label(text: String, color = null):
	var label = Label.new()
	label.text = text
	if color != null:
		label.add_color_override('font_color', color)
	label.connect("mouse_entered", self, "_item_mouse_entered", [label])
	label.mouse_filter = Control.MOUSE_FILTER_STOP
	return label
	
func _clickable_label(text: String, on_click_func, on_click_func_name, object):
	var label = LinkButton.new()
	label.text = text
	label.underline = LinkButton.UNDERLINE_MODE_NEVER
	label.mouse_default_cursor_shape = Control.CURSOR_ARROW
	label.connect("pressed", on_click_func, on_click_func_name, [label, object])
	label.connect("mouse_entered", self, "_item_mouse_entered", [label])
	label.mouse_filter = Control.MOUSE_FILTER_STOP
	return label

# 帶有長點擊事件的按鈕	
func _clickable_label_with_long_pressed_event(text: String, on_click_func, object, checkbox):
	var label = LinkButton.new()
	label.text = text
	label.underline = LinkButton.UNDERLINE_MODE_NEVER
	label.mouse_default_cursor_shape = Control.CURSOR_ARROW
	label.connect("button_down", self, "_long_pressed_down_event", [label])
	label.connect("button_up", self, "_long_pressed_up_event", [label, on_click_func, object, checkbox])
	label.connect("mouse_entered", self, "_item_mouse_entered", [label])
	label.mouse_filter = Control.MOUSE_FILTER_STOP
	return label
	
# for title 
func _title_sorting(text: String, on_click_func, on_click_func_name, object):
	var label = LinkButton.new()
	label.text = text
	label.underline = LinkButton.UNDERLINE_MODE_NEVER
	label.mouse_default_cursor_shape = Control.CURSOR_ARROW
	label.connect("pressed", on_click_func, on_click_func_name, [label, object])
	label.connect("mouse_entered", self, "_item_mouse_entered", [label])
	label.mouse_filter = Control.MOUSE_FILTER_STOP
	return label
	
func _title(text: String):
	var label = Label.new()
	label.text = text
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = TITLE_COLOR
	label.add_stylebox_override("normal", stylebox)
	return label
	
func _checkbox(id: int):
	var checkbox = CheckBox.new()
	checkbox.add_to_group("checkboxes")
	checkbox.add_to_group("id_" + str(id))
	checkbox.set_meta("id", id)
	checkbox.connect("pressed", self, "_checkbox_changed", [checkbox])
	checkbox.connect("mouse_entered", self, "_item_mouse_entered", [checkbox])
	checkbox.mouse_filter = Control.MOUSE_FILTER_STOP
	return checkbox
	
func _checkbox_changed(in_cb: CheckBox):
	if _max_selection == 1:
		for checkbox in get_tree().get_nodes_in_group("checkboxes"):
			checkbox.set_pressed(false)
		in_cb.set_pressed(true)
	
	for group in in_cb.get_groups():
		if group.find("id_") >= 0:
			for checkbox in get_tree().get_nodes_in_group(group):
				checkbox.set_pressed(in_cb.is_pressed())
				
	var any_checked = false
	for checkbox in get_tree().get_nodes_in_group("checkboxes"):
		if checkbox.is_pressed():
			any_checked = true
			break
	$ActionButtons/Confirm.disabled = not any_checked


####################################
#       Input and custom draw      #
####################################
# Override-able method to handle input
# https://godotengine.org/qa/9244/can-override-the-_ready-and-_process-functions-child-classes
func handle_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			hide()

func _input(event):
	handle_input(event)

func _draw():
	if _current_mouseover_rect != null:
		draw_rect(_current_mouseover_rect, Color.white, false, 1.0)

func _item_mouse_entered(label: Control):
	var y = label.rect_global_position.y - rect_global_position.y
	var x = $Tabs/Tab1.rect_global_position.x - rect_global_position.x
	var width = $Tabs/Tab1.rect_size.x
	var height = label.rect_size.y
	_current_mouseover_rect = Rect2(x, y, width, height)
	update()

func _on_TabList_mouse_entered():
	_current_mouseover_rect = null
	update()

func _long_pressed_down_event(label):
	long_pressed_object_id = label.get_instance_id()
	long_pressed_start_time = OS.get_system_time_msecs()
	
func _long_pressed_up_event(label, receiver, object, checkbox):
	if long_pressed_start_time > 0 and long_pressed_object_id > 0:
		if OS.get_system_time_msecs() - long_pressed_start_time > LONG_PRESSED_TIME:
			emit_signal("long_pressed_signal", label, receiver, object, checkbox)
		else:
			emit_signal("single_pressed_signal", label, receiver, object, checkbox)
		long_pressed_start_time = -1
		long_pressed_object_id = -1

####################################
#             Get list             #
####################################
func _get_selected_list() -> Array:
	var selected = {}
	for checkbox in get_tree().get_nodes_in_group("checkboxes"):
		if checkbox.is_pressed():
			var id = int(checkbox.get_meta("id"))
			selected[id] = true
	return selected.keys()

####################################
#            Own events            #
####################################
func _on_TabList_hide():
	if GameConfig.se_enabled and not _confirming:
		$CloseSound.play()
	_confirming = false


func _on_Cancel_pressed():
	hide()
	_on_UnselectAll_pressed()


func _on_Confirm_pressed():
	# Subclasses should handle their action types, and then invoke super func
	$ConfirmSound.play()
	_confirming = true
	hide()
	_on_UnselectAll_pressed()


func _on_SelectAll_pressed():
	for checkbox in get_tree().get_nodes_in_group("checkboxes"):
		checkbox.set_pressed(true)
	$ActionButtons/Confirm.disabled = false


func _on_UnselectAll_pressed():
	for checkbox in get_tree().get_nodes_in_group("checkboxes"):
		checkbox.set_pressed(false)
	$ActionButtons/Confirm.disabled = true
	
func _on_InverseSelect_pressed():
	var disable = true
	for checkbox in get_tree().get_nodes_in_group("checkboxes"):
		checkbox.set_pressed(!checkbox.is_pressed())
		if checkbox.is_pressed():
			disable = false
	$ActionButtons/Confirm.disabled = disable

# title to be sorted
func _on_title_sorting_click(label, object):
	# get clicked title
	_clicked_label = label.text
	# click again to change ordering
	match _current_order:
		_sorting_order.DEFAULT:
			_current_order = _sorting_order.DESC
		_sorting_order.DESC:
			_current_order = _sorting_order.ASC
		_sorting_order.ASC:
			_current_order = _sorting_order.DESC
	# update the list
	show_data(object)	

# sort the list
func _sorting_list(list_copy):	
	if list_copy.size() != 0:
		list_copy.sort_custom(self,"_custom_comparison")
		# default comparison is in ascending order
		match _current_order:
			_sorting_order.DESC:
				list_copy.invert()
	return list_copy

# get value that need to be compared
func _get_compare_value(a, b):
	var a1 = ""
	var b1 = ""
	# Person List
	if _selected_table == "person_list":
		if _clicked_label == tr("PERSON_NAME"):
			a1 = a.get_name()
			b1 = b.get_name()
		elif _clicked_label == tr("BELONGED_ARCHITECTURE"):
			a1 = a.get_location().get_name()
			b1 = b.get_location().get_name()
		elif _clicked_label == tr("STATUS"):
			a1 = a.get_status_str()
			b1 = b.get_status_str()
		elif _clicked_label == tr("GENDER"):
			a1 = a.get_gender_str()
			b1 = b.get_gender_str()
		elif _clicked_label == tr("AGE"):
			a1 = a.get_age()
			b1 = b.get_age()
		elif _clicked_label == tr("MERIT"):
			a1 = a.get_merit()
			b1 = b.get_merit()
		elif _clicked_label == tr("POPULARITY"):
			a1 = a.get_popularity()
			b1 = b.get_popularity()
		elif _clicked_label == tr("PRESTIGE"):
			a1 = a.get_prestige()
			b1 = b.get_prestige()
		elif _clicked_label == tr("KARMA"):
			a1 = a.get_karma()
			b1 = b.get_karma()
		elif _clicked_label == tr("TASK"):
			a1 = a.get_working_task_str()
			b1 = b.get_working_task_str()
		elif _clicked_label == tr("TASK_DAYS"):
			a1 = a.task_days
			b1 = b.task_days
		elif _clicked_label == tr("COMMAND"):
			a1 = a.get_command()
			b1 = b.get_command()
		elif _clicked_label == tr("STRENGTH"):
			a1 = a.get_strength()
			b1 = b.get_strength()
		elif _clicked_label == tr("INTELLIGENCE"):
			a1 = a.get_intelligence()
			b1 = b.get_intelligence()
		elif _clicked_label == tr("POLITICS"):
			a1 = a.get_politics()
			b1 = b.get_politics()
		elif _clicked_label == tr("GLAMOUR"):
			a1 = a.get_glamour()
			b1 = b.get_glamour()
		elif _clicked_label == tr("COMMAND_EXPERIENCE"):
			a1 = a.command_exp
			b1 = b.command_exp
		elif _clicked_label == tr("STRENGTH_EXPERIENCE"):
			a1 = a.strength_exp
			b1 = b.strength_exp
		elif _clicked_label == tr("INTELLIGENCE_EXPERIENCE"):
			a1 = a.intelligence_exp
			b1 = b.intelligence_exp
		elif _clicked_label == tr("POLITICS_EXPERIENCE"):
			a1 = a.politics_exp
			b1 = b.politics_exp
		elif _clicked_label == tr("GLAMOUR_EXPERIENCE"):
			a1 = a.glamour_exp
			b1 = b.glamour_exp
		elif _clicked_label == tr("AGRICULTURE_ABILITY"):
			a1 = a.get_agriculture_ability()
			b1 = b.get_agriculture_ability()
		elif _clicked_label == tr("COMMERCE_ABILITY"):
			a1 = a.get_commerce_ability()
			b1 = b.get_commerce_ability()
		elif _clicked_label == tr("MORALE_ABILITY"):
			a1 = a.get_morale_ability()
			b1 = b.get_morale_ability()
		elif _clicked_label == tr("ENDURANCE_ABILITY"):
			a1 = a.get_endurance_ability()
			b1 = b.get_endurance_ability()
		elif _clicked_label == tr("PRODUCING_EQUIPMENT_TYPE"):
			a1 = a.get_producing_equipment_name()
			b1 = b.get_producing_equipment_name()
		elif _clicked_label == tr("RECRUIT_ABILITY"):
			a1 = a.get_recruit_troop_ability()
			b1 = b.get_recruit_troop_ability()
		elif _clicked_label == tr("TRAIN_ABILITY"):
			a1 = a.get_train_troop_ability()
			b1 = b.get_train_troop_ability()
		elif _clicked_label == tr("PRODUCE_EQUIPMENT_ABILITY"):
			a1 = a.get_produce_equipment_ability()
			b1 = b.get_produce_equipment_ability()
		elif _clicked_label == tr("FATHER"):
			a1 = a.get_father_name()
			b1 = b.get_father_name()
		elif _clicked_label == tr("MOTHER"):
			a1 = a.get_mother_name()
			b1 = b.get_mother_name()
		elif _clicked_label == tr("SPOUSE"):
			a1 = a.get_spouse_names()
			b1 = b.get_spouse_names()
		elif _clicked_label == tr("BROTHER"):
			a1 = a.get_brother_names()
			b1 = b.get_brother_names()
	elif _selected_table == "architecture_list":
		# Architecture List
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
	elif _selected_table == "faction_list":
		# Faction List
		if _clicked_label == tr("FACTION_NAME"):
			a1 = a.get_name()
			b1 = b.get_name()
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
	elif _selected_table == "military_kind_list":
		# Military Kind List
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
	return [a1, b1]
	
# ascending comparison
func _custom_comparison(a, b):
	var a1 = _get_compare_value(a, b)[0]
	var b1 = _get_compare_value(a, b)[1]
	if typeof(a1) != typeof(b1):
		if typeof(a1) in _TYPE_ORDER and typeof(b1) in _TYPE_ORDER:
			return _TYPE_ORDER.find( typeof(a1) ) < _TYPE_ORDER.find( typeof(b1) )
		else:
			return typeof(a1) < typeof(b1)
	else:
		return a1 < b1
