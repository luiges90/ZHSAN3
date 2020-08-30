extends Control
class_name PersonDialog

func _init():
	$Timer.wait_time = GameConfig.dialog_show_time


func show_dialog(person: Person, text):
	if $Timer.wait_time > 0:
		$Portrait.texture = person.get_portrait()
		$SpeakerPanel/Speaker.text = person.get_name()
		$DialogPanel/Dialog.bbcode_text = text
		$Timer.start()
		show()


func _on_Timer_timeout():
	hide()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if (event.button_index == BUTTON_LEFT or event.button_index == BUTTON_RIGHT) and event.pressed:
			hide()
