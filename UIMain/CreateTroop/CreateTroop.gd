extends Panel
class_name CreateTroop

signal select_person
signal select_leader
signal select_military_kind
signal create_troop_select_position

var _confirming = false

var current_troop

var current_architecture
var eligible_persons
var eligible_military_kinds

func _on_ArchitectureMenu_architecture_create_troop(arch, persons, military_kinds):
	current_architecture = arch
	eligible_persons = persons
	eligible_military_kinds = military_kinds
	
	$All/H1/V2/H2/QuantitySlider.value = 0
	
	current_troop = CreatingTroop.new()
	current_troop.morale = current_architecture.troop_morale
	current_troop.combativity = current_architecture.troop_combativity
	
	show()
	set_data()
	

func _on_CreateTroop_hide():
	if not _confirming:
		$Cancel.play()
	_confirming = false


func _on_SelectPersons_pressed():
	if GameConfig.se_enabled:
		($Select as AudioStreamPlayer).play()
	call_deferred("emit_signal", "select_person", current_architecture, eligible_persons)

	
func set_data():
	Util.delete_all_children($All/H1/V1/PersonList)
	
	$All/Buttons/SelectLeader.disabled = current_troop.persons.size() <= 1
	$All/H1/V2/C/Morale.text = str(current_troop.morale)
	$All/H1/V2/C/Combativity.text = str(current_troop.combativity)
	
	if current_troop.persons.size() > 0:
		for p in current_troop.persons:
			var label = Label.new()
			label.text = p.get_name()
			$All/H1/V1/PersonList.add_child(label)
	if current_troop.military_kind != null:
		$All/H1/V2/C/MilitaryKind.text = current_troop.military_kind.get_name()
	
	$All/Buttons/Create.disabled = true
	if current_troop.persons.size() > 0 and current_troop.military_kind != null:
		var max_quantity = current_troop.military_kind.max_quantity_multiplier * current_troop.persons[0].get_max_troop_quantity()
		max_quantity = int(max_quantity)
		max_quantity = min(max_quantity, floor(current_architecture.troop / 100) * 100)
		if current_architecture.scenario.military_kinds[current_troop.military_kind.id].has_equipments():
			max_quantity = min(max_quantity, floor(current_architecture.equipments[current_troop.military_kind.id] / 100) * 100)
		$All/H1/V2/H2/H3/Quantity.text = str(current_troop.quantity) + "/" + str(max_quantity)
		$All/H1/V2/H2/QuantitySlider.step = 100
		$All/H1/V2/H2/QuantitySlider.min_value = 0
		$All/H1/V2/H2/QuantitySlider.max_value = max_quantity
		$All/H1/V2/C/Offence.text = str(current_troop.get_offence())
		$All/H1/V2/C/Defence.text = str(current_troop.get_defence())
		$All/H1/V2/C/Speed.text = str(current_troop.get_speed())
		$All/H1/V2/C/Initiative.text = str(current_troop.get_initiative())
		$All/H1/V2/C/Critical.text = str(current_troop.critical_chance() * 100) + "%"
		$All/H1/V2/C/AntiCritical.text = str(current_troop.anti_critical_chance() * 100) + "%"
		$All/H1/V2/C/CriticalRate.text = "x" + str(current_troop.critical_damage_rate())
		
		$All/Buttons/Create.disabled = current_troop.quantity <= 0


func get_available_kinds():
	var available_kinds = []
	for kind in eligible_military_kinds:
		if not current_architecture.scenario.military_kinds[kind].has_equipments() or current_architecture.equipments[kind] > 0:
			available_kinds.append(eligible_military_kinds[kind])
	return available_kinds


func _on_PersonList_person_selected(action, arch, selected):
	if action == PersonList.Action.SELECT_TROOP_PERSON:
		current_troop.persons = current_architecture.scenario.get_persons_from_ids(selected)
		set_data()
	elif action == PersonList.Action.SELECT_TROOP_LEADER:
		var selected_person = current_architecture.scenario.persons[selected[0]]
		var persons = current_troop.persons
		var index = persons.find(selected_person)
		persons.remove(index)
		persons.push_front(selected_person)
		current_troop.persons = persons
		set_data()


func _on_SelectLeader_pressed():
	if GameConfig.se_enabled:
		($Select as AudioStreamPlayer).play()
	call_deferred("emit_signal", "select_leader", current_architecture, current_troop.persons)


func _on_SelectMilitaryKind_pressed():
	if GameConfig.se_enabled:
		($Select as AudioStreamPlayer).play()
	call_deferred("emit_signal", "select_military_kind", current_architecture, get_available_kinds())

func _on_MilitaryKindList_military_kind_selected(current_action, selected_kinds):
	if current_action == MilitaryKindList.Action.SELECT_TROOP_MILITARY_KIND:
		var kind = current_architecture.scenario.military_kinds[selected_kinds[0]]
		current_troop.military_kind = kind
		set_data()


func _on_QuantitySlider_value_changed(value):
	current_troop.quantity = value
	current_troop.morale = current_architecture.troop_morale
	current_troop.combativity = current_architecture.troop_combativity
	set_data()


func _on_Create_pressed():
	_confirming = true
	if GameConfig.se_enabled:
		($Select as AudioStreamPlayer).play()
	call_deferred("emit_signal", "create_troop_select_position", current_architecture, current_troop)
	hide()



