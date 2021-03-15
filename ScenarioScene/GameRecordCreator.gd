extends Node
class_name GameRecordCreator

var _bubbles
var _dialogs

var _scenario

signal add_game_record
signal add_person_bubble
signal add_person_dialog

const GREEN = "#00FF00" # troop
const CYAN = "#00FFFF" # architecture, positions, other keywords
const RED = "#FF0000" # faction
const YELLOW = "#FFFF00" # person

func _init():
	var file = File.new()
	file.open("res://i18n/PersonBubbles.json", File.READ)
	_bubbles = parse_json(file.get_as_text())
	file.close()
	
	file = File.new()
	file.open("res://i18n/PersonDialogs.json", File.READ)
	_dialogs = parse_json(file.get_as_text())
	file.close()

	
func _get_bubble(key, person):
	var speech = _bubbles[key]
	for s in speech:
		var container = ScenarioUtil.InfluenceContainer.new()
		container.conditions = s['Conditions']
		
		if Conditions.check_conditions(container, {'person': person}):
			var texts = s['Text']
			if texts is Array:
				return Util.random_from(texts)
			else:
				return texts
	return ''
	
func _get_dialog(key, person, objects):
	var speech = _dialogs[key]
	for s in speech:
		var container = ScenarioUtil.InfluenceContainer.new()
		container.conditions = s['Conditions']
		
		var params = objects.duplicate()
		params['person'] = person
		if Conditions.check_conditions(container, params):
			var texts = s['Text']
			if texts is Array:
				return Util.random_from(texts)
			else:
				return texts
	return ''

func _color_block(color) -> String:
	return "[color=" + color + "]█[/color] "

func _color_text(color, text) -> String:
	return "[color=" + color + "]" + text + "[/color]"
	
func _register_click(func_name, text) -> String:
	return "[url=\"" + func_name + "\"]" + text + "[/url]"
	
func _on_Scenario_scenario_loaded(scenario):
	_scenario = scenario
	


func create_troop(troop, position):
	var faction = troop.get_belonged_faction()
	var fcolor = faction.color if faction != null else Color.white
	call_deferred("emit_signal", "add_game_record", _register_click(
		"focus(" + str(position.x) + "," + str(position.y) + ")",
		_color_block("#" + fcolor.to_html()) + tr("GAME_RECORD_CREATE_TROOP").format({
			"troop": _color_text(GREEN, troop.get_name()), 
			"architecture": _color_text(CYAN, troop.get_starting_architecture().get_name())
		})
	))

func _on_troop_occupy_architecture(troop, architecture):
	var faction = troop.get_belonged_faction()
	var fcolor = faction.color if faction != null else Color.white
	call_deferred("emit_signal", "add_game_record", _register_click(
		"focus(" + str(troop.map_position.x) + "," + str(troop.map_position.y) + ")",
		_color_block("#" + fcolor.to_html()) + tr("GAME_RECORD_TROOP_OCCUPY_ARCHITECTURE").format({
			"troop": _color_text(GREEN, troop.get_name()), 
			"architecture": _color_text(CYAN, architecture.get_name())
		})
	))
	if troop.get_belonged_faction().player_controlled:
		call_deferred("emit_signal", "add_person_dialog", troop.get_leader(),
			_get_dialog("troop_occupy_architecture", troop.get_leader(), {'troop': troop, 'architecture': architecture}).format({
				"troop": _color_text(GREEN, troop.get_name()), 
				"architecture": _color_text(CYAN, architecture.get_name())
			}), PersonDialog.SoundType.OCCUPY_ARCHITECTURE)
	

func _on_troop_destroyed(troop):
	var faction = troop.get_belonged_faction()
	var fcolor = faction.color if faction != null else Color.white
	call_deferred("emit_signal", "add_game_record", _register_click(
		"focus(" + str(troop.map_position.x) + "," + str(troop.map_position.y) + ")",
		_color_block("#" + fcolor.to_html()) + tr("GAME_RECORD_TROOP_DESTROYED").format({
			"troop": _color_text(GREEN, troop.get_name())
		})
	))
		
