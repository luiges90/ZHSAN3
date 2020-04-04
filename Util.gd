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
	if s.length() > 3:
		s = s.insert(s.length() - 3, ',')
	if s.length() > 7:
		s = s.insert(s.length() - 7, ',')
	if s.length() > 12:
		s = s.insert(s.length() - 12, ',')
	return s
	
static func current_date_str() -> String:
	var now = OS.get_datetime()
	return str(now['year']) + '-' + str(now['month']) + '-' + str(now['day']) + " " + str(now['hour']) + ":" + str(now['minute'])

##############################################
#                     Math                   #
##############################################

# float to integer with randomized component by remaining frac
# note: input should be positive otherwise result is not exactly correct...
static func f2ri(x: float) -> int:
	var trunc = int(x)
	var frac = abs(x - int(x))
	return trunc + (1 if randf() < frac else 0)


##############################################
#                 Collections                #
##############################################

static func append_all(list: Array, other: Array):
	for i in other:
		list.append(i)
		
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
	var value = list[0].call(criteria_func)
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

	
##############################################
#                    Misc                    #
##############################################

static func delete_all_children(node: Node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
		
