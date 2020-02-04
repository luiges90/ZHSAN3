extends Panel
class_name ArchitectureSurvey

func show_data(architecture: Architecture):
	($TitlePanel/Title as Label).text = architecture.gname
	var faction = architecture.get_belonged_faction()
	if faction:
		($Content/Faction/Text/Color as ColorRect).color = faction.color
		($Content/Faction/Text/Text as Label).text = faction.gname
	else:
		($Content/Faction/Text/Color as ColorRect).color = Color(1, 1, 1)
		($Content/Faction/Text/Text as Label).text = "----"
	($Content/PersonCount/Text as Label).text = str(architecture.get_persons().size())
	
	show()
