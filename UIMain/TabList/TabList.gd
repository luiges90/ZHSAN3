extends Panel
class_name TabList

const TITLE_COLOR = Color(0.04, 0.53, 0.79)

var current_action
var current_architecture

var _confirming

func show_data(list: Array):
	# Subclasses should override this
	pass

func _label(text: String):
	var label = Label.new()
	label.text = text
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
	return checkbox
	
func _checkbox_changed(in_cb: CheckBox):
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


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			hide()


func _on_TabList_hide():
	if GameConfig.se_enabled and not _confirming:
		$CloseSound.play()
	_confirming = false


func _on_Cancel_pressed():
	hide()


func _on_Confirm_pressed():
	# Subclasses should handle their action types, and then invoke super func
	$ConfirmSound.play()
	_confirming = true
	hide()


func _on_SelectAll_pressed():
	for checkbox in get_tree().get_nodes_in_group("checkboxes"):
		checkbox.set_pressed(true)
	$ActionButtons/Confirm.disabled = false


func _on_UnselectAll_pressed():
	for checkbox in get_tree().get_nodes_in_group("checkboxes"):
		checkbox.set_pressed(false)
	$ActionButtons/Confirm.disabled = true
