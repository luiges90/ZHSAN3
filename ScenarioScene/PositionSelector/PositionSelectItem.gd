extends Node2D
class_name PositionSelectItem

signal position_selected

var color
var mouse_in_area = false

func set_color(in_color):
	color = in_color
	($Area2D/Sprite as Sprite).modulate = color
	

func _on_Area2D_mouse_entered():
	($Area2D/Sprite as Sprite).modulate = color.lightened(0.5)
	mouse_in_area = true


func _on_Area2D_mouse_exited():
	($Area2D/Sprite as Sprite).modulate = color
	mouse_in_area = false


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed and mouse_in_area:
		call_deferred("emit_signal", "position_selected")
		get_tree().set_input_as_handled()
