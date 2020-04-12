extends Panel
class_name CreateTroop

signal select_person
signal select_leader

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


func _on_PersonList_person_selected(action, arch, selected):
	if action == PersonList.Action.SELECT_TROOP_PERSON:
		current_troop.set_persons(current_architecture.scenario.get_persons_from_ids(selected))
	elif action == PersonList.Action.SELECT_TROOP_LEADER:
		var selected_person = current_architecture.scenario.persons[selected[0]]
		var persons = current_troop.get_persons()
		var index = persons.find(selected_person)
		persons.remove(index)
		persons.push_front(selected_person)
		current_troop.set_persons(persons)
	set_data()
	
	
func set_data():
	Util.delete_all_children($PersonList)
	for p in current_troop.get_persons():
		var label = Label.new()
		label.text = p.get_name()
		$PersonList.add_child(label)
	$SelectLeader.disabled = current_troop.get_persons().size() <= 1


func _on_SelectLeader_pressed():
	if GameConfig.se_enabled:
		($Select as AudioStreamPlayer).play()
	emit_signal("select_leader", current_architecture, current_troop.get_persons())
