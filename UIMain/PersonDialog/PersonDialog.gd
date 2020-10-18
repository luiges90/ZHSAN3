extends Control
class_name PersonDialog

enum SoundType {
	NONE, OCCUPY_ARCHITECTURE, PERSON_DEAD
}


func _ready():
	$Timer.wait_time = GameConfig.dialog_show_time


func show_dialog(person: Person, text, sound = SoundType.NONE):
	if len(text) > 0 and $Timer.wait_time > 0:
		if person != null:
			$Portrait.texture = person.get_portrait()
			$SpeakerPanel/Speaker.text = person.get_name()
		else:
			if SharedData.person_portraits.has(SharedData.PERSON_PORTRAIT_DEFAULT_MALE_OFFICER):
				$Portrait.texture =  SharedData.person_portraits[SharedData.PERSON_PORTRAIT_DEFAULT_MALE_OFFICER]
			else:
				$Portrait.texture =  SharedData.person_portraits[SharedData.PERSON_PORTRAIT_BLANK]
			$SpeakerPanel/Speaker.text = tr('NARRATOR')
		$DialogPanel/Dialog.bbcode_text = text
		
		match sound:
			SoundType.OCCUPY_ARCHITECTURE: $OccupyArchitecture.play()
			SoundType.PERSON_DEAD: $PersonDead.play()
			SoundType.FACTION_DESTROYED: $FactionDestroyed.play()
		
		$Timer.start()
		show()


func _on_Timer_timeout():
	hide()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if (event.button_index == BUTTON_LEFT or event.button_index == BUTTON_RIGHT) and event.pressed:
			hide()
