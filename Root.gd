extends Node
class_name Root


func _on_Quit_pressed():
	get_tree().quit()


func _on_LoadGame_pressed():
	$SaveLoadMenu.load_game()
	$SaveLoadMenu.show()


func _on_NewGame_pressed():
	$ScenarioSelector.show()


func _on_SaveLoadMenu_file_slot_clicked(mode, path):
	SharedData.loading_file_path = path
	get_tree().change_scene("res://Main.tscn")


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if (event.button_index == BUTTON_LEFT or event.button_index == BUTTON_RIGHT) and event.pressed:
			$SaveLoadMenu.hide()
