extends Node
class_name Main

signal all_loaded

# Called when the node enters the scene tree for the first time.
func _ready():
	$Scenario/MainCamera.bottom_ui_margin = ($UICanvas/UIMain/Toolbar as Panel).rect_size.y
	
	$Scenario.connect("current_faction_set", $UICanvas/UIMain/ScreenBlind, "show_current_faction")
	
	_register_date_runner()
	_register_architecture_ui()
	_register_troop_ui()
	_register_game_record_ui()
	_register_lists()
	_register_menus()
	
	$UICanvas/UIMain/CreateTroop.connect("create_troop_select_position", $Scenario/PositionSelector, "_on_create_troop")
	$UICanvas/UIMain.connect("cancel_ui", $Scenario/PositionSelector, "_on_cancel_ui")
	
	$Scenario.connect("scenario_camera_moved", $UICanvas/UIMain/Map, "_on_camera_moved")
	
	$Scenario.connect("mouse_moved_to_map_position", $UICanvas/UIMain, "_on_mouse_moved_to_map_posiiton")
	
	_all_loaded()

func _register_architecture_ui():
	$Scenario.connect("architecture_clicked", $UICanvas/UIMain/ArchitectureSurvey, "show_data")
	$Scenario.connect("architecture_survey_updated", $UICanvas/UIMain/ArchitectureSurvey, "update_data")
	$Scenario.connect("architecture_clicked", $UICanvas/UIMain/ArchitectureMenu, "show_menu")

func _register_troop_ui():
	$Scenario.connect("troop_clicked", $UICanvas/UIMain/TroopMenu, "show_menu")
	$Scenario.connect("architecture_and_troop_clicked", $UICanvas/UIMain/ArchitectureAndTroopMenu, "show_menu")
	
func _register_game_record_ui():
	$Scenario/GameRecordCreator.connect("add_game_record", $UICanvas/UIMain/GameRecord, "add_text")
	$UICanvas/UIMain/GameRecord.connect("focus_camera", $Scenario, "_on_focus_camera")

func _register_date_runner():
	$Scenario/DateRunner.connect("date_updated", $UICanvas/UIMain/ScreenBlind, "show_date")
	$UICanvas/UIMain/Toolbar.connect("start_date_runner", $Scenario/DateRunner, "_on_start_date_runner")
	$UICanvas/UIMain/Toolbar.connect("stop_date_runner", $Scenario/DateRunner, "_on_stop_date_runner")
	$Scenario/DateRunner.connect("day_passed", $UICanvas/UIMain/Toolbar, "_on_day_passed")
	
func _register_lists():
	$UICanvas/UIMain/PersonList.connect("person_selected", $Scenario, "_on_person_selected")
	$UICanvas/UIMain/ArchitectureList.connect("architecture_selected", $Scenario, "_on_architecture_selected")
	$UICanvas/UIMain/MilitaryKindList.connect("military_kind_selected", $Scenario, "_on_military_kind_selected")
	
func _register_menus():
	$Scenario.connect("current_faction_set", $UICanvas/UIMain/SaveLoadMenu, "_on_faction_updated")
	$UICanvas/UIMain/ArchitectureMenu.connect("architecture_toggle_auto_task", $Scenario, "on_architecture_toggle_auto_task")
	
	$UICanvas/UIMain/SaveLoadMenu.connect("file_slot_clicked", $Scenario, "_on_file_slot_clicked")
	
	$UICanvas/UIMain/InfoMenu.connect("military_kind_clicked", $UICanvas/UIMain/MilitaryKindList, "_on_InfoMenu_military_kind_clicked", [$Scenario])
	
	$UICanvas/UIMain/TroopMenu.connect("move_clicked", $Scenario, "_on_troop_move_clicked")
	$UICanvas/UIMain/TroopMenu.connect("attack_clicked", $Scenario, "_on_troop_attack_clicked")
	$UICanvas/UIMain/TroopMenu.connect("enter_clicked", $Scenario, "_on_troop_enter_clicked")
	$UICanvas/UIMain/TroopMenu.connect("follow_clicked", $Scenario, "_on_troop_follow_clicked")
	$UICanvas/UIMain/TroopMenu.connect("occupy_clicked", $Scenario, "_on_troop_occupy_clicked")


func _all_loaded():
	connect("all_loaded", $Scenario, "_on_all_loaded")
	connect("all_loaded", $Scenario/DateRunner, "_on_all_loaded")
	
	emit_signal("all_loaded")
