extends Panel
class_name PersonBubble

var _speeches = {}

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


func _on_Timer_timeout():
	hide()


func _on_PersonBubble_visibility_changed():
	if visible:
		$Timer.start()


func _on_date_runner_stopped(scenario: Scenario):
	var leader = scenario.current_faction.get_leader()
	var location = leader.get_location()
	if location != null:
		var x = location.get_screen_position().x
		var y = location.get_screen_position().y - rect_size.y - 8
		rect_position = Vector2(x, y)
		$Text.bbcode_text = _get_speech("player_turn", leader.id) % leader.get_name()
		show()
