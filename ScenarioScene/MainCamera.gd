extends Camera2D
class_name MainCamera

export var camera_speed = 10
export var mouse_scroll_margin = 50
export var zoom_speed = 0.05
var bottom_ui_margin

var scenario

var _all_ready = false

func _on_all_loaded():
	_all_ready = true

func _process(_delta):
	if not _all_ready: 
		return
	var mouse_position = get_viewport().get_mouse_position()
	var viewport_rect = get_viewport_rect()
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		if mouse_position.y < viewport_rect.size.y - bottom_ui_margin:
			if mouse_position.y < mouse_scroll_margin:
				offset.y -= camera_speed
			if mouse_position.y > viewport_rect.size.y - mouse_scroll_margin - bottom_ui_margin:
				offset.y += camera_speed
			if mouse_position.x < mouse_scroll_margin:
				offset.x -= camera_speed
			if mouse_position.x > viewport_rect.size.x - mouse_scroll_margin:
				offset.x += camera_speed
		
	if Input.is_action_pressed("ui_up"):
		offset.y -= camera_speed
	if Input.is_action_pressed("ui_down"):
		offset.y += camera_speed
	if Input.is_action_pressed("ui_left"):
		offset.x -= camera_speed
	if Input.is_action_pressed("ui_right"):
		offset.x += camera_speed
	
	if Input.is_action_pressed("ui_page_up"):
		zoom.x -= zoom_speed
		zoom.y -= zoom_speed
	if Input.is_action_pressed("ui_page_down"):
		zoom.x += zoom_speed
		zoom.y += zoom_speed
		
	zoom.x = clamp(zoom.x, 0.3, 2)
	zoom.y = clamp(zoom.y, 0.3, 2)
	limit_left = 0
	limit_top = 0
	limit_right = scenario.tile_size * scenario.map_size.x - viewport_rect.size.x
	limit_bottom = scenario.tile_size * scenario.map_size.y - viewport_rect.size.y + bottom_ui_margin
	offset.x = clamp(offset.x, limit_left, limit_right)
	offset.y = clamp(offset.y, limit_top, limit_bottom)
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP:
			zoom.x -= zoom_speed
			zoom.y -= zoom_speed
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom.x += zoom_speed
			zoom.y += zoom_speed
		zoom.x = clamp(zoom.x, 0.3, 2)
		zoom.y = clamp(zoom.y, 0.3, 2)
