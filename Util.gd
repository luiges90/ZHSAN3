extends Node
class_name Util

static func load_position(v) -> Vector2:
	return Vector2(v[0], v[1])

static func load_color(v) -> Color:
	return Color(v[0], v[1], v[2])
