extends Control
class_name UIMain

# Called when the node enters the scene tree for the first time.
func _ready():
	var main = find_parent("Main") as Main
	main.connect("architecture_clicked", self, "_on_architecture_clicked")

func _on_architecture_clicked(arch):
	$ArchitectureSurvey.show_data(arch)
	
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			$ArchitectureSurvey.hide()

