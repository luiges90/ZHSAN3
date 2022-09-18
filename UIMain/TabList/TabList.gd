extends Panel
class_name TabList

const TITLE_COLOR = Color(0.04, 0.53, 0.79)
# 長按計算時間，單位：毫秒
const LONG_PRESSED_TIME = 500

var current_action
var current_architecture

var _confirming

var _max_selection = -1

var _allow_empty_selection = false

var tabs = {}

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
	connect("mouse_entered",Callable(self,"_on_TabList_mouse_entered"))

func show_data(list):
	# Subclasses should first call super and then override this to show data
	_allow_empty_selection = false
	
func _post_show():
	$ActionButtons/Confirm.disabled = true
	if _max_selection == 1:
		$SelectionButtons/SelectAll.visible = false
		$SelectionButtons/UnselectAll.visible = false
		$SelectionButtons/InverseSelect.visible = false
	else:
		$SelectionButtons/SelectAll.visible = true
		$SelectionButtons/UnselectAll.visible = true
		$SelectionButtons/InverseSelect.visible = true

####################################
# Control generation for subclass  #
####################################
func _label(text: String, color):
	var label = Label.new()
	label.text = text
	if color != null:
		label.add_theme_color_override('font_color', color)
	label.connect("mouse_entered",Callable(self,"_item_mouse_entered").bind(label))
	label.mouse_filter = Control.MOUSE_FILTER_STOP
	return label
	
func _clickable_label(text: String, on_click_func, on_click_func_name, object):
	var label = LinkButton.new()
	label.text = text
	label.underline = LinkButton.UNDERLINE_MODE_NEVER
	label.mouse_default_cursor_shape = Control.CURSOR_ARROW
	label.connect("pressed",Callable(on_click_func,on_click_func_name).bind(label, object))
	label.connect("mouse_entered",Callable(self,"_item_mouse_entered").bind(label))
	label.mouse_filter = Control.MOUSE_FILTER_STOP
	return label

# 帶有長點擊事件的按鈕
func _clickable_label_with_long_pressed_event(text: String, on_click_func, object, checkbox):
	var label = LinkButton.new()
	label.text = text
	label.underline = LinkButton.UNDERLINE_MODE_NEVER
	label.mouse_default_cursor_shape = Control.CURSOR_ARROW
	label.connect("button_down",Callable(self,"_long_pressed_down_event").bind(label))
	label.connect("button_up",Callable(self,"_long_pressed_up_event").bind(label, on_click_func, object, checkbox))
	label.connect("mouse_entered",Callable(self,"_item_mouse_entered").bind(label))
	label.mouse_filter = Control.MOUSE_FILTER_STOP
	return label
	
# for title 
func _title_sorting(text: String, on_click_func, on_click_func_name, object):
	var label = LinkButton.new()
	label.text = text
	label.underline = LinkButton.UNDERLINE_MODE_NEVER
	label.mouse_default_cursor_shape = Control.CURSOR_ARROW
	label.connect("pressed",Callable(on_click_func,on_click_func_name).bind(label, object))
	label.connect("mouse_entered",Callable(self,"_item_mouse_entered").bind(label))
	label.mouse_filter = Control.MOUSE_FILTER_STOP
	return label
	
func _title(text: String):
	var label = Label.new()
	label.text = text
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = TITLE_COLOR
	label.add_theme_stylebox_override("normal", stylebox)
	return label
	
func _checkbox(id: int, checked: bool = false):
	var checkbox 
	checkbox = CheckBox.new()
	checkbox.add_to_group("checkboxes")
	checkbox.add_to_group("id_" + str(id))
	checkbox.set_meta("id", id)
	checkbox.button_pressed = checked
	checkbox.connect("pressed",Callable(self,"_checkbox_changed").bind(checkbox))
	checkbox.connect("mouse_entered",Callable(self,"_item_mouse_entered").bind(checkbox))
	checkbox.mouse_filter = Control.MOUSE_FILTER_STOP
	if _max_selection == 1:
		# We handle radio un/select manually, use separate button group for radio button icon
		checkbox.set_button_group(ButtonGroup.new()) 

	return checkbox
	