func _on_troop_target_architecture_destroyed(current_troop, target):
	var leader = current_troop.get_leader()
	call_deferred("emit_signal", "add_person_bubble", leader, current_troop,
		 _get_bubble("destroyed_target_architecture", leader).format({
			"architecture": _color_text(CYAN, target.get_name())
		}))
			
func _on_troop_target_troop_destroyed(current_troop, target):
	var leader = current_troop.get_leader()
	call_deferred("emit_signal", "add_person_bubble", leader, current_troop,
		_get_bubble("destroyed_target_troop", leader).format({
			"troop": _color_text(GREEN, target.get_name())
		}))
		

func _on_troop_performed_attack(current, receiver, critical):
	if critical:
		var leader = current.get_leader()
		call_deferred("emit_signal", "add_person_bubble", leader, current,
			_get_bubble("troop_perform_critical_attack", leader).format({
				"leader": _color_text(YELLOW, leader.get_name())
			})
		)
	
	
func _on_troop_received_attack(current, sender, critical):
	if critical and current is Troop:
		var leader = current.get_leader()
		call_deferred("emit_signal", "add_person_bubble", leader, current,
			_get_bubble("troop_receive_critical_attack", leader).format({
				"leader": _color_text(YELLOW, leader.get_name())
			})
		)
		

func _on_faction_destroyed(faction):
	var fcolor = faction.color if faction != null else Color.white
	call_deferred("emit_signal", "add_game_record", 
		_color_block("#" + fcolor.to_html()) + tr("GAME_RECORD_FACTION_DESTROYED").format({
			"faction": _color_text(RED, faction.get_name())
		}))
	call_deferred("emit_signal", "add_person_dialog", null,
		_get_dialog("faction_destroyed", faction.get_leader(), {'faction': faction}).format({
			"faction": _color_text(RED, faction.get_name())
		}), PersonDialog.SoundType.FACTION_DESTROYED)
	

func _on_DateRunner_date_runner_stopped():
	var leader = _scenario.current_faction.get_leader()
	var location = leader.get_location()
	if location != null:
		call_deferred("emit_signal", "add_person_bubble", leader, location,
			 _get_bubble("player_turn", leader).format({
				"person": _color_text(YELLOW, leader.get_name())
			}))



func _on_PositionSelector_move_troop(current_troop, position):
	var leader = current_troop.get_leader()
	call_deferred("emit_signal", "add_person_bubble", leader, current_troop,
		 _get_bubble("troop_move", leader).format({
			"position": _color_text(CYAN, _scenario.describe_position(position))
		}))


func _on_PositionSelector_attack_troop(current_troop, position):
	var leader = current_troop.get_leader()
	call_deferred("emit_signal", "add_person_bubble", leader, current_troop,
		 _get_bubble("troop_attack", leader).format({
			"position": _color_text(CYAN, _scenario.describe_position(position))
		}))
		

func _on_PositionSelector_follow_troop(current_troop, position):
	var leader = current_troop.get_leader()
	call_deferred("emit_signal", "add_person_bubble", leader, current_troop,
		 _get_bubble("troop_follow", leader).format({
			"position": _color_text(CYAN, _scenario.describe_position(position))
		}))


func _on_PositionSelector_enter_troop(current_troop, position):
	var leader = current_troop.get_leader()
	call_deferred("emit_signal", "add_person_bubble", leader, current_troop,
		 _get_bubble("troop_enter", leader).format({
			"position": _color_text(CYAN, _scenario.describe_position(position))
		}))


func _on_PositionSelector_create_troop(current_troop, position):
	var leader = current_troop.get_leader()
	call_deferred("emit_signal", "add_person_bubble", leader, current_troop,
		 _get_bubble("troop_create", leader).format({
			"person": _color_text(YELLOW, leader.get_name())
		}))

