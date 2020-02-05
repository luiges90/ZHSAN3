extends Node
class_name Main

signal all_loaded

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("all_loaded", $Scenario, "_on_all_loaded")
	connect("all_loaded", $Scenario/DateRunner, "_on_all_loaded")
	
	$Scenario/DateRunner.connect("date_updated", $UICanvas/UIMain/ScreenBlind, "show_date")
	$Scenario.connect("player_faction_set", $UICanvas/UIMain/ScreenBlind, "show_player_faction")
	
	$Scenario.connect("architecture_clicked", $UICanvas/UIMain/ArchitectureSurvey, "show_data")
	
	emit_signal("all_loaded")
