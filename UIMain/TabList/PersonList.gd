extends Panel
class_name PersonList

const TITLE_COLOR = Color(0.04, 0.53, 0.79)

func _ready():
	$TabContainer.set_tab_title(0, tr('ABILITY'))
	$TabContainer.set_tab_title(1, tr('INTERNAL'))

func show_data(person_list: Array):
	_populate_ability_data(person_list)
	_populate_internal_data(person_list)
	show()

func _populate_ability_data(person_list: Array):
	var item_list = $TabContainer/Tab1 as ItemList
	item_list.clear()
	item_list.add_item(tr('NAME'), null, false)
	item_list.add_item(tr('COMMAND'), null, false)
	item_list.add_item(tr('STRENGTH'), null, false)
	item_list.add_item(tr('INTELLIGENCE'), null, false)
	item_list.add_item(tr('POLITICS'), null, false)
	item_list.add_item(tr('GLAMOUR'), null, false)
	for i in range(0, item_list.max_columns):
		item_list.set_item_custom_bg_color(i, TITLE_COLOR)
	for person in person_list:
		item_list.add_item(person.get_name())
		item_list.add_item(str(person.command))
		item_list.add_item(str(person.strength))
		item_list.add_item(str(person.intelligence))
		item_list.add_item(str(person.politics))
		item_list.add_item(str(person.glamour))
		
func _populate_internal_data(person_list: Array):
	var item_list = $TabContainer/Tab2 as ItemList
	item_list.clear()
	item_list.add_item(tr('NAME'), null, false)
	item_list.add_item(tr('TASK'), null, false)
	item_list.add_item(tr('AGRICULTURE_ABILITY'), null, false)
	item_list.add_item(tr('COMMERCE_ABILITY'), null, false)
	item_list.add_item(tr('MORALE_ABILITY'), null, false)
	item_list.add_item(tr('ENDURANCE_ABILITY'), null, false)
	for i in range(0, item_list.max_columns):
		item_list.set_item_custom_bg_color(i, TITLE_COLOR)
	for person in person_list:
		item_list.add_item(person.get_name())
		item_list.add_item(str(person.get_working_task_str()))
		item_list.add_item(str(round(person.get_agriculture_ability())))
		item_list.add_item(str(round(person.get_commerce_ability())))
		item_list.add_item(str(round(person.get_morale_ability())))
		item_list.add_item(str(round(person.get_endurance_ability())))

func _on_ArchitectureMenu_person_list_clicked(arch: Architecture):
	show_data(arch.get_persons())


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			hide()


func _on_PersonList_hide():
	if GameConfig.se_enabled:
		$CloseSound.play()