func person_died(person):
	var faction = person.get_belonged_faction()
	var fcolor = faction.color if faction != null else Color.white
	call_deferred("emit_signal", "add_game_record", 
		_color_block("#" + fcolor.to_html()) + tr("GAME_RECORD_PERSON_DIED").format({
			"person": _color_text(YELLOW, person.get_name())
		}))
	call_deferred("emit_signal", "add_person_dialog", null,
		_get_dialog("person_died", person, {}).format({
			"person": _color_text(YELLOW, person.get_name())
		}), PersonDialog.SoundType.PERSON_DEAD)

func person_available_by_brother(person, other_person):
	if person.get_belonged_faction() != null:
		if person.get_belonged_faction().player_controlled or _scenario.is_observer():
			var faction = person.get_belonged_faction()
			var fcolor = faction.color if faction != null else Color.white
			if !_scenario.is_observer():
				call_deferred("emit_signal", "add_person_dialog", person,
					_get_dialog("person_available_by_brother", person, {'other': other_person}).format({
						"person": _color_text(YELLOW, person.get_name()),
						"other_person": _color_text(YELLOW, other_person.get_name()),
						"location": _color_text(CYAN, person.get_location().get_name())
					}))
			call_deferred("emit_signal", "add_game_record", 
				_color_block("#" + fcolor.to_html()) + tr("GAME_RECORD_PERSON_GROWN_JOIN").format({
					"person": _color_text(YELLOW, person.get_name()),
					"faction": _color_text(RED, person.get_belonged_faction().get_name()),
					"architecture": _color_text(CYAN, person.get_location().get_name())
			}))

func person_available_by_spouse(person, other_person):
	if person.get_belonged_faction() != null:
		if person.get_belonged_faction().player_controlled or _scenario.is_observer():
			var faction = person.get_belonged_faction()
			var fcolor = faction.color if faction != null else Color.white
			if !_scenario.is_observer():
				call_deferred("emit_signal", "add_person_dialog", person,
					_get_dialog("person_available_by_spouse", person, {'other': other_person}).format({
						"person": _color_text(YELLOW, person.get_name()),
						"other_person": _color_text(YELLOW, other_person.get_name()),
						"location": _color_text(CYAN, person.get_location().get_name())
					}))
			call_deferred("emit_signal", "add_game_record", 
				_color_block("#" + fcolor.to_html()) + tr("GAME_RECORD_PERSON_GROWN_JOIN").format({
					"person": _color_text(YELLOW, person.get_name()),
					"faction": _color_text(RED, person.get_belonged_faction().get_name()),
					"architecture": _color_text(CYAN, person.get_location().get_name())
			}))

func person_available_by_children(person, other_person):
	if person.get_belonged_faction() != null:
		if person.get_belonged_faction().player_controlled or _scenario.is_observer():
			var faction = person.get_belonged_faction()
			var fcolor = faction.color if faction != null else Color.white
			if !_scenario.is_observer():
				call_deferred("emit_signal", "add_person_dialog", person,
					_get_dialog("person_available_by_children", person, {'other': other_person}).format({
						"person": _color_text(YELLOW, person.get_name()),
						"other_person": _color_text(YELLOW, other_person.get_name()),
						"location": _color_text(CYAN, person.get_location().get_name())
					}))
			call_deferred("emit_signal", "add_game_record", 
				_color_block("#" + fcolor.to_html()) + tr("GAME_RECORD_PERSON_GROWN_JOIN").format({
					"person": _color_text(YELLOW, person.get_name()),
					"faction": _color_text(RED, person.get_belonged_faction().get_name()),
					"architecture": _color_text(CYAN, person.get_location().get_name())
			}))
		
