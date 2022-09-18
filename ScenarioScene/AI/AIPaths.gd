extends Node
class_name AIPaths

var list = [] :
	get:
		return list # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of forbidden

class ArchitecturePath:
	var start_architecture: int
	var end_architecture: int
	var movement_kind: int
	var path: Array

func forbidden(x):
	assert(false)

func load_data(json: Array):
	list.clear()
	for j in json:
		var item = ArchitecturePath.new()
		item.start_architecture = j['StartArchitecture']
		item.end_architecture = j['EndArchitecture']
		item.movement_kind = j['MovementKind']
		
		var path = j['Path3D']
		var path_v2 = []
		for p in path:
			path_v2.append(Vector2(p[0], p[1]))
		item.path = path_v2
		
		list.append(item)
	
