extends Panel
class_name GameRecord

func add_text(text):
	$Records.append_bbcode(text + "\n")
	$Pop.play()


func _on_Toolbar_game_record_clicked():
	if visible:
		hide()
	else:
		show()


func _on_Records_meta_clicked(meta):
	print(meta)
