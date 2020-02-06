extends Panel
class_name ArchitectureSurvey

func show_data(architecture: Architecture):
	($TitlePanel/Title as Label).text = architecture.gname
	var faction = architecture.get_belonged_faction()
	if faction:
		($Content/Faction/Color as ColorRect).color = faction.color
		($Content/Faction/Text as Label).text = faction.gname
	else:
		($Content/Faction/Color as ColorRect).color = Color(1, 1, 1)
		($Content/Faction/Text as Label).text = "----"
	($Content/PersonCount as Label).text = str(architecture.get_persons().size())
	
	($Content/Fund as Label).text = Util.nstr(architecture.get_fund())
	($Content/Food as Label).text = Util.nstr(architecture.get_food())
	($Content/Agriculture as Label).text = Util.nstr(architecture.get_agriculture())
	($Content/Commerce as Label).text = Util.nstr(architecture.get_commerce())
	($Content/Morale as Label).text = Util.nstr(architecture.get_morale())
	($Content/Endurance as Label).text = Util.nstr(architecture.get_endurance())
	
	show()
