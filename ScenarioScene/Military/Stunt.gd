extends Node
class_name Stunt

var id: int setget forbidden
var scenario

var gname: String setget forbidden

var base_stunt setget forbidden

var experience: int setget forbidden

func forbidden(x):
	assert(false)