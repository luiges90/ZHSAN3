extends Node

enum ObjectType {
	ARCHITECTURE, TROOP, PERSON
}

static func object_distance(a, b) -> int:
	return a.map_position.distance_to(b.map_position)

static func nearest_architecture_of_faction(faction, map_position, exclude = null):
	var result
	var min_dist = 9e9
	for arch in faction.get_architectures():
		if arch == exclude:
			 continue
		var dist = Util.m_dist(map_position, arch.map_position)
		if dist < min_dist:
			min_dist = dist
			result = arch
	return result
	
class InfluenceContainer:
	var influences: Array
	var conditions: Array