func person_available_by_sibling(person, other_person):
	if person.get_belonged_faction() != null:
		if person.get_belonged_faction().player_controlled or _scenario.is_observer():
			var faction = person.get_belonged_faction()
			var fcolor = faction.color if faction != null else Color.white
			if !_scenario.is_observer():
				call_deferred("emit_signal", "add_person_dialog", person,
					_get_dialog("person_available_by_sibling", person, {'other': other_person}).format({
						"person": _color_text(YELLOW, person.get_name()),
						"other_person": _color_text(YELLOW, other_person.get_name()),
						"location": _color_text(CYAN, person.get_location().get_name())
					}))
			
			call_deferred("emit_signal", "add_game_record", 
				_color_block("#" + fcolor.to_html()) + tr("GAME_RECORD_PERSON_GROWN_JOIN").format({
					"person": _color_text(YELLOW, person.get_name()),
					"faction": _color_text(RED, person.get_belonged_faction().get_name()),
					"architecture": _color_text(CYAN, person.get_location().get_name())
			}))

func person_convince_success(person, other_person):
	if person.get_belonged_faction().player_controlled or _scenario.is_observer():
		var faction = person.get_belonged_faction()
		var fcolor = faction.color if faction != null else Color.white
		if !_scenario.is_observer():
			call_deferred("emit_signal", "add_person_dialog", other_person,
				_get_dialog("person_convince_success_destination", other_person, {'other': person}).format({
					"person": _color_text(YELLOW, other_person.get_name()),
					"other_person": _color_text(YELLOW, person.get_name()),
					"faction": _color_text(RED, person.get_belonged_faction().get_name()),
					"architecture": _color_text(CYAN, person.get_location().get_name())
				}))
		
		call_deferred("emit_signal", "add_game_record", 
			_color_block("#" + fcolor.to_html()) + tr("GAME_RECORD_CONVINCE_PERSON_SUCCESS").format({
				"person": _color_text(YELLOW, person.get_name()),
				"other_person": _color_text(YELLOW, other_person.get_name()),
				"faction": _color_text(RED, person.get_belonged_faction().get_name()),
				"architecture": _color_text(CYAN, person.get_location().get_name())
		}))
	
func person_convince_failure(person, other_person):
	if person.get_belonged_faction().player_controlled or _scenario.is_observer():
		var faction = person.get_belonged_faction()
		var fcolor = faction.color if faction != null else Color.white
		call_deferred("emit_signal", "add_game_record", 
			_color_block("#" + fcolor.to_html()) + tr("GAME_RECORD_CONVINCE_PERSON_FAILURE").format({
				"person": _color_text(YELLOW, person.get_name()),
				"other_person": _color_text(YELLOW, other_person.get_name())
		}))

func person_move_complete(person):
	if person.get_belonged_faction().player_controlled:
		var faction = person.get_belonged_faction()
		var fcolor = faction.color if faction != null else Color.white
		call_deferred("emit_signal", "add_game_record", 
			_color_block("#" + fcolor.to_html()) + tr("GAME_RECORD_PERSON_MOVE_COMPLETE").format({
				"person": _color_text(YELLOW, person.get_name()),
				"architecture": person.get_location_str()
		}))

func assign_advisor(person):
	if person.get_belonged_faction().player_controlled or _scenario.is_observer():
		var faction = person.get_belonged_faction()
		var fcolor = faction.color if faction != null else Color.white
		call_deferred("emit_signal", "add_person_dialog", person,
			_get_dialog("person_assigned_to_advisor", person, {}).format({
				"person": _color_text(YELLOW, person.get_name()),
				"faction": _color_text(YELLOW, person.get_belonged_faction().get_name())
			}))
		
		call_deferred("emit_signal", "add_game_record", 
			_color_block("#" + fcolor.to_html()) + tr("GAME_RECORD_ASSIGN_ADVISOR").format({
				"person": _color_text(YELLOW, person.get_name()),
				"faction": _color_text(YELLOW, person.get_belonged_faction().get_name())
		}))
	
func remove_advisor(faction):
	var fcolor = faction.color if faction != null else Color.white
	if faction.player_controlled:
		call_deferred("emit_signal", "add_game_record", 
			_color_block("#" + fcolor.to_html()) + tr("GAME_RECORD_REMOVE_ADVISOR").format({
				"faction": _color_text(YELLOW, faction.get_name())
		}))