func _checkbox_changed(in_cb: CheckBox):
	if _max_selection == 1:
		for checkbox in get_tree().get_nodes_in_group("checkboxes"):
			checkbox.set_pressed(false)
		in_cb.set_pressed(true)
		if GameConfig.radio_button_direct_select:
			_on_Confirm_pressed()
	
	for group in in_cb.get_groups():
		if String(group).find("id_") >= 0:
			for checkbox in get_tree().get_nodes_in_group(group):
				checkbox.set_pressed(in_cb.is_pressed())
				
	var any_checked = false
	for checkbox in get_tree().get_nodes_in_group("checkboxes"):
		if checkbox.is_pressed():
			any_checked = true
			break
	$ActionButtons/Confirm.disabled = not any_checked and not _allow_empty_selection
	
func _checkbox_change_status(checkbox: CheckBox):
	checkbox.set_pressed(!checkbox.is_pressed())
	_checkbox_changed(checkbox)


####################################
#       Input and custom draw      #
####################################
# Override-able method to handle input
# https://godotengine.org/qa/9244/can-override-the-_ready-and-_process-functions-child-classes
func handle_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			hide()

func _input(event):
	handle_input(event)

func _draw():
	if _current_mouseover_rect != null:
		draw_rect(_current_mouseover_rect, Color.WHITE, false, 1.0)

func _item_mouse_entered(label: Control):
	var y = label.global_position.y - global_position.y
	var x = $TabBar.global_position.x - global_position.x
	var width = $TabBar.size.x
	var height = label.size.y
	_current_mouseover_rect = Rect2(x, y, width, height)
	# update()

func _on_TabList_mouse_entered():
	_current_mouseover_rect = null
	# update()

func _add_tab(title, at_position = tabs.size()):
	if tabs.has(title):
		return
	
	var new_tab_container = ScrollContainer.new()
	new_tab_container.anchor_right = 1
	new_tab_container.anchor_bottom = 1
	new_tab_container.offset_top = 42
	new_tab_container.name = tr(title)
	
	var new_tab_data = GridContainer.new()
	new_tab_container.add_child(new_tab_data)
	new_tab_container.add_to_group("tab_" + title)
	$TabBar.add_child(new_tab_container)
	$TabBar.move_child(new_tab_container, at_position)
	
	tabs[title] = new_tab_data

func _remove_tab(title):
	if not tabs.has(title):
		return

	var tab = get_tree().get_nodes_in_group("tab_" + title)[0]
	$TabBar.remove_child(tab)

	tabs.erase(title)

func _long_pressed_down_event(label):
	long_pressed_object_id = label.get_instance_id()
	long_pressed_start_time = Time.get_unix_time_from_system() * 1000
	
func _long_pressed_up_event(label, receiver, object, checkbox):
	if long_pressed_start_time > 0 and long_pressed_object_id > 0:
		if Time.get_unix_time_from_system() * 1000 - long_pressed_start_time > LONG_PRESSED_TIME or checkbox == null:
			call_deferred("emit_signal", "long_pressed_signal", label, receiver, object, checkbox)
		else:
			call_deferred("emit_signal", "single_pressed_signal", label, receiver, object, checkbox)
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
	
func select_items(ids: Array):
	for checkbox in get_tree().get_nodes_in_group("checkboxes"):
		var id = int(checkbox.get_meta("id"))
		if ids.has(id):
			checkbox.set_pressed(true)

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
	$ActionButtons/Confirm.disabled = not _allow_empty_selection
	
func _on_InverseSelect_pressed():
	if _max_selection > 1:
		var disable = true
		for checkbox in get_tree().get_nodes_in_group("checkboxes"):
			checkbox.set_pressed(!checkbox.is_pressed())
			if checkbox.is_pressed():
				disable = false
		$ActionButtons/Confirm.disabled = disable and not _allow_empty_selection

#######################
#       Sorting       #
#######################
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
		list_copy.sort_custom(Callable(self,"_custom_comparison"))
		# default comparison is in ascending order
		match _current_order:
			_sorting_order.DESC:
				list_copy.reverse()
	return list_copy

func __get_compare_value(_clicked_label, a, b):
	# subclasses should override this and return [a, b] for value comparisons for sorting
	pass

# get value that need to be compared
func _get_compare_value(a, b):
	return __get_compare_value(_clicked_label, a, b)
	
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
