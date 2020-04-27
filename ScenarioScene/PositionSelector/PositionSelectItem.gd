extends Node2D
class_name PositionSelectItem

signal position_selected

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("position_selected")
			get_tree().set_input_as_handled()


func _on_Area2D_mouse_entered():
	($Area2D/Sprite as Sprite).modulate = Color.gray


func _on_Area2D_mouse_exited():
	($Area2D/Sprite as Sprite).modulate = Color.white
