extends Node
class_name Main

signal date_updated
signal architecture_clicked

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("date_updated", $UICanvas/UIMain/ScreenBlind, "show_date")
	($Scenario/DateRunner as DateRunner).invoke_date_updated()
	
	connect("architecture_clicked", $UICanvas/UIMain/ArchitectureSurvey, "show_data")
