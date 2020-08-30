extends Control
class_name UIMain

signal cancel_ui

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _process(delta):
	$FPSCounter.text = str(Engine.get_frames_per_second())
	
func _unhandled_input(event):
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
			emit_signal("cancel_ui")

func _on_mouse_moved_to_map_posiiton(position, terrain):
	$TileInfo.text = terrain.get_name() + str(position)

func _on_date_runner_stopped():
	$PlayerTurn.play()
