extends TabList
class_name FactionSurvey

export var full_size = 632
export var minimize_size = 60
var hidden = false

func _ready():
	$Tabs.set_tab_title(0, tr('ARCHITECTURE'))
	$Tabs.remove_child($Tabs/Tab2)
	$Tabs.remove_child($Tabs/Tab3)
	$Tabs.remove_child($Tabs/Tab4)

func show_data(faction):
	$Title.text = faction.get_name()

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
