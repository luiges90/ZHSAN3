extends Node
class_name GameRecordCreator

signal add_game_record

const GREEN = "#00FF00"
const CYAN = "#00FFFF"

func _color_text(color, text) -> String:
	return "[color=" + color + "]" + text + "[/color]"
	
func _register_click(func_name, text) -> String:
	return "[url=\"" + func_name + "\"]" + text + "[/url]"
	
func create_troop(troop, position):
	emit_signal("add_game_record", _register_click("create_troop(" + position.x + "," + position.y + ")",
		tr("GAME_RECORD_CREATE_TROOP") % [
			_color_text(GREEN, troop.get_name()), 
			_color_text(CYAN, troop.get_starting_architecture().get_name())
		])
	)
