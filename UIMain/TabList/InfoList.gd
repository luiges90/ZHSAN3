extends TabList
class_name InfoList

func _ready():
	_add_tab('BASIC')
	

func _on_InfoMenu_skills_clicked(scenario):
	$Title.text = tr('SKILL_LIST')
	show_data(scenario.skills)
	show()

func show_data(data):
	var item_list = tabs['BASIC'] as GridContainer
	Util.delete_all_children(item_list)
	
	item_list.columns = 3
	item_list.add_child(_title(tr('ID')))
	item_list.add_child(_title(tr('NAME')))
	item_list.add_child(_title(tr('DESCRIPTION')))

	for i in data:
		var item = data[i]
		var color = item.get_color() if item.has_method('get_color') else null
		
		item_list.add_child(_label(str(item.id)))
		item_list.add_child(_label(item.get_name(), color))
		item_list.add_child(_label(item.description))
		

