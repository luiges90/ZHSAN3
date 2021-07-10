extends VBoxContainer

signal back_button_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Back_pressed():
	emit_signal("back_button_pressed")
	$Close.play()
	hide()
