extends TabList
class_name FactionSurvey

@export var full_size = 632
@export var minimize_size = 60
var hidden = false

var current_faction
signal focus_camera

func _ready():
	_add_tab('ARCHITECTURE_LIST')

func handle_input(event):
	# do nothing
	pass

func show_data(faction):
	current_faction = faction
	$Title.text = faction.get_name()
	
	_populate_architecture_data(faction.get_architectures())
	
func _populate_architecture_data(arch_list):
	var item_list = tabs['ARCHITECTURE_LIST'] as GridContainer
	Util.delete_all_children(item_list)
	item_list.columns = 3
	item_list.add_child(_title(tr('NAME')))
	item_list.add_child(_title(tr('PERSON_COUNT')))
	item_list.add_child(_title(tr('WILD_PERSON_COUNT')))
	for arch in arch_list:
		item_list.add_child(_clickable_label(arch.get_name(), self, "__on_label_click", arch))
		var person_text = str(arch.get_idling_persons().size()) + "/" + str(arch.get_workable_persons().size()) + "/" + str(arch.get_faction_persons().size())
		item_list.add_child(_clickable_label(person_text, self, "__on_label_click", arch))
		item_list.add_child(_clickable_label(str(arch.get_wild_persons().size()), self, "__on_label_click", arch))

func __on_label_click(label, arch):
	call_deferred("emit_signal", 'focus_camera', arch.map_position)


func _on_all_loaded(scenario):
	show_data(scenario.current_faction)


func update_data():
	if current_faction != null:
		show_data(current_faction)


func _on_Minimize_pressed():
	if not hidden:
		$TabBar.hide()
		size.y = minimize_size
		hidden = true
	else:
		$TabBar.show()
		size.y = full_size
		hidden = false
