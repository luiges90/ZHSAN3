extends Panel
class_name GameRecord

signal focus_camera

func add_text(text):
	$Records.append_bbcode(text + "\n")
	if $Records.get_line_count() > GameConfig.game_record_limit:
		$Records.remove_line(0)
	$Pop.play()


func _on_Toolbar_game_record_clicked():
	if visible:
		hide()
	else:
		show()


func _on_Records_meta_clicked(meta):
	if meta.begins_with("\"focus"):
		var x = meta.substr(meta.find("(") + 1, meta.find(",") - meta.find("("))
		var y = meta.substr(meta.find(",") + 1, meta.find(")") - 1)
		emit_signal("focus_camera", Vector2(int(x), int(y)))
