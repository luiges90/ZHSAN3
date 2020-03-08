extends Node

static func arch_distance(a, b) -> int:
	return a.map_position.distance_to(b.map_position)
