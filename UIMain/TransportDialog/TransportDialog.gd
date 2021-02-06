extends Panel
class_name TransportDialog



func _on_ArchitectureMenu_transport_clicked(from_architecture):
	$FromArchitecture.text = from_architecture.get_name()
	show()


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if (event.button_index == BUTTON_RIGHT) and event.pressed:
			hide()
