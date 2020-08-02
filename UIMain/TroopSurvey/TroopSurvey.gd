extends Panel
class_name TroopSurvey

var showing_troop

func show_data(troop: Troop, mouse_x: int, mouse_y: int):
	showing_troop = troop
	
	$TitlePanel/Title.text = troop.get_name()
	
	show()
	



func _on_TroopSurvey_hide():
	showing_troop = null
