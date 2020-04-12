extends Panel
class_name CreateTroop

signal select_person

var _confirming = false

var current_troop

var current_architecture
var eligible_persons
var eligible_military_kinds


func _on_ArchitectureMenu_architecture_create_troop(arch, persons, military_kinds):
	current_architecture = arch
	eligible_persons = persons
	eligible_military_kinds = military_kinds
	
	current_troop = Troop.new()
	
	show()
	

func _on_CreateTroop_hide():
	if not _confirming:
		$Cancel.play()


func _on_SelectPersons_pressed():
	if GameConfig.se_enabled:
		($Select as AudioStreamPlayer).play()
	emit_signal("select_person", current_architecture, eligible_persons)


func _on_PersonList_person_selected(current_action, current_architecture, selected):
	current_troop.set_persons(selected)
	set_data()
	
	
func set_data():
	Util.delete_all_children($PersonList)
	for p in current_troop.get_persons():
		var label = Label.new()
		label.text = current_architecture.scenario.persons[p].get_name()
		$PersonList.add_child(label)
