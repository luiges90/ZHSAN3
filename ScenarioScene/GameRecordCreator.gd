extends Node
class_name GameRecordCreator

var _speeches = {}

signal add_game_record
signal add_person_bubble

const GREEN = "#00FF00"
const CYAN = "#00FFFF"
const RED = "#FF0000"

func _init():
	var file = File.new()
	file.open("res://i18n/PersonSpeeches.json", File.READ)
	var obj = parse_json(file.get_as_text())
	for item in obj:
		_speeches[item] = Util.convert_dict_to_int_key(obj[item])
	file.close()
	
func _get_speech(key, person_id):
	var speech = _speeches[key]
	if speech.has(person_id):
		return speech[person_id]
	else:
		return speech[-1]


func _color_text(color, text) -> String:
	return "[color=" + color + "]" + text + "[/color]"
	
func _register_click(func_name, text) -> String:
	return "[url=\"" + func_name + "\"]" + text + "[/url]"
	
func create_troop(troop, position):
	emit_signal("add_game_record", _register_click(
		"focus(" + str(position.x) + "," + str(position.y) + ")",
		tr("GAME_RECORD_CREATE_TROOP") % [
			_color_text(GREEN, troop.get_name()), 
			_color_text(CYAN, troop.get_starting_architecture().get_name())
		])
	)

func _on_troop_occupy_architecture(troop, architecture):
	emit_signal("add_game_record", _register_click(
		"focus(" + str(troop.map_position.x) + "," + str(troop.map_position.y) + ")",
		tr("GAME_RECORD_TROOP_OCCUPY_ARCHITECTURE") % [
			_color_text(GREEN, troop.get_name()), 
			_color_text(CYAN, architecture.get_name())
		])
	)

func _on_troop_destroyed(troop):
	emit_signal("add_game_record", _register_click(
		"focus(" + str(troop.map_position.x) + "," + str(troop.map_position.y) + ")",
		tr("GAME_RECORD_TROOP_DESTROYED") % [
			_color_text(GREEN, troop.get_name()), 
		])
	)

func _on_faction_destroyed(faction):
	emit_signal("add_game_record", 
		tr("GAME_RECORD_FACTION_DESTROYED") % [
			_color_text(RED, faction.get_name())
		])
	
func _on_date_runner_stopped(scenario: Scenario):
	var leader = scenario.current_faction.get_leader()
	var location = leader.get_location()
	if location != null:
		emit_signal("add_person_bubble", location,
			 _get_speech("player_turn", leader.id) % [
				_color_text(CYAN, leader.get_name())
			])
	
