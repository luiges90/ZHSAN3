extends Node
class_name Root


func _on_Quit_pressed():
	get_tree().quit()


func __hide_all():
	$SaveLoadMenu.hide()
	$ScenarioSelector.hide()
	$GameConfiguration.hide()
	$Options.hide()

func _on_LoadGame_pressed():
	__hide_all()
	$Click.play()
	$SaveLoadMenu.load_game()
	$SaveLoadMenu.show()


func _on_NewGame_pressed():
	__hide_all()
	$Click.play()
	$ScenarioSelector.show()


func _on_SaveLoadMenu_file_slot_clicked(mode, path):
	SharedData.loading_file_path = path
	get_tree().change_scene("res://Main.tscn")


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if (event.button_index == BUTTON_LEFT or event.button_index == BUTTON_RIGHT) and event.pressed:
			$Close.play()
			__hide_all()


func _on_ScenarioSelector_confirmed_scenario():
	__hide_all()
	$Click.play()
	$GameConfiguration.show()


func _on_Options_pressed():
	__hide_all()
	$Click.play()
	$Options.show()
	

func _on_CustomOfficers_pressed():
	__hide_all()
	$MainMenu.hide()
	$Click.play()
	$CustomOfficer.show()


func _on_CustomOfficer_back_button_pressed():
	$MainMenu.show()
