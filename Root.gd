extends Node
class_name Root


func _on_Quit_pressed():
	get_tree().quit()


func _on_LoadGame_pressed():
	# TODO new game setup
	get_tree().change_scene("res://Main.tscn")


func _on_NewGame_pressed():
	# TODO load game menu
	get_tree().change_scene("res://Main.tscn")


func _on_Other_pressed():
	$MainMenu.hide()
	$OtherMenu.show()
	

func _on_Back_pressed():
	$OtherMenu.hide()
	$MainMenu.show()
