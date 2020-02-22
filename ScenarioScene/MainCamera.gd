extends Camera2D
class_name MainCamera

export var camera_speed = 10
export var mouse_scroll_margin = 50
export var zoom_speed = 0.05
var bottom_ui_margin

var scenario

var _moving_camera_x = 0
var _moving_camera_y = 0
var _zooming_camera = 0

func _physics_process(delta):
	var viewport_rect = get_viewport_rect()
	offset.x += _moving_camera_x
	offset.y += _moving_camera_y
	zoom.x += _zooming_camera
	zoom.y += _zooming_camera
	
	limit_left = 0
	limit_top = 0
	limit_right = scenario.tile_size * scenario.map_size.x - viewport_rect.size.x
	limit_bottom = scenario.tile_size * scenario.map_size.y - viewport_rect.size.y + bottom_ui_margin
	offset.x = clamp(offset.x, limit_left, limit_right)
	offset.y = clamp(offset.y, limit_top, limit_bottom)
	zoom.x = clamp(zoom.x, 0.3, 2)
	zoom.y = clamp(zoom.y, 0.3, 2)
	
func _unhandled_input(event):
	var mouse_position = get_viewport().get_mouse_position()
	var viewport_rect = get_viewport_rect()
	if event is InputEventMouseButton:
		print(event.button_index, event.is_pressed())
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				if mouse_position.y < mouse_scroll_margin:
					_moving_camera_y = -camera_speed
				if mouse_position.y > viewport_rect.size.y - mouse_scroll_margin - bottom_ui_margin:
					_moving_camera_y = camera_speed
				if mouse_position.x < mouse_scroll_margin:
					_moving_camera_x = -camera_speed
				if mouse_position.x > viewport_rect.size.x - mouse_scroll_margin:
					_moving_camera_x = camera_speed
			else:
				_moving_camera_x = 0
				_moving_camera_y = 0
		elif event.button_index == BUTTON_WHEEL_UP:
			if event.is_pressed():
				zoom.x -= zoom_speed
				zoom.y -= zoom_speed
				zoom.x = clamp(zoom.x, 0.3, 2)
				zoom.y = clamp(zoom.y, 0.3, 2)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			if event.is_pressed():
				zoom.x += zoom_speed
				zoom.y += zoom_speed
				zoom.x = clamp(zoom.x, 0.3, 2)
				zoom.y = clamp(zoom.y, 0.3, 2)
	else:
		if event.is_action("ui_up"):
			if event.is_pressed():
				_moving_camera_y = -camera_speed
			else:
				_moving_camera_y = 0
		elif event.is_action("ui_down"):
			if event.is_pressed():
				_moving_camera_y = camera_speed
			else:
				_moving_camera_y = 0
		elif event.is_action("ui_left"):
			if event.is_pressed():
				_moving_camera_x = -camera_speed
			else:
				_moving_camera_x = 0
		elif event.is_action("ui_right"):
			if event.is_pressed():
				_moving_camera_x = camera_speed
			else:
				_moving_camera_x = 0
		elif event.is_action("ui_page_up"):
			if event.is_pressed():
				_zooming_camera = -zoom_speed
			else:
				_zooming_camera = 0
		elif event.is_action("ui_page_down"):
			if event.is_pressed():
				_zooming_camera = zoom_speed
			else:
				_zooming_camera = 0


