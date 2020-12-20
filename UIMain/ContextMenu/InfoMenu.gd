extends ContextMenu
class_name InfoMenu

signal military_kind_clicked
signal factions_clicked
signal architectures_clicked
signal persons_clicked
signal skills_clicked
signal stunts_clicked

func _on_MilitaryKind_pressed():
	_select_item()
	call_deferred("emit_signal", "military_kind_clicked")


func _on_SystemMenu_info_clicked():
	show()


func _on_Factions_pressed():
	_select_item()
	call_deferred("emit_signal", "factions_clicked")


func _on_Architectures_pressed():
	_select_item()
	call_deferred("emit_signal", "architectures_clicked")



func _on_Persons_pressed():
	_select_item()
	call_deferred("emit_signal", "persons_clicked")



func _on_Skill_pressed():
	_select_item()
	call_deferred("emit_signal", "skills_clicked")


func _on_Stunt_pressed():
	_select_item()
	call_deferred("emit_signal", "stunts_clicked")
