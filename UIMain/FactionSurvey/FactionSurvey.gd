extends TabList
class_name FactionSurvey

export var full_size = 632
export var minimize_size = 60
var hidden = false

func _ready():
	$Tabs.set_tab_title(0, tr('ARCHITECTURE_LIST'))
	$Tabs.remove_child($Tabs/Tab2)
	$Tabs.remove_child($Tabs/Tab3)
	$Tabs.remove_child($Tabs/Tab4)

func show_data(faction):
	$Title.text = faction.get_name()
	
	_populate_architecture_data(faction.get_architectures())
	
func _populate_architecture_data(arch_list):
	var item_list = $Tabs/Tab1/Grid as GridContainer
	Util.delete_all_children(item_list)
	item_list.columns = 2
	item_list.add_child(_title(tr('NAME')))
	item_list.add_child(_title(tr('PERSON_COUNT')))
	for arch in arch_list:
		item_list.add_child(_label(arch.get_name()))
		item_list.add_child(_label(str(arch.get_workable_persons().size()) + "/" + str(arch.get_workable_persons().size()) + "/" + str(arch.get_faction_persons().size())))


func _on_current_faction_set(faction):
	show_data(faction)


func _on_Minimize_pressed():
	if not hidden:
		$Tabs.hide()
		rect_size.y = minimize_size
		hidden = true
	else:
		$Tabs.show()
		rect_size.y = full_size
		hidden = false
