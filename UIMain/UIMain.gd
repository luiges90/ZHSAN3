extends Control
class_name UIMain

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
			($PersonList as PersonList).hide()
			($SystemMenu as SystemMenu).hide()

