extends Node
class_name DateRunner

enum Season { SPRING, SUMMER, AUTUMN, WINTER }

var year: int
var month: int
var day: int

var scenario
var has_player

signal date_updated

signal day_passed
signal month_passed
signal season_passed
signal year_passed
signal date_runner_stopped

var stop_date_runner = false

func get_season():
	if month >= 3 and month <= 5:
		return Season.SPRING
	if month >= 6 and month <= 8:
		return Season.SUMMER
	if month >= 9 and month <= 11:
		return Season.AUTUMN
	return Season.WINTER
	
func _on_all_loaded():
	call_deferred("emit_signal", "date_updated", year, month, day, get_season())

func _on_start_date_runner(day_count):
	while not stop_date_runner:
		day += GameConfig.day_per_turn
		call_deferred("emit_signal", "day_passed")
		if day > 30:
			day -= 30
			month += 1
			call_deferred("emit_signal", "month_passed", month)
			if month == 3 or month == 6 or month == 9 or month == 12:
				call_deferred("emit_signal", "season_passed", get_season())
			if month > 12:
				month -= 12
				year += 1
				call_deferred("emit_signal", "year_passed")
		call_deferred("emit_signal", "date_updated", year, month, day, get_season())
		await scenario.all_faction_finished
	stop_date_runner = false
	call_deferred("emit_signal", "date_runner_stopped")
	
func _on_stop_date_runner():
	if has_player:
		stop_date_runner = true


func _on_Scenario_scenario_loaded(scenario):
	has_player = false
	for f in scenario.factions:
		if scenario.factions[f].player_controlled:
			has_player = true
			break
	
	call_deferred("emit_signal", "date_updated", year, month, day, get_season())
