extends Panel
class_name TroopDetail

var current_troop

func _on_CreateTroop_hide():
	$Cancel.play()
	
func _on_TroopMenu_troop_detail_clicked(troop):
	current_troop = troop
	set_data()
	show()

func set_data():
	Util.delete_all_children($PersonList)
	
	$Title.text = current_troop.get_name()
	
	$Morale.text = str(current_troop.morale)
	$Combativity.text = str(current_troop.combativity)

	for p in current_troop.get_persons():
		var label = Label.new()
		label.text = p.get_name()
		$PersonList.add_child(label)
	
	$Leader.text = current_troop.get_leader().get_name()
	$MilitaryKind.text = current_troop.military_kind.get_name()
	
	$Order.text = tr(current_troop.get_order_text())
	$Target.text = current_troop.get_order_target_text()

	$Quantity.text = str(current_troop.quantity)
	$Offence.text = str(current_troop.get_offence())
	$Defence.text = str(current_troop.get_defence())
	$Speed.text = str(current_troop.get_speed())
	$Initiative.text = str(current_troop.get_initiative())

