extends Panel

func show_data(person_list: Array):
	var item_list = $TabContainer/ABILITY/ItemList as ItemList
	var list = [tr('NAME'), tr('COMMAND'), tr('STRENGTH'), tr('INTELLIGENCE'), tr('POLITICS'), tr('GLAMOUR')]
	for person in person_list:
		list.push_back(person.get_name())
		list.push_back(person.command)
		list.push_back(person.strength)
		list.push_back(person.intelligence)
		list.push_back(person.politics)
		list.push_back(person.glamour)
	item_list.items = person_list	
