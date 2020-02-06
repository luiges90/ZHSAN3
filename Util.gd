extends Node

static func load_position(v) -> Vector2:
	return Vector2(v[0], v[1])

static func load_color(v) -> Color:
	return Color(v[0], v[1], v[2])

static func nstr(n: int) -> String:
	var s = str(n)
	if s.length() > 3:
		s = s.insert(s.length() - 3, ',')
	if s.length() > 7:
		s = s.insert(s.length() - 7, ',')
	if s.length() > 12:
		s = s.insert(s.length() - 12, ',')
	return s
