extends Control
class_name TroopTitle

var texture_food
var texture_food_shortage
var action_undone
var action_done

func _init():
	action_done = preload("res://UIMain/TroopTitle/ActionDone.png")
	action_undone = preload("res://UIMain/TroopTitle/ActionUndone.png")
	texture_food = preload("res://UIMain/TroopTitle/FoodNormal.png")
	texture_food_shortage = preload("res://UIMain/TroopTitle/FoodShortage.png")

func show_data(troop: Troop):
	$Background/Morale.rect_scale.x = troop.morale / 100.0
	$Background/Combativity.rect_scale.x = troop.combativity / 100.0
	$Background/Portrait.texture = troop.get_leader().get_portrait()

	$Background/LeaderName.text = troop.get_leader().get_name()
	$Background/TroopQuantity.text = str(troop.quantity)
	$FlagBackground/FlagFaction.modulate = troop.get_belonged_faction().color
	$FlagBackground/FlagText.text = troop.get_leader().surname
	
	$Background/FoodStatus.texture = texture_food_shortage if troop._food_shortage else texture_food
	$Background/ActionStatus.texture = action_done if troop.order_made else action_undone


	