func _on_troop_person_captured(capturer, persons):
	var faction = capturer.get_belonged_faction()
	var other_faction = persons[0].get_belonged_faction()
	
	var person_list_str = ""
	for p in persons:
		person_list_str += p.get_name() + tr("SEPARATOR")
	person_list_str = person_list_str.substr(0, person_list_str.length() - 1)
	
	var fcolor = faction.color if faction != null else Color.white
	call_deferred("emit_signal", "add_person_bubble", capturer.get_leader(), capturer,
		 _get_bubble("troop_captured_person", capturer.get_leader()).format({
			"person": _color_text(YELLOW, person_list_str)
		}))
	if faction.player_controlled or other_faction.player_controlled or _scenario.is_observer():
		call_deferred("emit_signal", "add_game_record", 
			_color_block("#" + fcolor.to_html()) + tr("GAME_RECORD_PERSON_CAPTURED").format({
				"person": _color_text(YELLOW, person_list_str),
				"troop": _color_text(GREEN, capturer.get_name())
		}))
	
func _on_troop_person_released(troop, persons):
	var faction = persons[0].get_belonged_faction()
	
	var person_list_str = ""
	for p in persons:
		person_list_str += p.get_name() + tr("SEPARATOR")
	person_list_str = person_list_str.substr(0, person_list_str.length() - 1)
	
	var fcolor = faction.color if faction != null else Color.white
	if faction.player_controlled or _scenario.is_observer():
		call_deferred("emit_signal", "add_game_record", 
			_color_block("#" + fcolor.to_html()) + tr("GAME_RECORD_PERSON_CAPTURED").format({
				"person": _color_text(YELLOW, person_list_str),
				"troop": _color_text(GREEN, troop.get_name())
		}))

func _on_troop_prepare_start_stunt(current_troop, stunt):
	var leader = current_troop.get_leader()
	call_deferred("emit_signal", "add_person_bubble", leader, current_troop,
		 _get_bubble("troop_prepare_start_stunt", leader).format({
			"stunt": _color_text(CYAN, stunt.get_name()),
		}))

func _on_troop_start_stunt(current_troop, stunt, apply_to_self, friendly, success):
	var leader = current_troop.get_leader()
	if apply_to_self:
		if success:
			call_deferred("emit_signal", "add_person_bubble", leader, current_troop,
				_get_bubble("troop_start_stunt", leader).format({
					"person": _color_text(YELLOW, leader.get_name()),
					"stunt": _color_text(CYAN, stunt.get_name()),
				}))
		else:
			call_deferred("emit_signal", "add_person_bubble", leader, current_troop,
				_get_bubble("troop_start_stunt_failure", leader).format({
					"person": _color_text(YELLOW, leader.get_name()),
					"stunt": _color_text(CYAN, stunt.get_name()),
				}))
	else:
		if success:
			if friendly:
				call_deferred("emit_signal", "add_person_bubble", leader, current_troop,
					_get_bubble("troop_affected_by_friendly_start_stunt", leader).format({
						"person": _color_text(YELLOW, leader.get_name()),
						"stunt": _color_text(CYAN, stunt.get_name()),
					}))
			else:
				call_deferred("emit_signal", "add_person_bubble", leader, current_troop,
					_get_bubble("troop_affected_by_hostile_start_stunt", leader).format({
						"person": _color_text(YELLOW, leader.get_name()),
						"stunt": _color_text(CYAN, stunt.get_name()),
					}))
		else:
			if friendly:
				call_deferred("emit_signal", "add_person_bubble", leader, current_troop,
					_get_bubble("troop_affected_by_start_stunt_failure", leader).format({
						"person": _color_text(YELLOW, leader.get_name()),
						"stunt": _color_text(CYAN, stunt.get_name()),
					}))
			else:
				call_deferred("emit_signal", "add_person_bubble", leader, current_troop,
					_get_bubble("troop_affected_by_hostile_start_stunt_failure", leader).format({
						"person": _color_text(YELLOW, leader.get_name()),
						"stunt": _color_text(CYAN, stunt.get_name()),
					}))

