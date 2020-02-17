extends Panel
class_name PersonList

func show_data(person_list: Array):
	var item_list = $TabContainer/ABILITY/ItemList as ItemList
	item_list.clear()
	item_list.add_item(tr('NAME'), null, false)
	item_list.add_item(tr('COMMAND'), null, false)
	item_list.add_item(tr('STRENGTH'), null, false)
	item_list.add_item(tr('INTELLIGENCE'), null, false)
	item_list.add_item(tr('POLITICS'), null, false)
	item_list.add_item(tr('GLAMOUR'), null, false)
	for i in range(0, 6):
		item_list.set_item_custom_bg_color(i, Color(0.04, 0.53, 0.79))
	for person in person_list:
		item_list.add_item(person.get_name())
		item_list.add_item(str(person.command))
		item_list.add_item(str(person.strength))
		item_list.add_item(str(person.intelligence))
		item_list.add_item(str(person.politics))
		item_list.add_item(str(person.glamour))
	show()


func _on_ArchitectureMenu_person_list_clicked(arch: Architecture):
	show_data(arch.get_persons())


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			hide()


func _on_PersonList_hide():
	if GameConfig.se_enabled:
		$CloseSound.play()
