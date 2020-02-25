extends VBoxContainer
class_name SaveLoadMenu

signal file_slot_clicked

enum MODE { SAVE, LOAD }
var mode

var _confirming = false

func _on_game_pressed(name: String):
	$Confirm.play()
	_confirming = true
	hide()
	emit_signal("file_slot_clicked", mode, name)
	

func _on_Game1_pressed():
	_on_game_pressed("01")


func _on_Game2_pressed():
	_on_game_pressed("02")


func _on_Game3_pressed():
	_on_game_pressed("03")


func _on_Game4_pressed():
	_on_game_pressed("04")


func _on_Game5_pressed():
	_on_game_pressed("05")


func _on_Game6_pressed():
	_on_game_pressed("06")


func _on_Game7_pressed():
	_on_game_pressed("07")


func _on_Game8_pressed():
	_on_game_pressed("08")


func _on_Game9_pressed():
	_on_game_pressed("09")


func _on_Game10_pressed():
	_on_game_pressed("10")


func _on_SystemMenu_save_clicked():
	mode = MODE.SAVE
	$Title.text = tr('SAVE_GAME')
	show()


func _on_SystemMenu_load_clicked():
	mode = MODE.LOAD
	$Title.text = tr('LOAD_GAME')
	show()


func _on_SaveLoadMenu_hide():
	if not _confirming:
		$Cancel.play()
