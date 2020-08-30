extends Node
class_name GameRecordCreator

var _speeches
var _dialogs

var _scenario

signal add_game_record
signal add_person_bubble
signal add_person_dialog

const GREEN = "#00FF00" # troop
const CYAN = "#00FFFF" # architecture, positions
const RED = "#FF0000" # faction
const YELLOW = "#FFFF00" # person

func _init():
	var file = File.new()
	file.open("res://i18n/PersonBubbles.json", File.READ)
	_speeches = parse_json(file.get_as_text())
	file.close()
	
	file = File.new()
	file.open("res://i18n/PersonDialogs.json", File.READ)
	_dialogs = parse_json(file.get_as_text())
	file.close()

	
func _get_speech(key, person):
	var speech = _speeches[key]
	for s in speech:
		var container = ScenarioUtil.InfluenceContainer.new()
		container.conditions = s['Conditions']
		if ScenarioUtil.check_conditions(container, {'person': person}):
			return s['Text']
	return ''
	
func _get_dialog(key, person, objects):
	var speech = _dialogs[key]
	for s in speech:
		var container = ScenarioUtil.InfluenceContainer.new()
		container.conditions = s['Conditions']
		
		var params = objects.duplicate()
		params['person'] = person
		if ScenarioUtil.check_conditions(container, params):
			return s['Text']
	return ''

func _color_text(color, text) -> String:
	return "[color=" + color + "]" + text + "[/color]"
	
func _register_click(func_name, text) -> String:
	return "[url=\"" + func_name + "\"]" + text + "[/url]"
	
func _on_Scenario_scenario_loaded(scenario):
	_scenario = scenario


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
	
func _on_troop_target_architecture_destroyed(current_troop, target):
	var leader = current_troop.get_leader()
	emit_signal("add_person_bubble", leader, current_troop,
		 _get_speech("destroyed_target_architecture", leader) % [
			_color_text(CYAN, target.get_name())
		])
			
func _on_troop_target_troop_destroyed(current_troop, target):
	var leader = current_troop.get_leader()
	emit_signal("add_person_bubble", leader, current_troop,
		_get_speech("destroyed_target_troop", leader) % [
			_color_text(GREEN, target.get_name())
		])

func _on_faction_destroyed(faction):
	emit_signal("add_game_record", 
		tr("GAME_RECORD_FACTION_DESTROYED") % [
			_color_text(RED, faction.get_name())
		])
	emit_signal("add_person_dialog", null,
		_get_dialog("faction_destroyed", null, {'faction': faction}) % [
			_color_text(RED, faction.get_name())
		])
	

func _on_DateRunner_date_runner_stopped():
	var leader = _scenario.current_faction.get_leader()
	var location = leader.get_location()
	if location != null:
		emit_signal("add_person_bubble", leader, location,
			 _get_speech("player_turn", leader) % [
				_color_text(YELLOW, leader.get_name())
			])



func _on_PositionSelector_move_troop(current_troop, position):
	var leader = current_troop.get_leader()
	emit_signal("add_person_bubble", leader, current_troop,
		 _get_speech("troop_move", leader) % [
			_color_text(CYAN, _scenario.describe_position(position))
		])


func _on_PositionSelector_attack_troop(current_troop, position):
	var leader = current_troop.get_leader()
	emit_signal("add_person_bubble", leader, current_troop,
		 _get_speech("troop_attack", leader) % [
			_color_text(CYAN, _scenario.describe_position(position))
		])
		

func _on_PositionSelector_follow_troop(current_troop, position):
	var leader = current_troop.get_leader()
	emit_signal("add_person_bubble", leader, current_troop,
		 _get_speech("troop_follow", leader) % [
			_color_text(CYAN, _scenario.describe_position(position))
		])


func _on_PositionSelector_enter_troop(current_troop, position):
	var leader = current_troop.get_leader()
	emit_signal("add_person_bubble", leader, current_troop,
		 _get_speech("troop_enter", leader) % [
			_color_text(CYAN, _scenario.describe_position(position))
		])


func _on_PositionSelector_create_troop(current_troop, position):
	var leader = current_troop.get_leader()
	emit_signal("add_person_bubble", leader, current_troop,
		 _get_speech("troop_create", leader) % [
			_color_text(YELLOW, leader.get_name())
		])

func person_died(person):
	emit_signal("add_game_record", 
		tr("GAME_RECORD_PERSON_DIED") % [
			_color_text(YELLOW, person.get_name())
		])
	
