extends Panel
class_name TroopSurvey

var showing_troop

func show_data(troop: Troop, mouse_x: int, mouse_y: int, right_clicked: bool):
	showing_troop = troop
	
	var faction = troop.get_belonged_faction()
	if faction:
		($Content/Faction/Color as ColorRect).color = faction.color
		($Content/Faction/Text as Label).text = faction.gname
	else:
		($Content/Faction/Color as ColorRect).color = Color(1, 1, 1)
		($Content/Faction/Text as Label).text = "----"
	$TitlePanel/Title.text = troop.get_name()
	
	$Content/MilitaryKind.text = troop.military_kind.get_name()
	$Content/Quantity.text = Util.nstr(troop.quantity)
	$Content/Morale.text = str(troop.morale)
	$Content/Combativity.text = str(troop.combativity)
	
	$Content/Offence.text = Util.nstr(troop.get_offence())
	$Content/Defence.text = Util.nstr(troop.get_defence())
	
	show()
	

func update_data(troop: Troop):
	if showing_troop == null:
		return
	if troop.id == showing_troop.id:
		show_data(troop, 0, 0, false)

func _on_TroopSurvey_hide():
	showing_troop = null
