extends Node
class_name AIPaths

var list = [] setget forbidden

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
		item.path = j['Path']
		list.append(item)
	
