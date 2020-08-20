extends Panel
class_name PersonBubble


func _on_Timer_timeout():
	hide()


func _on_PersonBubble_visibility_changed():
	if visible:
		$Timer.start()


func show_bubble(scenario_location, text: String):
	var x = scenario_location.get_screen_position().x
	var y = scenario_location.get_screen_position().y - 88
	rect_position = Vector2(x, y)
	$Text.bbcode_text = text
	show()
