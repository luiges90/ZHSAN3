extends Node

static func object_distance(a, b) -> int:
	return a.map_position.distance_to(b.map_position)
