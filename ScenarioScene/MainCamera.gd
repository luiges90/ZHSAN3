extends Camera2D
class_name MainCamera

signal camera_moved

@export var camera_speed = 10
@export var mouse_scroll_margin = 50
@export var zoom_speed = 0.05
var bottom_ui_margin

var scenario

var _moving_camera_x = 0
var _moving_camera_y = 0
var _zooming_camera = 0

func _physics_process(delta):
	var bottom_margin = bottom_ui_margin if bottom_ui_margin != null else 0
	var viewport_rect = get_viewport_rect()
	limit_left = -viewport_rect.size.x * zoom.x / 2
	limit_top = -viewport_rect.size.y * zoom.y / 2
	limit_right = scenario.tile_size * scenario.map_size.x + viewport_rect.size.x * zoom.x
	limit_bottom = scenario.tile_size * scenario.map_size.y + bottom_margin * (zoom.y - 1) + viewport_rect.size.y * zoom.y
	
	position.x += _moving_camera_x
	position.y += _moving_camera_y
	position.x = clamp(position.x, 0, limit_right - viewport_rect.size.x * zoom.x)
	position.y = clamp(position.y, 0, limit_bottom - viewport_rect.size.y * zoom.y)
	
	zoom.x += _zooming_camera
	zoom.y += _zooming_camera
	zoom.x = clamp(zoom.x, 0.3, 2)
	zoom.y = clamp(zoom.y, 0.3, 2)
	
	if _moving_camera_x != 0 or _moving_camera_y != 0 or _zooming_camera != 0:
		call_deferred("emit_signal", "camera_moved", get_viewing_rect(), zoom)
		
func get_viewing_rect() -> Rect2:
	var size = get_viewport_rect().size * zoom
	var top = position.x - size.x / 2
	var left = position.y - size.y / 2
	return Rect2(Vector2(top, left), size)
	
func move_to(map_position):
	var viewport_rect = get_viewport_rect()
	position.x = map_position.x * scenario.tile_size
	position.y = map_position.y * scenario.tile_size
	call_deferred("emit_signal", "camera_moved", get_viewing_rect(), zoom)
	
func _unhandled_input(event):
	var mouse_position = get_viewport().get_mouse_position()
	var viewport_rect = get_viewport_rect()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
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
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if event.is_pressed():
				zoom.x -= zoom_speed
				zoom.y -= zoom_speed
				zoom.x = clamp(zoom.x, 0.3, 2)
				zoom.y = clamp(zoom.y, 0.3, 2)
				call_deferred("emit_signal", "camera_moved", get_viewing_rect(), zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if event.is_pressed():
				zoom.x += zoom_speed
				zoom.y += zoom_speed
				zoom.x = clamp(zoom.x, 0.3, 2)
				zoom.y = clamp(zoom.y, 0.3, 2)
				call_deferred("emit_signal", "camera_moved", get_viewing_rect(), zoom)
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


