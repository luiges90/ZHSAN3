extends Control
class_name UIMain

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			($ArchitectureSurvey as ArchitectureSurvey).hide()
			($ArchitectureMenu as ArchitectureMenu).hide()

