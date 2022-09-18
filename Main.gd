extends Node
class_name Main

signal all_loaded

# Called when the node enters the scene tree for the first time.
func _ready():
	$Scenario/MainCamera.bottom_ui_margin = ($UICanvas/UIMain/Toolbar as Panel).size.y
	
	$Scenario.connect("current_faction_set",Callable($UICanvas/UIMain/ScreenBlind,"show_current_faction"))
	
	_register_date_runner()
	_register_architecture_ui()
	_register_troop_ui()
	_register_game_record_ui()
	_register_lists()
	_register_detail_page_edits()
	_register_menus()
	_register_misc_uis()
	
	$UICanvas/UIMain/FactionSurvey.connect("focus_camera",Callable($Scenario,"_on_focus_camera"))
	$Scenario.connect("faction_survey_updated",Callable($UICanvas/UIMain/FactionSurvey,"update_data"))
	$Scenario.connect("person_move_clicked",Callable($UICanvas/UIMain/FactionSurvey,"update_data"))
	
	$UICanvas/UIMain/CreateTroop.connect("create_troop_select_position",Callable($Scenario/PositionSelector,"_on_create_troop"))
	$Scenario.connect("create_troop_from_attached_army_select_position",Callable($Scenario/PositionSelector,"_on_create_troop"))
	
	$UICanvas/UIMain.connect("cancel_ui",Callable($Scenario/PositionSelector,"_on_cancel_ui"))
	
	_register_map_ui()
	
	$Scenario.connect("mouse_moved_to_map_position",Callable($UICanvas/UIMain,"_on_mouse_moved_to_map_posiiton"))
	
	_all_loaded()

func _register_architecture_ui():
	$Scenario.connect("architecture_clicked",Callable($UICanvas/UIMain/ArchitectureSurvey,"show_data"))
	$Scenario.connect("architecture_survey_updated",Callable($UICanvas/UIMain/ArchitectureSurvey,"update_data"))
	$Scenario.connect("architecture_clicked",Callable($UICanvas/UIMain/ArchitectureMenu,"show_menu"))

func _register_troop_ui():
	$Scenario.connect("troop_clicked",Callable($UICanvas/UIMain/TroopMenu,"show_menu"))
	$Scenario.connect("architecture_and_troop_clicked",Callable($UICanvas/UIMain/ArchitectureAndTroopMenu,"show_menu"))
	
	$Scenario.connect("troop_clicked",Callable($UICanvas/UIMain/TroopSurvey,"show_data"))
	$Scenario.connect("troop_survey_updated",Callable($UICanvas/UIMain/TroopSurvey,"update_data"))
	
func _register_game_record_ui():
	$Scenario/GameRecordCreator.connect("add_game_record",Callable($UICanvas/UIMain/GameRecord,"add_text"))
	$UICanvas/UIMain/GameRecord.connect("focus_camera",Callable($Scenario,"_on_focus_camera"))
	
	$Scenario/GameRecordCreator.connect("add_person_bubble",Callable($UICanvas/UIMain/PersonBubble,"show_bubble"))
	
	$Scenario/GameRecordCreator.connect("add_person_dialog",Callable($UICanvas/UIMain/PersonDialog,"show_dialog"))

func _register_date_runner():
	$Scenario/DateRunner.connect("date_updated",Callable($UICanvas/UIMain/ScreenBlind,"show_date"))
	$UICanvas/UIMain/Toolbar.connect("start_date_runner",Callable($Scenario/DateRunner,"_on_start_date_runner"))
	$UICanvas/UIMain/Toolbar.connect("stop_date_runner",Callable($Scenario/DateRunner,"_on_stop_date_runner"))
	$Scenario/DateRunner.connect("day_passed",Callable($UICanvas/UIMain/Toolbar,"_on_day_passed"))
	$Scenario/DateRunner.connect("season_passed",Callable($UICanvas/UIMain/BGM,"_on_season_passed"))
	$Scenario/DateRunner.connect("date_runner_stopped",Callable($UICanvas/UIMain,"_on_date_runner_stopped"))
	
func _register_lists():
	$UICanvas/UIMain/PersonList.connect("person_selected",Callable($Scenario,"_on_person_selected"))
	$UICanvas/UIMain/ArchitectureList.connect("architecture_selected",Callable($Scenario,"_on_architecture_selected"))
	$UICanvas/UIMain/MilitaryKindList.connect("military_kind_selected",Callable($Scenario,"_on_military_kind_selected"))
	$UICanvas/UIMain/AttachedArmyList.connect("attached_army_selected",Callable($Scenario,"_on_attached_army_selected"))


