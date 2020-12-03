extends Panel
class_name TroopDetail

var current_troop: Troop

func _on_CreateTroop_hide():
	$Cancel.play()
	
func _on_TroopMenu_troop_detail_clicked(troop):
	current_troop = troop
	set_data()
	show()
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			hide()

func set_data():
	Util.delete_all_children($A/H1/V1/PersonList)
	
	$A/Title.text = current_troop.get_name()
	
	$A/H1/Content/Faction.text = current_troop.get_belonged_faction().get_name()
	$A/H1/Content/Section.text = current_troop.get_belonged_section().get_name()
	
	$A/H1/Content/Morale.text = str(current_troop.morale)
	$A/H1/Content/Combativity.text = str(current_troop.combativity)

	for p in current_troop.get_persons():
		var label = Label.new()
		label.text = p.get_name()
		$A/H1/V1/PersonList.add_child(label)
	
	$A/H1/V1/Leader.text = current_troop.get_leader().get_name()
	$A/H1/Content/MilitaryKind.text = current_troop.military_kind.get_name()
	
	$A/H1/Content/Order.text = tr(current_troop.get_order_text())
	$A/H1/Content/Target.text = current_troop.get_order_target_text()

	$A/H1/Content/Quantity.text = str(current_troop.quantity)
	$A/H1/Content/Offence.text = str(current_troop.get_offence())
	$A/H1/Content/Defence.text = str(current_troop.get_defence())
	$A/H1/Content/Speed.text = str(current_troop.get_speed())
	$A/H1/Content/Initiative.text = str(current_troop.get_initiative())
	$A/H1/Content/Critical.text = str(current_troop.critical_chance() * 100) + "%"
	$A/H1/Content/AntiCritical.text = str(current_troop.anti_critical_chance() * 100) + "%"
	$A/H1/Content/CriticalRate.text = "x" + str(current_troop.critical_damage_rate(null))

