extends Panel
class_name CreateTroop

var _confirming = false


func _on_ArchitectureMenu_architecture_create_troop(arch, persons, military_kinds):
	show()


func _on_CreateTroop_hide():
	if not _confirming:
		$Cancel.play()
