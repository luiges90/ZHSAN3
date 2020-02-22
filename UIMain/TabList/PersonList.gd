extends Panel
class_name PersonList

signal person_selected

enum Action { LIST, AGRICULTURE, COMMERCE, MORALE, ENDURANCE }

const TITLE_COLOR = Color(0.04, 0.53, 0.79)

var current_action = Action.LIST
var current_architecture

var _confirming

func _ready():
	$Tabs.set_tab_title(0, tr('ABILITY'))
	$Tabs.set_tab_title(1, tr('INTERNAL'))

func show_data(person_list: Array):
	match current_action:
		Action.LIST: $Title.text = tr('PERSON_LIST')
		Action.AGRICULTURE: $Title.text = tr('AGRICULTURE')
		Action.COMMERCE: $Title.text = tr('COMMERCE')
		Action.MORALE: $Title.text = tr('MORALE')
		Action.ENDURANCE: $Title.text = tr('ENDURANCE')
	_populate_ability_data(person_list, current_action)
	_populate_internal_data(person_list, current_action)
	show()
	
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
	checkbox.set_meta("person_id", id)
	checkbox.connect("pressed", self, "_checkbox_changed")
	return checkbox
	
func _checkbox_changed():
	var any_checked = false
	for checkbox in get_tree().get_nodes_in_group("checkboxes"):
		if checkbox.is_pressed():
			any_checked = true
			break
	$ActionButtons/Confirm.disabled = not any_checked

func _populate_ability_data(person_list: Array, action):
	var item_list = $Tabs/Tab1/Grid as GridContainer
	Util.delete_all_children(item_list)
	if action != Action.LIST:
		item_list.columns = 7
		item_list.add_child(_title(''))
	else:
		item_list.columns = 6
	item_list.add_child(_title(tr('NAME')))
	item_list.add_child(_title(tr('COMMAND')))
	item_list.add_child(_title(tr('STRENGTH')))
	item_list.add_child(_title(tr('INTELLIGENCE')))
	item_list.add_child(_title(tr('POLITICS')))
	item_list.add_child(_title(tr('GLAMOUR')))
	for person in person_list:
		if action != Action.LIST:
			item_list.add_child(_checkbox(person.id))
		item_list.add_child(_label(person.get_name()))
		item_list.add_child(_label(str(person.command)))
		item_list.add_child(_label(str(person.strength)))
		item_list.add_child(_label(str(person.intelligence)))
		item_list.add_child(_label(str(person.politics)))
		item_list.add_child(_label(str(person.glamour)))
		
func _populate_internal_data(person_list: Array, action):
	var item_list = $Tabs/Tab2/Grid as GridContainer
	Util.delete_all_children(item_list)
	item_list.add_child(_title(tr('NAME')))
	item_list.add_child(_title(tr('TASK')))
	item_list.add_child(_title(tr('AGRICULTURE_ABILITY')))
	item_list.add_child(_title(tr('COMMERCE_ABILITY')))
	item_list.add_child(_title(tr('MORALE_ABILITY')))
	item_list.add_child(_title(tr('ENDURANCE_ABILITY')))
	for person in person_list:
		item_list.add_child(_label(person.get_name()))
		item_list.add_child(_label(str(person.get_working_task_str())))
		item_list.add_child(_label(str(round(person.get_agriculture_ability()))))
		item_list.add_child(_label(str(round(person.get_commerce_ability()))))
		item_list.add_child(_label(str(round(person.get_morale_ability()))))
		item_list.add_child(_label(str(round(person.get_endurance_ability()))))

func _on_ArchitectureMenu_person_list_clicked(arch: int, persons: Array, action):
	current_action = action
	current_architecture = arch
	show_data(persons)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			hide()


func _on_PersonList_hide():
	if GameConfig.se_enabled and not _confirming:
		$CloseSound.play()
	_confirming = false


func _on_Cancel_pressed():
	hide()


func _on_Confirm_pressed():
	var selected_persons = []
	for checkbox in get_tree().get_nodes_in_group("checkboxes"):
		if checkbox.is_pressed():
			selected_persons.append(int(checkbox.get_meta("person_id")))
	var task
	match current_action:
		Action.AGRICULTURE: task = Person.Task.AGRICULTURE
		Action.COMMERCE: task = Person.Task.COMMERCE
		Action.MORALE: task = Person.Task.MORALE
		Action.ENDURANCE: task = Person.Task.ENDURANCE
	emit_signal("person_selected", current_action, current_architecture, selected_persons)
	$ConfirmSound.play()
	_confirming = true
	hide()
