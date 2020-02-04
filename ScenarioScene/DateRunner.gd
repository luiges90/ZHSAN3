extends Node
class_name DateRunner

enum Season { SPRING, SUMMER, AUTUMN, WINTER }

var year: int
var month: int
var day: int

var scenario

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func get_season():
	if month >= 3 and month <= 5:
		return Season.SPRING
	if month >= 6 and month <= 8:
		return Season.SUMMER
	if month >= 9 and month <= 11:
		return Season.AUTUMN
	return Season.WINTER

func add_day():
	day += 1
	invoke_date_updated()
	
func invoke_date_updated():
	find_parent("Main").emit_signal("date_updated", year, month, day, get_season())
