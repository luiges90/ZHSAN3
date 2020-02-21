extends Panel
class_name PersonList

enum Action { LIST, AGRICULTURE, COMMERCE, MORALE, ENDURANCE }

const TITLE_COLOR = Color(0.04, 0.53, 0.79)

func _ready():
	$Tabs.set_tab_title(0, tr('ABILITY'))
	$Tabs.set_tab_title(1, tr('INTERNAL'))

func show_data(person_list: Array):
	_populate_ability_data(person_list)
	_populate_internal_data(person_list)
	show()
	
func _label(text: String):
	var label = Label.new()
	label.text = text
	label.theme = theme
	return label
	
func _title(text: String):
	var label = Label.new()
	label.text = text
	label.theme = theme
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = TITLE_COLOR
	label.add_stylebox_override("normal", stylebox)
	return label

func _populate_ability_data(person_list: Array):
	var item_list = $Tabs/Tab1/Grid as GridContainer
	Util.delete_all_children(item_list)
	item_list.add_child(_title(tr('NAME')))
	item_list.add_child(_title(tr('COMMAND')))
	item_list.add_child(_title(tr('STRENGTH')))
	item_list.add_child(_title(tr('INTELLIGENCE')))
	item_list.add_child(_title(tr('POLITICS')))
	item_list.add_child(_title(tr('GLAMOUR')))
	for person in person_list:
		item_list.add_child(_label(person.get_name()))
		item_list.add_child(_label(str(person.command)))
		item_list.add_child(_label(str(person.strength)))
		item_list.add_child(_label(str(person.intelligence)))
		item_list.add_child(_label(str(person.politics)))
		item_list.add_child(_label(str(person.glamour)))
		
func _populate_internal_data(person_list: Array):
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

func _on_ArchitectureMenu_person_list_clicked(arch: Architecture, action):
	show_data(arch.get_persons())


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			hide()


func _on_PersonList_hide():
	if GameConfig.se_enabled:
		$CloseSound.play()
