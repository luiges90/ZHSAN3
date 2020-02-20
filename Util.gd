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

# float to integer with randomized component by remaining frac
# note: input should be positive otherwise result is not exactly correct...
static func f2ri(x: float) -> int:
	var trunc = int(x)
	var frac = abs(x - int(x))
	return trunc + (1 if randf() < frac else 0)


static func max_by(list: Array, criteria_func: String):
	var value = list[0].call(criteria_func)
	var result = list[0]
	var index = 0
	var result_index = 0
	for item in list:
		var i = item.call(criteria_func)
		if i > value:
			value = i
			result = item
			result_index = index
		index += 1
	return [result_index, result]
