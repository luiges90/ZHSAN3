extends Panel
class_name TabList

const TITLE_COLOR = Color(0.04, 0.53, 0.79)

var current_action
var current_architecture

var _confirming

var _max_selection = -1

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
	
	var any_checked = false
	for checkbox in get_tree().get_nodes_in_group("checkboxes"):
		if checkbox.is_pressed():
			any_checked = true
			break
	for group in in_cb.get_groups():
		if group.find("id_") >= 0:
			for checkbox in get_tree().get_nodes_in_group(group):
				checkbox.set_pressed(in_cb.is_pressed())
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
