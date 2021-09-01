extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Cancel_pressed():
	var btn_ok = $ConfirmationDialog.get_ok()
	btn_ok.text = tr("EXIT")
	
	var btn_cancel = $ConfirmationDialog.get_cancel()
	btn_cancel.text = tr("RETURN")

	$ConfirmationDialog.popup()


func _on_ConfirmationDialog_confirmed():
	hide()
