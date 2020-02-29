extends Node
class_name Root


func _on_Quit_pressed():
	get_tree().quit()


func _on_LoadGame_pressed():
	$SaveLoadMenu.load_game()
	$SaveLoadMenu.show()


func _on_NewGame_pressed():
	# TODO create scenario selection
	SharedData.loading_file_path = "user://Scenarios/000Test.json"
	get_tree().change_scene("res://Main.tscn")


func _on_Other_pressed():
	$MainMenu.hide()
	$OtherMenu.show()
	

func _on_Back_pressed():
	$OtherMenu.hide()
	$MainMenu.show()


func _on_SaveLoadMenu_file_slot_clicked(mode, path):
	SharedData.loading_file_path = path
	get_tree().change_scene("res://Main.tscn")
