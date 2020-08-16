extends Panel
class_name ArchitectureDetail

var current_architecture: Architecture

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
	$Data/TotalEquipment.text = Util.nstr(current_architecture.get_total_equipments())