func _register_detail_page_edits():
	$UICanvas/UIMain/PersonDetail.connect("on_select_skills",Callable($UICanvas/UIMain/InfoList,"_on_PersonDetail_edit_skills_clicked"))
	$UICanvas/UIMain/PersonDetail.connect("on_select_stunts",Callable($UICanvas/UIMain/InfoList,"_on_PersonDetail_edit_stunts_clicked"))
	
	$UICanvas/UIMain/InfoList.connect("edit_skill_item_selected",Callable($UICanvas/UIMain/PersonDetail,"_on_InfoList_edit_skill_item_selected"))
	$UICanvas/UIMain/InfoList.connect("edit_stunt_item_selected",Callable($UICanvas/UIMain/PersonDetail,"_on_InfoList_edit_stunt_item_selected"))
	
	
func _register_menus():
	$Scenario.connect("current_faction_set",Callable($UICanvas/UIMain/SaveLoadMenu,"_on_faction_updated"))
	
	$UICanvas/UIMain/ArchitectureMenu.connect("architecture_toggle_auto_task",Callable($Scenario,"on_architecture_toggle_auto_task"))
	$UICanvas/UIMain/ArchitectureMenu.connect("remove_advisor",Callable($Scenario,"on_architecture_remove_advisor"))
	$UICanvas/UIMain/ArchitectureMenu.connect("auto_convince",Callable($Scenario,"on_architecture_auto_convince"))
	
	$UICanvas/UIMain/SaveLoadMenu.connect("file_slot_clicked",Callable($Scenario,"_on_file_slot_clicked"))
	
	$UICanvas/UIMain/InfoMenu.connect("military_kind_clicked",Callable($UICanvas/UIMain/MilitaryKindList,"_on_InfoMenu_military_kind_clicked").bind($Scenario))
	$UICanvas/UIMain/InfoMenu.connect("factions_clicked",Callable($UICanvas/UIMain/FactionList,"_on_InfoMenu_factions_clicked").bind($Scenario))
	$UICanvas/UIMain/InfoMenu.connect("architectures_clicked",Callable($UICanvas/UIMain/ArchitectureList,"_on_InfoMenu_architectures_clicked").bind($Scenario))
	$UICanvas/UIMain/InfoMenu.connect("persons_clicked",Callable($UICanvas/UIMain/PersonList,"_on_InfoMenu_persons_clicked").bind($Scenario))
	$UICanvas/UIMain/InfoMenu.connect("skills_clicked",Callable($UICanvas/UIMain/InfoList,"_on_InfoMenu_skills_clicked").bind($Scenario))
	$UICanvas/UIMain/InfoMenu.connect("stunts_clicked",Callable($UICanvas/UIMain/InfoList,"_on_InfoMenu_stunts_clicked").bind($Scenario))
	
	$UICanvas/UIMain/TroopMenu.connect("move_clicked",Callable($Scenario,"_on_troop_move_clicked"))
	$UICanvas/UIMain/TroopMenu.connect("attack_clicked",Callable($Scenario,"_on_troop_attack_clicked"))
	$UICanvas/UIMain/TroopMenu.connect("stunt_clicked",Callable($Scenario,"_on_troop_stunt_clicked"))
	$UICanvas/UIMain/TroopMenu.connect("enter_clicked",Callable($Scenario,"_on_troop_enter_clicked"))
	$UICanvas/UIMain/TroopMenu.connect("follow_clicked",Callable($Scenario,"_on_troop_follow_clicked"))
	$UICanvas/UIMain/TroopMenu.connect("occupy_clicked",Callable($Scenario,"_on_troop_occupy_clicked"))

func _register_map_ui():
	$Scenario.connect("empty_space_right_clicked",Callable($UICanvas/UIMain,"_on_right_click_blank_space"))
	
	$Scenario.connect("scenario_camera_moved",Callable($UICanvas/UIMain/Map,"_on_camera_moved"))
	$Scenario.connect("scenario_architecture_faction_changed",Callable($UICanvas/UIMain/Map,"_on_architecture_faction_changed"))
	
	$Scenario.connect("scenario_troop_position_changed",Callable($UICanvas/UIMain/Map,"_on_troop_position_changed"))
	$Scenario.connect("scenario_troop_created",Callable($UICanvas/UIMain/Map,"_on_troop_created"))
	$Scenario.connect("scenario_troop_removed",Callable($UICanvas/UIMain/Map,"_on_troop_removed"))
	
	$UICanvas/UIMain/Map.connect("focus_camera",Callable($Scenario,"_on_focus_camera"))
	
func _register_misc_uis():
	$UICanvas/UIMain/TransportDialog.connect("confirm_transport_resources",Callable($Scenario,"_on_confirm_transport_resources"))

func _all_loaded():
	connect("all_loaded",Callable($Scenario,"_on_all_loaded"))
	connect("all_loaded",Callable($Scenario/DateRunner,"_on_all_loaded"))
	connect("all_loaded",Callable($UICanvas/UIMain/FactionSurvey,"_on_all_loaded").bind($Scenario))
	connect("all_loaded",Callable($UICanvas/UIMain/BGM,"_on_all_loaded").bind($Scenario))
	
	call_deferred("emit_signal", "all_loaded")
