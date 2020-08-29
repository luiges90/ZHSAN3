extends Panel
class_name GameConfiguration


func _on_Confirm_pressed():
	get_tree().change_scene("res://Main.tscn")


func _on_Cancel_pressed():
	hide()
