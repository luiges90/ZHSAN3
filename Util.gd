extends Node

##############################################
#           JSON de/serialization            #
##############################################

static func load_position(v: Array) -> Vector2:
	return Vector2(v[0], v[1])

static func load_color(v: Array) -> Color:
	return Color(v[0], v[1], v[2])
	
static func save_position(v: Vector2) -> Array:
	return [v.x, v.y]
	
static func save_color(c: Color) -> Array:
	 return [c.r, c.g, c.b]
	
static func id_list(list: Array) -> Array:
	var s = []
	for item in list:
		s.append(item.id)
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
	
static func squares_in_range(position: Vector2, r: int) -> Array:
	var result = []
	for x in range(position.x - r, position.x + r + 1):
		for y in range(position.y - r, position.y + r + 1):
			if m_dist(Vector2(x,y), position) <= r:
				result.append(Vector2(x, y))
	return result
	

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
		
static func dict_add(dict: Dictionary, key, value: int):
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
	
static func min_by(list: Array, criteria_func: String) -> Array:
	var value = 9e99
	var result = list[0]
	var index = 0
	var result_index = 0
	for item in list:
		var i = item.call(criteria_func)
		if i < value:
			value = i
			result = item
			result_index = index
		index += 1
	return [result_index, result]

static func max_by(list: Array, criteria_func: String) -> Array:
	var value = -9e99
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
	
