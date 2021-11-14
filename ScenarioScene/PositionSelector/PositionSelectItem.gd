extends Node2D
class_name PositionSelectItem

signal position_selected

var color

func set_color(in_color):
	color = in_color
	($Area2D/Sprite as Sprite).modulate = color
	

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		call_deferred("emit_signal", "position_selected")
		get_tree().set_input_as_handled()


func _on_Area2D_mouse_entered():
	($Area2D/Sprite as Sprite).modulate = color.lightened(0.5)


func _on_Area2D_mouse_exited():
	($Area2D/Sprite as Sprite).modulate = color


func _input(event):
	print(event)
	pass
