extends Node

var day_per_turn = 3

var bgm_enabled = true
var se_enabled = true

var enable_troop_animations = true
var troop_animation_speed = 3

var game_record_limit = 1000

var _use_threads = true
var day_passed_interrupt_time = 800

var dialog_show_time = 5
var bubble_show_time = 2

var radio_button_direct_select = true

var auto_save = true
var auto_save_interval = 60
var auto_save_file_count = 10

var enable_edit = false

var mod_directory = ""

func load_game_config():
	var file_path = "user://game_config.json"
	var file = File.new()
	file.open(file_path, File.READ)
	var obj = parse_json(file.get_as_text())

	if obj != null:
		GameConfig.day_per_turn = obj["day_per_turn"]
	
		GameConfig.bgm_enabled = Util.dict_try_get(obj, "bgm_enabled", true)
		GameConfig.se_enabled = obj["se_enabled"]
	
		GameConfig.enable_troop_animations = obj["enable_troop_animations"]
		GameConfig.troop_animation_speed = obj["troop_animation_speed"]
	
		GameConfig.game_record_limit = obj["game_record_limit"]
	
		GameConfig._use_threads = obj["_use_threads"]
		GameConfig.day_passed_interrupt_time = obj["day_passed_interrupt_time"]
	
		GameConfig.dialog_show_time = obj["dialog_show_time"]
		GameConfig.bubble_show_time = obj["bubble_show_time"]
		
		GameConfig.radio_button_direct_select = obj["radio_button_direct_select"]
	   
		GameConfig.auto_save = obj["auto_save"]
		GameConfig.auto_save_interval = obj["auto_save_interval"]
		GameConfig.auto_save_file_count = obj["auto_save_file_count"]
		
		GameConfig.enable_edit = Util.dict_try_get(obj, "enable_edit", false)

		GameConfig.mod_directory = Util.dict_try_get(obj, "mod_directory", "")

	file.close()

func save_game_config():
	var file_path = "user://game_config.json"
	var file = File.new()
	file.open(file_path, File.WRITE)
	
	var obj = {
		"day_per_turn": GameConfig.day_per_turn,

		"bgm_enabled": GameConfig.bgm_enabled,
		"se_enabled": GameConfig.se_enabled,

		"enable_troop_animations": GameConfig.enable_troop_animations,
		"troop_animation_speed": GameConfig.troop_animation_speed,

		"game_record_limit": GameConfig.game_record_limit,

		"_use_threads": GameConfig._use_threads,
		"day_passed_interrupt_time": GameConfig.day_passed_interrupt_time,

		"dialog_show_time": GameConfig.dialog_show_time,
		"bubble_show_time": GameConfig.bubble_show_time,

		"radio_button_direct_select": GameConfig.radio_button_direct_select,

		"auto_save": GameConfig.auto_save,
		"auto_save_interval": GameConfig.auto_save_interval,
		"auto_save_file_count": GameConfig.auto_save_file_count,
		
		"enable_edit": GameConfig.enable_edit,

		"mod_directory": GameConfig.mod_directory
	}

	file.store_line(to_json(obj))
	file.close()
