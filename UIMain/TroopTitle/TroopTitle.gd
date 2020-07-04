extends Control
class_name TroopTitle

var texture_food
var texture_food_shortage
func _init():
	texture_food = preload("res://UIMain/TroopTitle/FoodNormal.png")
	texture_food_shortage = preload("res://UIMain/TroopTitle/FoodShortage.png")

func show_data(troop: Troop):
	$Background/Morale.rect_scale.x = troop.morale / 100.0 * 0.75
	$Background/Combativity.rect_scale.x = troop.combativity / 100.0 * 0.75

	$Background/LeaderName.text = troop.get_leader().get_name()
	$Background/TroopQuantity.text = str(troop.quantity)
	$FlagBackground/FlagFaction.modulate = troop.get_belonged_faction().color
	$FlagBackground/FlagText.text = troop.get_leader().surname
	
	$Background/FoodStatus.texture = texture_food_shortage if troop._food_shortage else texture_food
