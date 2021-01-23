extends Control
class_name UIMain

signal cancel_ui

var _had_windows_showing = false

func _unhandled_input(event):
	_had_windows_showing = $ArchitectureSurvey.visible or \
		$ArchitectureMenu.visible or \
		$TroopSurvey.visible or \
		$ArchitectureAndTroopMenu.visible or \
		$PersonList.visible or \
		$InfoMenu.visible or \
		$SystemMenu.visible or \
		$SaveLoadMenu.visible or \
		$CreateTroop.visible or \
		$TroopDetail.visible or \
		$PersonDetail.visible or \
		$ArchitectureDetail.visible or \
		$PersonDialog.visible
	if event is InputEventMouseButton:
		if (event.button_index == BUTTON_LEFT or event.button_index == BUTTON_RIGHT) and event.pressed:
			($ArchitectureSurvey as ArchitectureSurvey).hide()
			($ArchitectureMenu as ArchitectureMenu).hide()
			($TroopSurvey as TroopSurvey).hide()
			($TroopMenu as TroopMenu).hide()
			($ArchitectureAndTroopMenu as ArchitectureAndTroopMenu).hide()
			($PersonList as PersonList).hide()
			($InfoMenu as InfoMenu).hide()
			($SystemMenu as SystemMenu).hide()
			($SaveLoadMenu as SaveLoadMenu).hide()
			($CreateTroop as CreateTroop).hide()
			($TroopDetail as TroopDetail).hide()
			($PersonDetail as PersonDetail).hide()
			($ArchitectureDetail as ArchitectureDetail).hide()
			($PersonDialog as PersonDialog).hide()
			call_deferred("emit_signal", "cancel_ui")
			
func _on_right_click_blank_space():
	if not _had_windows_showing:
		$SystemMenu.show()

func _on_mouse_moved_to_map_posiiton(position, terrain):
	$TileInfo.text = terrain.get_name() + str(position)

func _on_date_runner_stopped():
	$PlayerTurn.play()
