extends TabList
class_name FactionSurvey

func _ready():
	$Tabs.set_tab_title(0, tr('ARCHITECTURE'))
	$Tabs.remove_child($Tabs/Tab2)
	$Tabs.remove_child($Tabs/Tab3)
	$Tabs.remove_child($Tabs/Tab4)

func show_data(faction):
	$Title.text = faction.get_name()

func _on_current_faction_set(faction):
	show_data(faction)
