extends Control
class_name TroopTitle

func show_data(troop: Troop):
	var morale = $Background/Morale as TextureRect
	(morale.texture as AtlasTexture).region.position.y = troop.morale / 100.0 * 54
	morale.rect_position.y = troop.morale / 100.0 * 54 + 2
	
	var combativity = $Background/Combativity as TextureRect
	(combativity.texture as AtlasTexture).region.position.y = troop.combativity / 100.0 * 54
	combativity.rect_position.y = troop.combativity / 100.0 * 54 + 2
	
	$Background/LeaderName.text = troop.get_leader().get_name()
	$Background/TroopQuantity.text = str(troop.quantity)
	$FlagBackground/FlagFaction.modulate = troop.get_belonged_faction().color
	$FlagBackground/FlagText.text = troop.get_leader().surname
	
