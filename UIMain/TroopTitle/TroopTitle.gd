extends Control
class_name TroopTitle

onready var morale_height = $Background/Morale.rect_size.y
onready var morale_y = $Background/Morale.rect_position.y
onready var combativity_height = $Background/Combativity.rect_size.y
onready var combativity_y = $Background/Combativity.rect_position.y

func show_data(troop: Troop):
	var morale = $Background/Morale as TextureRect
	(morale.texture as AtlasTexture).region.position.y = troop.morale / 100.0 * morale_height
	morale.rect_position.y = troop.morale / 100.0 * combativity_height
	
	var combativity = $Background/Combativity as TextureRect
	(combativity.texture as AtlasTexture).region.position.y = troop.combativity / 100.0 * combativity_height
	combativity.rect_position.y = troop.combativity / 100.0 * combativity_height
	
	$Background/LeaderName.text = troop.get_leader().get_name()
	$Background/TroopQuantity.text = str(troop.quantity)
	$FlagBackground/FlagFaction.modulate = troop.get_belonged_faction().color
	$FlagBackground/FlagText.text = troop.get_leader().surname
	
