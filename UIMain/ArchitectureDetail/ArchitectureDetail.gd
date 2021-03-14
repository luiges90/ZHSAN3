extends Panel
class_name ArchitectureDetail

var current_architecture: Architecture

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			hide()

func set_data():
	$Name.text = current_architecture.get_name()
	
	($Data/Faction/Color as ColorRect).color = current_architecture.get_belonged_faction_color()
	($Data/Faction/Text as Label).text = current_architecture.get_belonged_faction_str()
	($Data/Section as Label).text = current_architecture.get_belonged_section_str()
	$Data/IdlingPersons.text = str(current_architecture.get_idling_persons().size())
	$Data/WorkablePersons.text = str(current_architecture.get_workable_persons().size())
	$Data/FactionPersons.text = str(current_architecture.get_faction_persons().size())
	$Data/WildPersons.text = str(current_architecture.get_wild_persons().size())
	
	$Data/Population.text = "%s (+%s)" % [Util.nstr(current_architecture.population), Util.nstr(current_architecture.expected_population_gain() * 30)]
	$Data/MilitaryPopulation.text = Util.nstr(current_architecture.military_population)
	$Data/Fund.text = "%s (+%s)" % [Util.nstr(current_architecture.fund), Util.nstr(current_architecture.expected_fund_income())]
	$Data/Food.text = "%s (+%s)" % [Util.nstr(current_architecture.food), Util.nstr(current_architecture.expected_food_income())]
	$Data/Agriculture.text = Util.nstr(current_architecture.agriculture)
	$Data/Commerce.text = Util.nstr(current_architecture.commerce)
	$Data/Morale.text = Util.nstr(current_architecture.morale)
	$Data/Endurance.text = Util.nstr(current_architecture.endurance)

	$Data/Troop.text = Util.nstr(current_architecture.troop)
	$Data/TroopMorale.text = Util.nstr(current_architecture.troop_morale)
	$Data/TroopCombativity.text = Util.nstr(current_architecture.troop_combativity)
	$Data/Frontline.text = Util.bstr(current_architecture.is_frontline())
	
	Util.delete_all_children($EquipmentCounts)
	for mk in current_architecture.scenario.military_kinds.values():
		if mk.has_equipments():
			var lbl_title = Label.new()
			lbl_title.text = mk.get_name()
			lbl_title.add_color_override("font_color", Color.cyan)
			$EquipmentCounts.add_child(lbl_title)
			
			var lbl_count = Label.new()
			lbl_count.text = str(current_architecture.equipments[mk.id])
			$EquipmentCounts.add_child(lbl_count)


func _on_ArchitectureList_architecture_row_clicked(arch):
	current_architecture = arch
	set_data()
	show()
