extends Panel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func show_data(architecture):
	($TitlePanel/Title as Label).text = architecture.gname
	show()
