extends Node
class_name Main

signal all_loaded

# Called when the node enters the scene tree for the first time.
func _ready():
	$Scenario/MainCamera.bottom_ui_margin = ($UICanvas/UIMain/Toolbar as Panel).rect_size.y
	
	$Scenario/DateRunner.connect("date_updated", $UICanvas/UIMain/ScreenBlind, "show_date")
	$Scenario.connect("player_faction_set", $UICanvas/UIMain/ScreenBlind, "show_player_faction")
	
	$UICanvas/UIMain/Toolbar.connect("start_date_runner", $Scenario/DateRunner, "_on_start_date_runner")
	$UICanvas/UIMain/Toolbar.connect("stop_date_runner", $Scenario/DateRunner, "_on_stop_date_runner")
	$Scenario/DateRunner.connect("day_passed", $UICanvas/UIMain/Toolbar, "_on_day_passed")
	
	$Scenario.connect("architecture_clicked", $UICanvas/UIMain/ArchitectureSurvey, "show_data")
	$Scenario.connect("architecture_survey_updated", $UICanvas/UIMain/ArchitectureSurvey, "update_data")
	$Scenario.connect("architecture_person_list_clicked", $UICanvas/UIMain/PersonList, "show_data")
	
	connect("all_loaded", $Scenario, "_on_all_loaded")
	connect("all_loaded", $Scenario/DateRunner, "_on_all_loaded")
	connect("all_loaded", $Scenario/MainCamera, "_on_all_loaded")
	
	emit_signal("all_loaded")
