extends Node

##############################################
#           JSON de/serialization            #
##############################################

static func load_position(v: Array) -> Vector2:
	return Vector2(v[0], v[1])

static func load_color(v: Array) -> Color:
	if len(v) == 3:
		return Color(v[0], v[1], v[2])
	elif len(v) == 4:
		return Color(v[0], v[1], v[2], v[3])
	else:
		assert('Load color array size must be either 3 or 4.')
		return Color(0, 0, 0)
	
static func save_position(v: Vector2) -> Array:
	return [v.x, v.y]
	
static func save_color(c: Color) -> Array:
	if c.a == 1:
		return [c.r, c.g, c.b]
	else:
		return [c.r, c.g, c.b, c.a]
	
static func id_list(list: Array) -> Array:
	var s = []
	for item in list:
		s.append(item.id)
	return s

static func id_key_dict(dict: Dictionary) -> Dictionary:
	var s = {}
	for item in dict:
		s[item.id] = dict[item]
	return s
	
##############################################
#                 Formatting                 #
##############################################

static func nstr(n: int) -> String:
	var s = str(n)
	var negative_shift = 1 if n < 0 else 0
	if s.length() > 3 + negative_shift:
		s = s.insert(s.length() - 3 - negative_shift, ',')
	if s.length() > 7 + negative_shift:
		s = s.insert(s.length() - 7 - negative_shift, ',')
	if s.length() > 12 + negative_shift:
		s = s.insert(s.length() - 12 - negative_shift, ',')
	if s.length() > 18 + negative_shift:
		s = s.insert(s.length() - 18 - negative_shift, ',')
	return s
	
static func snstr(n: int) -> String:
	var s = nstr(n)
	if n >= 0:
		s = '+' + s
	return s
	
static func current_date_str() -> String:
	var now = OS.get_datetime()
	return str(now['year']) + '-' + str(now['month']) + '-' + str(now['day']) + " " + str(now['hour']) + ":" + str(now['minute'])
	
static func bstr(b: bool) -> String:
	return "○" if b else "×"

##############################################
#                     Math                   #
##############################################

# float to integer with randomized component by remaining frac
static func f2ri(x: float) -> int:
	var trunc = int(x)
	var frac = abs(x - int(x))
	if x > 0:
		return trunc + (1 if randf() < frac else 0)
	else:
		return trunc - (1 if randf() < frac else 0)

# Mahattan Distance
static func m_dist(a: Vector2, b: Vector2):
	return abs(a.x - b.x) + abs(a.y - b.y)
	
# Get all positions in range of given position
static func squares_in_range(position: Vector2, r: int) -> Array:
	var result = []
	for x in range(position.x - r, position.x + r + 1):
		for y in range(position.y - r, position.y + r + 1):
			if m_dist(Vector2(x,y), position) <= r:
				result.append(Vector2(x, y))
	return result

# Rounding with arbitrary precision
static func pround(n: float, precision: int):
	return int(n + precision / 2.0) / precision * precision

# Shift position by 1 place at random
static func random_shift_position(pos: Vector2) -> Vector2:
	if randf() < 0.5:
		if randf() < 0.5:
			return Vector2(pos.x - 1, pos.y)
		else:
			return Vector2(pos.x + 1, pos.y)
	else:
		if randf() < 0.5:
			return Vector2(pos.x, pos.y - 1)
		else:
			return Vector2(pos.x, pos.y + 1)

static func gcd(a: int, b: int) -> int:
	while b != 0:
		var t = b
		b = a % b
		a = t
	return a

static func lcm(a: int, b: int) -> int:
	return a * b / gcd(a, b)
	
##############################################
#                 Collections                #
##############################################

static func random_from(list: Array):
	if list.size() > 0:
		return list[randi() % list.size()]
	else:
		return null

static func append_all(list: Array, other: Array):
	for i in other:
		list.append(i)
		
static func remove_object(arr: Array, item):
	var index = arr.find(item)
	if index >= 0:
		arr.remove(index)
		
static func dict_try_get(dict: Dictionary, key, default):
	if dict.has(key):
		return dict[key]
	else:
		return default
		
static func dict_inc(dict: Dictionary, key, value):
	if dict.has(key):
		dict[key] += value
	else:
		dict[key] = value
		
static func dict_min(dict: Dictionary):
	var least = 9e99
	var result
	for k in dict:
		if dict[k] < least:
			result = k
			least = dict[k]
	return result
	
static func dict_max(dict: Dictionary):
	var most = -9e99
	var result
	for k in dict:
		if dict[k] > most:
			result = k
			most = dict[k]
	return result

# Returns item and object
static func min_pos(list: Array) -> Array:
	var value = list[0]
	var result = list[0]
	var index = 0
	var result_index = 0
	for item in list:
		var i = item
		if i < value:
			value = i
			result = item
			result_index = index
		index += 1
	return [result_index, result]
	
# Returns item and object
static func max_pos(list: Array) -> Array:
	var value = list[0]
	var result = list[0]
	var index = 0
	var result_index = 0
	for item in list:
		var i = item
		if i > value:
			value = i
			result = item
			result_index = index
		index += 1
	return [result_index, result]
	
# Returns item and object and value
static func min_by(list: Array, criteria_func: String, params = null) -> Array:
	var value = 9e99
	var result = list[0]
	var index = 0
	var result_index = 0
	for item in list:
		var i
		if params != null:
			i = item.call(criteria_func, params)
		else:
			i = item.call(criteria_func)
		if i < value:
			value = i
			result = item
			result_index = index
		index += 1
	return [result_index, result, value]

# Returns item and object and value
static func max_by(list: Array, criteria_func: String, params = null) -> Array:
	var value = -9e99
	var result = list[0]
	var index = 0
	var result_index = 0
	for item in list:
		var i
		if params != null:
			i = item.call(criteria_func, params)
		else:
			i = item.call(criteria_func)
		if i > value:
			value = i
			result = item
			result_index = index
		index += 1
	return [result_index, result, value]

static func array_filter(list: Array, criteria_func: String) -> Array:
	var result = []
	for item in list:
		if item.call(criteria_func):
			result.append(item)
	return result
	
static func convert_dict_to_int_key(dict):
	var result = {}
	for k in dict:
		result[int(k)] = dict[k]
	return result
	
##############################################
#                    Misc                    #
##############################################

static func delete_all_children(node: Node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
		
static func resize_texture(texture, old_size: Vector2, new_size: Vector2):
	var sprite = Image.new()
	sprite.create(old_size.x, old_size.y, false, texture.get_format())
	sprite.blit_rect(texture, Rect2(0, 0, old_size.x, old_size.y), Vector2(0, 0))
	sprite.resize(new_size.x, new_size.y, Image.INTERPOLATE_CUBIC)
	
	var image = ImageTexture.new()
	image.create_from_image(sprite)
	return image

static func coalesce(a, b):
	return a if a else b
