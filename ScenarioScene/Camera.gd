extends Camera2D

var camera_speed = 10
var mouse_scroll_margin = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	var mouse_position = get_viewport().get_mouse_position()
	var viewport_rect = get_viewport_rect()
	print(get_viewport_rect().size)
	if Input.is_action_pressed("ui_up"):
		offset.y -= camera_speed
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and mouse_position.y < mouse_scroll_margin:
		offset.y -= camera_speed
	if Input.is_action_pressed("ui_down"):
		offset.y += camera_speed
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and mouse_position.y > viewport_rect.size.y - mouse_scroll_margin:
		offset.y += camera_speed
	if Input.is_action_pressed("ui_left"):
		offset.x -= camera_speed
	if  Input.is_mouse_button_pressed(BUTTON_LEFT) and mouse_position.x < mouse_scroll_margin:
		offset.x -= camera_speed
	if Input.is_action_pressed("ui_right"):
		offset.x += camera_speed
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and mouse_position.x > viewport_rect.size.x - mouse_scroll_margin:
		offset.x += camera_speed

