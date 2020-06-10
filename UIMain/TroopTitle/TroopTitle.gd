extends Control
class_name TroopTitle

func show_data(troop: Troop):
	$Background/Morale.rect_scale.x = troop.morale / 100.0 * 0.75
	$Background/Combativity.rect_scale.x = troop.combativity / 100.0 * 0.75

	$Background/LeaderName.text = troop.get_leader().get_name()
	$Background/TroopQuantity.text = str(troop.quantity)
	$FlagBackground/FlagFaction.modulate = troop.get_belonged_faction().color
	$FlagBackground/FlagText.text = troop.get_leader().surname
	
