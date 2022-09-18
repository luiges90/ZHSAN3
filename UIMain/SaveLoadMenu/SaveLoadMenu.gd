extends VBoxContainer
class_name SaveLoadMenu

signal file_slot_clicked

enum MODE { SAVE, LOAD }
var mode

var _confirming = false

var player_name = ""

func _on_faction_updated(faction):
	if faction.player_controlled:
		player_name = faction.get_name()

func _update_items():
	var file = File.new()
	var err = file.open("user://Saves/saves.json", File.READ)
	if err == OK:
		var json = file.get_as_text()
		var test_json_conv = JSON.new()
		test_json_conv.parse(json)
		var obj = test_json_conv.get_data()
		for key in obj:
			var node = get_node("Game" + key)
			node.text = obj[key]
			node.disabled = false
	elif err == ERR_FILE_NOT_FOUND:
		file.open("user://Saves/saves.json", File.WRITE)
		file.store_line("{}")
		file.close()

func _on_game_pressed(name: String):
	var path = "user://Saves"
	
	$Confirm.play()
	_confirming = true
	hide()
	call_deferred("emit_signal", "file_slot_clicked", mode, path + "/Save" + name)
	
	if mode == MODE.SAVE:
		var dir = Directory.new()
		if not dir.dir_exists(path):
			dir.make_dir(path)
		var file = File.new()
		file.open(path + "/saves.json", File.READ_WRITE)
		var json = file.get_as_text()
		var test_json_conv = JSON.new()
		test_json_conv.parse(json)
		var obj = test_json_conv.get_data()
		if obj == null:
			obj = {}
		obj[name] = name + "：" + player_name + "　" + Util.current_date_str()
		file.store_line(JSON.new().stringify(obj))
		file.close()

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
	for node in get_children():
		if String(node.get_name()).begins_with("Game"):
			node.disabled = false
	_update_items()
	show()


func _on_SystemMenu_load_clicked():
	load_game()
	
	
func load_game():
	mode = MODE.LOAD
	$Title.text = tr('LOAD_GAME')
	for node in get_children():
		if String(node.get_name()).begins_with("Game"):
			node.disabled = true
	_update_items()
	show()


func _on_SaveLoadMenu_hide():
	if not _confirming:
		$Cancel.play()


