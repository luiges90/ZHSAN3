extends AudioStreamPlayer

var spring
var summer
var autumn
var winter

func _init():
	spring = load("res://Music/Spring.ogg")
	summer = load("res://Music/Summer.ogg")
	autumn = load("res://Music/Autumn.ogg")
	winter = load("res://Music/Winter.ogg")

func _on_season_passed(season):
	if season == DateRunner.Season.SPRING:
		stream = spring
		play()
	elif season == DateRunner.Season.SUMMER:
		stream = summer
		play()
	elif season == DateRunner.Season.AUTUMN:
		stream = autumn
		play()
	elif season == DateRunner.Season.WINTER:
		stream = winter
		play()
		
func _on_all_loaded(scenario):
	_on_season_passed(scenario.get_season())
