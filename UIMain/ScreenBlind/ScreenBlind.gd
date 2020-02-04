extends Control
class_name ScreenBlind
	
func show_date(year, month, day, season):
	($OverviewPanel/Content/Date/Text as Label).text = \
		str(year) + tr("YEAR") + str(month) + tr("MONTH") + str(day) + tr("DAY")
	var season_texture
	match season:
		DateRunner.Season.SPRING: 
			season_texture = load("res://UIMain/ScreenBlind/Spring.png")
		DateRunner.Season.SUMMER: 
			season_texture = load("res://UIMain/ScreenBlind/Summer.png")
		DateRunner.Season.AUTUMN: 
			season_texture = load("res://UIMain/ScreenBlind/Autumn.png")
		DateRunner.Season.WINTER: 
			season_texture = load("res://UIMain/ScreenBlind/Winter.png")
	($Season as TextureRect).texture = season_texture
